import 'package:drift/drift.dart';

import '../db/database.dart';

/// ZedTalk 메시지 CRUD. 턴/버전 없이 보낸 순서 그대로 쌓고, 세션의 updatedAt만 갱신한다.
class TalkMessageRepository {
  TalkMessageRepository(this._db);

  final AppDatabase _db;

  // id는 삽입 순서와 정확히 같아서(자동 증가), createdAt이 밀리초 단위로 겹칠 수 있는
  // 상황에서도 항상 보낸 순서대로 정렬된다.
  Stream<List<TalkMessage>> watchBySession(int sessionId) {
    return (_db.select(_db.talkMessages)
          ..where((m) => m.sessionId.equals(sessionId))
          ..orderBy([(m) => OrderingTerm.asc(m.id)]))
        .watch();
  }

  Future<List<TalkMessage>> getBySession(int sessionId) {
    return (_db.select(_db.talkMessages)
          ..where((m) => m.sessionId.equals(sessionId))
          ..orderBy([(m) => OrderingTerm.asc(m.id)]))
        .get();
  }

  Future<int> send({
    required int sessionId,
    required TalkMessageSender sender,
    required String content,
    String? attachmentPath,
    TalkAttachmentType? attachmentType,
  }) async {
    final id = await _db.into(_db.talkMessages).insert(
          TalkMessagesCompanion.insert(
            sessionId: sessionId,
            sender: sender,
            content: Value(content),
            attachmentPath: Value(attachmentPath),
            attachmentType: Value(attachmentType),
          ),
        );
    await (_db.update(_db.talkSessions)..where((s) => s.id.equals(sessionId))).write(
      TalkSessionsCompanion(updatedAt: Value(DateTime.now())),
    );
    return id;
  }

  Future<void> delete(int messageId) => (_db.delete(_db.talkMessages)..where((m) => m.id.equals(messageId))).go();
}
