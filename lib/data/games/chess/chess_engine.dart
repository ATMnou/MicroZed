import 'chess_models.dart';

/// 캐슬링/앙파상/프로모션을 포함한 완전한 합법수 생성 + 체크/체크메이트/스테일메이트
/// 판정을 갖춘 체스 엔진. AI 탐색과 UI가 [applyMove]/[undoMove]를 공유해서 쓴다.
class ChessEngine {
  ChessEngine() {
    _setupInitialBoard();
  }

  final List<List<ChessPiece?>> board = List.generate(8, (_) => List<ChessPiece?>.filled(8, null));
  ChessColor turn = ChessColor.white;
  ChessPos? enPassantTarget;
  bool gameOver = false;

  /// null이면(gameOver=true일 때) 스테일메이트/무승부.
  ChessColor? winner;

  final List<ChessPiece> capturedByWhite = [];
  final List<ChessPiece> capturedByBlack = [];

  static const _backRank = [
    ChessPieceType.rook,
    ChessPieceType.knight,
    ChessPieceType.bishop,
    ChessPieceType.queen,
    ChessPieceType.king,
    ChessPieceType.bishop,
    ChessPieceType.knight,
    ChessPieceType.rook,
  ];

  static const _knightOffsets = [(-2, -1), (-2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2), (2, -1), (2, 1)];
  static const _diagonalDirs = [(-1, -1), (-1, 1), (1, -1), (1, 1)];
  static const _straightDirs = [(-1, 0), (1, 0), (0, -1), (0, 1)];

  void _setupInitialBoard() {
    for (var c = 0; c < 8; c++) {
      board[0][c] = ChessPiece(type: _backRank[c], color: ChessColor.black);
      board[1][c] = ChessPiece(type: ChessPieceType.pawn, color: ChessColor.black);
      board[6][c] = ChessPiece(type: ChessPieceType.pawn, color: ChessColor.white);
      board[7][c] = ChessPiece(type: _backRank[c], color: ChessColor.white);
    }
  }

  ChessPiece? at(ChessPos p) => p.inBounds ? board[p.row][p.col] : null;

  ChessPos? findKing(ChessColor color) {
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece != null && piece.type == ChessPieceType.king && piece.color == color) return ChessPos(r, c);
      }
    }
    return null;
  }

  bool isSquareAttacked(ChessPos pos, ChessColor byColor) {
    final forward = byColor == ChessColor.white ? -1 : 1;
    final pawnRow = pos.row - forward;
    for (final dc in [-1, 1]) {
      final piece = at(ChessPos(pawnRow, pos.col + dc));
      if (piece != null && piece.color == byColor && piece.type == ChessPieceType.pawn) return true;
    }
    for (final (dr, dc) in _knightOffsets) {
      final piece = at(ChessPos(pos.row + dr, pos.col + dc));
      if (piece != null && piece.color == byColor && piece.type == ChessPieceType.knight) return true;
    }
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final piece = at(ChessPos(pos.row + dr, pos.col + dc));
        if (piece != null && piece.color == byColor && piece.type == ChessPieceType.king) return true;
      }
    }
    for (final (dr, dc) in _diagonalDirs) {
      var r = pos.row + dr, c = pos.col + dc;
      while (ChessPos(r, c).inBounds) {
        final piece = board[r][c];
        if (piece != null) {
          if (piece.color == byColor && (piece.type == ChessPieceType.bishop || piece.type == ChessPieceType.queen)) {
            return true;
          }
          break;
        }
        r += dr;
        c += dc;
      }
    }
    for (final (dr, dc) in _straightDirs) {
      var r = pos.row + dr, c = pos.col + dc;
      while (ChessPos(r, c).inBounds) {
        final piece = board[r][c];
        if (piece != null) {
          if (piece.color == byColor && (piece.type == ChessPieceType.rook || piece.type == ChessPieceType.queen)) {
            return true;
          }
          break;
        }
        r += dr;
        c += dc;
      }
    }
    return false;
  }

  bool isColorInCheck(ChessColor color) {
    final king = findKing(color);
    return king != null && isSquareAttacked(king, color.opposite);
  }

  bool get isInCheck => isColorInCheck(turn);

  List<ChessMove> pseudoLegalMovesFrom(ChessPos pos) {
    final piece = at(pos);
    if (piece == null) return const [];
    switch (piece.type) {
      case ChessPieceType.pawn:
        return _pawnMoves(pos, piece);
      case ChessPieceType.knight:
        return _stepMoves(pos, piece, _knightOffsets);
      case ChessPieceType.bishop:
        return _slideMoves(pos, piece, _diagonalDirs);
      case ChessPieceType.rook:
        return _slideMoves(pos, piece, _straightDirs);
      case ChessPieceType.queen:
        return [..._slideMoves(pos, piece, _diagonalDirs), ..._slideMoves(pos, piece, _straightDirs)];
      case ChessPieceType.king:
        return _kingMoves(pos, piece);
    }
  }

  List<ChessMove> _stepMoves(ChessPos pos, ChessPiece piece, List<(int, int)> offsets) {
    final moves = <ChessMove>[];
    for (final (dr, dc) in offsets) {
      final to = ChessPos(pos.row + dr, pos.col + dc);
      if (!to.inBounds) continue;
      final target = at(to);
      if (target == null || target.color != piece.color) moves.add(ChessMove(from: pos, to: to));
    }
    return moves;
  }

  List<ChessMove> _slideMoves(ChessPos pos, ChessPiece piece, List<(int, int)> dirs) {
    final moves = <ChessMove>[];
    for (final (dr, dc) in dirs) {
      var r = pos.row + dr, c = pos.col + dc;
      while (ChessPos(r, c).inBounds) {
        final target = board[r][c];
        if (target == null) {
          moves.add(ChessMove(from: pos, to: ChessPos(r, c)));
        } else {
          if (target.color != piece.color) moves.add(ChessMove(from: pos, to: ChessPos(r, c)));
          break;
        }
        r += dr;
        c += dc;
      }
    }
    return moves;
  }

  List<ChessMove> _pawnMoves(ChessPos pos, ChessPiece piece) {
    final moves = <ChessMove>[];
    final forward = piece.color == ChessColor.white ? -1 : 1;
    final startRow = piece.color == ChessColor.white ? 6 : 1;
    final promoRow = piece.color == ChessColor.white ? 0 : 7;

    final oneStep = ChessPos(pos.row + forward, pos.col);
    if (oneStep.inBounds && at(oneStep) == null) {
      _addPawnMove(moves, pos, oneStep, promoRow);
      if (pos.row == startRow) {
        final twoStep = ChessPos(pos.row + 2 * forward, pos.col);
        if (at(twoStep) == null) moves.add(ChessMove(from: pos, to: twoStep));
      }
    }
    for (final dc in [-1, 1]) {
      final capPos = ChessPos(pos.row + forward, pos.col + dc);
      if (!capPos.inBounds) continue;
      final target = at(capPos);
      if (target != null && target.color != piece.color) {
        _addPawnMove(moves, pos, capPos, promoRow);
      } else if (target == null && enPassantTarget != null && capPos == enPassantTarget) {
        moves.add(ChessMove(from: pos, to: capPos, isEnPassant: true));
      }
    }
    return moves;
  }

  void _addPawnMove(List<ChessMove> moves, ChessPos from, ChessPos to, int promoRow) {
    if (to.row == promoRow) {
      for (final t in [ChessPieceType.queen, ChessPieceType.rook, ChessPieceType.bishop, ChessPieceType.knight]) {
        moves.add(ChessMove(from: from, to: to, promotion: t));
      }
    } else {
      moves.add(ChessMove(from: from, to: to));
    }
  }

  List<ChessMove> _kingMoves(ChessPos pos, ChessPiece piece) {
    final offsets = [
      for (var dr = -1; dr <= 1; dr++)
        for (var dc = -1; dc <= 1; dc++)
          if (!(dr == 0 && dc == 0)) (dr, dc),
    ];
    final moves = _stepMoves(pos, piece, offsets);
    if (!piece.hasMoved && !isSquareAttacked(pos, piece.color.opposite)) {
      final row = pos.row;
      final kingRook = board[row][7];
      if (kingRook != null &&
          kingRook.type == ChessPieceType.rook &&
          !kingRook.hasMoved &&
          at(ChessPos(row, 5)) == null &&
          at(ChessPos(row, 6)) == null &&
          !isSquareAttacked(ChessPos(row, 5), piece.color.opposite) &&
          !isSquareAttacked(ChessPos(row, 6), piece.color.opposite)) {
        moves.add(ChessMove(from: pos, to: ChessPos(row, 6), isCastleKingSide: true));
      }
      final queenRook = board[row][0];
      if (queenRook != null &&
          queenRook.type == ChessPieceType.rook &&
          !queenRook.hasMoved &&
          at(ChessPos(row, 1)) == null &&
          at(ChessPos(row, 2)) == null &&
          at(ChessPos(row, 3)) == null &&
          !isSquareAttacked(ChessPos(row, 2), piece.color.opposite) &&
          !isSquareAttacked(ChessPos(row, 3), piece.color.opposite)) {
        moves.add(ChessMove(from: pos, to: ChessPos(row, 2), isCastleQueenSide: true));
      }
    }
    return moves;
  }

  /// 자기 킹이 체크에 걸리는 수는 걸러낸 완전한 합법수 목록.
  List<ChessMove> legalMoves(ChessColor color) {
    final result = <ChessMove>[];
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece == null || piece.color != color) continue;
        for (final move in pseudoLegalMovesFrom(ChessPos(r, c))) {
          final undo = applyMove(move);
          final king = findKing(color);
          final safe = king != null && !isSquareAttacked(king, color.opposite);
          undoMove(undo);
          if (safe) result.add(move);
        }
      }
    }
    return result;
  }

  ChessUndo applyMove(ChessMove move) {
    final piece = board[move.from.row][move.from.col]!;
    final movedHadMoved = piece.hasMoved;
    ChessPiece? captured;
    ChessPos? capturedAt;
    final prevEnPassant = enPassantTarget;

    if (move.isEnPassant) {
      capturedAt = ChessPos(move.from.row, move.to.col);
      captured = board[capturedAt.row][capturedAt.col];
      board[capturedAt.row][capturedAt.col] = null;
    } else if (board[move.to.row][move.to.col] != null) {
      capturedAt = move.to;
      captured = board[move.to.row][move.to.col];
    }

    board[move.to.row][move.to.col] = piece;
    board[move.from.row][move.from.col] = null;
    piece.hasMoved = true;

    if (move.promotion != null) {
      board[move.to.row][move.to.col] = ChessPiece(type: move.promotion!, color: piece.color, hasMoved: true);
    }

    if (move.isCastleKingSide || move.isCastleQueenSide) {
      final row = move.from.row;
      final rookFromCol = move.isCastleKingSide ? 7 : 0;
      final rookToCol = move.isCastleKingSide ? 5 : 3;
      final rook = board[row][rookFromCol];
      board[row][rookToCol] = rook;
      board[row][rookFromCol] = null;
      rook?.hasMoved = true;
    }

    if (piece.type == ChessPieceType.pawn && (move.to.row - move.from.row).abs() == 2) {
      enPassantTarget = ChessPos((move.from.row + move.to.row) ~/ 2, move.from.col);
    } else {
      enPassantTarget = null;
    }

    return ChessUndo(
      move: move,
      movedPieceHadMoved: movedHadMoved,
      capturedPiece: captured,
      capturedAt: capturedAt,
      previousEnPassantTarget: prevEnPassant,
    );
  }

  void undoMove(ChessUndo undo) {
    final move = undo.move;
    var piece = board[move.to.row][move.to.col]!;
    if (move.promotion != null) {
      piece = ChessPiece(type: ChessPieceType.pawn, color: piece.color, hasMoved: undo.movedPieceHadMoved);
    } else {
      piece.hasMoved = undo.movedPieceHadMoved;
    }
    board[move.from.row][move.from.col] = piece;
    board[move.to.row][move.to.col] = null;

    if (move.isEnPassant) {
      board[undo.capturedAt!.row][undo.capturedAt!.col] = undo.capturedPiece;
    } else if (undo.capturedPiece != null) {
      board[move.to.row][move.to.col] = undo.capturedPiece;
    }

    if (move.isCastleKingSide || move.isCastleQueenSide) {
      final row = move.from.row;
      final rookFromCol = move.isCastleKingSide ? 7 : 0;
      final rookToCol = move.isCastleKingSide ? 5 : 3;
      final rook = board[row][rookToCol];
      board[row][rookFromCol] = rook;
      board[row][rookToCol] = null;
      rook?.hasMoved = false;
    }

    enPassantTarget = undo.previousEnPassantTarget;
  }

  /// UI/AI가 실제로 두는 수. 캡처 기록, 턴 전환, 체크메이트/스테일메이트 판정까지 처리한다.
  void makeMove(ChessMove move) {
    final movingPiece = board[move.from.row][move.from.col];
    final undo = applyMove(move);
    if (undo.capturedPiece != null && movingPiece != null) {
      if (movingPiece.color == ChessColor.white) {
        capturedByWhite.add(undo.capturedPiece!);
      } else {
        capturedByBlack.add(undo.capturedPiece!);
      }
    }
    turn = turn.opposite;
    if (legalMoves(turn).isEmpty) {
      gameOver = true;
      winner = isColorInCheck(turn) ? turn.opposite : null;
    }
  }
}
