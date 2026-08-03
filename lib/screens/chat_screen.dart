import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/ai/ai_chat_service.dart';
import '../data/ai/image_gen_client.dart';
import '../data/ai/message_format_parser.dart';
import '../data/ai/prompt_builder.dart';
import '../data/ai/snapshot_settings_store.dart';
import '../data/chat_image_preferences.dart';
import '../data/db/database.dart';
import '../data/local_image_store.dart';
import '../data/repositories/ai_preset_repository.dart';
import '../data/repositories/character_repository.dart';
import '../data/repositories/chat_memory_repository.dart';
import '../data/repositories/chat_message_repository.dart';
import '../data/repositories/chat_session_repository.dart';
import '../data/repositories/chat_turn_repository.dart';
import '../data/repositories/conversation_profile_repository.dart';
import '../data/repositories/plot_conversation_profile_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../widgets/local_avatar.dart';
import '../widgets/start_fresh_dialog.dart';
import '../widgets/start_fresh_from_here_dialog.dart';
import 'ai_preset_screen.dart';
import 'conversation_profile_edit_screen.dart';
import 'resume_conversations_screen.dart';
import 'snapshot_settings_screen.dart';

/// 캐릭터 채팅 화면. 세션(sessionId)에 연결된 실제 메시지를
/// 로컬 DB(Drift)에서 스트리밍하고, 유저가 입력한 메시지를 저장한다.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _inputController = TextEditingController();

  late final ChatMessageRepository _messageRepo;
  late final ChatSessionRepository _sessionRepo;
  late final ChatTurnRepository _turnRepo;
  late final AiPresetRepository _presetRepo;
  late final PlotRepository _plotRepo;
  late final ConversationProfileRepository _profileRepo;
  late final PlotConversationProfileRepository _plotProfileRepo;
  late final CharacterRepository _characterRepo;
  late final ChatMemoryRepository _memoryRepo;
  late final AiChatService _aiChatService;
  final ImageGenClient _imageGenClient = ImageGenClient();
  final SnapshotSettingsStore _snapshotSettingsStore = SnapshotSettingsStore();
  final LocalImageStore _localImageStore = LocalImageStore();

  int? _plotId;
  String _plotTitle = '';
  int? _profileId;
  String _profileName = '유저';
  String? _profileImagePath;
  String _profileDescription = '';
  AiPreset? _selectedPreset;
  List<Character> _characters = const [];
  bool _loading = true;
  bool _generating = false;
  bool _snapshotting = false;
  String _streamingText = '';
  String _reasoningText = '';
  AiGenerationCancelToken? _cancelToken;

  /// 재시도 중인 턴 id. 새 버전이 완성될 때까지 이 턴의 기존 말풍선은 화면에서 미리 감춘다.
  int? _retryingTurnId;

  static const _background = Color(0xFF141414);
  static const _bubbleGrey = Color(0xFF2A2A2A);
  static const _bubblePurple = Color(0xFF7A6FF0);
  static const _pillGrey = Color(0xFF262626);
  static const _mutedText = Color(0xFF9A9A9A);

  @override
  void initState() {
    super.initState();
    final db = AppDatabase.instance;
    _messageRepo = ChatMessageRepository(db);
    _sessionRepo = ChatSessionRepository(db);
    _turnRepo = ChatTurnRepository(db);
    _presetRepo = AiPresetRepository(db);
    _plotRepo = PlotRepository(db);
    _profileRepo = ConversationProfileRepository(db);
    _plotProfileRepo = PlotConversationProfileRepository(db);
    _characterRepo = CharacterRepository(db);
    _memoryRepo = ChatMemoryRepository(db);
    _aiChatService = AiChatService(db: db);
    _loadSessionContext();
  }

  Future<void> _loadSessionContext() async {
    final session = await _sessionRepo.getById(widget.sessionId);
    if (session == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final plot = await _plotRepo.getById(session.plotId);
    _characters = await _characterRepo.getByPlot(session.plotId);
    if (session.presetId != null) {
      _selectedPreset = await _presetRepo.getById(session.presetId!);
    }
    if (session.plotConversationProfileId != null) {
      final profile = await _plotProfileRepo.getById(
        session.plotConversationProfileId!,
      );
      if (profile != null) {
        // 전역 프로필 목록(마이페이지/프로필 변경 시트)과는 별개의 id 공간이라, 거기서
        // '선택됨' 체크가 우연히 겹치지 않도록 _profileId는 비워 둔다.
        _profileId = null;
        _profileName = await _plotProfileRepo.resolveDisplayName(profile);
        _profileImagePath = profile.imagePath;
        _profileDescription = profile.description;
      }
    } else if (session.conversationProfileId != null) {
      final profile = await _profileRepo.getById(
        session.conversationProfileId!,
      );
      if (profile != null) {
        _profileId = profile.id;
        _profileName = profile.name;
        _profileImagePath = profile.imagePath;
        _profileDescription = profile.description;
      }
    } else {
      // 예전에 만들어져 프로필이 안 붙어있는 세션은 기본 프로필로 채워서 앞으로는 '유저'로
      // 뜨지 않게 하고, 세션에도 그대로 저장해 다음부터는 바로 불러오게 한다.
      final defaultProfile = await _profileRepo.getDefault();
      if (defaultProfile != null) {
        _profileId = defaultProfile.id;
        _profileName = defaultProfile.name;
        _profileImagePath = defaultProfile.imagePath;
        _profileDescription = defaultProfile.description;
        await _sessionRepo.setConversationProfile(
          widget.sessionId,
          defaultProfile.id,
        );
      }
    }
    if (mounted) {
      setState(() {
        _plotId = session.plotId;
        _plotTitle = plot?.title ?? '';
        _loading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _generating) return;
    _inputController.clear();
    await _messageRepo.send(
      sessionId: widget.sessionId,
      senderType: MessageSender.user,
      content: text,
    );
    await _generateAiReply();
  }

  Future<void> _generateAiReply() async {
    await _withPreset(
      (preset, plotId, cancelToken) => _aiChatService.generateReply(
        sessionId: widget.sessionId,
        plotId: plotId,
        preset: preset,
        userProfileName: _profileName,
        userProfileDescription: _profileDescription,
        onDelta: _onDelta,
        onReasoning: _onReasoning,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<void> _retryTurn(int turnId) async {
    setState(() => _retryingTurnId = turnId);
    try {
      await _withPreset(
        (preset, plotId, cancelToken) => _aiChatService.retryReply(
          sessionId: widget.sessionId,
          plotId: plotId,
          preset: preset,
          userProfileName: _profileName,
          userProfileDescription: _profileDescription,
          turnId: turnId,
          onDelta: _onDelta,
          onReasoning: _onReasoning,
          cancelToken: cancelToken,
        ),
      );
    } finally {
      if (mounted) setState(() => _retryingTurnId = null);
    }
  }

  Future<void> _reviseTurn(int turnId, String instruction) async {
    await _withPreset(
      (preset, plotId, cancelToken) => _aiChatService.reviseReply(
        sessionId: widget.sessionId,
        plotId: plotId,
        preset: preset,
        userProfileName: _profileName,
        userProfileDescription: _profileDescription,
        turnId: turnId,
        instruction: instruction,
        onDelta: _onDelta,
        onReasoning: _onReasoning,
        cancelToken: cancelToken,
      ),
    );
  }

  void _onDelta(String accumulated) {
    if (mounted) setState(() => _streamingText = accumulated);
  }

  void _onReasoning(String reasoningDelta) {
    if (mounted) setState(() => _reasoningText += reasoningDelta);
  }

  Future<void> _withPreset(
    Future<void> Function(AiPreset preset, int plotId, AiGenerationCancelToken cancelToken) action,
  ) async {
    final preset = _selectedPreset;
    final plotId = _plotId;
    if (preset == null || plotId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.chatSelectPresetFirstMessage,
            ),
          ),
        );
      }
      return;
    }
    final cancelToken = AiGenerationCancelToken();
    setState(() {
      _generating = true;
      _streamingText = '';
      _reasoningText = '';
      _cancelToken = cancelToken;
    });
    try {
      await action(preset, plotId, cancelToken);
    } catch (e) {
      if (mounted && !cancelToken.isCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.chatGenerateFailureMessage(e),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _generating = false;
          _streamingText = '';
          _reasoningText = '';
          _cancelToken = null;
        });
      }
    }
  }

  /// 답변 생성 중 전송 버튼이 바뀐 중지 버튼을 눌렀을 때. 지금까지 받은 부분 응답은
  /// [AiChatService]가 최종 메시지로 그대로 저장한다.
  void _cancelGeneration() {
    _cancelToken?.cancel();
  }

  /// 왼쪽 드래그/'<' 버튼은 항상 이전 버전으로. 오른쪽 드래그/'>' 버튼은 다음 버전으로
  /// 넘기되, 이미 마지막 버전이면 [allowGenerateNext]일 때만 재시도로 새 버전을 만든다.
  /// (인트로 턴은 AI 재시도 대상이 아니라서 false로 막는다.)
  Future<void> _navigateVersion(
    ChatTurn turn,
    int delta,
    int versionCount, {
    required bool allowGenerateNext,
  }) async {
    final newIndex = turn.activeVersionIndex + delta;
    if (newIndex < 0) return;
    if (newIndex >= versionCount) {
      if (!allowGenerateNext) return;
      await _retryTurn(turn.id);
      return;
    }
    await _turnRepo.setActiveVersion(turn.id, newIndex);
  }

  /// 세션에서 유저 메시지가 하나도 나오기 전의 턴(들)은 인트로다. 이 턴들에서는
  /// AI 수정/재시도를 숨긴다.
  Set<int> _introTurnIds(List<ChatTimelineItem> items) {
    final ids = <int>{};
    var seenUserMessage = false;
    for (final item in items) {
      if (item.turn == null) {
        seenUserMessage = true;
        continue;
      }
      if (!seenUserMessage) ids.add(item.turn!.id);
    }
    return ids;
  }

  int? _lastTurnId(List<ChatTimelineItem> items) {
    for (final item in items.reversed) {
      if (item.turn != null) return item.turn!.id;
    }
    return null;
  }

  void _showSuggestionsSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final preset = _selectedPreset;
    final plotId = _plotId;
    if (preset == null || plotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chatSelectPresetFirstMessage)),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _SuggestionsSheet(
        onGenerate: () => _aiChatService.generateSuggestions(
          sessionId: widget.sessionId,
          plotId: plotId,
          preset: preset,
          userProfileName: _profileName,
        ),
        onUseSuggestion: (text) {
          Navigator.of(sheetContext).pop();
          _inputController.text = text;
          _inputController.selection = TextSelection.collapsed(
            offset: text.length,
          );
        },
        onSendSuggestion: (text) {
          Navigator.of(sheetContext).pop();
          _inputController.text = text;
          _sendMessage();
        },
      ),
    );
  }

  /// 채팅의 스냅샷 버튼. 지금까지의 장면을 AI가 묘사문으로 요약하고, 마이페이지 >
  /// 스냅샷 설정에서 고른 엔드포인트로 이미지를 생성해서 채팅에 그림 말풍선으로 추가한다.
  Future<void> _generateSnapshot() async {
    final l10n = AppLocalizations.of(context)!;
    final preset = _selectedPreset;
    final plotId = _plotId;
    if (preset == null || plotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chatSelectPresetFirstMessage)),
      );
      return;
    }
    final settings = await _snapshotSettingsStore.read();
    if (settings == null || !settings.isConfigured) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.chatSnapshotNotConfiguredMessage),
          action: SnackBarAction(
            label: l10n.myPageSnapshotSettingsButton,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SnapshotSettingsScreen(),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    setState(() => _snapshotting = true);
    try {
      final prompt = await _aiChatService.summarizeSceneForSnapshot(
        sessionId: widget.sessionId,
        plotId: plotId,
        preset: preset,
        userProfileName: _profileName,
      );
      final bytes = await _imageGenClient.generate(
        settings: settings,
        prompt: prompt,
      );
      final path = await _localImageStore.saveBytes('snapshot', bytes);
      await _messageRepo.send(
        sessionId: widget.sessionId,
        senderType: MessageSender.image,
        content: path,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.chatSnapshotFailureMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _snapshotting = false);
    }
  }

  Future<void> _openReviseDialog(int turnId) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final instruction = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          l10n.chatReviseDialogTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.chatReviseDialogHint,
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF3A3A3A)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _bubblePurple),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              l10n.commonCancel,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(
              l10n.chatReviseConfirmButton,
              style: const TextStyle(color: _bubblePurple),
            ),
          ),
        ],
      ),
    );
    if (instruction == null || instruction.isEmpty) return;
    await _reviseTurn(turnId, instruction);
  }

  Future<void> _editTurn(ChatTurn turn) async {
    final plotId = _plotId;
    if (plotId == null) return;
    final versionMessages = await _turnRepo.getVersionMessages(
      turn.id,
      turn.activeVersionIndex,
    );
    final rawText = PromptBuilder.reconstructRawText(
      messages: versionMessages,
      characters: _characters,
    );
    final controller = TextEditingController(text: rawText);
    if (!mounted) return;
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLines: 10,
                minLines: 4,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _background,
                  contentPadding: const EdgeInsets.all(12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _bubblePurple),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: _bubblePurple),
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(controller.text),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (result == null || !mounted) return;
    await _aiChatService.applyManualEdit(
      turnId: turn.id,
      plotId: plotId,
      activeVersionIndex: turn.activeVersionIndex,
      editedRawText: result,
    );
  }

  Character? _findCharacter(int? characterId) {
    if (characterId == null) return null;
    final match = _characters.where((c) => c.id == characterId);
    return match.isEmpty ? null : match.first;
  }

  /// 스트리밍 미리보기용: 아직 저장되지 않은 세그먼트의 화자 이름으로 캐릭터를 찾는다.
  /// [AiChatService._matchCharacter]와 같은 완화된(포함 관계도 허용) 매칭을 쓴다.
  Character? _findCharacterByName(String? speakerName) {
    final normalized = speakerName?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final c in _characters) {
      if (c.name.trim().toLowerCase() == normalized) return c;
    }
    for (final c in _characters) {
      final name = c.name.trim().toLowerCase();
      if (name.isEmpty) continue;
      if (normalized.contains(name) || name.contains(normalized)) return c;
    }
    return null;
  }

  /// AI 응답에 그대로 저장된 `{{user}}` 자리표시자를 지금 대화 프로필 이름으로 바꿔서
  /// 보여준다. 프로필을 나중에 바꿔도 예전 메시지가 그 이름으로 다시 렌더링된다.
  String _substituteUser(String content) =>
      content.replaceAll('{{user}}', _profileName);

  /// `{{user}}`와 대칭으로, AI가 캐릭터 말풍선 안에 `{{char}}`를 남겼다면 그 말풍선을
  /// 말하는 캐릭터 자신의 이름으로 바꿔서 보여준다.
  String _substituteChar(String content, String characterName) =>
      content.replaceAll('{{char}}', characterName);

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _background,
      appBar: _buildAppBar(context),
      endDrawer: _buildChatMenuDrawer(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _bubblePurple))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<ChatTimelineItem>>(
                      stream: _turnRepo.watchTimeline(widget.sessionId),
                      builder: (context, snapshot) {
                        final allItems = snapshot.data ?? const [];
                        // 재시도 중인 턴은 새 버전이 완성될 때까지 기존 말풍선을 감추고,
                        // 그 자리에 아래 스트리밍 미리보기가 보이게 한다.
                        final items = _retryingTurnId == null
                            ? allItems
                            : allItems
                                  .where((i) => i.turn?.id != _retryingTurnId)
                                  .toList();
                        final showPreview =
                            _generating && _streamingText.isNotEmpty;
                        // 첫 토큰(또는 추론 델타)이 오기 전까지 보여주는 '생성 중' 표시.
                        final showTypingIndicator = _generating &&
                            _streamingText.isEmpty &&
                            _reasoningText.isEmpty;
                        // 완결되지 않은 텍스트라도 MessageFormatParser는 안전하게 처리한다
                        // (미완성 태그는 이어지는 내용으로 취급될 뿐 예외를 던지지 않는다).
                        // 최종 저장 결과와 동일한 방식으로 화자별 말풍선을 나눠 보여줘서,
                        // 스트리밍 중 미리보기가 저장 후 렌더링과 어긋나지 않게 한다.
                        final previewSegments = showPreview
                            ? MessageFormatParser.parse(_streamingText)
                            : const <ParsedSpeechSegment>[];
                        final showReasoning =
                            _generating && _reasoningText.isNotEmpty;
                        final introTurnIds = _introTurnIds(allItems);
                        final lastTurnId = _lastTurnId(allItems);
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          itemCount:
                              items.length +
                              (showReasoning ? 1 : 0) +
                              (showTypingIndicator ? 1 : 0) +
                              previewSegments.length +
                              1,
                          itemBuilder: (context, rawIndex) {
                            if (rawIndex == 0) {
                              return _buildDisclaimerBanner(context);
                            }
                            final index = rawIndex - 1;
                            if (index == items.length && showTypingIndicator) {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: _TypingIndicator(),
                              );
                            }
                            if (index == items.length && showReasoning) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ReasoningBlock(text: _reasoningText),
                              );
                            }
                            final previewStart = items.length +
                                (showReasoning ? 1 : 0) +
                                (showTypingIndicator ? 1 : 0);
                            if (index >= previewStart) {
                              final segment =
                                  previewSegments[index - previewStart];
                              final Widget previewBubble;
                              if (segment.senderType ==
                                  MessageSender.narrator) {
                                previewBubble = _NarratorLine(
                                  text: _substituteUser(segment.content),
                                );
                              } else {
                                final character = _findCharacterByName(
                                  segment.speakerName,
                                );
                                final resolvedName =
                                    character?.name ??
                                    segment.speakerName ??
                                    AppLocalizations.of(
                                      context,
                                    )!.chatDefaultCharacterName;
                                previewBubble = _CharacterMessage(
                                  characterName: resolvedName,
                                  imagePath: character?.imagePath,
                                  message: _substituteChar(
                                    _substituteUser(segment.content),
                                    resolvedName,
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: previewBubble,
                              );
                            }
                            final item = items[index];
                            final message = item.message;
                            Widget bubble;
                            switch (message.senderType) {
                              case MessageSender.character:
                                final character = _findCharacter(
                                  message.characterId,
                                );
                                final resolvedName =
                                    character?.name ??
                                    message.speakerNameOverride ??
                                    AppLocalizations.of(
                                      context,
                                    )!.chatDefaultCharacterName;
                                bubble = _CharacterMessage(
                                  characterName: resolvedName,
                                  imagePath: character?.imagePath,
                                  message: _substituteChar(
                                    _substituteUser(message.content),
                                    resolvedName,
                                  ),
                                );
                                final turn = item.turn;
                                if (turn != null &&
                                    turn.id == lastTurnId &&
                                    !_generating) {
                                  final isIntro = introTurnIds.contains(
                                    turn.id,
                                  );
                                  bubble = GestureDetector(
                                    onHorizontalDragEnd: (details) {
                                      final velocity =
                                          details.primaryVelocity ?? 0;
                                      if (velocity > 200) {
                                        _navigateVersion(
                                          turn,
                                          1,
                                          item.versionCount,
                                          allowGenerateNext: !isIntro,
                                        );
                                      } else if (velocity < -200) {
                                        _navigateVersion(
                                          turn,
                                          -1,
                                          item.versionCount,
                                          allowGenerateNext: true,
                                        );
                                      }
                                    },
                                    child: bubble,
                                  );
                                }
                              case MessageSender.narrator:
                                bubble = _NarratorLine(
                                  text: _substituteUser(message.content),
                                );
                              case MessageSender.user:
                                bubble = _UserMessage(
                                  userName: _profileName,
                                  imagePath: _profileImagePath,
                                  message: message.content,
                                  onLongPress: () =>
                                      _showUserMessageMenu(context, message),
                                );
                              case MessageSender.image:
                                bubble = _IntroImageLine(
                                  imagePath: message.content,
                                );
                            }
                            // 스냅샷 이미지처럼 턴에 속하지 않는 말풍선이 맨 뒤에 붙을 수 있어서,
                            // '진짜 마지막 항목'이 아니라 '마지막 턴의 마지막 말풍선'인지로 액션 줄을 판단한다.
                            final showActions =
                                !showPreview &&
                                item.turn != null &&
                                item.turn!.id == lastTurnId &&
                                item.isLastBubbleOfTurn &&
                                !_generating;
                            final isIntroTurn =
                                item.turn != null &&
                                introTurnIds.contains(item.turn!.id);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  bubble,
                                  if (showActions) ...[
                                    const SizedBox(height: 6),
                                    _TurnActionRow(
                                      versionCount: item.versionCount,
                                      isIntro: isIntroTurn,
                                      snapshotting: _snapshotting,
                                      onEdit: () => _editTurn(item.turn!),
                                      onRevise: () =>
                                          _openReviseDialog(item.turn!.id),
                                      onRetry: () => _retryTurn(item.turn!.id),
                                      onPrev: () => _navigateVersion(
                                        item.turn!,
                                        -1,
                                        item.versionCount,
                                        allowGenerateNext: true,
                                      ),
                                      onNext: () => _navigateVersion(
                                        item.turn!,
                                        1,
                                        item.versionCount,
                                        allowGenerateNext: !isIntroTurn,
                                      ),
                                      onSnapshot: _generateSnapshot,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  _buildInputBar(context),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        _plotTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => _showModelPresetSheet(context),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _pillGrey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedPreset?.name ??
                      AppLocalizations.of(context)!.chatPresetSelectDefault,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 22),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
    );
  }

  Widget _buildChatMenuDrawer(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      backgroundColor: const Color(0xFF1B1B1B),
      width: MediaQuery.of(context).size.width * 0.72,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _DrawerMenuItem(
              title: l10n.chatDrawerStartFreshTitle,
              subtitle: l10n.chatDrawerStartFreshSubtitle,
              onTap: () => _startFresh(context),
            ),
            _DrawerMenuItem(
              title: l10n.chatDrawerResumeTitle,
              showChevron: true,
              onTap: () => _openResume(context),
            ),
            _DrawerMenuItem(
              title: l10n.chatDrawerDeleteTitle,
              onTap: () async {
                await _sessionRepo.delete(widget.sessionId);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            const Divider(color: Color(0xFF2A2A2A), height: 24),
            _DrawerMenuItem(
              title: l10n.chatDrawerProfileTitle,
              trailingText: _profileName,
              showChevron: true,
              onTap: () {
                Navigator.of(context).pop();
                _showConversationProfileSheet(context);
              },
            ),
            _DrawerMenuItem(
              title: l10n.chatDrawerChoicesTitle,
              trailingText: l10n.chatDrawerChoicesDisabled,
              showChevron: true,
              onTap: () => Navigator.of(context).pop(),
            ),
            _DrawerMenuItem(
              title: l10n.chatDrawerMemoryTitle,
              showChevron: true,
              onTap: () {
                Navigator.of(context).pop();
                _showMemorySheet(context);
              },
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                color: const Color(0xFF262626),
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.chatDrawerExitButton,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 드로어 '기억 보기'. 컨텍스트 길이 제한으로 잘려나간 오래된 대화를 요약해둔 내용을
  /// 읽기 전용으로 보여준다(투명성 확보용, 자동으로만 생성/갱신되고 여기선 편집하지 않는다).
  void _showMemorySheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B1B1B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StreamBuilder<ChatMemorySummary?>(
              stream: _memoryRepo.watchForSession(widget.sessionId),
              builder: (context, snapshot) {
                final summary = snapshot.data;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.chatMemorySheetTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      summary?.summaryText.isNotEmpty == true ? summary!.summaryText : l10n.chatMemoryEmptyMessage,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisclaimerBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0xFF1B1B1B),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: _mutedText, size: 14),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!.chatDisclaimerBanner,
            style: const TextStyle(color: _mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: _background,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showSuggestionsSheet(context),
            child: const Icon(Icons.bolt, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: _pillGrey,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: AppLocalizations.of(context)!.chatInputHint,
                  hintStyle: const TextStyle(color: _mutedText, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _generating ? _cancelGeneration : _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: _bubblePurple,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _generating ? Icons.stop_rounded : Icons.arrow_upward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showModelPresetSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
            ),
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
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.chatModelSheetTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.chatModelSheetDescription,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AiPresetScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          l10n.chatModelSheetPresetSettingsLink,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: StreamBuilder<List<AiPreset>>(
                        stream: _presetRepo.watchAll(),
                        builder: (context, snapshot) {
                          final presets = snapshot.data ?? const [];
                          if (presets.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                l10n.chatModelSheetNoPresets,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: presets.map((preset) {
                              final selected = preset.id == _selectedPreset?.id;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () async {
                                    await _sessionRepo.setPreset(
                                      widget.sessionId,
                                      preset.id,
                                    );
                                    setState(() => _selectedPreset = preset);
                                    if (sheetContext.mounted)
                                      Navigator.of(sheetContext).pop();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF262626),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selected
                                            ? _bubblePurple
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                preset.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                preset.description,
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (selected)
                                          const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 20,
                                          ),
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

  Future<void> _startFresh(BuildContext context) async {
    Navigator.of(context).pop();
    final plotId = _plotId;
    if (plotId == null) return;
    final saveCurrent = await StartFreshDialog.show(context);
    if (saveCurrent == null || !context.mounted) return;
    final newSessionId = await _sessionRepo.startFresh(
      plotId: plotId,
      currentSessionId: widget.sessionId,
      saveCurrent: saveCurrent,
    );
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ChatScreen(sessionId: newSessionId)),
    );
  }

  void _showUserMessageMenu(BuildContext context, ChatMessage message) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _SheetActionTile(
                  icon: Icons.restart_alt,
                  label: l10n.chatSheetStartFreshFromHere,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _startFreshFromHere(context, message.id);
                  },
                ),
                const SizedBox(height: 8),
                _SheetActionTile(
                  icon: Icons.copy_outlined,
                  label: l10n.commonCopy,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Clipboard.setData(ClipboardData(text: message.content));
                  },
                ),
                const SizedBox(height: 8),
                _SheetActionTile(
                  icon: Icons.delete_outline,
                  label: l10n.commonDelete,
                  isDestructive: true,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _turnRepo.deleteFromMessage(widget.sessionId, message.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startFreshFromHere(BuildContext context, int messageId) async {
    final plotId = _plotId;
    if (plotId == null) return;
    final confirmed = await StartFreshFromHereDialog.show(context);
    if (confirmed != true || !context.mounted) return;
    final newSessionId = await _sessionRepo.startFreshFromMessage(
      plotId: plotId,
      currentSessionId: widget.sessionId,
      uptoMessageId: messageId,
    );
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ChatScreen(sessionId: newSessionId)),
    );
  }

  Future<void> _openResume(BuildContext context) async {
    Navigator.of(context).pop();
    final plotId = _plotId;
    if (plotId == null) return;
    final resumedId = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => ResumeConversationsScreen(
          plotId: plotId,
          currentSessionId: widget.sessionId,
        ),
      ),
    );
    if (resumedId == null || !context.mounted) return;
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ChatScreen(sessionId: resumedId)));
  }

  void _showConversationProfileSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chatProfileSheetTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ConversationProfileEditScreen(
                          profileId: null,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add, color: Colors.white70, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          l10n.chatProfileSheetAddButton,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: StreamBuilder<List<ConversationProfile>>(
                    stream: _profileRepo.watchAll(),
                    builder: (context, snapshot) {
                      final profiles = snapshot.data ?? const [];
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: profiles.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          final selected = profile.id == _profileId;
                          return InkWell(
                            onTap: () async {
                              await _sessionRepo.setConversationProfile(
                                widget.sessionId,
                                profile.id,
                              );
                              setState(() {
                                _profileId = profile.id;
                                _profileName = profile.name;
                                _profileImagePath = profile.imagePath;
                                _profileDescription = profile.description;
                              });
                              if (sheetContext.mounted)
                                Navigator.of(sheetContext).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      LocalAvatar(
                                        imagePath: profile.imagePath,
                                        radius: 20,
                                      ),
                                      if (selected)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                              color: _bubblePurple,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 11,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      profile.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white54,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      Navigator.of(sheetContext).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ConversationProfileEditScreen(
                                                profileId: profile.id,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.title,
    this.subtitle,
    this.trailingText,
    this.showChevron = false,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? trailingText;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(width: 4),
            ],
            if (showChevron)
              const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}

/// 유저 말풍선을 길게 누르면(데스크톱은 우클릭) 뜨는 바텀시트의 항목 한 줄.
class _SheetActionTile extends StatelessWidget {
  const _SheetActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : Colors.white;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

final _actionTextPattern = RegExp(r'\*([^*]+)\*');

/// `*지문/행동*` 구간을 이탤릭으로, 나머지는 기본 스타일로 렌더링한다.
class _FormattedMessageText extends StatelessWidget {
  const _FormattedMessageText(this.content, {required this.style});

  final String content;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    var last = 0;
    for (final match in _actionTextPattern.allMatches(content)) {
      if (match.start > last) {
        spans.add(TextSpan(text: content.substring(last, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: style.copyWith(
            fontStyle: FontStyle.italic,
            color: style.color?.withValues(alpha: 0.7),
          ),
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

class _CharacterMessage extends StatelessWidget {
  const _CharacterMessage({
    required this.characterName,
    required this.message,
    this.imagePath,
  });

  final String characterName;
  final String message;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocalAvatar(imagePath: imagePath, radius: 16, icon: Icons.pets),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                characterName,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _ChatScreenState._bubbleGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _FormattedMessageText(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 인트로 탭에서 첨부한 이미지 한 장, 또는 스냅샷으로 생성된 이미지. 마이페이지 >
/// 환경설정에서 고른 표시 방식(정사각형/가로 꽉 채우기)을 따른다.
class _IntroImageLine extends StatelessWidget {
  const _IntroImageLine({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: ValueListenableBuilder<ChatImageDisplayMode>(
        valueListenable: chatImagePreferences,
        builder: (context, mode, _) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: mode == ChatImageDisplayMode.fullWidth
                ? Image.file(
                    File(imagePath),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(imagePath),
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
          );
        },
      ),
    );
  }
}

/// 요청을 보낸 뒤 첫 토큰(또는 추론 델타)이 도착하기 전까지 보여주는 '생성 중' 표시.
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
        ),
        const SizedBox(width: 8),
        Text(
          AppLocalizations.of(context)!.chatGeneratingIndicator,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}

class _NarratorLine extends StatelessWidget {
  const _NarratorLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.reorder, color: Colors.white54, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: _FormattedMessageText(
            text,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

/// 추론(reasoning/thinking) 모델이 답변 전 생각하는 과정을 실시간으로 보여주는 블록.
/// 저장되지 않는 휘발성 표시로, 생성이 끝나면(또는 답변이 나오기 시작하면) 사라진다.
class _ReasoningBlock extends StatelessWidget {
  const _ReasoningBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(left: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.chatReasoningInProgressLabel,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMessage extends StatelessWidget {
  const _UserMessage({
    required this.userName,
    required this.message,
    this.imagePath,
    this.onLongPress,
  });

  final String userName;
  final String message;
  final String? imagePath;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                userName,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onLongPress: onLongPress,
                onSecondaryTap: onLongPress,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _ChatScreenState._bubblePurple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _FormattedMessageText(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        LocalAvatar(imagePath: imagePath, radius: 16),
      ],
    );
  }
}

/// 세션 전체에서 가장 마지막 AI 턴 아래에만 그리는 액션 버튼 줄.
/// 인트로 턴에서는 AI 수정/재시도/스냅샷을 숨기고 수정(+ 인트로 버전이 여럿이면 이전/다음)만 남긴다.
/// 일반 턴은 버전이 하나뿐이면 [수정/AI 수정/스냅샷/재시도], 재시도로 버전이 여러 개가 되면
/// [수정/AI 수정/스냅샷/이전<, 다음>]으로 바뀐다. '>'를 마지막 버전에서 누르면 새로 하나 더 생성한다.
class _TurnActionRow extends StatelessWidget {
  const _TurnActionRow({
    required this.versionCount,
    required this.isIntro,
    required this.snapshotting,
    required this.onEdit,
    required this.onRevise,
    required this.onRetry,
    required this.onPrev,
    required this.onNext,
    required this.onSnapshot,
  });

  final int versionCount;
  final bool isIntro;
  final bool snapshotting;
  final VoidCallback onEdit;
  final VoidCallback onRevise;
  final VoidCallback onRetry;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSnapshot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _RoundIconButton(icon: Icons.edit_outlined, onTap: onEdit),
          if (!isIntro) ...[
            const SizedBox(width: 8),
            _RoundIconButton(icon: Icons.auto_fix_high, onTap: onRevise),
            const SizedBox(width: 8),
            if (snapshotting)
              const SizedBox(
                width: 32,
                height: 32,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                ),
              )
            else
              _RoundIconButton(
                icon: Icons.camera_alt_outlined,
                onTap: onSnapshot,
              ),
          ],
          if (versionCount <= 1) ...[
            if (!isIntro) ...[
              const SizedBox(width: 8),
              _RoundIconButton(icon: Icons.refresh, onTap: onRetry),
            ],
          ] else ...[
            const SizedBox(width: 8),
            _RoundIconButton(icon: Icons.chevron_left, onTap: onPrev),
            const SizedBox(width: 8),
            _RoundIconButton(icon: Icons.chevron_right, onTap: onNext),
          ],
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Color(0xFF262626),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 16),
      ),
    );
  }
}

/// 번개 버튼을 누르면 뜨는 바텀시트. 열리자마자 AI에게 다음 대화 후보 3개를 요청하고,
/// 각 후보를 탭하면 입력창에 채워주고 화살표를 누르면 바로 전송한다.
class _SuggestionsSheet extends StatefulWidget {
  const _SuggestionsSheet({
    required this.onGenerate,
    required this.onUseSuggestion,
    required this.onSendSuggestion,
  });

  final Future<List<String>> Function() onGenerate;
  final void Function(String text) onUseSuggestion;
  final void Function(String text) onSendSuggestion;

  @override
  State<_SuggestionsSheet> createState() => _SuggestionsSheetState();
}

class _SuggestionsSheetState extends State<_SuggestionsSheet> {
  late final Future<List<String>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.onGenerate();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.bolt,
                  color: _ChatScreenState._bubblePurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.chatSuggestSheetTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.chatSuggestUseHint,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<String>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _ChatScreenState._bubblePurple,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      l10n.chatSuggestFailureMessage(snapshot.error!),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                final suggestions = snapshot.data ?? const [];
                if (suggestions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      l10n.chatSuggestEmptyMessage,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return Column(
                  children: suggestions
                      .map(
                        (suggestion) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => widget.onUseSuggestion(suggestion),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF262626),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      suggestion,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () =>
                                        widget.onSendSuggestion(suggestion),
                                    child: const SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: _ChatScreenState._bubblePurple,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
