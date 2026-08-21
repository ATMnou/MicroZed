import '../../db/database.dart';
import '../game_llm_choice.dart';
import 'chess_ai.dart';
import 'chess_engine.dart';
import 'chess_models.dart';

/// [ChessAi]를 항상 폴백으로 갖고 있는 LLM 기반 판단. 실제 둘 수 있는 합법수 목록([ChessEngine.legalMoves])
/// 만 후보로 제시하므로 LLM이 무슨 답을 하든 불법적인 수는 절대 나올 수 없다.
class ChessLlmAi {
  ChessLlmAi(this.difficulty) : _fallback = ChessAi(difficulty);

  final GameDifficulty difficulty;
  final ChessAi _fallback;

  Future<ChessMove> chooseMove({
    required ChessEngine engine,
    required GameLlmChoice llmChoice,
    required AiPreset? preset,
    required Character character,
  }) async {
    final moves = engine.legalMoves(engine.turn);
    final options = [for (final m in moves) _describeMove(engine, m)];
    final index = await llmChoice.chooseIndex(
      preset: preset,
      character: character,
      gameNameKo: '체스',
      stateKo: _boardText(engine),
      options: options,
    );
    if (index != null) return moves[index];
    return _fallback.chooseMove(engine);
  }

  String _squareName(ChessPos pos) => '${String.fromCharCode(97 + pos.col)}${8 - pos.row}';

  String _describeMove(ChessEngine engine, ChessMove move) {
    final base = '${_squareName(move.from)}-${_squareName(move.to)}';
    if (move.promotion != null) {
      final letter = switch (move.promotion!) {
        ChessPieceType.queen => 'Q',
        ChessPieceType.rook => 'R',
        ChessPieceType.bishop => 'B',
        ChessPieceType.knight => 'N',
        _ => '',
      };
      return '$base=$letter';
    }
    if (move.isCastleKingSide) return '$base (캐슬링, 킹사이드)';
    if (move.isCastleQueenSide) return '$base (캐슬링, 퀸사이드)';
    return engine.at(move.to) != null ? '$base (잡기)' : base;
  }

  String _boardText(ChessEngine engine) {
    final buffer = StringBuffer('현재 보드(대문자=백, 소문자=흑, .=빈칸):\n');
    for (var r = 0; r < 8; r++) {
      buffer.write('${8 - r} ');
      for (var c = 0; c < 8; c++) {
        final piece = engine.board[r][c];
        buffer.write(piece == null ? '. ' : '${_pieceLetter(piece)} ');
      }
      buffer.writeln();
    }
    buffer.write('  a b c d e f g h');
    return buffer.toString();
  }

  String _pieceLetter(ChessPiece piece) {
    final letter = switch (piece.type) {
      ChessPieceType.pawn => 'p',
      ChessPieceType.knight => 'n',
      ChessPieceType.bishop => 'b',
      ChessPieceType.rook => 'r',
      ChessPieceType.queen => 'q',
      ChessPieceType.king => 'k',
    };
    return piece.color == ChessColor.white ? letter.toUpperCase() : letter;
  }
}
