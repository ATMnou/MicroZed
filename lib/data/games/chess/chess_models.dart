enum ChessPieceType { pawn, knight, bishop, rook, queen, king }

enum ChessColor { white, black }

extension ChessColorX on ChessColor {
  ChessColor get opposite => this == ChessColor.white ? ChessColor.black : ChessColor.white;
}

class ChessPiece {
  ChessPiece({required this.type, required this.color, this.hasMoved = false});

  final ChessPieceType type;
  final ChessColor color;
  bool hasMoved;

  ChessPiece copy() => ChessPiece(type: type, color: color, hasMoved: hasMoved);
}

class ChessPos {
  const ChessPos(this.row, this.col);
  final int row;
  final int col;

  bool get inBounds => row >= 0 && row < 8 && col >= 0 && col < 8;

  @override
  bool operator ==(Object other) => other is ChessPos && other.row == row && other.col == col;

  @override
  int get hashCode => row * 8 + col;
}

/// 완전한 합법 이동 하나. [ChessEngine.applyMove]/[undoMove]가 이 정보로 되돌릴 수 있게
/// capture/castle/en-passant/승진 관련 정보를 전부 담는다.
class ChessMove {
  ChessMove({
    required this.from,
    required this.to,
    this.promotion,
    this.isEnPassant = false,
    this.isCastleKingSide = false,
    this.isCastleQueenSide = false,
  });

  final ChessPos from;
  final ChessPos to;
  final ChessPieceType? promotion;
  final bool isEnPassant;
  final bool isCastleKingSide;
  final bool isCastleQueenSide;
}

/// [ChessEngine.applyMove]가 반환하는, 되돌리기에 필요한 이전 상태 스냅샷.
class ChessUndo {
  ChessUndo({
    required this.move,
    required this.movedPieceHadMoved,
    this.capturedPiece,
    this.capturedAt,
    required this.previousEnPassantTarget,
  });

  final ChessMove move;
  final bool movedPieceHadMoved;
  final ChessPiece? capturedPiece;
  final ChessPos? capturedAt;
  final ChessPos? previousEnPassantTarget;
}
