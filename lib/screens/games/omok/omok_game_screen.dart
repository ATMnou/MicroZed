import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/ai/ai_chat_service.dart';
import '../../../data/db/database.dart';
import '../../../data/games/game_flavor_dialogue.dart';
import '../../../data/games/game_llm_choice.dart';
import '../../../data/games/omok/omok_engine.dart';
import '../../../data/repositories/ai_preset_repository.dart';
import '../../../data/repositories/game_result_repository.dart';
import '../../../data/theme/palette_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../game_widgets.dart';

class OmokGameScreen extends StatefulWidget {
  const OmokGameScreen({
    super.key,
    required this.opponent,
    required this.difficulty,
    this.useLlmMoves = false,
    this.speakEveryMove = false,
  });

  final Character opponent;
  final GameDifficulty difficulty;
  final bool useLlmMoves;
  final bool speakEveryMove;

  @override
  State<OmokGameScreen> createState() => _OmokGameScreenState();
}

class _OmokGameScreenState extends State<OmokGameScreen> {
  late OmokEngine _engine;
  late OmokAi _ai;
  late OmokLlmAi _llmAi;
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
      _engine = OmokEngine();
      _ai = OmokAi(widget.difficulty);
      _llmAi = OmokLlmAi(widget.difficulty);
      _aiThinking = false;
      _opponentLine = null;
      _resultRecorded = false;
    });
    _maybeSpeak('게임을 시작한다');
  }

  Future<void> _maybeSpeak(String situationKo) async {
    final preset = await _presetRepo.getDefault();
    final line = await _flavor.requestLine(preset: preset, character: widget.opponent, situationKo: situationKo);
    if (!mounted || line == null) return;
    setState(() => _opponentLine = line);
  }

  Future<OmokMove> _chooseAiMove() async {
    if (!widget.useLlmMoves) return _ai.chooseMove(_engine);
    final preset = await _presetRepo.getDefault();
    return _llmAi.chooseMove(engine: _engine, llmChoice: _llmChoice, preset: preset, character: widget.opponent);
  }

  Future<void> _onCellTap(int row, int col) async {
    if (_engine.gameOver || _aiThinking || _engine.turn != OmokStone.player) return;
    if (!_engine.isEmpty(row, col)) return;
    setState(() => _engine.place(row, col));
    if (_engine.gameOver) {
      _onGameOver();
      return;
    }
    setState(() => _aiThinking = true);
    final moveFuture = _chooseAiMove();
    await Future.delayed(const Duration(milliseconds: 450));
    final move = await moveFuture;
    if (!mounted) return;
    setState(() {
      _engine.place(move.row, move.col);
      _aiThinking = false;
    });
    if (_engine.gameOver) {
      _onGameOver();
    } else if (widget.speakEveryMove) {
      unawaited(_maybeSpeak('방금 그 자리에 돌을 놓았다'));
    } else if (_engine.board.expand((r) => r).where((s) => s != OmokStone.empty).length >= 6) {
      unawaited(_maybeSpeak('바둑판 위 상황을 보고 짧게 한마디 한다'));
    }
  }

  void _onGameOver() {
    final outcome = switch (_engine.winner) {
      OmokStone.player => GameEndOutcome.win,
      OmokStone.opponent => GameEndOutcome.loss,
      _ => GameEndOutcome.draw,
    };
    _recordResult(outcome);
    unawaited(_maybeSpeak(outcome == GameEndOutcome.win ? '내가 졌다' : (outcome == GameEndOutcome.loss ? '내가 이겼다' : '무승부다')));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGameEndSheet(context, outcome: outcome, onPlayAgain: _resetGame);
    });
  }

  Future<void> _recordResult(GameEndOutcome outcome) async {
    if (_resultRecorded) return;
    _resultRecorded = true;
    await _resultRepo.record(
      gameType: GameType.omok,
      opponentCharacterId: widget.opponent.id,
      difficulty: widget.difficulty,
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
        _engine.winner = OmokStone.opponent;
      });
      _onGameOver();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = PaletteScope.of(context);
    final isWinningCell = <int, bool>{};
    for (final m in _engine.winningLine) {
      isWinningCell[m.row * _engine.size + m.col] = true;
    }
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: p.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l10n.gamesHomeOmokTitle, style: TextStyle(color: p.textPrimary, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.flag_outlined, color: p.textSecondary, size: 20),
            tooltip: l10n.gameResignButton,
            onPressed: _confirmResign,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
        children: [
          OpponentBanner(
            opponent: widget.opponent,
            line: _opponentLine,
            turnLabel: _engine.turn == OmokStone.player ? l10n.gameYourTurnLabel : l10n.gameOpponentTurnLabel,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(4),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _engine.size),
                      itemCount: _engine.size * _engine.size,
                      itemBuilder: (context, index) {
                        final row = index ~/ _engine.size;
                        final col = index % _engine.size;
                        final stone = _engine.board[row][col];
                        final highlight = isWinningCell[index] ?? false;
                        return GestureDetector(
                          onTap: () => _onCellTap(row, col),
                          child: Container(
                            margin: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: highlight ? p.primary.withValues(alpha: 0.25) : p.surfaceAlt,
                              border: Border.all(color: p.border, width: 0.5),
                            ),
                            child: Center(
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOutBack,
                                scale: stone == OmokStone.empty ? 0 : 1,
                                child: Container(
                                  margin: const EdgeInsets.all(1.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: stone == OmokStone.player ? p.textPrimary : p.danger,
                                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 1)],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
