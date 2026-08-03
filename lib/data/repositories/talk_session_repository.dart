import 'package:drift/drift.dart';

import '../db/database.dart';

/// ZedTalk 세션 1건 + 목록 표시용 부가 정보(플롯 제목, 마지막 메시지 미리보기).
class TalkSessionSummary {
  const TalkSessionSummary({
    required this.session,
    required this.plotTitle,
    required this.lastMessagePreview,
    this.plotCoverImagePath,
  });

  final TalkSession session;
  final String plotTitle;
  final String lastMessagePreview;
  final String? plotCoverImagePath;
}

/// 대화 탭 '톡' 목록과 ZedTalk 세션 생성/삭제를 담당한다. 롤플레이용
/// [ChatSessionRepository]와 달리 턴/버전/보관(이어하기) 개념이 없는 단순한 목록이다.
class TalkSessionRepository {
  TalkSessionRepository(this._db);

  final AppDatabase _db;

  Stream<List<TalkSessionSummary>> watchAll() {
    final query = _db.select(_db.talkSessions).join([
      innerJoin(_db.plots, _db.plots.id.equalsExp(_db.talkSessions.plotId)),
    ])
      // updatedAt만으로는 밀리초 단위로 겹칠 수 있어 id를 2차 정렬 기준으로 더한다.
      ..orderBy([
        OrderingTerm.desc(_db.talkSessions.updatedAt),
        OrderingTerm.desc(_db.talkSessions.id),
      ]);

    return query.watch().asyncMap((rows) async {
      final summaries = <TalkSessionSummary>[];
      for (final row in rows) {
        final session = row.readTable(_db.talkSessions);
        final plot = row.readTable(_db.plots);
        summaries.add(TalkSessionSummary(
          session: session,
          plotTitle: plot.title,
          plotCoverImagePath: plot.coverImagePath,
          lastMessagePreview: await _lastMessagePreview(session.id),
        ));
      }
      return summaries;
    });
  }

  Future<String> _lastMessagePreview(int sessionId) async {
    // id는 삽입 순서와 정확히 같아서(자동 증가), createdAt이 밀리초 단위로 겹칠 수 있는
    // 상황에서도 항상 정확한 마지막 메시지를 찾는다.
    final message = await (_db.select(_db.talkMessages)
          ..where((m) => m.sessionId.equals(sessionId))
          ..orderBy([(m) => OrderingTerm.desc(m.id)])
          ..limit(1))
        .getSingleOrNull();
    return message?.content ?? '';
  }

  Future<TalkSession?> getById(int id) =>
      (_db.select(_db.talkSessions)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// 캐릭터 상세 화면의 'ZedTalk' 버튼에서 쓴다. 롤플레이와 달리 플롯당 여러 톡방을
  /// 만들 수 있지만, 버튼을 누르면 가장 최근에 갱신된 방을 이어서 여는 게 자연스러워서
  /// 그 방을 찾아 돌려준다(없으면 null, 호출부가 새로 만든다).
  Future<int?> mostRecentSessionIdForPlot(int plotId) async {
    final session = await (_db.select(_db.talkSessions)
          ..where((s) => s.plotId.equals(plotId))
          ..orderBy([(s) => OrderingTerm.desc(s.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
    return session?.id;
  }

  Future<int> createSession({required int plotId, int? presetId}) {
    return _db.into(_db.talkSessions).insert(
          TalkSessionsCompanion.insert(plotId: plotId, presetId: Value(presetId)),
        );
  }

  Future<void> setPreset(int sessionId, int presetId) {
    return (_db.update(_db.talkSessions)..where((s) => s.id.equals(sessionId))).write(
      TalkSessionsCompanion(presetId: Value(presetId), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> touch(int sessionId) {
    return (_db.update(_db.talkSessions)..where((s) => s.id.equals(sessionId))).write(
      TalkSessionsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> delete(int sessionId) => (_db.delete(_db.talkSessions)..where((s) => s.id.equals(sessionId))).go();

  Future<void> deleteMany(Iterable<int> sessionIds) =>
      (_db.delete(_db.talkSessions)..where((s) => s.id.isIn(sessionIds))).go();
}
