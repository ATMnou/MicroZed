import 'package:flutter/material.dart';

import '../../data/db/database.dart';
import '../../data/repositories/character_repository.dart';
import '../../data/repositories/plot_repository.dart';
import '../../data/theme/color_palette.dart';
import '../../data/theme/palette_scope.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/local_avatar.dart';
import 'chess/chess_game_screen.dart';
import 'liars_bar/liars_bar_game_screen.dart';
import 'omok/omok_game_screen.dart';
import 'uno/uno_game_screen.dart';

/// 게임 시작 전, 1:1로 겨룰 상대 캐릭터(전 플롯 통틀어)를 고르는 화면. 체스/오목은 위쪽에
/// 난이도 세그먼트도 함께 보여준다(우노/라이어스바는 난이도 설정이 없다).
class GameOpponentPickerScreen extends StatefulWidget {
  const GameOpponentPickerScreen({super.key, required this.gameType, required this.hasDifficulty});

  final GameType gameType;
  final bool hasDifficulty;

  @override
  State<GameOpponentPickerScreen> createState() => _GameOpponentPickerScreenState();
}

class _GameOpponentPickerScreenState extends State<GameOpponentPickerScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  late final CharacterRepository _characterRepo;
  late final PlotRepository _plotRepo;

  bool _loading = true;
  List<Character> _characters = const [];
  Map<int, String> _plotTitleById = const {};
  GameDifficulty _difficulty = GameDifficulty.medium;
  bool _useLlmMoves = false;
  bool _speakEveryMove = false;

  @override
  void initState() {
    super.initState();
    _characterRepo = CharacterRepository(AppDatabase.instance);
    _plotRepo = PlotRepository(AppDatabase.instance);
    _load();
  }

  Future<void> _load() async {
    final characters = await _characterRepo.getAll();
    final plotIds = characters.map((c) => c.plotId).toSet();
    final titles = <int, String>{};
    for (final id in plotIds) {
      final plot = await _plotRepo.getById(id);
      if (plot != null) titles[id] = plot.title;
    }
    if (!mounted) return;
    setState(() {
      _characters = characters;
      _plotTitleById = titles;
      _loading = false;
    });
  }

  void _startGame(Character opponent) {
    final difficulty = widget.hasDifficulty ? _difficulty : null;
    final Widget screen = switch (widget.gameType) {
      GameType.chess => ChessGameScreen(
          opponent: opponent,
          difficulty: difficulty ?? GameDifficulty.medium,
          useLlmMoves: _useLlmMoves,
          speakEveryMove: _speakEveryMove,
        ),
      GameType.omok => OmokGameScreen(
          opponent: opponent,
          difficulty: difficulty ?? GameDifficulty.medium,
          useLlmMoves: _useLlmMoves,
          speakEveryMove: _speakEveryMove,
        ),
      GameType.uno => UnoGameScreen(opponent: opponent, useLlmMoves: _useLlmMoves, speakEveryMove: _speakEveryMove),
      GameType.liarsBar =>
        LiarsBarGameScreen(opponent: opponent, useLlmMoves: _useLlmMoves, speakEveryMove: _speakEveryMove),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
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
          l10n.gameOpponentPickerTitle,
          style: TextStyle(color: p.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: p.primary))
          : Column(
              children: [
                if (widget.hasDifficulty) _buildDifficultySelector(l10n, p),
                _buildOptionToggles(l10n, p),
                Expanded(
                  child: _characters.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.gameOpponentPickerEmptyMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: p.textFaint, fontSize: 13),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _characters.length,
                          itemBuilder: (context, index) {
                            final character = _characters[index];
                            final plotTitle = _plotTitleById[character.plotId];
                            return InkWell(
                              onTap: () => _startGame(character),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    LocalAvatar(imagePath: character.imagePath, radius: 22, icon: Icons.pets),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            character.name,
                                            style: TextStyle(
                                              color: p.textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (plotTitle != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              plotTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: p.textFaint, fontSize: 11),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: p.textFaint, size: 18),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildDifficultySelector(AppLocalizations l10n, ColorPalette p) {
    final options = <(GameDifficulty, String)>[
      (GameDifficulty.easy, l10n.vnEditDifficultyEasy),
      (GameDifficulty.medium, l10n.vnEditDifficultyMedium),
      (GameDifficulty.hard, l10n.vnEditDifficultyHard),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.gameOpponentPickerDifficultyLabel,
            style: TextStyle(color: p.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final option in options) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _difficulty = option.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _difficulty == option.$1 ? p.primary : p.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        option.$2,
                        style: TextStyle(
                          color: _difficulty == option.$1 ? p.onPrimary : p.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildOptionToggles(AppLocalizations l10n, ColorPalette p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          _buildToggleRow(
            title: l10n.gameOpponentPickerUseLlmLabel,
            description: l10n.gameOpponentPickerUseLlmDescription,
            value: _useLlmMoves,
            onChanged: (v) => setState(() => _useLlmMoves = v),
            p: p,
          ),
          const SizedBox(height: 8),
          _buildToggleRow(
            title: l10n.gameOpponentPickerSpeakEveryMoveLabel,
            description: l10n.gameOpponentPickerSpeakEveryMoveDescription,
            value: _speakEveryMove,
            onChanged: (v) => setState(() => _speakEveryMove = v),
            p: p,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorPalette p,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: p.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(color: p.textFaint, fontSize: 11)),
              ],
            ),
          ),
          Switch(value: value, activeTrackColor: p.primary, onChanged: onChanged),
        ],
      ),
    );
  }
}
