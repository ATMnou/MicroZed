import 'dart:math';

import '../../db/database.dart';
import 'chess_engine.dart';
import 'chess_models.dart';

/// 미니맥스 + 알파베타. 난이도로 탐색 깊이와(쉬움만) 실수 확률을 조절한다.
class ChessAi {
  ChessAi(this.difficulty);

  final GameDifficulty difficulty;
  final _random = Random();

  int get _depth => switch (difficulty) {
        GameDifficulty.easy => 1,
        GameDifficulty.medium => 2,
        GameDifficulty.hard => 3,
      };

  ChessMove chooseMove(ChessEngine engine) {
    final color = engine.turn;
    final moves = engine.legalMoves(color)..shuffle(_random);
    if (moves.isEmpty) return moves.first;

    if (difficulty == GameDifficulty.easy && _random.nextDouble() < 0.35) {
      return moves[_random.nextInt(moves.length)];
    }

    _orderMoves(engine, moves);
    final maximizing = color == ChessColor.white;
    ChessMove best = moves.first;
    var bestScore = maximizing ? -1000000 : 1000000;
    var alpha = -1000000, beta = 1000000;
    for (final move in moves) {
      final undo = engine.applyMove(move);
      final score = _minimax(engine, _depth - 1, alpha, beta, color.opposite);
      engine.undoMove(undo);
      if (maximizing) {
        if (score > bestScore) {
          bestScore = score;
          best = move;
        }
        alpha = max(alpha, bestScore);
      } else {
        if (score < bestScore) {
          bestScore = score;
          best = move;
        }
        beta = min(beta, bestScore);
      }
    }
    return best;
  }

  int _minimax(ChessEngine engine, int depth, int alpha, int beta, ChessColor sideToMove) {
    final moves = engine.legalMoves(sideToMove);
    if (moves.isEmpty) {
      if (engine.isColorInCheck(sideToMove)) {
        return sideToMove == ChessColor.white ? -100000 - depth : 100000 + depth;
      }
      return 0;
    }
    if (depth == 0) return _evaluate(engine);

    _orderMoves(engine, moves);
    if (sideToMove == ChessColor.white) {
      var value = -1000000;
      for (final move in moves) {
        final undo = engine.applyMove(move);
        value = max(value, _minimax(engine, depth - 1, alpha, beta, ChessColor.black));
        engine.undoMove(undo);
        alpha = max(alpha, value);
        if (alpha >= beta) break;
      }
      return value;
    } else {
      var value = 1000000;
      for (final move in moves) {
        final undo = engine.applyMove(move);
        value = min(value, _minimax(engine, depth - 1, alpha, beta, ChessColor.white));
        engine.undoMove(undo);
        beta = min(beta, value);
        if (beta <= alpha) break;
      }
      return value;
    }
  }

  void _orderMoves(ChessEngine engine, List<ChessMove> moves) {
    moves.sort((a, b) {
      final aCap = engine.at(a.to);
      final bCap = engine.at(b.to);
      final aScore = aCap == null ? 0 : _pieceValue(aCap.type);
      final bScore = bCap == null ? 0 : _pieceValue(bCap.type);
      return bScore.compareTo(aScore);
    });
  }

  static int _pieceValue(ChessPieceType t) => switch (t) {
        ChessPieceType.pawn => 100,
        ChessPieceType.knight => 320,
        ChessPieceType.bishop => 330,
        ChessPieceType.rook => 500,
        ChessPieceType.queen => 900,
        ChessPieceType.king => 20000,
      };

  static int _positionalBonus(ChessPiece piece, int r, int c) {
    final centerDistance = (r - 3.5).abs() + (c - 3.5).abs();
    final centerScore = (7 - centerDistance) * 4;
    switch (piece.type) {
      case ChessPieceType.knight:
      case ChessPieceType.bishop:
      case ChessPieceType.queen:
        return centerScore.round();
      case ChessPieceType.pawn:
        final advancement = piece.color == ChessColor.white ? (6 - r) : (r - 1);
        return advancement * 8 + (centerScore * 0.3).round();
      case ChessPieceType.king:
        return -(centerScore * 2).round();
      case ChessPieceType.rook:
        return 0;
    }
  }

  static int _evaluate(ChessEngine engine) {
    var score = 0;
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final piece = engine.board[r][c];
        if (piece == null) continue;
        final value = _pieceValue(piece.type) + _positionalBonus(piece, r, c);
        score += piece.color == ChessColor.white ? value : -value;
      }
    }
    return score;
  }
}
