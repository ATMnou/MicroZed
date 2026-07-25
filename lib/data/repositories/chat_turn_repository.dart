import 'package:drift/drift.dart';

import '../ai/message_format_parser.dart';
import '../db/database.dart';

/// 채팅 화면에 그릴 말풍선 한 개 + 그 말풍선이 속한 턴의 메타데이터.
class ChatTimelineItem {
  const ChatTimelineItem({
    required this.message,
    this.turn,
    this.versionCount = 1,
    this.isLastBubbleOfTurn = false,
  });

  final ChatMessage message;

  /// null이면 유저가 직접 보낸 메시지.
  final ChatTurn? turn;

  /// 이 턴에 재시도/AI 수정으로 쌓인 버전이 몇 개인지(유저 메시지는 항상 1).
  final int versionCount;

  /// 이 말풍선이 현재 활성 버전의 마지막 말풍선인지. 액션 버튼(수정/AI 수정/재시도, `<``>`)은
  /// 세션 전체에서 가장 마지막 턴의 마지막 말풍선 아래에만 그린다.
  final bool isLastBubbleOfTurn;
}

/// AI 응답(또는 인트로)의 턴/버전 관리를 담당한다.
///
/// 한 턴(ChatTurn)은 유저 메시지 하나에 대한 응답(또는 대화 시작 시 인트로)이고, 재시도/AI 수정을
/// 할 때마다 같은 턴 아래 새 버전(versionIndex)이 쌓인다. 화면에는 턴마다 activeVersionIndex가
/// 가리키는 버전의 말풍선들만 보여준다.
class ChatTurnRepository {
  ChatTurnRepository(this._db);

  final AppDatabase _db;

  Future<int> createTurn(int sessionId) {
    return _db.into(_db.chatTurns).insert(ChatTurnsCompanion.insert(sessionId: sessionId));
  }

  Future<ChatTurn?> getTurn(int turnId) {
    return (_db.select(_db.chatTurns)..where((t) => t.id.equals(turnId))).getSingleOrNull();
  }

  Future<int> nextVersionIndex(int turnId) async {
    final maxExp = _db.chatMessages.versionIndex.max();
    final query = _db.selectOnly(_db.chatMessages)
      ..addColumns([maxExp])
      ..where(_db.chatMessages.turnId.equals(turnId));
    final row = await query.getSingle();
    return (row.read(maxExp) ?? -1) + 1;
  }

  Future<void> setActiveVersion(int turnId, int versionIndex) {
    return (_db.update(_db.chatTurns)..where((t) => t.id.equals(turnId))).write(
      ChatTurnsCompanion(activeVersionIndex: Value(versionIndex)),
    );
  }

  Future<void> addVersionMessages({
    required int sessionId,
    required int turnId,
    required int versionIndex,
    required List<ParsedSpeechSegment> segments,
    required int? Function(String speakerName) resolveCharacterId,
  }) async {
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final isCharacter = segment.senderType == MessageSender.character && segment.speakerName != null;
      final characterId = isCharacter ? resolveCharacterId(segment.speakerName!) : null;
      await _db.into(_db.chatMessages).insert(
            ChatMessagesCompanion.insert(
              sessionId: sessionId,
              senderType: segment.senderType,
              characterId: Value(characterId),
              content: segment.content,
              speakerNameOverride: Value(isCharacter && characterId == null ? segment.speakerName : null),
              turnId: Value(turnId),
              versionIndex: Value(versionIndex),
              turnSortOrder: Value(i),
            ),
          );
    }
    await (_db.update(_db.chatSessions)..where((s) => s.id.equals(sessionId))).write(
      ChatSessionsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  /// 편집("수정")으로 텍스트가 다시 파싱됐을 때, 같은 버전의 말풍선들을 통째로 교체한다.
  Future<void> replaceVersionMessages({
    required int turnId,
    required int versionIndex,
    required List<ParsedSpeechSegment> segments,
    required int? Function(String speakerName) resolveCharacterId,
  }) async {
    final existing = await (_db.select(_db.chatMessages)
          ..where((m) => m.turnId.equals(turnId) & m.versionIndex.equals(versionIndex)))
        .get();
    if (existing.isEmpty) return;
    final sessionId = existing.first.sessionId;

    await (_db.delete(_db.chatMessages)
          ..where((m) => m.turnId.equals(turnId) & m.versionIndex.equals(versionIndex)))
        .go();
    await addVersionMessages(
      sessionId: sessionId,
      turnId: turnId,
      versionIndex: versionIndex,
      segments: segments,
      resolveCharacterId: resolveCharacterId,
    );
  }

  /// [messageId]와 그 이후의 모든 말풍선(유저 메시지 + AI 턴 전체, 재시도로 쌓인
  /// 버전 전부 포함)을 지운다. 유저 말풍선 메뉴의 '삭제'가 사용한다.
  Future<void> deleteFromMessage(int sessionId, int messageId) async {
    final timeline = await timelineOnce(sessionId);
    final idx = timeline.indexWhere((item) => item.message.id == messageId);
    if (idx == -1) return;
    final toDelete = timeline.sublist(idx);

    final turnIds = <int>{};
    final userMessageIds = <int>{};
    for (final item in toDelete) {
      if (item.turn != null) {
        turnIds.add(item.turn!.id);
      } else {
        userMessageIds.add(item.message.id);
      }
    }
    if (turnIds.isNotEmpty) {
      await (_db.delete(_db.chatTurns)..where((t) => t.id.isIn(turnIds))).go();
    }
    if (userMessageIds.isNotEmpty) {
      await (_db.delete(_db.chatMessages)..where((m) => m.id.isIn(userMessageIds))).go();
    }
  }

  Future<List<ChatMessage>> getVersionMessages(int turnId, int versionIndex) {
    return (_db.select(_db.chatMessages)
          ..where((m) => m.turnId.equals(turnId) & m.versionIndex.equals(versionIndex))
          ..orderBy([(m) => OrderingTerm.asc(m.turnSortOrder)]))
        .get();
  }

  Stream<List<ChatTimelineItem>> watchTimeline(int sessionId) {
    final query = _db.select(_db.chatMessages).join([
      leftOuterJoin(_db.chatTurns, _db.chatTurns.id.equalsExp(_db.chatMessages.turnId)),
    ])
      ..where(_db.chatMessages.sessionId.equals(sessionId));

    return query.watch().map((rows) => _resolveTimeline(rows));
  }

  Future<List<ChatTimelineItem>> timelineOnce(int sessionId) async {
    final query = _db.select(_db.chatMessages).join([
      leftOuterJoin(_db.chatTurns, _db.chatTurns.id.equalsExp(_db.chatMessages.turnId)),
    ])
      ..where(_db.chatMessages.sessionId.equals(sessionId));
    final rows = await query.get();
    return _resolveTimeline(rows);
  }

  /// [turnId]가 처음 만들어졌을 당시의 대화 상태(그 턴 자체는 제외)를 반환한다.
  /// 재시도/AI 수정 시 원래 있던 맥락과 동일한 히스토리로 다시 생성하기 위해 쓴다.
  Future<List<ChatMessage>> historyBeforeTurn(int sessionId, int? beforeTurnId) async {
    final timeline = await timelineOnce(sessionId);
    if (beforeTurnId == null) return timeline.map((i) => i.message).toList();
    final idx = timeline.indexWhere((i) => i.turn?.id == beforeTurnId);
    if (idx == -1) return timeline.map((i) => i.message).toList();
    return timeline.sublist(0, idx).map((i) => i.message).toList();
  }

  List<ChatTimelineItem> _resolveTimeline(List<TypedResult> rows) {
    final allMessages = <ChatMessage>[];
    final turnById = <int, ChatTurn>{};
    for (final row in rows) {
      final message = row.readTable(_db.chatMessages);
      allMessages.add(message);
      if (message.turnId != null) {
        final turn = row.readTableOrNull(_db.chatTurns);
        if (turn != null) turnById[message.turnId!] = turn;
      }
    }

    final versionCountByTurn = <int, int>{};
    for (final m in allMessages) {
      if (m.turnId == null) continue;
      final versions = allMessages.where((x) => x.turnId == m.turnId).map((x) => x.versionIndex).toSet();
      versionCountByTurn[m.turnId!] = versions.length;
    }

    final visible = allMessages.where((m) {
      if (m.turnId == null) return true;
      final turn = turnById[m.turnId];
      return turn != null && m.versionIndex == turn.activeVersionIndex;
    }).toList();

    visible.sort((a, b) {
      final aKey = a.turnId != null ? turnById[a.turnId]!.createdAt : a.createdAt;
      final bKey = b.turnId != null ? turnById[b.turnId]!.createdAt : b.createdAt;
      final cmp = aKey.compareTo(bKey);
      if (cmp != 0) return cmp;
      if (a.turnId != null && a.turnId == b.turnId) {
        return a.turnSortOrder.compareTo(b.turnSortOrder);
      }
      return a.id.compareTo(b.id);
    });

    return List.generate(visible.length, (index) {
      final m = visible[index];
      final next = index + 1 < visible.length ? visible[index + 1] : null;
      return ChatTimelineItem(
        message: m,
        turn: m.turnId != null ? turnById[m.turnId] : null,
        versionCount: m.turnId != null ? (versionCountByTurn[m.turnId!] ?? 1) : 1,
        isLastBubbleOfTurn: m.turnId != null && (next == null || next.turnId != m.turnId),
      );
    });
  }
}
