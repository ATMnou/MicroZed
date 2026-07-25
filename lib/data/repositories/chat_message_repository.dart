import 'package:drift/drift.dart';

import '../db/database.dart';

/// 채팅 화면의 메시지 스트림/전송을 담당한다.
class ChatMessageRepository {
  ChatMessageRepository(this._db);

  final AppDatabase _db;

  Stream<List<ChatMessage>> watchBySession(int sessionId) {
    return (_db.select(_db.chatMessages)
          ..where((m) => m.sessionId.equals(sessionId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .watch();
  }

  Future<int> send({
    required int sessionId,
    required MessageSender senderType,
    int? characterId,
    required String content,
    String? speakerNameOverride,
  }) async {
    final id = await _db.into(_db.chatMessages).insert(
          ChatMessagesCompanion.insert(
            sessionId: sessionId,
            senderType: senderType,
            characterId: Value(characterId),
            content: content,
            speakerNameOverride: Value(speakerNameOverride),
          ),
        );
    await (_db.update(_db.chatSessions)..where((s) => s.id.equals(sessionId))).write(
      ChatSessionsCompanion(updatedAt: Value(DateTime.now())),
    );
    return id;
  }

  Future<void> delete(int id) => (_db.delete(_db.chatMessages)..where((m) => m.id.equals(id))).go();
}
