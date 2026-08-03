import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/ai/talk_chat_service.dart';
import '../data/db/database.dart';
import '../data/local_image_store.dart';
import '../data/repositories/ai_preset_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../data/repositories/talk_message_repository.dart';
import '../data/repositories/talk_session_repository.dart';
import '../l10n/app_localizations.dart';
import '../widgets/local_avatar.dart';

/// ZedTalk 대화 화면. 롤플레이용 ChatScreen과 시각적으로는 비슷하지만(같은 버블/입력바
/// 배색), 턴/버전/재시도/인트로 같은 롤플레이 전용 기능은 전부 빠지고 단순한 메신저형
/// 주고받기만 남긴 별도 화면이다.
class TalkChatScreen extends StatefulWidget {
  const TalkChatScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<TalkChatScreen> createState() => _TalkChatScreenState();
}

class _TalkChatScreenState extends State<TalkChatScreen> {
  static const _background = Color(0xFF141414);
  static const _bubbleGrey = Color(0xFF2A2A2A);
  static const _bubblePurple = Color(0xFF7A6FF0);
  static const _pillGrey = Color(0xFF262626);
  static const _mutedText = Color(0xFF9A9A9A);

  late final TalkSessionRepository _sessionRepo;
  late final TalkMessageRepository _messageRepo;
  late final AiPresetRepository _presetRepo;
  late final PlotRepository _plotRepo;
  final _talkChatService = TalkChatService();
  final _imageStore = LocalImageStore();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  bool _loading = true;
  Character? _character;
  String _plotTitle = '';
  AiPreset? _selectedPreset;
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
    _load();
  }

  Future<void> _load() async {
    final session = await _sessionRepo.getById(widget.sessionId);
    if (session == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final plot = await _plotRepo.getById(session.plotId);
    final character = await _plotRepo.representativeCharacter(session.plotId);
    AiPreset? preset;
    if (session.presetId != null) {
      preset = await _presetRepo.getById(session.presetId!);
    }
    if (!mounted) return;
    setState(() {
      _plotTitle = plot?.title ?? '';
      _character = character;
      _selectedPreset = preset;
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
      backgroundColor: const Color(0xFF1E1E1E),
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
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              ...presets.map((preset) => ListTile(
                    title: Text(preset.name, style: const TextStyle(color: Colors.white)),
                    trailing: _selectedPreset?.id == preset.id ? const Icon(Icons.check, color: _bubblePurple) : null,
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
        userProfileName: '나',
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
      backgroundColor: const Color(0xFF1E1E1E),
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
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined, color: Colors.white),
                title: Text(l10n.talkAttachmentImageOption, style: const TextStyle(color: Colors.white)),
                onTap: () => Navigator.of(sheetContext).pop('image'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined, color: Colors.white),
                title: Text(l10n.talkAttachmentVideoOption, style: const TextStyle(color: Colors.white)),
                onTap: () => Navigator.of(sheetContext).pop('video'),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined, color: Colors.white),
                title: Text(l10n.talkAttachmentDocumentOption, style: const TextStyle(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
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
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _selectedPreset?.name ?? l10n.talkNoPresetMessage,
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _bubblePurple))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<TalkMessage>>(
                      stream: _messageRepo.watchBySession(widget.sessionId),
                      builder: (context, snapshot) {
                        final messages = snapshot.data ?? const [];
                        final showTyping = _generating && _streamingText.isEmpty;
                        final showPreview = _generating && _streamingText.isNotEmpty;
                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: messages.length + (showTyping || showPreview ? 1 : 0),
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
                            final index =
                                messages.length - 1 - (reversedIndex - (showTyping || showPreview ? 1 : 0));
                            final message = messages[index];
                            final isUser = message.sender == TalkMessageSender.user;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Align(
                                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                child: _TalkBubble(
                                  text: message.content,
                                  isUser: isUser,
                                  bubbleColor: isUser ? _bubblePurple : _bubbleGrey,
                                  attachmentPath: message.attachmentPath,
                                  attachmentType: message.attachmentType,
                                ),
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
      color: _background,
      child: Row(
        children: [
          GestureDetector(
            onTap: _generating ? null : _showAttachmentSheet,
            child: Icon(Icons.add_circle_outline, color: _generating ? Colors.white24 : Colors.white, size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(color: _pillGrey, borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _inputController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: l10n.chatInputHint,
                  hintStyle: const TextStyle(color: _mutedText, fontSize: 14),
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
              decoration: const BoxDecoration(color: _bubblePurple, shape: BoxShape.circle),
              child: Icon(_generating ? Icons.stop_rounded : Icons.arrow_upward, color: Colors.white, size: 20),
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
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    attachmentPath!.split(Platform.pathSeparator).last,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          if (text.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: bubbleColor, borderRadius: BorderRadius.circular(16)),
              child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14.5, height: 1.35)),
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
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
      ),
    );
  }
}
