import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/chat_session_repository.dart';
import '../data/repositories/talk_session_repository.dart';
import '../l10n/app_localizations.dart';
import '../widgets/local_avatar.dart';
import 'chat_screen.dart';
import 'talk_chat_screen.dart';

/// '대화' 탭 화면. 상단이 '대화'(롤플레이)/'톡'(ZedTalk) 두 버튼으로 나뉘어 있고, 각각
/// 서로 다른 세션 목록(ChatSessions/TalkSessions)을 로컬 DB에서 스트리밍한다.
class ConversationTab extends StatefulWidget {
  const ConversationTab({super.key});

  @override
  State<ConversationTab> createState() => _ConversationTabState();
}

class _ConversationTabState extends State<ConversationTab> {
  late final ChatSessionRepository _sessionRepository;
  late final TalkSessionRepository _talkSessionRepository;

  /// 0 = 대화(롤플레이), 1 = 톡(ZedTalk).
  int _activeTab = 0;

  /// 톱니바퀴로 진입하는 다중 선택(체크박스) 삭제 모드. 탭을 넘어가면 항상 초기화한다.
  bool _selecting = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _sessionRepository = ChatSessionRepository(AppDatabase.instance);
    _talkSessionRepository = TalkSessionRepository(AppDatabase.instance);
  }

  void _switchTab(int tab) {
    setState(() {
      _activeTab = tab;
      _selecting = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelecting() {
    setState(() {
      _selecting = !_selecting;
      _selectedIds.clear();
    });
  }

  void _toggleSelected(int sessionId) {
    setState(() {
      if (!_selectedIds.add(sessionId)) _selectedIds.remove(sessionId);
    });
  }

  Future<void> _confirmDeleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final isTalk = _activeTab == 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          isTalk ? l10n.talkDeleteConfirmTitle : l10n.conversationTabDeleteConfirmTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isTalk ? l10n.talkDeleteConfirmContent : l10n.conversationTabDeleteConfirmContent,
          style: const TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonDelete, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (isTalk) {
      await _talkSessionRepository.deleteMany(_selectedIds);
    } else {
      await _sessionRepository.deleteMany(_selectedIds);
    }
    if (!mounted) return;
    setState(() {
      _selecting = false;
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: _activeTab == 0
              ? StreamBuilder<List<ChatSessionSummary>>(
                  stream: _sessionRepository.watchAll(),
                  builder: (context, snapshot) {
                    final sessions = snapshot.data ?? const [];
                    if (sessions.isEmpty) {
                      return Center(
                        child: Text(l10n.conversationTabEmpty, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                      );
                    }
                    return ListView(
                      children: sessions
                          .map((s) => _ConversationTile(
                                title: s.plotTitle,
                                subtitle: s.lastMessagePreview.isEmpty
                                    ? l10n.conversationTilePlaceholder
                                    : s.lastMessagePreview,
                                imagePath: s.plotCoverImagePath,
                                pinned: s.session.pinned,
                                locked: s.session.locked,
                                selecting: _selecting,
                                selected: _selectedIds.contains(s.session.id),
                                onToggleSelected: () => _toggleSelected(s.session.id),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ChatScreen(sessionId: s.session.id)),
                                ),
                              ))
                          .toList(),
                    );
                  },
                )
              : StreamBuilder<List<TalkSessionSummary>>(
                  stream: _talkSessionRepository.watchAll(),
                  builder: (context, snapshot) {
                    final sessions = snapshot.data ?? const [];
                    if (sessions.isEmpty) {
                      return Center(
                        child: Text(l10n.talkListEmpty, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                      );
                    }
                    return ListView(
                      children: sessions
                          .map((s) => _ConversationTile(
                                title: s.plotTitle,
                                subtitle: s.lastMessagePreview.isEmpty
                                    ? l10n.conversationTilePlaceholder
                                    : s.lastMessagePreview,
                                imagePath: s.plotCoverImagePath,
                                pinned: s.session.pinned,
                                locked: false,
                                selecting: _selecting,
                                selected: _selectedIds.contains(s.session.id),
                                onToggleSelected: () => _toggleSelected(s.session.id),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => TalkChatScreen(sessionId: s.session.id)),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_selecting) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Text(
              l10n.conversationTabSelectedCount(_selectedIds.length),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            IconButton(
              onPressed: _selectedIds.isEmpty ? null : _confirmDeleteSelected,
              icon: Icon(
                Icons.delete_outline,
                color: _selectedIds.isEmpty ? Colors.white24 : Colors.redAccent,
                size: 22,
              ),
            ),
            IconButton(
              onPressed: _toggleSelecting,
              icon: const Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _switchTab(0),
            child: Text(
              l10n.conversationTabTitle,
              style: TextStyle(
                color: _activeTab == 0 ? Colors.white : Colors.white38,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _switchTab(1),
            child: Text(
              l10n.conversationTabTalkLabel,
              style: TextStyle(
                color: _activeTab == 1 ? Colors.white : Colors.white38,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          const Icon(Icons.manage_search, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _toggleSelecting,
            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.pinned,
    required this.locked,
    required this.selecting,
    required this.selected,
    required this.onToggleSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String? imagePath;
  final bool pinned;
  final bool locked;
  final bool selecting;
  final bool selected;
  final VoidCallback onToggleSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selecting ? onToggleSelected : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selecting) ...[
              Checkbox(
                value: selected,
                onChanged: (_) => onToggleSelected(),
                activeColor: const Color(0xFF7A6FF0),
              ),
              const SizedBox(width: 4),
            ],
            LocalAvatar(imagePath: imagePath, radius: 22, icon: Icons.person),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (pinned) const Icon(Icons.push_pin, color: Colors.white38, size: 13),
                      if (locked) const Icon(Icons.lock_outline, color: Colors.white38, size: 13),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
