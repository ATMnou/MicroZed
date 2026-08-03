import 'package:drift/drift.dart';

import '../db/database.dart';

/// 전체 내역의 합계(마이페이지 요약 카드가 사용).
class TokenUsageTotals {
  const TokenUsageTotals({required this.promptTokens, required this.completionTokens, required this.costUsd});

  final int promptTokens;
  final int completionTokens;
  final double costUsd;

  int get totalTokens => promptTokens + completionTokens;
}

/// AI 응답마다 쌓이는 토큰/가격 사용 내역.
class TokenUsageRepository {
  TokenUsageRepository(this._db);

  final AppDatabase _db;

  Future<void> log({
    required String presetName,
    required String baseUrl,
    required String modelName,
    required int promptTokens,
    required int completionTokens,
    double? costUsd,
    String? provider,
  }) {
    return _db.into(_db.tokenUsageLogs).insert(
          TokenUsageLogsCompanion.insert(
            presetName: presetName,
            baseUrl: baseUrl,
            modelName: modelName,
            promptTokens: Value(promptTokens),
            completionTokens: Value(completionTokens),
            costUsd: Value(costUsd),
            provider: Value(provider),
          ),
        );
  }

  Stream<List<TokenUsageLog>> watchAll() {
    return (_db.select(_db.tokenUsageLogs)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Stream<TokenUsageTotals> watchTotals() {
    return watchAll().map((logs) {
      var prompt = 0;
      var completion = 0;
      var cost = 0.0;
      for (final log in logs) {
        prompt += log.promptTokens;
        completion += log.completionTokens;
        cost += log.costUsd ?? 0;
      }
      return TokenUsageTotals(promptTokens: prompt, completionTokens: completion, costUsd: cost);
    });
  }

  Future<void> deleteAll() => _db.delete(_db.tokenUsageLogs).go();
}
