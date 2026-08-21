import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/ai/ai_chat_service.dart';
import '../../../data/db/database.dart';
import '../../../data/games/chess/chess_ai.dart';
import '../../../data/games/chess/chess_engine.dart';
import '../../../data/games/chess/chess_llm_ai.dart';
import '../../../data/games/chess/chess_models.dart';
import '../../../data/games/game_flavor_dialogue.dart';
import '../../../data/games/game_llm_choice.dart';
import '../../../data/repositories/ai_preset_repository.dart';
import '../../../data/repositories/game_result_repository.dart';
import '../../../data/theme/color_palette.dart';
import '../../../data/theme/palette_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../game_widgets.dart';

class ChessGameScreen extends StatefulWidget {
  const ChessGameScreen({
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
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  late ChessEngine _engine;
  late ChessAi _ai;
  late ChessLlmAi _llmAi;
  late final GameResultRepository _resultRepo;
  late final GameFlavorDialogue _flavor;
  late final GameLlmChoice _llmChoice;
  late final AiPresetRepository _presetRepo;
  bool _aiThinking = false;
  String? _opponentLine;
  bool _resultRecorded = false;
  ChessPos? _selected;
  List<ChessMove> _selectedMoves = const [];

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
      _engine = ChessEngine();
      _ai = ChessAi(widget.difficulty);
      _llmAi = ChessLlmAi(widget.difficulty);
      _aiThinking = false;
      _opponentLine = null;
      _resultRecorded = false;
      _selected = null;
      _selectedMoves = const [];
    });
  }

  Future<void> _maybeSpeak(String situationKo) async {
    final preset = await _presetRepo.getDefault();
    final line = await _flavor.requestLine(preset: preset, character: widget.opponent, situationKo: situationKo);
    if (!mounted || line == null) return;
    setState(() => _opponentLine = line);
  }

  Future<ChessMove> _chooseAiMove() async {
    if (!widget.useLlmMoves) return _ai.chooseMove(_engine);
    final preset = await _presetRepo.getDefault();
    return _llmAi.chooseMove(engine: _engine, llmChoice: _llmChoice, preset: preset, character: widget.opponent);
  }

  void _onSquareTap(int row, int col) {
    if (_engine.gameOver || _aiThinking || _engine.turn != ChessColor.white) return;
    final pos = ChessPos(row, col);
    final matches = _selectedMoves.where((m) => m.to == pos).toList();
    if (matches.isNotEmpty) {
      _commitMove(matches);
      return;
    }
    final piece = _engine.at(pos);
    if (piece != null && piece.color == ChessColor.white) {
      setState(() {
        _selected = pos;
        _selectedMoves = _engine.legalMoves(ChessColor.white).where((m) => m.from == pos).toList();
      });
    } else {
      setState(() {
        _selected = null;
        _selectedMoves = const [];
      });
    }
  }

  Future<void> _commitMove(List<ChessMove> matches) async {
    ChessMove move = matches.first;
    if (matches.length > 1) {
      final chosen = await _pickPromotion();
      if (chosen == null) return;
      move = matches.firstWhere((m) => m.promotion == chosen, orElse: () => matches.first);
    }
    setState(() {
      _engine.makeMove(move);
      _selected = null;
      _selectedMoves = const [];
    });
    if (_engine.gameOver) {
      _onGameOver();
      return;
    }
    var spokeThisTurn = false;
    if (_engine.isInCheck) {
      spokeThisTurn = true;
      unawaited(_maybeSpeak('체크를 당했다'));
    }
    setState(() => _aiThinking = true);
    final aiMoveFuture = _chooseAiMove();
    await Future.delayed(const Duration(milliseconds: 500));
    final aiMove = await aiMoveFuture;
    if (!mounted) return;
    final moveDescription = _describeMoveKo(aiMove);
    setState(() {
      _engine.makeMove(aiMove);
      _aiThinking = false;
    });
    if (_engine.gameOver) {
      _onGameOver();
    } else if (_engine.isInCheck) {
      spokeThisTurn = true;
      unawaited(_maybeSpeak('내가 상대를 체크에 몰아넣었다'));
    }
    if (!spokeThisTurn && widget.speakEveryMove) {
      unawaited(_maybeSpeak('방금 $moveDescription 수를 두었다'));
    }
  }

  String _describeMoveKo(ChessMove move) {
    final piece = _engine.at(move.from);
    final pieceKo = switch (piece?.type) {
      ChessPieceType.pawn => '폰',
      ChessPieceType.knight => '나이트',
      ChessPieceType.bishop => '비숍',
      ChessPieceType.rook => '룩',
      ChessPieceType.queen => '퀸',
      ChessPieceType.king => '킹',
      null => '기물',
    };
    return _engine.at(move.to) != null ? '$pieceKo로 잡는' : '$pieceKo를 움직이는';
  }

  Future<ChessPieceType?> _pickPromotion() {
    final l10n = AppLocalizations.of(context)!;
    final p = PaletteScope.of(context);
    return showModalBottomSheet<ChessPieceType>(
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
                Text(l10n.chessPromotionTitle, style: TextStyle(color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final t in [ChessPieceType.queen, ChessPieceType.rook, ChessPieceType.bishop, ChessPieceType.knight])
                      GestureDetector(
                        onTap: () => Navigator.of(sheetContext).pop(t),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10)),
                          alignment: Alignment.center,
                          child: Text(_glyph(ChessPiece(type: t, color: ChessColor.white)), style: const TextStyle(fontSize: 30)),
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
      ChessColor.white => GameEndOutcome.win,
      ChessColor.black => GameEndOutcome.loss,
      null => GameEndOutcome.draw,
    };
    _recordResult(outcome);
    unawaited(_maybeSpeak(outcome == GameEndOutcome.win
        ? '체크메이트로 내가 졌다'
        : (outcome == GameEndOutcome.loss ? '체크메이트로 내가 이겼다' : '스테일메이트, 무승부다')));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGameEndSheet(context, outcome: outcome, onPlayAgain: _resetGame);
    });
  }

  Future<void> _recordResult(GameEndOutcome outcome) async {
    if (_resultRecorded) return;
    _resultRecorded = true;
    await _resultRepo.record(
      gameType: GameType.chess,
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
        _engine.winner = ChessColor.black;
      });
      _onGameOver();
    }
  }

  String _glyph(ChessPiece piece) {
    const white = {
      ChessPieceType.king: '♔',
      ChessPieceType.queen: '♕',
      ChessPieceType.rook: '♖',
      ChessPieceType.bishop: '♗',
      ChessPieceType.knight: '♘',
      ChessPieceType.pawn: '♙',
    };
    const black = {
      ChessPieceType.king: '♚',
      ChessPieceType.queen: '♛',
      ChessPieceType.rook: '♜',
      ChessPieceType.bishop: '♝',
      ChessPieceType.knight: '♞',
      ChessPieceType.pawn: '♟',
    };
    return (piece.color == ChessColor.white ? white : black)[piece.type]!;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = PaletteScope.of(context);
    final destinationSquares = {for (final m in _selectedMoves) m.to: true};

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: p.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l10n.gamesHomeChessTitle, style: TextStyle(color: p.textPrimary, fontSize: 17)),
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
            turnLabel: _engine.turn == ChessColor.white
                ? (_engine.isInCheck ? l10n.chessCheckLabel : l10n.gameYourTurnLabel)
                : l10n.gameOpponentTurnLabel,
          ),
          _buildCapturedRow(l10n.chessCapturedByYouLabel, _engine.capturedByWhite, p),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final row = index ~/ 8;
                      final col = index % 8;
                      final pos = ChessPos(row, col);
                      final piece = _engine.board[row][col];
                      final isDark = (row + col) % 2 == 1;
                      final isSelected = _selected == pos;
                      final isDestination = destinationSquares.containsKey(pos);
                      return GestureDetector(
                        onTap: () => _onSquareTap(row, col),
                        child: Container(
                          color: isSelected
                              ? p.primary.withValues(alpha: 0.55)
                              : (isDark ? p.surfaceAlt : p.surface),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isDestination)
                                Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: piece == null ? p.primary.withValues(alpha: 0.35) : Colors.transparent,
                                    border: piece != null ? Border.all(color: p.primary, width: 2.5) : null,
                                  ),
                                ),
                              if (piece != null)
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 150),
                                  scale: 1,
                                  child: Text(_glyph(piece), style: const TextStyle(fontSize: 26)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          _buildCapturedRow(l10n.chessCapturedByOpponentLabel, _engine.capturedByBlack, p),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCapturedRow(String label, List<ChessPiece> captured, ColorPalette p) {
    if (captured.isEmpty) return const SizedBox(height: 4);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Text('$label ', style: TextStyle(color: p.textFaint, fontSize: 11)),
          Expanded(
            child: Wrap(
              children: [for (final piece in captured) Text(_glyph(piece), style: TextStyle(fontSize: 14, color: p.textSecondary))],
            ),
          ),
        ],
      ),
    );
  }
}
