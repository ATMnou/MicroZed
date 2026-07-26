import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/chat_session_repository.dart';
import '../l10n/app_localizations.dart';

/// 채팅 화면 드로어의 '이어하기'에서 진입하는, 저장된(보관된) 대화 목록 화면.
class ResumeConversationsScreen extends StatefulWidget {
  const ResumeConversationsScreen({
    super.key,
    required this.plotId,
    required this.currentSessionId,
  });

  final int plotId;
  final int currentSessionId;

  @override
  State<ResumeConversationsScreen> createState() => _ResumeConversationsScreenState();
}

class _ResumeConversationsScreenState extends State<ResumeConversationsScreen> {
  late final ChatSessionRepository _repository;

  static const _background = Color(0xFF141414);

  @override
  void initState() {
    super.initState();
    _repository = ChatSessionRepository(AppDatabase.instance);
  }

  Future<void> _resume(ChatSessionSummary summary) async {
    final resumedId = await _repository.resume(
      currentSessionId: widget.currentSessionId,
      archivedSessionId: summary.session.id,
    );
    if (!mounted) return;
    Navigator.of(context).pop(resumedId);
  }

  Future<void> _delete(int sessionId) => _repository.delete(sessionId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.of(context)!.chatDrawerResumeTitle, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<List<ChatSessionSummary>>(
        stream: _repository.watchArchivedByPlot(widget.plotId),
        builder: (context, snapshot) {
          final sessions = snapshot.data ?? const [];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('${sessions.length}/100', style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              Expanded(
                child: sessions.isEmpty
                    ? Center(
                        child: Text(AppLocalizations.of(context)!.resumeNoSavedConversations, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                      )
                    : ListView.separated(
                        itemCount: sessions.length,
                        separatorBuilder: (_, _) => const Divider(color: Color(0xFF2A2A2A), height: 1),
                        itemBuilder: (context, index) => _SavedConversationTile(
                          data: sessions[index],
                          onTap: () => _resume(sessions[index]),
                          onDelete: () => _delete(sessions[index].session.id),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');

String _formatSavedAt(DateTime dt) {
  return '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)} ${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';
}

String _relativeLabel(AppLocalizations l10n, DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return l10n.resumeJustNow;
  if (diff.inHours < 1) return l10n.resumeMinutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return l10n.resumeHoursAgo(diff.inHours);
  if (diff.inDays < 30) return l10n.resumeDaysAgo(diff.inDays);
  final year = dt.year.toString().substring(2);
  return '$year/${_twoDigits(dt.month)}/${_twoDigits(dt.day)}';
}

class _SavedConversationTile extends StatelessWidget {
  const _SavedConversationTile({required this.data, required this.onTap, required this.onDelete});

  final ChatSessionSummary data;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  void _showOptionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.white),
                title: Text(l10n.commonDelete, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final archivedAt = data.session.archivedAt ?? data.session.updatedAt;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.resumeSavedAtLabel(_formatSavedAt(archivedAt)),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_relativeLabel(l10n, archivedAt)} | ${data.lastMessagePreview.isEmpty ? l10n.resumeNoSavedMessage : data.lastMessagePreview}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showOptionsMenu(context),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.more_vert, color: Colors.white38, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
