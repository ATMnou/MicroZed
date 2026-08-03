import 'package:drift/drift.dart';

import '../db/database.dart';

/// 세션마다 1행씩 쌓이는 장기 기억(오래된 대화 요약) CRUD.
class ChatMemoryRepository {
  ChatMemoryRepository(this._db);

  final AppDatabase _db;

  Future<ChatMemorySummary?> getForSession(int sessionId) {
    return (_db.select(_db.chatMemorySummaries)..where((s) => s.sessionId.equals(sessionId))).getSingleOrNull();
  }

  Stream<ChatMemorySummary?> watchForSession(int sessionId) {
    return (_db.select(_db.chatMemorySummaries)..where((s) => s.sessionId.equals(sessionId)))
        .watchSingleOrNull();
  }

  /// 세션당 요약은 하나뿐이라(누적/재요약 방식), 있으면 덮어쓰고 없으면 새로 만든다.
  Future<void> upsert({
    required int sessionId,
    required int coveredUpToMessageId,
    required String summaryText,
  }) async {
    final existing = await getForSession(sessionId);
    if (existing == null) {
      await _db.into(_db.chatMemorySummaries).insert(
            ChatMemorySummariesCompanion.insert(
              sessionId: sessionId,
              coveredUpToMessageId: coveredUpToMessageId,
              summaryText: summaryText,
            ),
          );
    } else {
      await (_db.update(_db.chatMemorySummaries)..where((s) => s.id.equals(existing.id))).write(
        ChatMemorySummariesCompanion(
          coveredUpToMessageId: Value(coveredUpToMessageId),
          summaryText: Value(summaryText),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }
}
