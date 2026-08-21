import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/ai/ai_chat_service.dart';
import '../data/ai/vn_directive_parser.dart';
import '../data/db/database.dart';
import '../data/korean_josa.dart';
import '../data/repositories/ai_preset_repository.dart';
import '../data/repositories/character_repository.dart';
import '../data/repositories/chat_message_repository.dart';
import '../data/repositories/chat_session_repository.dart';
import '../data/repositories/chat_turn_repository.dart';
import '../data/repositories/conversation_profile_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../data/repositories/vn_background_repository.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';
import '../l10n/app_localizations.dart';
import '../widgets/dashed_box.dart';
import '../widgets/start_fresh_dialog.dart';
import 'ai_preset_screen.dart';
import 'vn_plot_edit_screen.dart';

/// 비주얼 노벨 플레이(리딩) 화면. 채팅 화면([lib/screens/chat_screen.dart])과 데이터 흐름
/// 패턴(세션→플롯→캐릭터→프리셋→프로필 로드, `_withPreset` 가드, `watchTimeline` 스트림)은
/// 그대로 따르되, 화면 형태는 말풍선 목록이 아니라 전체화면 배경 그림 + 하단 대사창인
/// 비주얼 노벨 형태다.
///
/// [sessionId]가 있으면 그 세션을 바로 이어서 열고, [plotId]만 있으면 그 플롯의 활성
/// 세션을 찾거나(없으면) 새로 만든다 - 플레이어블 캐릭터가 있으면 먼저 고르게 한다.
class VnPlayerScreen extends StatefulWidget {
  const VnPlayerScreen({super.key, this.sessionId, this.plotId})
      : assert(sessionId != null || plotId != null);

  final int? sessionId;
  final int? plotId;

  @override
  State<VnPlayerScreen> createState() => _VnPlayerScreenState();
}

class _VnPlayerScreenState extends State<VnPlayerScreen> {
  ColorPalette get _p => PaletteScope.of(context);

  late final ChatSessionRepository _sessionRepo;
  late final PlotRepository _plotRepo;
  late final CharacterRepository _characterRepo;
  late final VnBackgroundRepository _bgRepo;
  late final ChatMessageRepository _messageRepo;
  late final ChatTurnRepository _turnRepo;
  late final AiPresetRepository _presetRepo;
  late final ConversationProfileRepository _profileRepo;
  late final AiChatService _aiChatService;

  final TextEditingController _inputController = TextEditingController();
  late final PageController _pickerController;

  bool _loading = true;
  bool _sessionLoadFailed = false;
  List<Character> _playableCharacters = const [];
  int _pickerIndex = 0;
  int? _playableCharacterId;
  bool _isNewlyCreatedSession = false;

  int? _sessionId;
  Plot? _plot;
  List<Character> _characters = const [];
  List<VnBackground> _backgrounds = const [];
  Map<int, List<VnCharacterExpression>> _expressionsByCharacter = const {};
  AiPreset? _selectedPreset;
  int? _profileId;
  String _profileName = '유저';
  String _profileDescription = '';
  String? _profileVnStandingImagePath;

  StreamSubscription<List<ChatTimelineItem>>? _timelineSub;
  bool _timelineInitialized = false;
  List<ChatTimelineItem> _timeline = const [];
  int _cursor = -1;

  bool _generating = false;
  String _streamingText = '';
  AiGenerationCancelToken? _cancelToken;
  VnDiceRequest? _pendingDice;

  bool _manualInputMode = false;
  List<String> _suggestions = const [];
  bool _suggestionsLoading = false;

  @override
  void initState() {
    super.initState();
    final db = AppDatabase.instance;
    _sessionRepo = ChatSessionRepository(db);
    _plotRepo = PlotRepository(db);
    _characterRepo = CharacterRepository(db);
    _bgRepo = VnBackgroundRepository(db);
    _messageRepo = ChatMessageRepository(db);
    _turnRepo = ChatTurnRepository(db);
    _presetRepo = AiPresetRepository(db);
    _profileRepo = ConversationProfileRepository(db);
    _aiChatService = AiChatService(db: db);
    _pickerController = PageController(viewportFraction: 0.88);
    _load();
  }

  @override
  void dispose() {
    _timelineSub?.cancel();
    _inputController.dispose();
    _pickerController.dispose();
    super.dispose();
  }

  // ── 진입 흐름: 세션 해석/생성 ──────────────────────────────────────────

  Future<void> _load() async {
    if (widget.sessionId != null) {
      await _loadSession(widget.sessionId!);
      return;
    }
    final plotId = widget.plotId!;
    final existing = await _sessionRepo.activeSessionIdForPlot(plotId);
    if (existing != null) {
      await _loadSession(existing);
      return;
    }
    await _enterFreshPlotFlow(plotId);
  }

  /// 이 플롯에 진행 중인 세션이 없을 때(최초 진입 또는 '새로하기' 직후) 곧바로 새 세션을 연다.
  /// 플레이어블 캐릭터 선택은 더 이상 세션 생성 전 게이트가 아니라, 인트로 타임라인 안의
  /// characterPick 마커에 커서가 도달했을 때 인라인으로 뜬다([_isAtUnresolvedCharacterPick]).
  Future<void> _enterFreshPlotFlow(int plotId) async {
    await _createAndLoadSession(plotId);
  }

  Future<void> _onCharacterPicked(Character character) async {
    final sessionId = _sessionId;
    if (sessionId == null) return;
    await _sessionRepo.setPlayableCharacter(sessionId, character.id);
    if (!mounted) return;
    setState(() {
      _playableCharacterId = character.id;
      if (_cursor < _timeline.length - 1) _cursor++;
    });
  }

  /// 캐릭터 선택 화면의 '+ 새 플레이어블 캐릭터' 카드. 만들고 나면 목록을 새로고침해서
  /// 방금 만든 캐릭터로 캐러셀을 옮겨준다.
  Future<void> _addPlayableCharacter() async {
    final plotId = _plot?.id ?? widget.plotId;
    if (plotId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VnCharacterFormScreen(
          plotId: plotId,
          isPlayable: true,
          sortOrder: _playableCharacters.length,
        ),
      ),
    );
    final previousCount = _playableCharacters.length;
    await _reloadPlayableCharacters();
    if (!mounted || _playableCharacters.length <= previousCount) return;
    final newIndex = _playableCharacters.length - 1;
    setState(() => _pickerIndex = newIndex);
    if (_pickerController.hasClients) {
      _pickerController.animateToPage(newIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _editPlayableCharacter(Character character) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VnCharacterFormScreen(
          plotId: character.plotId,
          characterId: character.id,
          isPlayable: true,
          sortOrder: character.sortOrder,
        ),
      ),
    );
    await _reloadPlayableCharacters();
  }

  Future<void> _reloadPlayableCharacters() async {
    final plotId = _plot?.id ?? widget.plotId;
    if (plotId == null) return;
    final playable = await _characterRepo.watchPlayableByPlot(plotId).first;
    if (!mounted) return;
    setState(() => _playableCharacters = playable);
  }

  Future<void> _createAndLoadSession(int plotId) async {
    final defaultProfile = await _profileRepo.getDefault();
    final sessionId = await _sessionRepo.createSession(
      plotId: plotId,
      conversationProfileId: defaultProfile?.id,
    );
    _isNewlyCreatedSession = true;
    await _loadSession(sessionId);
  }

  Future<void> _loadSession(int sessionId) async {
    final session = await _sessionRepo.getById(sessionId);
    if (session == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _sessionLoadFailed = true;
        });
      }
      return;
    }
    final plot = await _plotRepo.getById(session.plotId);
    final characters = await _characterRepo.getByPlot(session.plotId);
    final backgrounds = await _bgRepo.getByPlot(session.plotId);
    final playable = await _characterRepo.watchPlayableByPlot(session.plotId).first;
    AiPreset? preset;
    if (session.presetId != null) {
      preset = await _presetRepo.getById(session.presetId!);
    } else {
      final defaultPreset = await _presetRepo.getDefault();
      if (defaultPreset != null) {
        preset = defaultPreset;
        await _sessionRepo.setPreset(sessionId, defaultPreset.id);
      }
    }
    // 플롯 전용 프로필 선택 화면은 v1 범위에서 생략한다. 세션에 전역 프로필이 이미
    // 붙어있으면 그걸 쓰고, 없으면(예전 세션) 마이페이지 기본 프로필로 채우면서 세션에도
    // 저장해 다음부터 바로 불러오게 한다 - 채팅 화면의 폴백 경로와 동일한 패턴.
    int? profileId;
    String? profileName;
    String? profileDescription;
    String? profileVnStandingImagePath;
    if (session.conversationProfileId != null) {
      final profile = await _profileRepo.getById(session.conversationProfileId!);
      if (profile != null) {
        profileId = profile.id;
        profileName = profile.name;
        profileDescription = profile.description;
        profileVnStandingImagePath = profile.vnStandingImagePath;
      }
    } else {
      final defaultProfile = await _profileRepo.getDefault();
      if (defaultProfile != null) {
        profileId = defaultProfile.id;
        profileName = defaultProfile.name;
        profileDescription = defaultProfile.description;
        profileVnStandingImagePath = defaultProfile.vnStandingImagePath;
        await _sessionRepo.setConversationProfile(sessionId, defaultProfile.id);
      }
    }
    final expressionsByCharacter = <int, List<VnCharacterExpression>>{};
    for (final c in characters) {
      expressionsByCharacter[c.id] = await _characterRepo.getExpressions(c.id);
    }
    if (!mounted) return;
    setState(() {
      _sessionId = sessionId;
      _plot = plot;
      _characters = characters;
      _backgrounds = backgrounds;
      _playableCharacters = playable;
      _playableCharacterId = session.vnPlayableCharacterId;
      _pickerIndex = 0;
      _selectedPreset = preset;
      _profileId = profileId;
      if (profileName != null) _profileName = profileName;
      if (profileDescription != null) _profileDescription = profileDescription;
      _profileVnStandingImagePath = profileVnStandingImagePath;
      _expressionsByCharacter = expressionsByCharacter;
      _loading = false;
    });
    _subscribeTimeline(sessionId);
  }

  // ── 타임라인 구독 + 커서 ────────────────────────────────────────────────

  /// 처음 스트림이 도착하면(=화면을 처음 열었을 때) 커서 위치를 정한다: 방금 만든 새
  /// 세션이면 맨 앞(0)에 두어 아직 안 읽은 인트로를 '▶▶'로 한 줄씩 넘겨보게 하고, 기존
  /// 세션을 다시 열었으면 마지막으로 진행했던 맨 끝 턴으로 곧바로 이동시킨다. 그 이후
  /// 갱신에서는, 유저가 이미 맨 끝까지 따라와 있었을 때만(=방금 보낸 메시지의 응답을
  /// 기다리던 중) 새로 생긴 마지막 메시지로 자동으로 따라가고, 과거를 되짚어보던
  /// 중이었다면 보던 위치를 그대로 유지한다.
  void _subscribeTimeline(int sessionId) {
    _timelineSub?.cancel();
    _timelineInitialized = false;
    final isNewSession = _isNewlyCreatedSession;
    _isNewlyCreatedSession = false;
    _timelineSub = _turnRepo.watchTimeline(sessionId).listen((items) {
      if (!mounted) return;
      setState(() {
        if (!_timelineInitialized) {
          _timeline = items;
          var initialCursor = items.isEmpty ? -1 : (isNewSession ? 0 : items.length - 1);
          // 아직 안 고른 플레이어블 캐릭터 선택 마커가 있으면, 그 지점을 건너뛰고 마지막으로
          // 이동해버리지 않도록 그 마커 위치로 되돌린다(재진입 시에도 선택을 강제하기 위함).
          if (_playableCharacterId == null) {
            final pickIndex = items.indexWhere((i) => i.message.senderType == MessageSender.characterPick);
            if (pickIndex != -1 && pickIndex < initialCursor) initialCursor = pickIndex;
          }
          _cursor = initialCursor;
          _timelineInitialized = true;
          return;
        }
        final wasCaughtUp = _timeline.isEmpty || _cursor >= _timeline.length - 1;
        _timeline = items;
        if (items.isEmpty) {
          _cursor = -1;
        } else if (wasCaughtUp) {
          _cursor = items.length - 1;
        } else {
          _cursor = _cursor.clamp(0, items.length - 1);
        }
      });
      _maybeAutoLoadSuggestions();
    });
  }

  void _stepBack() {
    if (_cursor <= 0) return;
    setState(() => _cursor--);
  }

  void _stepForward() {
    if (_timeline.isEmpty || _cursor >= _timeline.length - 1) return;
    setState(() => _cursor++);
    if (_cursor == _timeline.length - 1) _maybeAutoLoadSuggestions();
  }

  bool get _wantsSuggestions {
    final plot = _plot;
    if (plot == null) return false;
    return plot.vnInputMode == VnInputMode.choice || plot.vnAiInputAssist;
  }

  void _maybeAutoLoadSuggestions() {
    if (_generating || _pendingDice != null) return;
    if (_timeline.isEmpty || _cursor != _timeline.length - 1) return;
    if (!_wantsSuggestions) return;
    if (_suggestionsLoading || _suggestions.isNotEmpty) return;
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final preset = _selectedPreset;
    final sessionId = _sessionId;
    final plotId = _plot?.id;
    if (preset == null || sessionId == null || plotId == null) return;
    setState(() => _suggestionsLoading = true);
    try {
      final list = await _aiChatService.generateSuggestions(
        sessionId: sessionId,
        plotId: plotId,
        preset: preset,
        userProfileName: _profileName,
        playableCharacter: _selectedPlayableCharacter,
      );
      if (!mounted) return;
      setState(() {
        _suggestions = list;
        _suggestionsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = const [];
        _suggestionsLoading = false;
      });
    }
  }

  // ── 캐릭터/이름 해석 (채팅 화면과 동일한 완화 매칭) ───────────────────

  Character? _findCharacter(int? id) {
    if (id == null) return null;
    final match = _characters.where((c) => c.id == id);
    return match.isEmpty ? null : match.first;
  }

  Character? _findCharacterByName(String? name) {
    final normalized = name?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final c in _characters) {
      if (c.name.trim().toLowerCase() == normalized) return c;
    }
    for (final c in _characters) {
      final n = c.name.trim().toLowerCase();
      if (n.isEmpty) continue;
      if (normalized.contains(n) || n.contains(normalized)) return c;
    }
    return null;
  }

  /// 지금 선택된 플레이어블 캐릭터(없으면 null). 골라놓은 캐릭터가 곧 '플레이어'가 되므로
  /// {{user}} 표시/발화 이름/스프라이트 전부 이걸 우선한다.
  Character? get _selectedPlayableCharacter => _findCharacter(_playableCharacterId);

  /// 실제로 화면/AI에 노출할 플레이어 이름. 플레이어블 캐릭터가 있으면 그 이름을, 없으면
  /// 마이페이지/플롯 전용 대화 프로필 이름(`_profileName`)을 그대로 쓴다.
  String get _effectiveUserName => _selectedPlayableCharacter?.name ?? _profileName;

  String _substituteUser(String content) => content.replaceAll('{{user}}', _effectiveUserName);
  String _substituteChar(String content, String name) => content.replaceAll('{{char}}', name);
  String _resolveJosa(String content) => KoreanJosaMacro.resolve(content);

  int? _resolveBackgroundIdUpTo(int index) {
    for (var i = index; i >= 0 && i < _timeline.length; i--) {
      final bg = _timeline[i].message.vnBackgroundId;
      if (bg != null) return bg;
    }
    return null;
  }

  ({Character? character, VnEmotion? expression}) _resolveSpeakerUpTo(int index) {
    for (var i = index; i >= 0 && i < _timeline.length; i--) {
      final m = _timeline[i].message;
      if (m.senderType == MessageSender.character) {
        final c = _findCharacter(m.characterId) ?? _findCharacterByName(m.speakerNameOverride);
        return (character: c, expression: m.vnExpression);
      }
    }
    return (character: null, expression: null);
  }

  String? _resolvedBackgroundPath(int? bgId) {
    if (bgId != null) {
      final match = _backgrounds.where((b) => b.id == bgId);
      if (match.isNotEmpty) return match.first.imagePath;
    }
    return _plot?.coverImagePath;
  }

  String? _spriteImagePath(Character? character, VnEmotion? expression) {
    if (character == null) return null;
    if (expression != null) {
      final list = _expressionsByCharacter[character.id] ?? const <VnCharacterExpression>[];
      final match = list.where((e) => e.emotion == expression);
      if (match.isNotEmpty) return match.first.imagePath;
    }
    return character.imagePath;
  }

  // ── 화면에 지금 보여줄 한 장(대사/배경/스프라이트) 계산 ────────────────

  _DisplayState _staticDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_timeline.isEmpty || _cursor < 0) return const _DisplayState();
    final message = _timeline[_cursor].message;
    final bgId = _resolveBackgroundIdUpTo(_cursor);
    final speakerInfo = _resolveSpeakerUpTo(_cursor);
    String? pillName;
    String text;
    Character? spriteCharacter = speakerInfo.character;
    VnEmotion? spriteExpression = speakerInfo.expression;
    String? standingOverride;
    switch (message.senderType) {
      case MessageSender.character:
        final character = _findCharacter(message.characterId) ?? _findCharacterByName(message.speakerNameOverride);
        final resolvedName = character?.name ?? message.speakerNameOverride ?? l10n.vnPlayDefaultCharacterName;
        pillName = resolvedName;
        text = _resolveJosa(_substituteChar(_substituteUser(message.content), resolvedName));
        break;
      case MessageSender.narrator:
        text = _resolveJosa(_substituteUser(message.content));
        break;
      case MessageSender.user:
        pillName = _effectiveUserName;
        text = message.content;
        // 플레이어가 곧 그 캐릭터이므로, 유저 발화 차례에는 마지막 NPC 스프라이트 대신
        // 선택한 플레이어블 캐릭터(없으면 프로필의 VN 스탠딩 이미지)를 보여준다.
        final playable = _selectedPlayableCharacter;
        if (playable != null) {
          spriteCharacter = playable;
          spriteExpression = null;
        } else {
          spriteCharacter = null;
          spriteExpression = null;
          standingOverride = _profileVnStandingImagePath;
        }
        break;
      case MessageSender.image:
        text = '';
        break;
      case MessageSender.characterPick:
        text = '';
        break;
    }
    return _DisplayState(
      speakerName: pillName,
      text: text,
      backgroundId: bgId,
      speakingCharacter: spriteCharacter,
      expression: spriteExpression,
      standingImageOverride: standingOverride,
    );
  }

  _DisplayState _streamingDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final parsed = VnDirectiveParser.parse(_streamingText, backgrounds: _backgrounds);
    final segs = parsed.segments;
    if (segs.isEmpty) {
      final fallback = _resolveSpeakerUpTo(_cursor);
      return _DisplayState(
        backgroundId: _resolveBackgroundIdUpTo(_cursor),
        speakingCharacter: fallback.character,
        expression: fallback.expression,
      );
    }
    final last = segs.last;

    int? bgId;
    for (var i = segs.length - 1; i >= 0; i--) {
      if (segs[i].vnBackgroundId != null) {
        bgId = segs[i].vnBackgroundId;
        break;
      }
    }
    bgId ??= _resolveBackgroundIdUpTo(_cursor);

    Character? character;
    VnEmotion? expr;
    for (var i = segs.length - 1; i >= 0; i--) {
      if (segs[i].senderType == MessageSender.character) {
        character = _findCharacterByName(segs[i].speakerName);
        expr = segs[i].vnExpression;
        break;
      }
    }
    if (character == null) {
      final fallback = _resolveSpeakerUpTo(_cursor);
      character = fallback.character;
      expr = fallback.expression;
    }

    String? pillName;
    String text;
    switch (last.senderType) {
      case MessageSender.character:
        final resolvedName = _findCharacterByName(last.speakerName)?.name ?? last.speakerName ?? l10n.vnPlayDefaultCharacterName;
        pillName = resolvedName;
        text = _resolveJosa(_substituteChar(_substituteUser(last.content), resolvedName));
        break;
      case MessageSender.narrator:
        text = _resolveJosa(_substituteUser(last.content));
        break;
      case MessageSender.user:
      case MessageSender.image:
      case MessageSender.characterPick:
        text = last.content;
    }

    return _DisplayState(
      speakerName: pillName,
      text: text,
      backgroundId: bgId,
      speakingCharacter: character,
      expression: expr,
    );
  }

  // ── 생성(전송/AI 응답) ──────────────────────────────────────────────

  Future<void> _withPreset(
    Future<void> Function(AiPreset preset, int plotId, AiGenerationCancelToken cancelToken) action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final preset = _selectedPreset;
    final plotId = _plot?.id;
    if (preset == null || plotId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.vnPlaySelectPresetMessage)));
      }
      return;
    }
    final cancelToken = AiGenerationCancelToken();
    setState(() {
      _generating = true;
      _streamingText = '';
      _cancelToken = cancelToken;
      _suggestions = const [];
      _suggestionsLoading = false;
    });
    try {
      await action(preset, plotId, cancelToken);
    } catch (e) {
      if (mounted && !cancelToken.isCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.vnPlayGenerateFailureMessage(e))));
      }
    } finally {
      if (mounted) {
        setState(() {
          _generating = false;
          _streamingText = '';
          _cancelToken = null;
        });
      }
    }
  }

  void _onDelta(String accumulated) {
    if (mounted) setState(() => _streamingText = accumulated);
  }

  Future<void> _generateAiTurn() async {
    final sessionId = _sessionId;
    if (sessionId == null) return;
    await _withPreset(
      (preset, plotId, cancelToken) => _aiChatService.generateReply(
        sessionId: sessionId,
        plotId: plotId,
        preset: preset,
        userProfileName: _profileName,
        userProfileDescription: _profileDescription,
        onDelta: _onDelta,
        cancelToken: cancelToken,
        vnMode: true,
        vnBackgrounds: _backgrounds,
        vnDiceEnabled: _plot?.vnDiceEnabled ?? true,
        onVnDiceRequest: _handleDiceRequest,
        playableCharacter: _selectedPlayableCharacter,
      ),
    );
    if (mounted && _pendingDice == null) {
      _maybeAutoLoadSuggestions();
    }
  }

  Future<void> _sendUserAction(String text) async {
    final trimmed = text.trim();
    final sessionId = _sessionId;
    if (trimmed.isEmpty || _generating || sessionId == null) return;
    _inputController.clear();
    setState(() => _manualInputMode = false);
    await _messageRepo.send(sessionId: sessionId, senderType: MessageSender.user, content: trimmed);
    await _generateAiTurn();
  }

  void _submitFreeText() => _sendUserAction(_inputController.text);

  // ── 주사위 ──────────────────────────────────────────────────────────

  /// [AiChatService]가 스트리밍 도중 동기 콜백으로 호출한다. 아직 프레임 렌더링/DB 반영이
  /// 끝나기 전일 수 있어서, 다음 프레임으로 미뤄 안전하게 시트를 띄운다.
  void _handleDiceRequest(VnDiceRequest request) {
    _pendingDice = request;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_pendingDice != request) return;
      _showDiceSheetAndContinue(request);
    });
  }

  Future<void> _showDiceSheetAndContinue(VnDiceRequest request) async {
    _pendingDice = null;
    final result = await showModalBottomSheet<_DiceRollOutcome>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: _p.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DiceRollSheet(request: request),
    );
    if (result == null || !mounted || _sessionId == null) return;
    final content = '[주사위 결과: ${result.success ? "성공" : "실패"}] '
        '(${result.roll} + ${request.bonus} = ${result.total} / 목표 ${request.target})';
    await _messageRepo.send(sessionId: _sessionId!, senderType: MessageSender.user, content: content);
    await _generateAiTurn();
  }

  // ── 히스토리 / 설정 시트 ────────────────────────────────────────────

  ({String label, String text}) _historyLineFor(BuildContext context, ChatMessage message) {
    final l10n = AppLocalizations.of(context)!;
    switch (message.senderType) {
      case MessageSender.character:
        final character = _findCharacter(message.characterId) ?? _findCharacterByName(message.speakerNameOverride);
        final name = character?.name ?? message.speakerNameOverride ?? l10n.vnPlayDefaultCharacterName;
        return (label: name, text: _resolveJosa(_substituteChar(_substituteUser(message.content), name)));
      case MessageSender.narrator:
        return (label: l10n.vnPlayHistoryNarratorLabel, text: _resolveJosa(_substituteUser(message.content)));
      case MessageSender.user:
        return (label: _effectiveUserName, text: message.content);
      case MessageSender.image:
        return (label: '', text: message.content);
      case MessageSender.characterPick:
        final picked = _playableCharacterId != null ? _findCharacter(_playableCharacterId) : null;
        return (label: l10n.vnPlayHistoryCharacterPickLabel, text: picked?.name ?? '-');
    }
  }

  void _showHistorySheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = _p;
    showModalBottomSheet(
      context: context,
      backgroundColor: p.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.75,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(color: p.textGhost, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.vnPlayHistorySheetTitle,
                    style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _timeline.isEmpty
                        ? Center(
                            child: Text(
                              l10n.vnPlayHistoryEmptyMessage,
                              style: TextStyle(color: p.textFaint),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _timeline.length,
                            separatorBuilder: (_, _) => Divider(color: p.border, height: 20),
                            itemBuilder: (context, index) {
                              final item = _timeline[index];
                              final line = _historyLineFor(context, item.message);
                              return InkWell(
                                onTap: _generating
                                    ? null
                                    : () {
                                        setState(() => _cursor = index);
                                        Navigator.of(sheetContext).pop();
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (line.label.isNotEmpty)
                                        Text(
                                          line.label,
                                          style: TextStyle(color: p.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        line.text,
                                        style: TextStyle(color: p.textPrimary, fontSize: 14, height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 톱니바퀴(설정) 메뉴. 프리셋 선택은 상단 바의 별도 드롭다운([_showPresetPickerSheet])으로
  /// 분리되어 있고, 여기는 히스토리/플롯 편집/세션 관리만 다룬다.
  void _showSettingsSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = _p;
    final plotId = _plot?.id ?? widget.plotId;
    showModalBottomSheet(
      context: context,
      backgroundColor: p.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: p.textGhost, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.vnPlaySettingsSheetTitle,
                  style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _settingsMenuItem(
                  icon: Icons.history,
                  label: l10n.vnPlayHistoryMenuItem,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showHistorySheet(context);
                  },
                ),
                _settingsMenuItem(
                  icon: Icons.person_outline,
                  label: l10n.vnPlayProfileMenuItem,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showProfilePickerSheet(context);
                  },
                ),
                if (plotId != null)
                  _settingsMenuItem(
                    icon: Icons.article_outlined,
                    label: l10n.vnPlayJumpToPlotDetailMenuItem,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => VnPlotEditScreen(plotId: plotId)));
                    },
                  ),
                _settingsMenuItem(
                  icon: Icons.refresh,
                  label: l10n.vnPlayStartFreshMenuItem,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _startFreshFlow();
                  },
                ),
                _settingsMenuItem(
                  icon: Icons.delete_outline,
                  label: l10n.vnPlayDeleteSessionMenuItem,
                  color: p.danger,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _deleteSession();
                  },
                  isLast: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _settingsMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    bool isLast = false,
  }) {
    final p = _p;
    final tint = color ?? p.textSecondary;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: tint, size: 18),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: color ?? p.textPrimary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  /// 상단 바의 프리셋 드롭다운. 톱니바퀴 메뉴와 분리된, 프리셋 선택 전용 시트다.
  void _showPresetPickerSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = _p;
    showModalBottomSheet(
      context: context,
      backgroundColor: p.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(color: p.textGhost, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.vnPlayPresetSheetTitle,
                    style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.vnPlayPresetSheetDescription, style: TextStyle(color: p.textFaint, fontSize: 12)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AiPresetScreen()));
                    },
                    child: Row(
                      children: [
                        Text(l10n.vnPlayPresetManageLink, style: TextStyle(color: p.textSecondary, fontSize: 13)),
                        Icon(Icons.chevron_right, color: p.textSecondary, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      child: StreamBuilder<List<AiPreset>>(
                        stream: _presetRepo.watchAll(),
                        builder: (context, snapshot) {
                          final presets = snapshot.data ?? const [];
                          if (presets.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(l10n.vnPlayPresetSheetEmpty, style: TextStyle(color: p.textFaint, fontSize: 13)),
                            );
                          }
                          return Column(
                            children: presets.map((preset) {
                              final selected = preset.id == _selectedPreset?.id;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (_sessionId != null) {
                                      await _sessionRepo.setPreset(_sessionId!, preset.id);
                                    }
                                    setState(() => _selectedPreset = preset);
                                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: p.surfaceAlt,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: selected ? p.primary : Colors.transparent, width: 1.5),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                preset.name,
                                                style: TextStyle(color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(preset.description, style: TextStyle(color: p.textMuted, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        if (selected) Icon(Icons.check, color: p.textPrimary, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 설정 메뉴의 '대화 프로필'. 비주얼 노벨 전용(또는 공용) 프로필만 골라서 고를 수 있다.
  void _showProfilePickerSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = _p;
    showModalBottomSheet(
      context: context,
      backgroundColor: p.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(color: p.textGhost, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.vnPlayProfileSheetTitle,
                    style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      child: StreamBuilder<List<ConversationProfile>>(
                        stream: _profileRepo.watchAll(scope: PlotType.visualNovel),
                        builder: (context, snapshot) {
                          final profiles = snapshot.data ?? const [];
                          if (profiles.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(l10n.vnPlayProfileSheetEmpty, style: TextStyle(color: p.textFaint, fontSize: 13)),
                            );
                          }
                          return Column(
                            children: profiles.map((profile) {
                              final selected = profile.id == _profileId;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () async {
                                    final sessionId = _sessionId;
                                    if (sessionId != null) {
                                      await _sessionRepo.setConversationProfile(sessionId, profile.id);
                                    }
                                    setState(() {
                                      _profileId = profile.id;
                                      _profileName = profile.name;
                                      _profileDescription = profile.description;
                                      _profileVnStandingImagePath = profile.vnStandingImagePath;
                                    });
                                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: p.surfaceAlt,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: selected ? p.primary : Colors.transparent, width: 1.5),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                profile.name,
                                                style: TextStyle(color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(profile.description, style: TextStyle(color: p.textMuted, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        if (selected) Icon(Icons.check, color: p.textPrimary, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 설정 메뉴의 '새로하기'. 현재 세션을 보관(또는 삭제)한 뒤, 이 화면을 플롯 진입 흐름으로
  /// 되돌려서(플레이어블 캐릭터가 있으면 다시 고르게 한다) 새 세션을 시작한다.
  Future<void> _startFreshFlow() async {
    final plotId = _plot?.id ?? widget.plotId;
    final sessionId = _sessionId;
    if (plotId == null || sessionId == null) return;
    final saveCurrent = await StartFreshDialog.show(context);
    if (saveCurrent == null || !mounted) return;
    if (saveCurrent) {
      await _sessionRepo.archive(sessionId);
    } else {
      await _sessionRepo.delete(sessionId);
    }
    if (!mounted) return;
    _timelineSub?.cancel();
    setState(() {
      _loading = true;
      _sessionId = null;
      _timelineInitialized = false;
      _timeline = const [];
      _cursor = -1;
      _selectedPreset = null;
    });
    await _enterFreshPlotFlow(plotId);
  }

  /// 설정 메뉴의 '삭제'. 확인 후 세션을 완전히 지우고 화면을 닫는다.
  Future<void> _deleteSession() async {
    final l10n = AppLocalizations.of(context)!;
    final p = _p;
    final sessionId = _sessionId;
    if (sessionId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: p.surface,
        content: Text(l10n.vnPlayDeleteSessionConfirmMessage, style: TextStyle(color: p.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel, style: TextStyle(color: p.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonDelete, style: TextStyle(color: p.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _sessionRepo.delete(sessionId);
    if (mounted) Navigator.of(context).maybePop();
  }

  // ── build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: PaletteScope.of(context).primary)),
      );
    }
    if (_sessionLoadFailed) {
      final l10n = AppLocalizations.of(context)!;
      final p = PaletteScope.of(context);
      return Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: p.textPrimary),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Center(
          child: Text(l10n.vnPlaySessionLoadFailedMessage, style: TextStyle(color: p.textSecondary)),
        ),
      );
    }
    if (_isAtUnresolvedCharacterPick) {
      return _buildCharacterPicker(context);
    }
    return _buildGameplay(context);
  }

  /// 현재 커서가 아직 안 고른 '플레이어블 캐릭터 선택' 마커 위(또는 그 이전)에 있는지.
  /// 참이면 대사창 대신 캐릭터 선택 화면을 띄운다.
  bool get _isAtUnresolvedCharacterPick {
    if (_playableCharacterId != null) return false;
    if (_cursor < 0 || _cursor >= _timeline.length) return false;
    return _timeline[_cursor].message.senderType == MessageSender.characterPick;
  }

  // ── 플레이어블 캐릭터 선택 ──────────────────────────────────────────

  Widget _buildCharacterPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = PaletteScope.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    tooltip: l10n.vnPlayBackTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      l10n.vnPlayCharacterPickerTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_playableCharacters.length + 1, (i) {
                  final active = i == _pickerIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? p.primary : Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pickerController,
                itemCount: _playableCharacters.length + 1,
                onPageChanged: (i) => setState(() => _pickerIndex = i),
                itemBuilder: (context, index) {
                  if (index == _playableCharacters.length) {
                    return _AddCharacterCard(onTap: _addPlayableCharacter);
                  }
                  final character = _playableCharacters[index];
                  return _CharacterPickerCard(
                    character: character,
                    onSelect: () => _onCharacterPicked(character),
                    onEdit: () => _editPlayableCharacter(character),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 게임플레이 화면 ────────────────────────────────────────────────

  Widget _buildGameplay(BuildContext context) {
    final display = _generating ? _streamingDisplay(context) : _staticDisplay(context);
    final atEnd = _timeline.isEmpty || _cursor >= _timeline.length - 1;
    final canBrowse = !_generating && !atEnd;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _BackgroundLayer(imagePath: _resolvedBackgroundPath(display.backgroundId)),
          _SpriteLayer(
            imagePath: display.standingImageOverride ?? _spriteImagePath(display.speakingCharacter, display.expression),
            character: display.speakingCharacter,
          ),
          if (canBrowse)
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _stepBack)),
                  Expanded(child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _stepForward)),
                ],
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogueBox(context, display),
                      const SizedBox(height: 10),
                      _buildBottomControls(context, atEnd: atEnd),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _plot?.title.isNotEmpty == true ? _plot!.title : l10n.vnPlayUntitledPlotTitle;
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            tooltip: l10n.vnPlayBackTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          _PresetSelectorButton(
            label: _selectedPreset?.name ?? l10n.vnPlayPresetDropdownPlaceholder,
            onTap: () => _showPresetPickerSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
            tooltip: l10n.vnPlaySettingsTooltip,
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogueBox(BuildContext context, _DisplayState display) {
    final l10n = AppLocalizations.of(context)!;
    final hasText = display.text.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (display.speakerName != null) ...[
            _SpeakerPill(name: display.speakerName!),
            const SizedBox(height: 8),
          ],
          if (!hasText && _generating)
            const _TypingDots()
          else if (!hasText)
            Text(l10n.vnPlayEmptyStateMessage, style: const TextStyle(color: Colors.white54, fontSize: 14))
          else
            _FormattedMessageText(display.text, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.45)),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, {required bool atEnd}) {
    if (_generating) return _buildGeneratingRow(context);
    if (!atEnd) return _buildNavRow(context);
    return _buildInputArea(context);
  }

  Widget _buildGeneratingRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: Alignment.centerRight,
      child: _RoundIconButton(
        icon: Icons.stop_rounded,
        onTap: () => _cancelToken?.cancel(),
        tooltip: l10n.vnPlayCancelGenerationTooltip,
        filled: true,
      ),
    );
  }

  Widget _buildNavRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canBack = _cursor > 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RoundIconButton(
          icon: Icons.chevron_left,
          onTap: canBack ? _stepBack : null,
          tooltip: l10n.vnPlayStepBackTooltip,
          filled: true,
        ),
        _RoundIconButton(
          icon: Icons.keyboard_double_arrow_right_rounded,
          onTap: _stepForward,
          tooltip: l10n.vnPlayStepForwardTooltip,
          filled: true,
          accent: true,
        ),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final plot = _plot;
    final isChoiceMode = plot?.vnInputMode == VnInputMode.choice;
    if (isChoiceMode && !_manualInputMode) {
      return _buildChoiceInput(context);
    }
    return _buildFreeTextInput(context, showBackToChoices: isChoiceMode);
  }

  Widget _buildChoiceInput(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_suggestionsLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                ),
                const SizedBox(width: 8),
                Text(l10n.vnPlaySuggestionsLoadingLabel, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          )
        else if (_suggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              l10n.vnPlaySuggestionsEmptyMessage,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          )
        else
          ..._suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ChoiceButton(
                text: s,
                onTap: () => _sendUserAction(s),
                onEdit: () {
                  _inputController.text = s;
                  _inputController.selection = TextSelection.collapsed(offset: s.length);
                  setState(() => _manualInputMode = true);
                },
              ),
            ),
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _manualInputMode = true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.keyboard, size: 18),
                label: Text(l10n.vnPlayManualInputToggle),
              ),
            ),
            const SizedBox(width: 8),
            _RoundIconButton(
              icon: Icons.refresh,
              onTap: _suggestionsLoading ? null : _loadSuggestions,
              tooltip: l10n.vnPlayRegenerateSuggestionsTooltip,
              filled: true,
            ),
            const SizedBox(width: 8),
            _RoundIconButton(
              icon: Icons.history,
              onTap: () => _showHistorySheet(context),
              tooltip: l10n.vnPlayHistoryTooltip,
              filled: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFreeTextInput(BuildContext context, {bool showBackToChoices = false}) {
    final l10n = AppLocalizations.of(context)!;
    final showAssistChips = (_plot?.vnAiInputAssist ?? false) && !showBackToChoices && _suggestions.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showAssistChips)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ActionChip(
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  side: const BorderSide(color: Colors.white24),
                  label: Text(_suggestions[i], style: const TextStyle(color: Colors.white, fontSize: 13)),
                  onPressed: () {
                    _inputController.text = _suggestions[i];
                    _inputController.selection = TextSelection.collapsed(offset: _suggestions[i].length);
                  },
                ),
              ),
            ),
          ),
        Row(
          children: [
            if (showBackToChoices)
              _RoundIconButton(
                icon: Icons.arrow_back,
                onTap: () => setState(() => _manualInputMode = false),
                tooltip: l10n.vnPlayBackToChoicesButton,
                filled: true,
              )
            else if (_plot?.vnAiInputAssist ?? false)
              _RoundIconButton(
                icon: Icons.auto_awesome,
                onTap: _suggestionsLoading ? null : _loadSuggestions,
                tooltip: l10n.vnPlayAiAssistTooltip,
                filled: true,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: TextField(
                  controller: _inputController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitFreeText(),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: l10n.vnPlayFreeInputHint,
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _RoundIconButton(
              icon: Icons.history,
              onTap: () => _showHistorySheet(context),
              tooltip: l10n.vnPlayHistoryTooltip,
              filled: true,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _submitFreeText,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: _p.primary, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── 화면 상태 스냅샷 ──────────────────────────────────────────────────

class _DisplayState {
  const _DisplayState({
    this.speakerName,
    this.text = '',
    this.backgroundId,
    this.speakingCharacter,
    this.expression,
    this.standingImageOverride,
  });

  final String? speakerName;
  final String text;
  final int? backgroundId;
  final Character? speakingCharacter;
  final VnEmotion? expression;

  /// 플레이어블 캐릭터 없이(마이페이지/플롯 프로필만으로) 진행 중인 VN에서 유저가 말할 때
  /// 보여줄 프로필의 VN 전용 스탠딩 이미지 경로. [speakingCharacter]가 null이어도 이 값이
  /// 있으면 그걸 스프라이트로 그린다.
  final String? standingImageOverride;
}

// ── 배경/스프라이트 레이어 ────────────────────────────────────────────

class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final path = imagePath;
    final valid = path != null && path.isNotEmpty && File(path).existsSync();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: KeyedSubtree(
        key: ValueKey(valid ? path : 'none'),
        child: valid
            ? Image.file(File(path), fit: BoxFit.cover, width: double.infinity, height: double.infinity)
            : Container(color: p.background),
      ),
    );
  }
}

class _SpriteLayer extends StatelessWidget {
  const _SpriteLayer({required this.imagePath, this.character});

  final String? imagePath;

  /// 크기 배율/X·Y 위치([Character.spriteScale]/[spriteOffsetX]/[spriteOffsetY])를
  /// 읽어와 배치에 반영한다. null이면 기본(배율 1.0, 하단 중앙)으로 그린다.
  final Character? character;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path == null || path.isEmpty || !File(path).existsSync()) {
      return const SizedBox.shrink();
    }
    final scale = character?.spriteScale ?? 1.0;
    final offsetX = character?.spriteOffsetX ?? 0.0;
    final offsetY = character?.spriteOffsetY ?? 0.0;
    return Align(
      alignment: vnSpriteAlignment(offsetX, offsetY),
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.bottomCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          child: FractionallySizedBox(
            key: ValueKey(path),
            heightFactor: 0.85,
            child: Image.file(File(path), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

/// 상단 바의 프리셋 드롭다운 버튼. 톱니바퀴(설정) 아이콘과는 별개로, 지금 선택된 AI
/// 프리셋 이름을 보여주고 눌러서 바꿀 수 있게 한다.
class _PresetSelectorButton extends StatelessWidget {
  const _PresetSelectorButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 108),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── 대사창 부속 위젯 ──────────────────────────────────────────────────

class _SpeakerPill extends StatelessWidget {
  const _SpeakerPill({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: p.primary, borderRadius: BorderRadius.circular(20)),
      child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

final _vnActionTextPattern = RegExp(r'\*([^*]+)\*');

/// `*지문/행동*` 구간을 이탤릭으로 렌더링한다([chat_screen.dart]의 동명 위젯과 같은 방식이지만,
/// Dart의 라이브러리 단위 프라이버시 덕분에 이 파일 안에서만 쓰이는 별도 클래스다).
class _FormattedMessageText extends StatelessWidget {
  const _FormattedMessageText(this.content, {required this.style});

  final String content;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    var last = 0;
    for (final match in _vnActionTextPattern.allMatches(content)) {
      if (match.start > last) {
        spans.add(TextSpan(text: content.substring(last, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: style.copyWith(fontStyle: FontStyle.italic, color: style.color?.withValues(alpha: 0.75)),
        ),
      );
      last = match.end;
    }
    if (last < content.length) {
      spans.add(TextSpan(text: content.substring(last)));
    }
    return Text.rich(TextSpan(style: style, children: spans));
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
        const SizedBox(width: 8),
        Text(l10n.vnPlayGeneratingIndicator, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

/// 배경 이미지 위에 떠 있는 둥근 아이콘 버튼. 앱 팔레트가 아니라 항상 흰색/반투명
/// 검정을 쓴다 - 임의의 배경 그림 위에서 항상 읽히게 하기 위한 의도적인 선택이다
/// ([accent]만 브랜드 포인트 컬러를 쓴다).
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.filled = false,
    this.accent = false,
    this.size = 42,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool filled;
  final bool accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final disabled = onTap == null;
    final bg = accent
        ? p.primary
        : (filled ? Colors.black.withValues(alpha: 0.45) : Colors.transparent);
    final iconColor = disabled ? Colors.white38 : Colors.white;
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: (filled && !accent) ? Border.all(color: Colors.white24) : null,
      ),
      child: Icon(icon, color: iconColor, size: size * 0.5),
    );
    final wrapped = InkWell(borderRadius: BorderRadius.circular(size / 2), onTap: onTap, child: button);
    if (tooltip == null || tooltip!.isEmpty) return wrapped;
    return Tooltip(message: tooltip!, child: wrapped);
  }
}

/// 선택지 버튼 한 개(연필 아이콘 = 수정 후 전송으로 전환).
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.text, required this.onTap, required this.onEdit});

  final String text;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3)),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: l10n.vnPlaySuggestionEditTooltip,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onEdit,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.edit_outlined, color: Colors.white54, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 플레이어블 캐릭터 선택 카드 ────────────────────────────────────────

class _CharacterPickerCard extends StatelessWidget {
  const _CharacterPickerCard({required this.character, required this.onSelect, required this.onEdit});

  final Character character;
  final VoidCallback onSelect;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = PaletteScope.of(context);
    final imagePath = character.imagePath;
    final hasImage = imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: p.surfaceAlt),
            if (hasImage)
              Image.file(File(imagePath), fit: BoxFit.cover)
            else
              Center(child: Icon(Icons.person, size: 96, color: p.textFaint)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                    stops: const [0, 0.4, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 20,
              right: 20,
              child: Text(
                character.name,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            if (character.description.isNotEmpty)
              Positioned(
                left: 20,
                top: 56,
                right: 20,
                child: Text(
                  character.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.edit_outlined,
                    onTap: onEdit,
                    tooltip: l10n.vnPlayEditCharacterTooltip,
                    filled: true,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        l10n.vnPlaySelectCharacterButton,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 캐릭터 선택 캐러셀 맨 끝에 붙는 '+ 새 플레이어블 캐릭터' 카드.
class _AddCharacterCard extends StatelessWidget {
  const _AddCharacterCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = PaletteScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
      child: GestureDetector(
        onTap: onTap,
        child: DashedBox(
          borderRadius: 20,
          color: p.textFaint,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline, color: p.textFaint, size: 40),
              const SizedBox(height: 10),
              Text(
                l10n.vnPlayAddPlayableCharacterCardTitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textFaint, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 주사위 굴리기 시트 ────────────────────────────────────────────────

class _DiceRollOutcome {
  const _DiceRollOutcome({required this.roll, required this.total, required this.success});

  final int roll;
  final int total;
  final bool success;
}

class _DiceRollSheet extends StatefulWidget {
  const _DiceRollSheet({required this.request});

  final VnDiceRequest request;

  @override
  State<_DiceRollSheet> createState() => _DiceRollSheetState();
}

class _DiceRollSheetState extends State<_DiceRollSheet> {
  bool _rolling = false;
  _DiceRollOutcome? _outcome;

  Future<void> _roll() async {
    setState(() => _rolling = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final roll = Random().nextInt(20) + 1;
    final total = roll + widget.request.bonus;
    final success = total >= widget.request.target;
    if (!mounted) return;
    setState(() {
      _rolling = false;
      _outcome = _DiceRollOutcome(roll: roll, total: total, success: success);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = PaletteScope.of(context);
    final outcome = _outcome;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: p.textGhost, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.casino, color: p.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.vnPlayDiceSheetTitle,
                  style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.request.goal.isNotEmpty) ...[
              Text(l10n.vnPlayDiceGoalLabel, style: TextStyle(color: p.textFaint, fontSize: 12)),
              const SizedBox(height: 4),
              Text(widget.request.goal, style: TextStyle(color: p.textPrimary, fontSize: 15)),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(child: _DiceStatTile(label: l10n.vnPlayDiceTargetLabel, value: '${widget.request.target}')),
                const SizedBox(width: 12),
                Expanded(child: _DiceStatTile(label: l10n.vnPlayDiceBonusLabel, value: '+${widget.request.bonus}')),
              ],
            ),
            const SizedBox(height: 20),
            if (outcome != null) ...[
              Center(
                child: Column(
                  children: [
                    Text(
                      '${outcome.roll}',
                      style: TextStyle(color: p.textPrimary, fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: outcome.success ? p.primary : p.danger,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        outcome.success ? l10n.vnPlayDiceResultSuccess : l10n.vnPlayDiceResultFailure,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.vnPlayDiceResultDetail(outcome.roll, widget.request.bonus, outcome.total, widget.request.target),
                      style: TextStyle(color: p.textFaint, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(outcome),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.vnPlayDiceConfirmButton),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _rolling ? null : _roll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _rolling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.vnPlayDiceRollButton),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DiceStatTile extends StatelessWidget {
  const _DiceStatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: p.textFaint, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
