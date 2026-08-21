import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/ai/ai_chat_service.dart';
import '../../../data/db/database.dart';
import '../../../data/games/game_flavor_dialogue.dart';
import '../../../data/games/game_llm_choice.dart';
import '../../../data/games/uno/uno_engine.dart';
import '../../../data/games/uno/uno_models.dart';
import '../../../data/repositories/ai_preset_repository.dart';
import '../../../data/repositories/game_result_repository.dart';
import '../../../data/theme/palette_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../game_widgets.dart';

class UnoGameScreen extends StatefulWidget {
  const UnoGameScreen({super.key, required this.opponent, this.useLlmMoves = false, this.speakEveryMove = false});

  final Character opponent;
  final bool useLlmMoves;
  final bool speakEveryMove;

  @override
  State<UnoGameScreen> createState() => _UnoGameScreenState();
}

class _UnoGameScreenState extends State<UnoGameScreen> {
  late UnoEngine _engine;
  final _llmAi = UnoLlmAi();
  late final GameResultRepository _resultRepo;
  late final GameFlavorDialogue _flavor;
  late final GameLlmChoice _llmChoice;
  late final AiPresetRepository _presetRepo;
  bool _aiThinking = false;
  String? _opponentLine;
  bool _resultRecorded = false;

  @override
  void initState() {
    super.initState();
    _resultRepo = GameResultRepository(AppDatabase.instance);
    _presetRepo = AiPresetRepository(AppDatabase.instance);
    final aiChatService = AiChatService(db: AppDatabase.instance);
    _flavor = GameFlavorDialogue(aiChatService: aiChatService);
    _llmChoice = GameLlmChoice(aiChatService: aiChatService);
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _engine = UnoEngine();
      _aiThinking = false;
      _opponentLine = null;
      _resultRecorded = false;
    });
  }

  Future<void> _maybeSpeak(String situationKo) async {
    final preset = await _presetRepo.getDefault();
    final line = await _flavor.requestLine(preset: preset, character: widget.opponent, situationKo: situationKo);
    if (!mounted || line == null) return;
    setState(() => _opponentLine = line);
  }

  Future<void> _onPlayCard(UnoCard card) async {
    if (_engine.gameOver || _aiThinking || _engine.turn != UnoPlayer.user || !_engine.isPlayable(card)) return;
    UnoColor? chosenColor;
    if (unoValueIsWild(card.value)) {
      chosenColor = await _pickColor();
      if (chosenColor == null) return;
    }
    setState(() => _engine.playCard(UnoPlayer.user, card, chosenColor: chosenColor));
    await _afterMove();
  }

  Future<void> _onDrawTap() async {
    if (_engine.gameOver || _aiThinking || _engine.turn != UnoPlayer.user) return;
    final drawn = _engine.drawCard(UnoPlayer.user);
    setState(() {});
    if (_engine.isPlayable(drawn)) return; // 낸 카드가 즉시 낼 수 있으면 이어서 선택하게 둔다.
    setState(() => _engine.turn = UnoPlayer.opponent);
    await _afterMove();
  }

  Future<void> _afterMove() async {
    if (_engine.gameOver) {
      _onGameOver();
      return;
    }
    if (_engine.userHand.length == 1) unawaited(_maybeSpeak('상대가 UNO를 외쳤다'));
    if (_engine.turn == UnoPlayer.opponent) {
      await _runAiTurn();
    }
  }

  Future<({UnoCard card, UnoColor? color})?> _chooseAiPlay() async {
    if (!widget.useLlmMoves) return _engine.chooseAiPlay();
    final preset = await _presetRepo.getDefault();
    return _llmAi.chooseMove(engine: _engine, llmChoice: _llmChoice, preset: preset, character: widget.opponent);
  }

  Future<void> _runAiTurn() async {
    setState(() => _aiThinking = true);
    final choiceFuture = _chooseAiPlay();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final choice = await choiceFuture;
    var played = choice;
    if (choice == null) {
      final drawn = _engine.drawCard(UnoPlayer.opponent);
      if (_engine.isPlayable(drawn)) {
        // 뽑은 카드를 바로 낼 수 있으면 짧은 텀을 두고 이어서 낸다.
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        final again = await _chooseAiPlay();
        played = again;
        if (again != null) {
          setState(() => _engine.playCard(UnoPlayer.opponent, again.card, chosenColor: again.color));
        } else {
          setState(() => _engine.turn = UnoPlayer.user);
        }
      } else {
        setState(() => _engine.turn = UnoPlayer.user);
      }
    } else {
      setState(() => _engine.playCard(UnoPlayer.opponent, choice.card, chosenColor: choice.color));
    }
    setState(() => _aiThinking = false);
    if (_engine.gameOver) {
      _onGameOver();
    } else if (_engine.opponentHand.length == 1) {
      unawaited(_maybeSpeak('내 손패가 한 장 남아서 UNO를 외친다'));
    } else if (widget.speakEveryMove && played != null) {
      unawaited(_maybeSpeak('방금 ${played.card.label} 카드를 냈다'));
    }
    if (!_engine.gameOver && _engine.turn == UnoPlayer.opponent) {
      await _runAiTurn();
    }
  }

  Future<UnoColor?> _pickColor() {
    final l10n = AppLocalizations.of(context)!;
    final p = PaletteScope.of(context);
    return showModalBottomSheet<UnoColor>(
      context: context,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.unoChooseColorTitle, style: TextStyle(color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final c in [UnoColor.red, UnoColor.yellow, UnoColor.green, UnoColor.blue])
                      GestureDetector(
                        onTap: () => Navigator.of(sheetContext).pop(c),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: unoColorValue(c), shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onGameOver() {
    final outcome = switch (_engine.winner) {
      UnoPlayer.user => GameEndOutcome.win,
      UnoPlayer.opponent => GameEndOutcome.loss,
      null => GameEndOutcome.draw,
    };
    _recordResult(outcome);
    unawaited(_maybeSpeak(outcome == GameEndOutcome.win ? '내가 졌다' : '내가 이겼다'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGameEndSheet(context, outcome: outcome, onPlayAgain: _resetGame);
    });
  }

  Future<void> _recordResult(GameEndOutcome outcome) async {
    if (_resultRecorded) return;
    _resultRecorded = true;
    await _resultRepo.record(
      gameType: GameType.uno,
      opponentCharacterId: widget.opponent.id,
      outcome: switch (outcome) {
        GameEndOutcome.win => GameOutcome.win,
        GameEndOutcome.loss => GameOutcome.loss,
        GameEndOutcome.draw => GameOutcome.draw,
      },
    );
  }

  Future<void> _confirmResign() async {
    final l10n = AppLocalizations.of(context)!;
    final p = PaletteScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: p.surface,
        content: Text(l10n.gameResignConfirmMessage, style: TextStyle(color: p.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.gameResignButton, style: TextStyle(color: p.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() {
        _engine.gameOver = true;
        _engine.winner = UnoPlayer.opponent;
      });
      _onGameOver();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = PaletteScope.of(context);
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: p.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l10n.gamesHomeUnoTitle, style: TextStyle(color: p.textPrimary, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.flag_outlined, color: p.textSecondary, size: 20),
            tooltip: l10n.gameResignButton,
            onPressed: _confirmResign,
          ),
        ],
      ),
      body: Column(
        children: [
          OpponentBanner(
            opponent: widget.opponent,
            line: _opponentLine,
            turnLabel: _aiThinking
                ? l10n.gameOpponentTurnLabel
                : (_engine.turn == UnoPlayer.user ? l10n.gameYourTurnLabel : l10n.gameOpponentTurnLabel),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.style, color: p.textFaint, size: 16),
                const SizedBox(width: 6),
                Text('${l10n.unoOpponentHandLabel} ${_engine.opponentHand.length}',
                    style: TextStyle(color: p.textFaint, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _onDrawTap,
                    child: Tooltip(
                      message: l10n.unoDrawPileTooltip,
                      child: _UnoCardBack(color: p.surfaceAlt),
                    ),
                  ),
                  const SizedBox(width: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _UnoCardWidget(
                      key: ValueKey(_engine.discardPile.length),
                      card: _engine.topCard,
                      displayColor: unoColorValue(_engine.currentColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: [
                Text(l10n.unoYourHandLabel, style: TextStyle(color: p.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                if (_engine.userHand.length == 1) ...[
                  const SizedBox(width: 8),
                  Text(l10n.unoUnoCalloutLabel, style: TextStyle(color: p.danger, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 108,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              scrollDirection: Axis.horizontal,
              itemCount: _engine.userHand.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final card = _engine.userHand[index];
                final playable = _engine.turn == UnoPlayer.user && !_aiThinking && _engine.isPlayable(card);
                return GestureDetector(
                  onTap: playable ? () => _onPlayCard(card) : null,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: playable ? 1 : 0.45,
                    child: _UnoCardWidget(card: card, displayColor: unoColorValue(card.color)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Color unoColorValue(UnoColor color) => switch (color) {
      UnoColor.red => const Color(0xFFE64545),
      UnoColor.yellow => const Color(0xFFE0B12A),
      UnoColor.green => const Color(0xFF3FA84A),
      UnoColor.blue => const Color(0xFF3A6FE0),
      UnoColor.wild => const Color(0xFF3A3A3A),
    };

class _UnoCardWidget extends StatelessWidget {
  const _UnoCardWidget({super.key, required this.card, required this.displayColor});

  final UnoCard card;
  final Color displayColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 100,
      decoration: BoxDecoration(
        color: displayColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
      ),
      alignment: Alignment.center,
      child: Text(
        card.label,
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _UnoCardBack extends StatelessWidget {
  const _UnoCardBack({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.style, color: Colors.white54, size: 26),
    );
  }
}
