import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/ai/ai_chat_service.dart';
import '../data/ai/message_format_parser.dart';
import '../data/ai/prompt_builder.dart';
import '../data/db/database.dart';
import '../data/repositories/ai_preset_repository.dart';
import '../data/repositories/character_repository.dart';
import '../data/repositories/chat_message_repository.dart';
import '../data/repositories/chat_session_repository.dart';
import '../data/repositories/chat_turn_repository.dart';
import '../data/repositories/conversation_profile_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../widgets/local_avatar.dart';
import '../widgets/start_fresh_dialog.dart';
import '../widgets/start_fresh_from_here_dialog.dart';
import 'ai_preset_screen.dart';
import 'conversation_profile_edit_screen.dart';
import 'resume_conversations_screen.dart';

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
  late final CharacterRepository _characterRepo;
  late final AiChatService _aiChatService;

  int? _plotId;
  String _plotTitle = '';
  int? _profileId;
  String _profileName = '유저';
  String? _profileImagePath;
  AiPreset? _selectedPreset;
  List<Character> _characters = const [];
  bool _loading = true;
  bool _generating = false;
  String _streamingText = '';

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
    _characterRepo = CharacterRepository(db);
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
    if (session.conversationProfileId != null) {
      final profile = await _profileRepo.getById(session.conversationProfileId!);
      if (profile != null) {
        _profileId = profile.id;
        _profileName = profile.name;
        _profileImagePath = profile.imagePath;
      }
    } else {
      // 예전에 만들어져 프로필이 안 붙어있는 세션은 기본 프로필로 채워서 앞으로는 '유저'로
      // 뜨지 않게 하고, 세션에도 그대로 저장해 다음부터는 바로 불러오게 한다.
      final defaultProfile = await _profileRepo.getDefault();
      if (defaultProfile != null) {
        _profileId = defaultProfile.id;
        _profileName = defaultProfile.name;
        _profileImagePath = defaultProfile.imagePath;
        await _sessionRepo.setConversationProfile(widget.sessionId, defaultProfile.id);
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
    await _messageRepo.send(sessionId: widget.sessionId, senderType: MessageSender.user, content: text);
    await _generateAiReply();
  }

  Future<void> _generateAiReply() async {
    await _withPreset((preset, plotId) => _aiChatService.generateReply(
          sessionId: widget.sessionId,
          plotId: plotId,
          preset: preset,
          userProfileName: _profileName,
          onDelta: _onDelta,
        ));
  }

  Future<void> _retryTurn(int turnId) async {
    await _withPreset((preset, plotId) => _aiChatService.retryReply(
          sessionId: widget.sessionId,
          plotId: plotId,
          preset: preset,
          userProfileName: _profileName,
          turnId: turnId,
          onDelta: _onDelta,
        ));
  }

  Future<void> _reviseTurn(int turnId, String instruction) async {
    await _withPreset((preset, plotId) => _aiChatService.reviseReply(
          sessionId: widget.sessionId,
          plotId: plotId,
          preset: preset,
          userProfileName: _profileName,
          turnId: turnId,
          instruction: instruction,
          onDelta: _onDelta,
        ));
  }

  void _onDelta(String accumulated) {
    if (mounted) setState(() => _streamingText = accumulated);
  }

  Future<void> _withPreset(Future<void> Function(AiPreset preset, int plotId) action) async {
    final preset = _selectedPreset;
    final plotId = _plotId;
    if (preset == null || plotId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI 프리셋을 먼저 선택해주세요')),
        );
      }
      return;
    }
    setState(() {
      _generating = true;
      _streamingText = '';
    });
    try {
      await action(preset, plotId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI 응답 생성에 실패했어요: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _generating = false;
          _streamingText = '';
        });
      }
    }
  }

  Future<void> _navigateVersion(ChatTurn turn, int delta, int versionCount) async {
    final newIndex = turn.activeVersionIndex + delta;
    if (newIndex < 0) return;
    if (newIndex >= versionCount) {
      await _retryTurn(turn.id);
      return;
    }
    await _turnRepo.setActiveVersion(turn.id, newIndex);
  }

  Future<void> _openReviseDialog(int turnId) async {
    final controller = TextEditingController();
    final instruction = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('AI 수정', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '어떻게 고칠지 알려주세요 (예: 더 짧게)',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF3A3A3A))),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _bubblePurple)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('수정하기', style: TextStyle(color: _bubblePurple)),
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
    final versionMessages = await _turnRepo.getVersionMessages(turn.id, turn.activeVersionIndex);
    final rawText = PromptBuilder.reconstructRawText(messages: versionMessages, characters: _characters);
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
                    onPressed: () => Navigator.of(dialogContext).pop(controller.text),
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

  /// AI 응답에 그대로 저장된 `{{user}}` 자리표시자를 지금 대화 프로필 이름으로 바꿔서
  /// 보여준다. 프로필을 나중에 바꿔도 예전 메시지가 그 이름으로 다시 렌더링된다.
  String _substituteUser(String content) => content.replaceAll('{{user}}', _profileName);

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
                  _buildDisclaimerBanner(),
                  Expanded(
                    child: StreamBuilder<List<ChatTimelineItem>>(
                      stream: _turnRepo.watchTimeline(widget.sessionId),
                      builder: (context, snapshot) {
                        final items = snapshot.data ?? const [];
                        final showPreview = _generating && _streamingText.isNotEmpty;
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: items.length + (showPreview ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= items.length) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _CharacterMessage(
                                  characterName: _characters.isNotEmpty ? _characters.first.name : 'AI',
                                  imagePath: _characters.isNotEmpty ? _characters.first.imagePath : null,
                                  message: _substituteUser(
                                    MessageFormatParser.stripSpeakerTagsForPreview(_streamingText),
                                  ),
                                ),
                              );
                            }
                            final item = items[index];
                            final message = item.message;
                            Widget bubble;
                            switch (message.senderType) {
                              case MessageSender.character:
                                final character = _findCharacter(message.characterId);
                                bubble = _CharacterMessage(
                                  characterName: character?.name ?? message.speakerNameOverride ?? '캐릭터',
                                  imagePath: character?.imagePath,
                                  message: _substituteUser(message.content),
                                );
                              case MessageSender.narrator:
                                bubble = _NarratorLine(text: _substituteUser(message.content));
                              case MessageSender.user:
                                bubble = _UserMessage(
                                  userName: _profileName,
                                  imagePath: _profileImagePath,
                                  message: message.content,
                                  onLongPress: () => _showUserMessageMenu(context, message),
                                );
                              case MessageSender.image:
                                bubble = _IntroImageLine(imagePath: message.content);
                            }
                            final isLastItem = index == items.length - 1 && !showPreview;
                            final showActions = isLastItem && item.isLastBubbleOfTurn && item.turn != null && !_generating;
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
                                      onEdit: () => _editTurn(item.turn!),
                                      onRevise: () => _openReviseDialog(item.turn!.id),
                                      onRetry: () => _retryTurn(item.turn!.id),
                                      onPrev: () => _navigateVersion(item.turn!, -1, item.versionCount),
                                      onNext: () => _navigateVersion(item.turn!, 1, item.versionCount),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        _plotTitle,
        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
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
                  _selectedPreset?.name ?? '프리셋 선택',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
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
              title: '새로하기',
              subtitle: '현재 내용을 저장하고 다시 시작할 수 있어요',
              onTap: () => _startFresh(context),
            ),
            _DrawerMenuItem(
              title: '이어하기',
              showChevron: true,
              onTap: () => _openResume(context),
            ),
            _DrawerMenuItem(
              title: '대화 삭제',
              onTap: () async {
                await _sessionRepo.delete(widget.sessionId);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            const Divider(color: Color(0xFF2A2A2A), height: 24),
            _DrawerMenuItem(
              title: '대화 프로필',
              trailingText: _profileName,
              showChevron: true,
              onTap: () {
                Navigator.of(context).pop();
                _showConversationProfileSheet(context);
              },
            ),
            _DrawerMenuItem(
              title: '선택지',
              trailingText: '사용 안함',
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
                color: const Color(0xFF262626),
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white70, size: 18),
                    SizedBox(width: 8),
                    Text('대화방 나가기', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0xFF1B1B1B),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.error_outline, color: _mutedText, size: 14),
          SizedBox(width: 6),
          Text(
            '답변은 모두 AI가 생성한 내용이에요',
            style: TextStyle(color: _mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: _background,
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Colors.white, size: 22),
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
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '내용 입력하기',
                  hintStyle: TextStyle(color: _mutedText, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: _bubblePurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showModelPresetSheet(BuildContext context) {
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
                const Text(
                  'AI 모델 선택',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '선택한 프리셋의 설정으로 대화가 진행돼요. 프리셋은 마이페이지에서 관리할 수 있어요.',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AiPresetScreen()),
                    );
                  },
                  child: const Row(
                    children: [
                      Text('프리셋 설정', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Icon(Icons.chevron_right, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<AiPreset>>(
                  stream: _presetRepo.watchAll(),
                  builder: (context, snapshot) {
                    final presets = snapshot.data ?? const [];
                    if (presets.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('아직 만든 프리셋이 없어요', style: TextStyle(color: Colors.white38, fontSize: 13)),
                      );
                    }
                    return Column(
                      children: presets.map((preset) {
                        final selected = preset.id == _selectedPreset?.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () async {
                              await _sessionRepo.setPreset(widget.sessionId, preset.id);
                              setState(() => _selectedPreset = preset);
                              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF262626),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected ? _bubblePurple : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (selected) const Icon(Icons.check, color: Colors.white, size: 20),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
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
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
                _SheetActionTile(
                  icon: Icons.restart_alt,
                  label: '여기서부터 새로하기',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _startFreshFromHere(context, message.id);
                  },
                ),
                const SizedBox(height: 8),
                _SheetActionTile(
                  icon: Icons.copy_outlined,
                  label: '복사',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Clipboard.setData(ClipboardData(text: message.content));
                  },
                ),
                const SizedBox(height: 8),
                _SheetActionTile(
                  icon: Icons.delete_outline,
                  label: '삭제',
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
        builder: (_) => ResumeConversationsScreen(plotId: plotId, currentSessionId: widget.sessionId),
      ),
    );
    if (resumedId == null || !context.mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(sessionId: resumedId)),
    );
  }

  void _showConversationProfileSheet(BuildContext context) {
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
                const Text(
                  '내 대화 프로필',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.white70, size: 20),
                        SizedBox(width: 12),
                        Text('대화 프로필 추가', style: TextStyle(color: Colors.white, fontSize: 14)),
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
                                _profileImagePath = profile.imagePath;
                              });
                              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                                            decoration: const BoxDecoration(
                                              color: _bubblePurple,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.check, color: Colors.white, size: 11),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      profile.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 18),
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
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(trailingText!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 4),
            ],
            if (showChevron) const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
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
      spans.add(TextSpan(
        text: match.group(1),
        style: style.copyWith(fontStyle: FontStyle.italic, color: style.color?.withValues(alpha: 0.7)),
      ));
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

/// 인트로 탭에서 첨부한 이미지 한 장. 관리용일 뿐 AI에게는 전달되지 않는다.
class _IntroImageLine extends StatelessWidget {
  const _IntroImageLine({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(imagePath), width: 160, height: 160, fit: BoxFit.cover),
      ),
    );
  }
}

class _NarratorLine extends StatelessWidget {
  const _NarratorLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Row(
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
/// 버전이 하나뿐이면 [수정/AI 수정/재시도], 재시도로 버전이 여러 개가 되면
/// [수정/AI 수정/이전<, 다음>]으로 바뀐다. '>'를 마지막 버전에서 누르면 새로 하나 더 생성한다.
class _TurnActionRow extends StatelessWidget {
  const _TurnActionRow({
    required this.versionCount,
    required this.onEdit,
    required this.onRevise,
    required this.onRetry,
    required this.onPrev,
    required this.onNext,
  });

  final int versionCount;
  final VoidCallback onEdit;
  final VoidCallback onRevise;
  final VoidCallback onRetry;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _RoundIconButton(icon: Icons.edit_outlined, onTap: onEdit),
          const SizedBox(width: 8),
          _RoundIconButton(icon: Icons.auto_fix_high, onTap: onRevise),
          const SizedBox(width: 8),
          if (versionCount <= 1)
            _RoundIconButton(icon: Icons.refresh, onTap: onRetry)
          else ...[
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
        decoration: const BoxDecoration(color: Color(0xFF262626), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white70, size: 16),
      ),
    );
  }
}
