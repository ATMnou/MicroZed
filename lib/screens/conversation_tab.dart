import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/chat_session_repository.dart';
import '../widgets/local_avatar.dart';
import 'chat_screen.dart';

/// '대화' 탭 화면.
/// 대화방 목록을 로컬 DB(Drift)에서 스트리밍하며, 항목을 누르면 해당 세션의 대화 화면으로 이동한다.
class ConversationTab extends StatefulWidget {
  const ConversationTab({super.key});

  @override
  State<ConversationTab> createState() => _ConversationTabState();
}

class _ConversationTabState extends State<ConversationTab> {
  late final ChatSessionRepository _sessionRepository;

  @override
  void initState() {
    super.initState();
    _sessionRepository = ChatSessionRepository(AppDatabase.instance);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: StreamBuilder<List<ChatSessionSummary>>(
            stream: _sessionRepository.watchAll(),
            builder: (context, snapshot) {
              final sessions = snapshot.data ?? const [];
              if (sessions.isEmpty) {
                return const Center(
                  child: Text('아직 진행 중인 대화가 없어요', style: TextStyle(color: Colors.white38, fontSize: 13)),
                );
              }
              return ListView(
                children: [
                  _buildSortRow(),
                  ...sessions.map((s) => _ConversationTile(data: s)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const Text(
            '대화',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Icon(Icons.manage_search, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
        ],
      ),
    );
  }

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: const [
          Text('최신순', style: TextStyle(color: Colors.white70, fontSize: 13)),
          Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.data});

  final ChatSessionSummary data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChatScreen(sessionId: data.session.id)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocalAvatar(imagePath: data.plotCoverImagePath, radius: 22, icon: Icons.person),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          data.plotTitle,
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
                      if (data.session.pinned)
                        const Icon(Icons.push_pin, color: Colors.white38, size: 13),
                      if (data.session.locked)
                        const Icon(Icons.lock_outline, color: Colors.white38, size: 13),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.lastMessagePreview.isEmpty ? '대화를 시작해보세요' : data.lastMessagePreview,
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
