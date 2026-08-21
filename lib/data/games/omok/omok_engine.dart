import 'dart:math';

import '../../db/database.dart';
import '../game_llm_choice.dart';

enum OmokStone { empty, player, opponent }

class OmokMove {
  const OmokMove(this.row, this.col);
  final int row;
  final int col;
}

/// 15x15 자유형 오목(렌주룰의 흑 금수 제한 없음). 플레이어가 항상 흑(선공)이다.
class OmokEngine {
  OmokEngine({this.size = 15}) : board = List.generate(size, (_) => List.filled(size, OmokStone.empty));

  final int size;
  final List<List<OmokStone>> board;
  OmokStone turn = OmokStone.player;
  bool gameOver = false;
  OmokStone? winner;
  List<OmokMove> winningLine = const [];

  static const _directions = [
    (1, 0),
    (0, 1),
    (1, 1),
    (1, -1),
  ];

  bool inBounds(int r, int c) => r >= 0 && r < size && c >= 0 && c < size;

  bool isEmpty(int r, int c) => inBounds(r, c) && board[r][c] == OmokStone.empty;

  /// 착수한다. 이미 끝난 게임이거나 빈 칸이 아니면 아무 일도 안 일어난다.
  void place(int row, int col) {
    if (gameOver || !isEmpty(row, col)) return;
    board[row][col] = turn;
    final line = _findWinningLine(row, col, turn);
    if (line != null) {
      gameOver = true;
      winner = turn;
      winningLine = line;
      return;
    }
    if (_isBoardFull()) {
      gameOver = true;
      winner = null;
      return;
    }
    turn = turn == OmokStone.player ? OmokStone.opponent : OmokStone.player;
  }

  bool _isBoardFull() {
    for (final row in board) {
      if (row.contains(OmokStone.empty)) return false;
    }
    return true;
  }

  List<OmokMove>? _findWinningLine(int row, int col, OmokStone color) {
    for (final (dr, dc) in _directions) {
      final line = [OmokMove(row, col)];
      var r = row + dr, c = col + dc;
      while (inBounds(r, c) && board[r][c] == color) {
        line.add(OmokMove(r, c));
        r += dr;
        c += dc;
      }
      r = row - dr;
      c = col - dc;
      while (inBounds(r, c) && board[r][c] == color) {
        line.insert(0, OmokMove(r, c));
        r -= dr;
        c -= dc;
      }
      if (line.length >= 5) return line;
    }
    return null;
  }
}

/// 각 빈 칸의 패턴 점수를 휴리스틱으로 매겨 최선 수를 고르는 AI. 미니맥스 없이도 15x15
/// 보드에서 즉시 반응할 수 있을 만큼 가볍다.
class OmokAi {
  OmokAi(this.difficulty);

  final GameDifficulty difficulty;
  final _random = Random();

  OmokMove chooseMove(OmokEngine engine) {
    final scored = scoredCandidates(engine);
    if (scored.isEmpty) {
      return OmokMove(engine.size ~/ 2, engine.size ~/ 2);
    }

    final poolSize = switch (difficulty) {
      GameDifficulty.easy => 6,
      GameDifficulty.medium => 3,
      GameDifficulty.hard => 1,
    };
    final pool = scored.take(poolSize.clamp(1, scored.length)).toList();
    return pool[_random.nextInt(pool.length)].cell;
  }

  /// 후보 칸을 공격+수비 점수(내림차순)로 정렬해서 돌려준다. [OmokLlmAi]도 같은 후보 목록을
  /// 공유해서 LLM에게 제시할 상위 몇 개를 고른다.
  List<({OmokMove cell, int score})> scoredCandidates(OmokEngine engine) {
    final candidates = _candidateCells(engine);
    final scored = candidates.map((cell) {
      final attack = _score(engine, cell.row, cell.col, OmokStone.opponent);
      final defenseWeight = switch (difficulty) {
        GameDifficulty.easy => 0.4,
        GameDifficulty.medium => 0.85,
        GameDifficulty.hard => 1.15,
      };
      final defense = _score(engine, cell.row, cell.col, OmokStone.player) * defenseWeight;
      return (cell: cell, score: (attack + defense).round());
    }).toList();
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  /// 빈 칸 전체를 다 보진 않고, 이미 놓인 돌 주변 2칸 이내만 후보로 삼는다(빈 보드면 중앙).
  List<OmokMove> _candidateCells(OmokEngine engine) {
    final occupied = <OmokMove>[];
    for (var r = 0; r < engine.size; r++) {
      for (var c = 0; c < engine.size; c++) {
        if (engine.board[r][c] != OmokStone.empty) occupied.add(OmokMove(r, c));
      }
    }
    if (occupied.isEmpty) {
      final mid = engine.size ~/ 2;
      return [OmokMove(mid, mid)];
    }
    final seen = <int>{};
    final result = <OmokMove>[];
    for (final o in occupied) {
      for (var dr = -2; dr <= 2; dr++) {
        for (var dc = -2; dc <= 2; dc++) {
          final r = o.row + dr, c = o.col + dc;
          if (!engine.isEmpty(r, c)) continue;
          final key = r * engine.size + c;
          if (seen.add(key)) result.add(OmokMove(r, c));
        }
      }
    }
    return result;
  }

  int _score(OmokEngine engine, int row, int col, OmokStone color) {
    // 실제로 두지 않고 임시로 놓아본 뒤 되돌리는 방식으로 각 방향의 연결 패턴을 평가한다.
    engine.board[row][col] = color;
    var total = 0;
    for (final (dr, dc) in OmokEngine._directions) {
      total += _directionScore(engine, row, col, dr, dc, color);
    }
    engine.board[row][col] = OmokStone.empty;
    return total;
  }

  int _directionScore(OmokEngine engine, int row, int col, int dr, int dc, OmokStone color) {
    var count = 1;
    var r = row + dr, c = col + dc;
    while (engine.inBounds(r, c) && engine.board[r][c] == color) {
      count++;
      r += dr;
      c += dc;
    }
    final forwardOpen = engine.isEmpty(r, c);
    r = row - dr;
    c = col - dc;
    while (engine.inBounds(r, c) && engine.board[r][c] == color) {
      count++;
      r -= dr;
      c -= dc;
    }
    final backwardOpen = engine.isEmpty(r, c);
    final openEnds = (forwardOpen ? 1 : 0) + (backwardOpen ? 1 : 0);

    if (count >= 5) return 100000;
    if (count == 4) return openEnds == 2 ? 10000 : (openEnds == 1 ? 1200 : 0);
    if (count == 3) return openEnds == 2 ? 800 : (openEnds == 1 ? 90 : 0);
    if (count == 2) return openEnds == 2 ? 80 : (openEnds == 1 ? 10 : 0);
    return openEnds == 2 ? 5 : 1;
  }
}

/// [OmokAi]와 동일한 후보 칸 점수화를 재사용하되(상위 20개로 제한), 최종 선택만 LLM에게
/// 맡긴다. 실패하면 [OmokAi]로 폴백.
class OmokLlmAi {
  OmokLlmAi(this.difficulty) : _fallback = OmokAi(difficulty);

  final GameDifficulty difficulty;
  final OmokAi _fallback;

  static const _maxCandidates = 20;

  Future<OmokMove> chooseMove({
    required OmokEngine engine,
    required GameLlmChoice llmChoice,
    required AiPreset? preset,
    required Character character,
  }) async {
    final scored = _fallback.scoredCandidates(engine);
    if (scored.isEmpty) return _fallback.chooseMove(engine);
    final top = scored.take(_maxCandidates).toList();
    final options = [for (final entry in top) '${_colLetter(entry.cell.col)}${entry.cell.row + 1}'];
    final index = await llmChoice.chooseIndex(
      preset: preset,
      character: character,
      gameNameKo: '오목',
      stateKo: _boardText(engine),
      options: options,
    );
    if (index != null) return top[index].cell;
    return _fallback.chooseMove(engine);
  }

  String _colLetter(int col) => String.fromCharCode(65 + col);

  String _boardText(OmokEngine engine) {
    final buffer = StringBuffer('현재 보드(O=나, X=상대, .=빈칸), 열은 A~O, 행은 1~15:\n   ');
    for (var c = 0; c < engine.size; c++) {
      buffer.write('${_colLetter(c)} ');
    }
    buffer.writeln();
    for (var r = 0; r < engine.size; r++) {
      buffer.write('${(r + 1).toString().padLeft(2)} ');
      for (var c = 0; c < engine.size; c++) {
        final stone = engine.board[r][c];
        buffer.write(switch (stone) {
          OmokStone.empty => '. ',
          OmokStone.player => 'X ',
          OmokStone.opponent => 'O ',
        });
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
