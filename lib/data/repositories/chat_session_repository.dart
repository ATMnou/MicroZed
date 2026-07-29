import 'package:drift/drift.dart';

import '../db/database.dart';
import 'chat_turn_repository.dart';
import 'intro_entry_repository.dart';

/// 대화 세션 1건 + 목록 표시용 부가 정보(플롯 제목, 마지막 메시지 미리보기).
class ChatSessionSummary {
  const ChatSessionSummary({
    required this.session,
    required this.plotTitle,
    required this.lastMessagePreview,
    this.plotCoverImagePath,
  });

  final ChatSession session;
  final String plotTitle;
  final String lastMessagePreview;
  final String? plotCoverImagePath;
}

/// 대화 탭의 대화방 목록과 채팅 화면 진입/설정 변경을 담당한다.
///
/// 세션은 두 종류로 나뉜다: `archivedAt`이 null인 '활성' 세션(플롯당 최대 1개, 대화 탭에
/// 노출)과, '새로하기'로 저장되어 `archivedAt`에 저장 시각이 채워진 보관 세션('이어하기'
/// 목록에만 노출).
class ChatSessionRepository {
  ChatSessionRepository(this._db);

  final AppDatabase _db;

  Stream<List<ChatSessionSummary>> watchAll() {
    final query = _db.select(_db.chatSessions).join([
      innerJoin(_db.plots, _db.plots.id.equalsExp(_db.chatSessions.plotId)),
    ])
      ..where(_db.chatSessions.archivedAt.isNull())
      ..orderBy([OrderingTerm.desc(_db.chatSessions.updatedAt)]);

    return query.watch().asyncMap((rows) async {
      final summaries = <ChatSessionSummary>[];
      for (final row in rows) {
        final session = row.readTable(_db.chatSessions);
        final plot = row.readTable(_db.plots);
        summaries.add(ChatSessionSummary(
          session: session,
          plotTitle: plot.title,
          plotCoverImagePath: plot.coverImagePath,
          lastMessagePreview: await _lastMessagePreview(session.id),
        ));
      }
      return summaries;
    });
  }

  /// 채팅 화면의 '이어하기' 목록. 특정 플롯의 보관된(저장된) 대화들을 최신순으로 보여준다.
  Stream<List<ChatSessionSummary>> watchArchivedByPlot(int plotId) {
    final query = _db.select(_db.chatSessions)
      ..where((s) => s.plotId.equals(plotId) & s.archivedAt.isNotNull())
      ..orderBy([(s) => OrderingTerm.desc(s.archivedAt)]);

    return query.watch().asyncMap((sessions) async {
      final summaries = <ChatSessionSummary>[];
      for (final session in sessions) {
        summaries.add(ChatSessionSummary(
          session: session,
          plotTitle: '',
          lastMessagePreview: await _lastMessagePreview(session.id),
        ));
      }
      return summaries;
    });
  }

  /// 목록 미리보기용 마지막 메시지. 스냅샷/인트로 이미지는 파일 경로라 미리보기로 보여줄
  /// 수 없으므로 건너뛰고, 그 앞의 마지막 텍스트 메시지를 찾는다.
  Future<String> _lastMessagePreview(int sessionId) async {
    final recentMessages = await (_db.select(_db.chatMessages)
          ..where((m) => m.sessionId.equals(sessionId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
          ..limit(20))
        .get();
    for (final message in recentMessages) {
      if (message.senderType != MessageSender.image) return message.content;
    }
    return '';
  }

  Future<ChatSession?> getById(int id) {
    return (_db.select(_db.chatSessions)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// 새 세션을 만들고, 플롯의 인트로 탭에 설정된 첫 상황을 첫 메시지들로 채워 넣는다.
  /// [conversationProfileId](전역 프로필)와 [plotConversationProfileId](이 플롯 전용 프로필)는
  /// 동시에 값이 있을 수 없다 - 새 채팅 시작 시 프로필 선택 화면에서 어느 쪽이든 하나만 골라 넘긴다.
  /// 둘 다 안 넘기면(=플롯에 전용 프로필이 없어서 선택 화면 자체가 안 뜬 경우) 마이페이지의
  /// 전역 기본 프로필로 조용히 채운다(있으면). 예전과 동일한 동작.
  Future<int> createSession({
    required int plotId,
    int? conversationProfileId,
    int? plotConversationProfileId,
    int? presetId,
  }) async {
    assert(conversationProfileId == null || plotConversationProfileId == null);
    var resolvedGlobalProfileId = conversationProfileId;
    if (resolvedGlobalProfileId == null && plotConversationProfileId == null) {
      resolvedGlobalProfileId = await _defaultConversationProfileId();
    }
    final sessionId = await _db.into(_db.chatSessions).insert(
          ChatSessionsCompanion.insert(
            plotId: plotId,
            conversationProfileId: Value(resolvedGlobalProfileId),
            plotConversationProfileId: Value(plotConversationProfileId),
            presetId: Value(presetId),
          ),
        );
    await _seedIntroMessages(sessionId, plotId);
    return sessionId;
  }

  Future<int?> _defaultConversationProfileId() async {
    final profile = await (_db.select(_db.conversationProfiles)
          ..where((p) => p.isDefault.equals(true))
          ..limit(1))
        .getSingleOrNull();
    return profile?.id;
  }

  /// 플롯에 인트로 버전이 여러 개면, 그 버전들을 전부 한 턴의 여러 '버전'으로 심어서
  /// 채팅 화면에서 '<, >'로 다른 인트로를 넘겨볼 수 있게 한다(활성 버전은 0번째).
  Future<void> _seedIntroMessages(int sessionId, int plotId) async {
    // 예전 스키마(플롯당 인트로 1세트)로 만들어진 플롯도 대응할 수 있도록 기본 버전을 보장한다.
    await IntroEntryRepository(_db).ensureDefaultVersion(plotId);
    final versions = await (_db.select(_db.introVersions)
          ..where((v) => v.plotId.equals(plotId))
          ..orderBy([(v) => OrderingTerm.asc(v.sortOrder)]))
        .get();
    if (versions.isEmpty) return;

    final turnId = await _db.into(_db.chatTurns).insert(ChatTurnsCompanion.insert(sessionId: sessionId));
    for (var v = 0; v < versions.length; v++) {
      final entries = await (_db.select(_db.introEntries)
            ..where((e) => e.introVersionId.equals(versions[v].id))
            ..orderBy([(e) => OrderingTerm.asc(e.sortOrder)]))
          .get();
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        await _db.into(_db.chatMessages).insert(
              ChatMessagesCompanion.insert(
                sessionId: sessionId,
                senderType: MessageSender.values[entry.type.index],
                characterId: Value(entry.characterId),
                content: entry.content,
                turnId: Value(turnId),
                versionIndex: Value(v),
                turnSortOrder: Value(i),
              ),
            );
      }
    }
  }

  /// 이 플롯의 활성 세션(있으면) id. 새 채팅 시작 버튼이 프로필 선택 화면을 띄울지
  /// 판단할 때 쓴다 - 이미 활성 세션이 있으면 프로필은 이미 정해져 있으니 다시 묻지 않는다.
  Future<int?> activeSessionIdForPlot(int plotId) async {
    final existing = await (_db.select(_db.chatSessions)
          ..where((s) => s.plotId.equals(plotId) & s.archivedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return existing?.id;
  }

  Future<void> setPreset(int sessionId, int presetId) {
    return (_db.update(_db.chatSessions)..where((s) => s.id.equals(sessionId))).write(
      ChatSessionsCompanion(presetId: Value(presetId), updatedAt: Value(DateTime.now())),
    );
  }

  /// 전역 프로필로 전환한다. [conversationProfileId]와 [plotConversationProfileId]는
  /// 동시에 값이 있을 수 없으므로 플롯 전용 프로필 쪽은 함께 지운다.
  Future<void> setConversationProfile(int sessionId, int profileId) {
    return (_db.update(_db.chatSessions)..where((s) => s.id.equals(sessionId))).write(
      ChatSessionsCompanion(
        conversationProfileId: Value(profileId),
        plotConversationProfileId: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 플롯 전용 프로필로 전환한다. 전역 프로필 쪽은 함께 지운다.
  Future<void> setPlotConversationProfile(int sessionId, int plotProfileId) {
    return (_db.update(_db.chatSessions)..where((s) => s.id.equals(sessionId))).write(
      ChatSessionsCompanion(
        plotConversationProfileId: Value(plotProfileId),
        conversationProfileId: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 채팅 화면 드로어의 '새로하기'. saveCurrent가 true면 현재 세션을 보관 처리해 '이어하기'에
  /// 남기고, false면 완전히 삭제한다. 어느 쪽이든 같은 플롯의 새 활성 세션을 만들어 id를 반환한다.
  Future<int> startFresh({
    required int plotId,
    required int currentSessionId,
    required bool saveCurrent,
  }) async {
    final current = await getById(currentSessionId);
    if (saveCurrent) {
      await (_db.update(_db.chatSessions)..where((s) => s.id.equals(currentSessionId))).write(
        ChatSessionsCompanion(archivedAt: Value(DateTime.now())),
      );
    } else {
      await (_db.delete(_db.chatSessions)..where((s) => s.id.equals(currentSessionId))).go();
    }
    return createSession(
      plotId: plotId,
      conversationProfileId: current?.conversationProfileId,
      plotConversationProfileId: current?.plotConversationProfileId,
      presetId: current?.presetId,
    );
  }

  /// 유저 말풍선 메뉴의 '여기서부터 새로하기'. 지금 활성 세션은 손대지 않고 그대로
  /// 보관 처리해 '이어하기'에 남기고, [uptoMessageId]까지의 대화만 복제한 새 활성 세션을
  /// 만들어 그 뒤(이후 답변 포함)를 잘라낸 상태로 이어서 진행할 수 있게 한다.
  Future<int> startFreshFromMessage({
    required int plotId,
    required int currentSessionId,
    required int uptoMessageId,
  }) async {
    final current = await getById(currentSessionId);
    final timeline = await ChatTurnRepository(_db).timelineOnce(currentSessionId);
    final cutIndex = timeline.indexWhere((item) => item.message.id == uptoMessageId);
    final itemsToCopy = cutIndex == -1 ? timeline : timeline.sublist(0, cutIndex + 1);

    await (_db.update(_db.chatSessions)..where((s) => s.id.equals(currentSessionId))).write(
      ChatSessionsCompanion(archivedAt: Value(DateTime.now())),
    );
    final newSessionId = await _db.into(_db.chatSessions).insert(
          ChatSessionsCompanion.insert(
            plotId: plotId,
            conversationProfileId: Value(current?.conversationProfileId),
            plotConversationProfileId: Value(current?.plotConversationProfileId),
            presetId: Value(current?.presetId),
          ),
        );

    final turnIdMap = <int, int>{};
    for (final item in itemsToCopy) {
      final message = item.message;
      int? newTurnId;
      if (item.turn != null) {
        newTurnId = turnIdMap[item.turn!.id];
        if (newTurnId == null) {
          newTurnId = await _db.into(_db.chatTurns).insert(ChatTurnsCompanion.insert(sessionId: newSessionId));
          turnIdMap[item.turn!.id] = newTurnId;
        }
      }
      await _db.into(_db.chatMessages).insert(
            ChatMessagesCompanion.insert(
              sessionId: newSessionId,
              senderType: message.senderType,
              characterId: Value(message.characterId),
              content: message.content,
              speakerNameOverride: Value(message.speakerNameOverride),
              turnId: Value(newTurnId),
              versionIndex: const Value(0),
              turnSortOrder: Value(message.turnSortOrder),
            ),
          );
    }
    return newSessionId;
  }

  /// 채팅 화면 드로어의 '이어하기'에서 보관된 세션을 선택했을 때 호출한다.
  /// 지금 활성 세션은 보관 처리해 유실 없이 남기고, 선택한 세션을 활성 상태로 되돌린다.
  Future<int> resume({
    required int currentSessionId,
    required int archivedSessionId,
  }) async {
    await (_db.update(_db.chatSessions)..where((s) => s.id.equals(currentSessionId))).write(
      ChatSessionsCompanion(archivedAt: Value(DateTime.now())),
    );
    await (_db.update(_db.chatSessions)..where((s) => s.id.equals(archivedSessionId))).write(
      ChatSessionsCompanion(archivedAt: const Value(null), updatedAt: Value(DateTime.now())),
    );
    return archivedSessionId;
  }

  Future<void> delete(int sessionId) => (_db.delete(_db.chatSessions)..where((s) => s.id.equals(sessionId))).go();
}
