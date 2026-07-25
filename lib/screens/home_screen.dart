import 'dart:io';

import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/plot_repository.dart';
import 'character_detail_screen.dart';
import 'conversation_tab.dart';
import 'create_tab.dart';
import 'my_page_tab.dart';

/// 메인 홈 화면.
/// 상단 콘테스트/랭킹 탭과 배너는 제거하고 'MicroZed' 타이틀로 대체했다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _background = Color(0xFF141414);

  final _tabs = const [
    _HomeTab(),
    ConversationTab(),
    CreateTab(),
    MyPageTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: _background,
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white38,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: '대화'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: '제작'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '마이페이지'),
      ],
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  late final PlotRepository _plotRepository;
  final _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';

  static const _cardColors = [
    Color(0xFF3B5A7A),
    Color(0xFF6B4A57),
    Color(0xFF2E5B6B),
    Color(0xFF6A4A2A),
    Color(0xFF3A3A3A),
    Color(0xFF2A4A5A),
  ];

  @override
  void initState() {
    super.initState();
    _plotRepository = PlotRepository(AppDatabase.instance);
  }

  Color _colorFor(int plotId) => _cardColors[plotId % _cardColors.length];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlotSummary> _filter(List<PlotSummary> plots) {
    if (_query.trim().isEmpty) return plots;
    final q = _query.trim().toLowerCase();
    return plots.where((p) {
      return p.plot.title.toLowerCase().contains(q) ||
          p.plot.description.toLowerCase().contains(q) ||
          p.plot.hashtags.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: StreamBuilder<List<PlotSummary>>(
            stream: _plotRepository.watchAll(),
            builder: (context, snapshot) {
              final plots = _filter(snapshot.data ?? const []);
              if (plots.isEmpty) {
                return Center(
                  child: Text(
                    _query.trim().isEmpty ? '아직 만든 플롯이 없어요' : '검색 결과가 없어요',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemCount: plots.length,
                itemBuilder: (context, index) {
                  final summary = plots[index];
                  return _CharacterCard(
                    data: summary,
                    color: _colorFor(summary.plot.id),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CharacterDetailScreen(
                            plotId: summary.plot.id,
                            heroColor: _colorFor(summary.plot.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: _searching
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: '플롯 제목, 소개, 해시태그 검색',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() {
                    _searching = false;
                    _query = '';
                    _searchController.clear();
                  }),
                  child: const Text('취소', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ],
            )
          : Row(
              children: [
                const Text(
                  'MicroZed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _searching = true),
                  child: const Icon(Icons.search, color: Colors.white, size: 24),
                ),
              ],
            ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.data, required this.color, required this.onTap});

  final PlotSummary data;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tags = data.plot.hashtags.split(',').where((t) => t.trim().isNotEmpty).map((t) => '#$t').join(' ');
    final shortIntro = data.plot.shortIntro;
    final subtitle = (shortIntro != null && shortIntro.isNotEmpty) ? shortIntro : data.plot.description;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            data.plot.coverImagePath != null
                ? Image.file(File(data.plot.coverImagePath!), fit: BoxFit.cover)
                : Container(color: color),
            Positioned(
              left: 8,
              top: 8,
              child: _ChatCountBadge(count: data.conversationCount),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.plot.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tags,
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatCountBadge extends StatelessWidget {
  const _ChatCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble, color: Colors.white70, size: 10),
          const SizedBox(width: 3),
          Text('$count', style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}
