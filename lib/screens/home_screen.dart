import 'dart:io';

import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/plot_repository.dart';
import '../l10n/app_localizations.dart';
import 'character_detail_screen.dart';
import 'conversation_tab.dart';
import 'create_tab.dart';
import 'my_page_tab.dart';
import 'vn_player_screen.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 메인 홈 화면.
/// 상단 콘테스트/랭킹 탭과 배너는 제거하고 'MicroZed' 타이틀로 대체했다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _tabs = const [
    _HomeTab(),
    ConversationTab(),
    CreateTab(),
    MyPageTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, background),
    );
  }

  Widget _buildBottomNav(BuildContext context, Color background) {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return BottomNavigationBar(
      backgroundColor: background,
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: onSurface,
      unselectedItemColor: onSurface.withValues(alpha: 0.38),
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.navHome),
        BottomNavigationBarItem(icon: const Icon(Icons.chat_bubble_outline), label: l10n.navChat),
        BottomNavigationBarItem(icon: const Icon(Icons.add_circle_outline), label: l10n.navCreate),
        BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: l10n.navMyPage),
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
  ColorPalette get _p => PaletteScope.of(context);
  Color get _borderGrey => _p.border;
  Color get _textFaint => _p.textFaint;
  Color get _textPrimary => _p.textPrimary;
  Color get _cardBg => _p.surface;
  Color get _textSecondary => _p.textSecondary;
  late final PlotRepository _plotRepository;
  final _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';

  List<Color> get _cardColors => [
    const Color(0xFF3B5A7A),
    const Color(0xFF6B4A57),
    const Color(0xFF2E5B6B),
    const Color(0xFF6A4A2A),
    _borderGrey,
    const Color(0xFF2A4A5A),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: StreamBuilder<List<PlotSummary>>(
            stream: _plotRepository.watchAll(),
            builder: (context, snapshot) {
              final plots = _filter(snapshot.data ?? const []);
              if (plots.isEmpty) {
                return Center(
                  child: Text(
                    _query.trim().isEmpty ? l10n.homeNoPlotsYet : l10n.commonNoSearchResults,
                    style: TextStyle(color: _textFaint, fontSize: 13),
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
                          builder: (_) => summary.plot.plotType == PlotType.visualNovel
                              ? VnPlayerScreen(plotId: summary.plot.id)
                              : CharacterDetailScreen(
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

  Widget _buildTopBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: _searching
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: _textPrimary, fontSize: 14),
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: l10n.searchHintPlot,
                      hintStyle: TextStyle(color: _textFaint, fontSize: 13),
                      filled: true,
                      fillColor: _cardBg,
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
                  child: Text(l10n.commonCancel, style: TextStyle(color: _textSecondary, fontSize: 14)),
                ),
              ],
            )
          : Row(
              children: [
                Text(
                  'MicroZed',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _searching = true),
                  child: Icon(Icons.search, color: _textPrimary, size: 24),
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
                      style: TextStyle(
                        color: PaletteScope.of(context).textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: PaletteScope.of(context).textSecondary, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tags,
                        style: TextStyle(color: PaletteScope.of(context).textFaint, fontSize: 11),
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
          Icon(Icons.chat_bubble, color: PaletteScope.of(context).textSecondary, size: 10),
          const SizedBox(width: 3),
          Text('$count', style: TextStyle(color: PaletteScope.of(context).textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}
