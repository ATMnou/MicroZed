import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/db/database.dart';
import 'package:microzed/data/repositories/chat_memory_repository.dart';
import 'package:microzed/data/repositories/plot_repository.dart';

void main() {
  test('세션당 요약은 하나만 유지되고, upsert마다 덮어써진다', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final plotRepo = PlotRepository(db);
    final memoryRepo = ChatMemoryRepository(db);

    final plotId = await plotRepo.upsertPlot(title: '테스트 플롯', description: '설명');
    final sessionId = await db.into(db.chatSessions).insert(
          ChatSessionsCompanion.insert(plotId: plotId),
        );

    expect(await memoryRepo.getForSession(sessionId), isNull);

    await memoryRepo.upsert(sessionId: sessionId, coveredUpToMessageId: 10, summaryText: '첫 요약');
    final first = await memoryRepo.getForSession(sessionId);
    expect(first?.summaryText, '첫 요약');
    expect(first?.coveredUpToMessageId, 10);

    // 경계가 더 늘어나서 다시 요약하면, 새 행을 추가하는 게 아니라 같은 행을 덮어써야 한다.
    await memoryRepo.upsert(sessionId: sessionId, coveredUpToMessageId: 25, summaryText: '갱신된 요약');
    final second = await memoryRepo.getForSession(sessionId);
    expect(second?.summaryText, '갱신된 요약');
    expect(second?.coveredUpToMessageId, 25);
    expect(second?.id, first?.id);

    final all = await db.select(db.chatMemorySummaries).get();
    expect(all, hasLength(1));
  });

  test('다른 세션의 요약과 서로 섞이지 않는다', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final plotRepo = PlotRepository(db);
    final memoryRepo = ChatMemoryRepository(db);
    final plotId = await plotRepo.upsertPlot(title: '테스트 플롯', description: '설명');
    final sessionId1 = await db.into(db.chatSessions).insert(
          ChatSessionsCompanion.insert(plotId: plotId),
        );
    final sessionId2 = await db.into(db.chatSessions).insert(
          ChatSessionsCompanion.insert(plotId: plotId),
        );

    await memoryRepo.upsert(sessionId: sessionId1, coveredUpToMessageId: 1, summaryText: '세션1 요약');
    await memoryRepo.upsert(sessionId: sessionId2, coveredUpToMessageId: 2, summaryText: '세션2 요약');

    expect((await memoryRepo.getForSession(sessionId1))?.summaryText, '세션1 요약');
    expect((await memoryRepo.getForSession(sessionId2))?.summaryText, '세션2 요약');
  });
}
