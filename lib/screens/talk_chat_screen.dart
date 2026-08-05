import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/ai/talk_chat_service.dart';
import '../data/db/database.dart';
import '../data/local_image_store.dart';
import '../data/repositories/ai_preset_repository.dart';
import '../data/repositories/character_repository.dart';
import '../data/repositories/conversation_profile_repository.dart';
import '../data/repositories/plot_conversation_profile_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../data/repositories/talk_message_repository.dart';
import '../data/repositories/talk_session_repository.dart';
import '../l10n/app_localizations.dart';
import '../widgets/local_avatar.dart';
import 'conversation_profile_edit_screen.dart';
import 'talk_character_picker_screen.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// ZedTalk 대화 화면. 롤플레이용 ChatScreen과 시각적으로는 비슷하지만(같은 버블/입력바
/// 배색), 턴/버전 개념은 없이 단순한 메신저형 주고받기를 기본으로 하되, 햄버거 메뉴/
/// 롱프레스 메뉴/메시지 수정·재시도/캐릭터 아바타/날짜 구분선처럼 플롯 대화의 핵심
/// 기능은 그대로 가져왔다.
class TalkChatScreen extends StatefulWidget {
  const TalkChatScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<TalkChatScreen> createState() => _TalkChatScreenState();
}

class _TalkChatScreenState extends State<TalkChatScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _bubbleGrey => _p.surfaceAlt;
  Color get _bubblePurple => _p.primary;
  Color get _pillGrey => _p.surfaceAlt;
  Color get _mutedText => _p.textMuted;
  Color get _cardBg => _p.surface;
  Color get _textPrimary => _p.textPrimary;
  Color get _textFaint => _p.textFaint;
  Color get _textSecondary => _p.textSecondary;
  Color get _textGhost => _p.textGhost;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late final TalkSessionRepository _sessionRepo;
  late final TalkMessageRepository _messageRepo;
  late final AiPresetRepository _presetRepo;
  late final PlotRepository _plotRepo;
  late final CharacterRepository _characterRepo;
  late final ConversationProfileRepository _profileRepo;
  late final PlotConversationProfileRepository _plotProfileRepo;
  final _talkChatService = TalkChatService();
  final _imageStore = LocalImageStore();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  bool _loading = true;
  int? _plotId;
  Character? _character;
  String _plotTitle = '';
  AiPreset? _selectedPreset;
  int? _profileId;
  String _profileName = '유저';
  bool _generating = false;
  String _streamingText = '';
  AiGenerationCancelTokenLike? _cancelToken;

  @override
  void initState() {
    super.initState();
    final db = AppDatabase.instance;
    _sessionRepo = TalkSessionRepository(db);
    _messageRepo = TalkMessageRepository(db);
    _presetRepo = AiPresetRepository(db);
    _plotRepo = PlotRepository(db);
    _characterRepo = CharacterRepository(db);
    _profileRepo = ConversationProfileRepository(db);
    _plotProfileRepo = PlotConversationProfileRepository(db);
    _load();
  }

  Future<void> _load() async {
    final session = await _sessionRepo.getById(widget.sessionId);
    if (session == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final plot = await _plotRepo.getById(session.plotId);
    final character = session.characterId != null
        ? await _characterRepo.getById(session.characterId!)
        : await _plotRepo.representativeCharacter(session.plotId);
    AiPreset? preset;
    if (session.presetId != null) {
      preset = await _presetRepo.getById(session.presetId!);
    }

    int? profileId;
    var profileName = _profileName;
    if (session.plotConversationProfileId != null) {
      final profile = await _plotProfileRepo.getById(session.plotConversationProfileId!);
      if (profile != null) {
        profileName = await _plotProfileRepo.resolveDisplayName(profile);
      }
    } else if (session.conversationProfileId != null) {
      final profile = await _profileRepo.getById(session.conversationProfileId!);
      if (profile != null) {
        profileId = profile.id;
        profileName = profile.name;
      }
    } else {
      final defaultProfile = await _profileRepo.getDefault();
      if (defaultProfile != null) {
        profileId = defaultProfile.id;
        profileName = defaultProfile.name;
        await _sessionRepo.setConversationProfile(widget.sessionId, defaultProfile.id);
      }
    }

    if (!mounted) return;
    setState(() {
      _plotId = session.plotId;
      _plotTitle = plot?.title ?? '';
      _character = character;
      _selectedPreset = preset;
      _profileId = profileId;
      _profileName = profileName;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickPreset() async {
    final l10n = AppLocalizations.of(context)!;
    final presets = await _presetRepo.watchAll().first;
    if (!mounted) return;
    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.plotAiGeneratePresetEmptyHint)),
      );
      return;
    }
    final selected = await showModalBottomSheet<AiPreset>(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.talkPresetSheetTitle,
                    style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              ...presets.map((preset) => ListTile(
                    title: Text(preset.name, style: TextStyle(color: _textPrimary)),
                    trailing: _selectedPreset?.id == preset.id ? Icon(Icons.check, color: _bubblePurple) : null,
                    onTap: () => Navigator.of(sheetContext).pop(preset),
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected == null) return;
    await _sessionRepo.setPreset(widget.sessionId, selected.id);
    if (mounted) setState(() => _selectedPreset = selected);
  }

  Future<void> _sendMessage({String? attachmentPath, TalkAttachmentType? attachmentType}) async {
    final text = _inputController.text.trim();
    if ((text.isEmpty && attachmentPath == null) || _generating) return;
    _inputController.clear();
    await _messageRepo.send(
      sessionId: widget.sessionId,
      sender: TalkMessageSender.user,
      content: text,
      attachmentPath: attachmentPath,
      attachmentType: attachmentType,
    );
    await _generateReply();
  }

  Future<void> _generateReply() async {
    final l10n = AppLocalizations.of(context)!;
    final preset = _selectedPreset;
    final character = _character;
    if (preset == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.talkNoPresetMessage)));
      return;
    }

    final cancelToken = AiGenerationCancelTokenLike();
    setState(() {
      _generating = true;
      _streamingText = '';
      _cancelToken = cancelToken;
    });
    try {
      final history = await _messageRepo.getBySession(widget.sessionId);
      final systemPrompt = buildTalkSystemPrompt(
        characterName: character?.name ?? l10n.chatDefaultCharacterName,
        characterDescription: character?.description ?? '',
        userProfileName: _profileName,
        now: DateTime.now(),
      );
      final buffer = StringBuffer();
      await for (final delta in _talkChatService.streamReply(
        preset: preset,
        systemPrompt: systemPrompt,
        history: history,
      )) {
        buffer.write(delta);
        if (mounted) setState(() => _streamingText = buffer.toString());
        if (cancelToken.isCancelled) break;
      }
      final fullText = buffer.toString().trim();
      if (fullText.isNotEmpty) {
        await _messageRepo.send(
          sessionId: widget.sessionId,
          sender: TalkMessageSender.character,
          content: fullText,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.chatGenerateFailureMessage(e))),
        );
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

  void _cancelGeneration() => _cancelToken?.cancel();

  Future<void> _showAttachmentSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.talkAttachmentSheetTitle,
                    style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.image_outlined, color: _textPrimary),
                title: Text(l10n.talkAttachmentImageOption, style: TextStyle(color: _textPrimary)),
                onTap: () => Navigator.of(sheetContext).pop('image'),
              ),
              ListTile(
                leading: Icon(Icons.videocam_outlined, color: _textPrimary),
                title: Text(l10n.talkAttachmentVideoOption, style: TextStyle(color: _textPrimary)),
                onTap: () => Navigator.of(sheetContext).pop('video'),
              ),
              ListTile(
                leading: Icon(Icons.description_outlined, color: _textPrimary),
                title: Text(l10n.talkAttachmentDocumentOption, style: TextStyle(color: _textPrimary)),
                onTap: () => Navigator.of(sheetContext).pop('document'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (choice == null) return;

    final type = switch (choice) {
      'image' => TalkAttachmentType.image,
      'video' => TalkAttachmentType.video,
      _ => TalkAttachmentType.document,
    };
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    final bytes = await picked.readAsBytes();
    final ext = picked.extension == null || picked.extension!.isEmpty ? '' : '.${picked.extension}';
    final savedPath = await _imageStore.saveBytes('talk_attachment', bytes, ext: ext.isEmpty ? '.bin' : ext);

    if (!mounted) return;
    if (type == TalkAttachmentType.image && _selectedPreset?.supportsVision != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.talkVisionUnsupportedNote)),
      );
    }
    await _sendMessage(attachmentPath: savedPath, attachmentType: type);
  }

  // ── 햄버거 드로어 메뉴 ────────────────────────────────────────────────

  /// 플롯 캐릭터가 1명 이하면 바로 그 id(없으면 null)를, 2명 이상이면 선택 화면을 띄워
  /// 고른 id를 돌려준다. 취소하면 null과 함께 `cancelled: true`.
  Future<({bool cancelled, int? characterId})> _pickCharacterForNewSession() async {
    final plotId = _plotId;
    if (plotId == null) return (cancelled: false, characterId: null);
    final characters = await _characterRepo.getByPlot(plotId);
    if (characters.length <= 1) {
      return (cancelled: false, characterId: characters.isEmpty ? null : characters.first.id);
    }
    if (!mounted) return (cancelled: true, characterId: null);
    final chosen = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => TalkCharacterPickerScreen(plotId: plotId)),
    );
    return chosen == null ? (cancelled: true, characterId: null) : (cancelled: false, characterId: chosen);
  }

  Future<void> _startFresh() async {
    Navigator.of(context).pop();
    final plotId = _plotId;
    if (plotId == null) return;
    final current = await _sessionRepo.getById(widget.sessionId);
    final pick = await _pickCharacterForNewSession();
    if (pick.cancelled || !mounted) return;
    final newSessionId = await _sessionRepo.createSession(
      plotId: plotId,
      presetId: current?.presetId,
      characterId: pick.characterId,
    );
    if (current?.conversationProfileId != null) {
      await _sessionRepo.setConversationProfile(newSessionId, current!.conversationProfileId!);
    } else if (current?.plotConversationProfileId != null) {
      await _sessionRepo.setPlotConversationProfile(newSessionId, current!.plotConversationProfileId!);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TalkChatScreen(sessionId: newSessionId)),
    );
  }

  void _openResumeSheet() {
    final l10n = AppLocalizations.of(context)!;
    final plotId = _plotId;
    Navigator.of(context).pop();
    if (plotId == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.talkResumeSheetTitle,
                  style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: StreamBuilder<List<TalkSessionSummary>>(
                    stream: _sessionRepo.watchOthersForPlot(plotId, widget.sessionId),
                    builder: (context, snapshot) {
                      final sessions = snapshot.data ?? const [];
                      if (sessions.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            l10n.talkResumeSheetEmpty,
                            style: TextStyle(color: _textFaint, fontSize: 13),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final summary = sessions[index];
                          return ListTile(
                            leading: Icon(Icons.chat_bubble_outline, color: _textSecondary),
                            title: Text(
                              summary.lastMessagePreview.isEmpty
                                  ? l10n.talkListEmpty
                                  : summary.lastMessagePreview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: _textPrimary),
                            ),
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => TalkChatScreen(sessionId: summary.session.id)),
                              );
                            },
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

  void _showProfileSheet() {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
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
                    decoration: BoxDecoration(color: _textGhost, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chatProfileSheetTitle,
                  style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ConversationProfileEditScreen(profileId: null)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: _pillGrey, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.add, color: _textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Text(l10n.chatProfileSheetAddButton, style: TextStyle(color: _textPrimary, fontSize: 14)),
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
                              await _sessionRepo.setConversationProfile(widget.sessionId, profile.id);
                              setState(() {
                                _profileId = profile.id;
                                _profileName = profile.name;
                              });
                              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      LocalAvatar(imagePath: profile.imagePath, radius: 20),
                                      if (selected)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(color: _bubblePurple, shape: BoxShape.circle),
                                            child: Icon(Icons.check, color: _textPrimary, size: 11),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(profile.name, style: TextStyle(color: _textPrimary, fontSize: 14)),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined, color: _mutedText, size: 18),
                                    onPressed: () {
                                      Navigator.of(sheetContext).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ConversationProfileEditScreen(profileId: profile.id),
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
              title: l10n.talkDrawerStartFreshTitle,
              subtitle: l10n.talkDrawerStartFreshSubtitle,
              onTap: _startFresh,
            ),
            _DrawerMenuItem(
              title: l10n.talkDrawerResumeTitle,
              showChevron: true,
              onTap: _openResumeSheet,
            ),
            _DrawerMenuItem(
              title: l10n.talkDrawerDeleteTitle,
              onTap: () async {
                await _sessionRepo.delete(widget.sessionId);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            Divider(color: _bubbleGrey, height: 24),
            _DrawerMenuItem(
              title: l10n.talkDrawerProfileTitle,
              trailingText: _profileName,
              showChevron: true,
              onTap: _showProfileSheet,
            ),
            _DrawerMenuItem(
              title: l10n.talkDrawerChoicesTitle,
              trailingText: l10n.chatDrawerChoicesDisabled,
              showChevron: true,
              onTap: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                color: _bubbleGrey,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: _textSecondary, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.talkDrawerExitButton, style: TextStyle(color: _textSecondary, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 유저 말풍선 롱프레스 메뉴 ─────────────────────────────────────────

  void _showUserMessageMenu(TalkMessage message) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
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
                  decoration: BoxDecoration(color: _textGhost, borderRadius: BorderRadius.circular(2)),
                ),
                _SheetActionTile(
                  icon: Icons.restart_alt,
                  label: l10n.talkSheetStartFreshFromHere,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _startFreshFromHere(message.id);
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
                    _messageRepo.deleteFrom(widget.sessionId, message.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startFreshFromHere(int messageId) async {
    final plotId = _plotId;
    if (plotId == null) return;
    final newSessionId = await _sessionRepo.startFreshFromMessage(
      plotId: plotId,
      currentSessionId: widget.sessionId,
      uptoMessageId: messageId,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TalkChatScreen(sessionId: newSessionId)),
    );
  }

  // ── 마지막 캐릭터 메시지의 수정/재시도 ─────────────────────────────────

  Future<void> _editMessage(TalkMessage message) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: message.content);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.talkEditMessageTitle,
                      style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: _mutedText, size: 20),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                  IconButton(
                    icon: Icon(Icons.check, color: _bubblePurple, size: 20),
                    onPressed: () => Navigator.of(dialogContext).pop(controller.text),
                  ),
                ],
              ),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 8,
                minLines: 3,
                style: TextStyle(color: _textPrimary, fontSize: 14),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == null) return;
    await _messageRepo.updateContent(message.id, result.trim());
  }

  Future<void> _retryLastMessage(TalkMessage message) async {
    await _messageRepo.delete(message.id);
    await _generateReply();
  }

  // ── 날짜/시간 그룹핑 ─────────────────────────────────────────────────

  bool _sameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool _sameMinute(DateTime a, DateTime b) =>
      _sameDate(a, b) && a.hour == b.hour && a.minute == b.minute;

  String _formatDateDivider(DateTime dt) => DateFormat('yyyy년 M월 d일 EEEE', 'ko').format(dt);

  String _formatTime(DateTime dt) => DateFormat('a h:mm', 'ko').format(dt);

  List<_TalkRenderEntry> _buildRenderEntries(List<TalkMessage> messages) {
    final entries = <_TalkRenderEntry>[];
    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      final prev = i > 0 ? messages[i - 1] : null;
      if (prev == null || !_sameDate(prev.createdAt, message.createdAt)) {
        entries.add(_TalkRenderEntry.divider(message.createdAt));
      }
      final next = i + 1 < messages.length ? messages[i + 1] : null;
      final showTime = next == null || next.sender != message.sender || !_sameMinute(next.createdAt, message.createdAt);
      entries.add(_TalkRenderEntry.message(message, showTime));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      endDrawer: _buildChatMenuDrawer(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: GestureDetector(
          onTap: _pickPreset,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalAvatar(imagePath: _character?.imagePath, radius: 14, icon: Icons.pets),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _character?.name ?? _plotTitle,
                      style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _selectedPreset?.name ?? l10n.talkNoPresetMessage,
                      style: TextStyle(color: _textFaint, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: _textPrimary, size: 22),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _bubblePurple))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<TalkMessage>>(
                      stream: _messageRepo.watchBySession(widget.sessionId),
                      builder: (context, snapshot) {
                        final messages = snapshot.data ?? const [];
                        final entries = _buildRenderEntries(messages).reversed.toList();
                        final showTyping = _generating && _streamingText.isEmpty;
                        final showPreview = _generating && _streamingText.isNotEmpty;
                        final lastMessageId = messages.isEmpty ? null : messages.last.id;
                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: entries.length + (showTyping || showPreview ? 1 : 0),
                          itemBuilder: (context, reversedIndex) {
                            if (reversedIndex == 0 && (showTyping || showPreview)) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: showPreview
                                      ? _TalkBubble(text: _streamingText, isUser: false, bubbleColor: _bubbleGrey)
                                      : const _TalkTypingIndicator(),
                                ),
                              );
                            }
                            final entryIndex = reversedIndex - (showTyping || showPreview ? 1 : 0);
                            final entry = entries[entryIndex];
                            if (entry.isDivider) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: _DateDividerPill(text: _formatDateDivider(entry.dividerDate!)),
                              );
                            }
                            final message = entry.message!;
                            final isUser = message.sender == TalkMessageSender.user;
                            final timeText = entry.showTime ? _formatTime(message.createdAt) : null;
                            final isLastCharacterMessage =
                                !isUser && message.id == lastMessageId && !_generating;

                            Widget row;
                            if (isUser) {
                              row = GestureDetector(
                                onLongPress: () => _showUserMessageMenu(message),
                                onSecondaryTap: () => _showUserMessageMenu(message),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (timeText != null) ...[
                                      Text(timeText, style: TextStyle(color: _mutedText, fontSize: 11)),
                                      const SizedBox(width: 6),
                                    ],
                                    _TalkBubble(
                                      text: message.content,
                                      isUser: true,
                                      bubbleColor: _bubblePurple,
                                      attachmentPath: message.attachmentPath,
                                      attachmentType: message.attachmentType,
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              row = Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  LocalAvatar(imagePath: _character?.imagePath, radius: 14, icon: Icons.pets),
                                  const SizedBox(width: 8),
                                  _TalkBubble(
                                    text: message.content,
                                    isUser: false,
                                    bubbleColor: _bubbleGrey,
                                    attachmentPath: message.attachmentPath,
                                    attachmentType: message.attachmentType,
                                  ),
                                  if (timeText != null) ...[
                                    const SizedBox(width: 6),
                                    Text(timeText, style: TextStyle(color: _mutedText, fontSize: 11)),
                                  ],
                                ],
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment:
                                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                    child: row,
                                  ),
                                  if (isLastCharacterMessage) ...[
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 38),
                                      child: Row(
                                        children: [
                                          _RoundIconButton(icon: Icons.edit_outlined, onTap: () => _editMessage(message)),
                                          const SizedBox(width: 8),
                                          _RoundIconButton(icon: Icons.refresh, onTap: () => _retryLastMessage(message)),
                                        ],
                                      ),
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
                  _buildInputBar(),
                ],
              ),
            ),
    );
  }

  Widget _buildInputBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          GestureDetector(
            onTap: _generating ? null : _showAttachmentSheet,
            child: Icon(Icons.add_circle_outline, color: _generating ? _textGhost : _textPrimary, size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(color: _pillGrey, borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _inputController,
                style: TextStyle(color: _textPrimary, fontSize: 14),
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 6,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: l10n.chatInputHint,
                  hintStyle: TextStyle(color: _mutedText, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _generating ? _cancelGeneration : () => _sendMessage(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: _bubblePurple, shape: BoxShape.circle),
              child: Icon(_generating ? Icons.stop_rounded : Icons.arrow_upward, color: _textPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// [AiGenerationCancelToken]과 동일한 아주 단순한 취소 신호. ai_chat_service.dart의
/// 클래스를 그대로 재사용해도 되지만, ZedTalk 쪽에서 독립적으로 두는 게 결합을 줄인다.
class AiGenerationCancelTokenLike {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

/// 메시지 리스트를 시간순으로 순회하며 만드는 렌더 단위. 날짜가 바뀌면 그 앞에
/// [divider] 항목이, 메시지 항목은 [message] + [showTime](그룹의 마지막 메시지인지)로 온다.
class _TalkRenderEntry {
  const _TalkRenderEntry._({this.dividerDate, this.message, this.showTime = false});

  factory _TalkRenderEntry.divider(DateTime date) => _TalkRenderEntry._(dividerDate: date);

  factory _TalkRenderEntry.message(TalkMessage message, bool showTime) =>
      _TalkRenderEntry._(message: message, showTime: showTime);

  final DateTime? dividerDate;
  final TalkMessage? message;
  final bool showTime;

  bool get isDivider => dividerDate != null;
}

class _DateDividerPill extends StatelessWidget {
  const _DateDividerPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: PaletteScope.of(context).textPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, color: PaletteScope.of(context).textMuted, size: 11),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(color: PaletteScope.of(context).textSecondary, fontSize: 11.5, fontWeight: FontWeight.w500)),
          ],
        ),
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: PaletteScope.of(context).surfaceAlt, shape: BoxShape.circle),
        child: Icon(icon, color: PaletteScope.of(context).textSecondary, size: 16),
      ),
    );
  }
}

/// 드로어 메뉴 한 줄. chat_screen.dart의 `_DrawerMenuItem`과 동일한 모양이다.
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
                  Text(title, style: TextStyle(color: PaletteScope.of(context).textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: TextStyle(color: PaletteScope.of(context).textFaint, fontSize: 12)),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(trailingText!, style: TextStyle(color: PaletteScope.of(context).textSecondary, fontSize: 13)),
              const SizedBox(width: 4),
            ],
            if (showChevron) Icon(Icons.chevron_right, color: PaletteScope.of(context).textFaint, size: 18),
          ],
        ),
      ),
    );
  }
}

/// 유저 말풍선을 길게 누르면(데스크톱은 우클릭) 뜨는 바텀시트의 항목 한 줄.
/// chat_screen.dart의 `_SheetActionTile`과 동일한 모양이다.
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
    final color = isDestructive ? PaletteScope.of(context).danger : PaletteScope.of(context).textPrimary;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: PaletteScope.of(context).surfaceAlt, borderRadius: BorderRadius.circular(12)),
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

class _TalkBubble extends StatelessWidget {
  const _TalkBubble({
    required this.text,
    required this.isUser,
    required this.bubbleColor,
    this.attachmentPath,
    this.attachmentType,
  });

  final String text;
  final bool isUser;
  final Color bubbleColor;
  final String? attachmentPath;
  final TalkAttachmentType? attachmentType;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (attachmentType == TalkAttachmentType.image && attachmentPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(attachmentPath!), width: 160, height: 160, fit: BoxFit.cover),
            )
          else if (attachmentPath != null)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: bubbleColor, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    attachmentType == TalkAttachmentType.video ? Icons.videocam_outlined : Icons.description_outlined,
                    color: PaletteScope.of(context).textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    attachmentPath!.split(Platform.pathSeparator).last,
                    style: TextStyle(color: PaletteScope.of(context).textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          if (text.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: bubbleColor, borderRadius: BorderRadius.circular(16)),
              child: Text(text, style: TextStyle(color: PaletteScope.of(context).textPrimary, fontSize: 14.5, height: 1.35)),
            ),
        ],
      ),
    );
  }
}

class _TalkTypingIndicator extends StatelessWidget {
  const _TalkTypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: PaletteScope.of(context).surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: PaletteScope.of(context).textMuted),
      ),
    );
  }
}
