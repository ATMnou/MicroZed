import 'package:drift/drift.dart';

import '../db/database.dart';

/// 게임별 승/패/무 집계 한 줄. 게임 홈 화면의 최근 전적 배지에 쓴다.
class GameSummary {
  const GameSummary({required this.gameType, required this.wins, required this.losses, required this.draws});

  final GameType gameType;
  final int wins;
  final int losses;
  final int draws;

  int get total => wins + losses + draws;
}

/// 홈 > 게임의 대국 결과 CRUD. 중간 진행 상태는 저장하지 않고 결과만 기록한다.
class GameResultRepository {
  GameResultRepository(this._db);

  final AppDatabase _db;

  Future<int> record({
    required GameType gameType,
    int? opponentCharacterId,
    GameDifficulty? difficulty,
    required GameOutcome outcome,
  }) {
    return _db.into(_db.gameResults).insert(
          GameResultsCompanion.insert(
            gameType: gameType,
            opponentCharacterId: Value(opponentCharacterId),
            difficulty: Value(difficulty),
            outcome: outcome,
          ),
        );
  }

  Stream<List<GameResult>> watchRecent({GameType? gameType, int limit = 20}) {
    final query = _db.select(_db.gameResults)
      ..orderBy([(g) => OrderingTerm.desc(g.createdAt)])
      ..limit(limit);
    if (gameType != null) {
      query.where((g) => g.gameType.equalsValue(gameType));
    }
    return query.watch();
  }

  /// 게임 홈 화면의 4개 타일에 표시할 게임별 승/패/무 집계.
  Stream<List<GameSummary>> watchSummary() {
    return _db.select(_db.gameResults).watch().map((rows) {
      final byType = <GameType, List<GameResult>>{};
      for (final row in rows) {
        (byType[row.gameType] ??= []).add(row);
      }
      return [
        for (final type in GameType.values)
          GameSummary(
            gameType: type,
            wins: (byType[type] ?? const []).where((r) => r.outcome == GameOutcome.win).length,
            losses: (byType[type] ?? const []).where((r) => r.outcome == GameOutcome.loss).length,
            draws: (byType[type] ?? const []).where((r) => r.outcome == GameOutcome.draw).length,
          ),
      ];
    });
  }
}
