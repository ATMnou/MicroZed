import 'package:flutter/material.dart';

import '../../data/db/database.dart';
import '../../data/repositories/game_result_repository.dart';
import '../../data/theme/color_palette.dart';
import '../../data/theme/palette_scope.dart';
import '../../l10n/app_localizations.dart';
import 'game_opponent_picker_screen.dart';

/// 홈 > 게임 진입점. 체스/오목/우노/라이어스바 4종을 타일로 보여주고, 각 타일을 누르면
/// 상대 캐릭터(+체스/오목은 난이도) 선택 화면으로 이동한다.
class GamesHomeScreen extends StatefulWidget {
  const GamesHomeScreen({super.key});

  @override
  State<GamesHomeScreen> createState() => _GamesHomeScreenState();
}

class _GamesHomeScreenState extends State<GamesHomeScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  late final GameResultRepository _resultRepo;

  @override
  void initState() {
    super.initState();
    _resultRepo = GameResultRepository(AppDatabase.instance);
  }

  static const _tiles = [
    (
      type: GameType.chess,
      icon: Icons.castle,
      titleKey: 'chess',
      hasDifficulty: true,
    ),
    (
      type: GameType.omok,
      icon: Icons.grid_4x4,
      titleKey: 'omok',
      hasDifficulty: true,
    ),
    (
      type: GameType.uno,
      icon: Icons.style,
      titleKey: 'uno',
      hasDifficulty: false,
    ),
    (
      type: GameType.liarsBar,
      icon: Icons.local_bar,
      titleKey: 'liarsBar',
      hasDifficulty: false,
    ),
  ];

  ({String title, String subtitle}) _labelsFor(AppLocalizations l10n, GameType type) {
    switch (type) {
      case GameType.chess:
        return (title: l10n.gamesHomeChessTitle, subtitle: l10n.gamesHomeChessSubtitle);
      case GameType.omok:
        return (title: l10n.gamesHomeOmokTitle, subtitle: l10n.gamesHomeOmokSubtitle);
      case GameType.uno:
        return (title: l10n.gamesHomeUnoTitle, subtitle: l10n.gamesHomeUnoSubtitle);
      case GameType.liarsBar:
        return (title: l10n.gamesHomeLiarsBarTitle, subtitle: l10n.gamesHomeLiarsBarSubtitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = _p;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: p.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          l10n.gamesHomeTitle,
          style: TextStyle(color: p.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: StreamBuilder<List<GameSummary>>(
        stream: _resultRepo.watchSummary(),
        builder: (context, snapshot) {
          final summaries = {for (final s in snapshot.data ?? const <GameSummary>[]) s.gameType: s};
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.92,
            ),
            itemCount: _tiles.length,
            itemBuilder: (context, index) {
              final tile = _tiles[index];
              final labels = _labelsFor(l10n, tile.type);
              final summary = summaries[tile.type];
              return _GameTile(
                icon: tile.icon,
                title: labels.title,
                subtitle: labels.subtitle,
                recordLabel: (summary == null || summary.total == 0)
                    ? l10n.gamesHomeNoRecord
                    : l10n.gamesHomeRecordSummary(summary.wins, summary.losses, summary.draws),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GameOpponentPickerScreen(gameType: tile.type, hasDifficulty: tile.hasDifficulty),
                  ),
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.recordLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String recordLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: p.primary, size: 24),
            ),
            const Spacer(),
            Text(title, style: TextStyle(color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: p.textSecondary, fontSize: 12, height: 1.3),
            ),
            const SizedBox(height: 8),
            Text(recordLabel, style: TextStyle(color: p.textFaint, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
