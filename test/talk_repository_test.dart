import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/db/database.dart';
import 'package:microzed/data/repositories/plot_repository.dart';
import 'package:microzed/data/repositories/talk_message_repository.dart';
import 'package:microzed/data/repositories/talk_session_repository.dart';

void main() {
  test('ZedTalk 세션 생성/메시지 전송이 목록 미리보기와 정렬에 반영된다', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final plotRepo = PlotRepository(db);
    final sessionRepo = TalkSessionRepository(db);
    final messageRepo = TalkMessageRepository(db);

    final plotId = await plotRepo.upsertPlot(title: '톡 테스트 플롯', description: '설명');
    final sessionId = await sessionRepo.createSession(plotId: plotId);

    final emptySummaries = await sessionRepo.watchAll().first;
    expect(emptySummaries, hasLength(1));
    expect(emptySummaries.single.lastMessagePreview, '');

    await messageRepo.send(sessionId: sessionId, sender: TalkMessageSender.user, content: '안녕!');
    await messageRepo.send(sessionId: sessionId, sender: TalkMessageSender.character, content: '어 안녕~');

    final messages = await messageRepo.getBySession(sessionId);
    expect(messages, hasLength(2));
    expect(messages.first.content, '안녕!');
    expect(messages.first.sender, TalkMessageSender.user);
    expect(messages.last.sender, TalkMessageSender.character);

    final summaries = await sessionRepo.watchAll().first;
    expect(summaries.single.lastMessagePreview, '어 안녕~');
    expect(summaries.single.plotTitle, '톡 테스트 플롯');

    // 두 번째 세션을 만들면 최근 갱신순으로 먼저 나와야 한다.
    final sessionId2 = await sessionRepo.createSession(plotId: plotId);
    await messageRepo.send(sessionId: sessionId2, sender: TalkMessageSender.user, content: '두번째 세션');
    final reordered = await sessionRepo.watchAll().first;
    expect(reordered.first.session.id, sessionId2);

    await sessionRepo.deleteMany([sessionId, sessionId2]);
    expect(await sessionRepo.watchAll().first, isEmpty);
  });
}
