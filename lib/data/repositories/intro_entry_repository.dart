import 'package:drift/drift.dart';

import '../db/database.dart';

/// 플롯의 인트로(첫 상황) 버전 관리 + 버전별 '첫 상황' 줄들의 CRUD.
///
/// 인트로는 플롯 하나에 여러 버전을 만들 수 있고(대안 오프닝), 채팅 시작 시 이 버전들이
/// [ChatTurns]의 versionIndex로 그대로 옮겨져서 '<, >'로 넘겨볼 수 있게 된다.
class IntroEntryRepository {
  IntroEntryRepository(this._db);

  final AppDatabase _db;

  /// 예전 스키마(플롯당 인트로 1세트)로 만들어진 플롯도 계속 쓸 수 있도록, 버전이
  /// 하나도 없으면 기본 버전을 만들고 introVersionId가 비어있는 기존 항목들을 편입시킨다.
  Future<int> ensureDefaultVersion(int plotId) async {
    final existing = await (_db.select(_db.introVersions)
          ..where((v) => v.plotId.equals(plotId))
          ..orderBy([(v) => OrderingTerm.asc(v.sortOrder)])
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) {
      await ensurePlayableCharacterPickEntry(plotId, existing.id);
      return existing.id;
    }

    final versionId = await _db.into(_db.introVersions).insert(
          IntroVersionsCompanion.insert(plotId: plotId),
        );
    await (_db.update(_db.introEntries)
          ..where((e) => e.plotId.equals(plotId) & e.introVersionId.isNull()))
        .write(IntroEntriesCompanion(introVersionId: Value(versionId)));
    await ensurePlayableCharacterPickEntry(plotId, versionId);
    return versionId;
  }

  Stream<List<IntroVersion>> watchVersions(int plotId) {
    return (_db.select(_db.introVersions)
          ..where((v) => v.plotId.equals(plotId))
          ..orderBy([(v) => OrderingTerm.asc(v.sortOrder)]))
        .watch();
  }

  Future<List<IntroVersion>> getVersions(int plotId) async {
    await ensureDefaultVersion(plotId);
    return (_db.select(_db.introVersions)
          ..where((v) => v.plotId.equals(plotId))
          ..orderBy([(v) => OrderingTerm.asc(v.sortOrder)]))
        .get();
  }

  Future<int> addVersion(int plotId) async {
    final maxOrderExp = _db.introVersions.sortOrder.max();
    final query = _db.selectOnly(_db.introVersions)
      ..addColumns([maxOrderExp])
      ..where(_db.introVersions.plotId.equals(plotId));
    final row = await query.getSingle();
    final nextOrder = (row.read(maxOrderExp) ?? -1) + 1;
    final versionId = await _db.into(_db.introVersions).insert(
          IntroVersionsCompanion.insert(plotId: plotId, sortOrder: Value(nextOrder)),
        );
    await ensurePlayableCharacterPickEntry(plotId, versionId);
    return versionId;
  }

  Future<void> deleteVersion(int id) => (_db.delete(_db.introVersions)..where((v) => v.id.equals(id))).go();

  Stream<List<IntroEntry>> watchByVersion(int introVersionId) {
    return (_db.select(_db.introEntries)
          ..where((e) => e.introVersionId.equals(introVersionId))
          ..orderBy([(e) => OrderingTerm.asc(e.sortOrder)]))
        .watch();
  }

  Future<List<IntroEntry>> getByVersion(int introVersionId) {
    return (_db.select(_db.introEntries)
          ..where((e) => e.introVersionId.equals(introVersionId))
          ..orderBy([(e) => OrderingTerm.asc(e.sortOrder)]))
        .get();
  }

  Future<int> add({
    required int plotId,
    required int introVersionId,
    int? characterId,
    required IntroEntryType type,
    required String content,
    int? vnBackgroundId,
    VnEmotion? vnExpression,
    VnSceneType vnSceneType = VnSceneType.dialogue,
  }) async {
    final nextOrder = await _nextSortOrder(introVersionId);
    return _db.into(_db.introEntries).insert(
          IntroEntriesCompanion.insert(
            plotId: plotId,
            introVersionId: Value(introVersionId),
            characterId: Value(characterId),
            type: type,
            content: content,
            sortOrder: Value(nextOrder),
            vnBackgroundId: Value(vnBackgroundId),
            vnExpression: Value(vnExpression),
            vnSceneType: Value(vnSceneType),
          ),
        );
  }

  Future<void> updateVnFields(
    int id, {
    String? content,
    int? vnBackgroundId,
    bool clearBackground = false,
    VnEmotion? vnExpression,
    bool clearExpression = false,
    VnSceneType? vnSceneType,
    int? characterId,
    bool clearCharacter = false,
  }) {
    return (_db.update(_db.introEntries)..where((e) => e.id.equals(id))).write(
      IntroEntriesCompanion(
        content: content != null ? Value(content) : const Value.absent(),
        vnBackgroundId: clearBackground
            ? const Value(null)
            : (vnBackgroundId != null ? Value(vnBackgroundId) : const Value.absent()),
        vnExpression:
            clearExpression ? const Value(null) : (vnExpression != null ? Value(vnExpression) : const Value.absent()),
        vnSceneType: vnSceneType != null ? Value(vnSceneType) : const Value.absent(),
        characterId:
            clearCharacter ? const Value(null) : (characterId != null ? Value(characterId) : const Value.absent()),
      ),
    );
  }

  // ── 비주얼 노벨: 인트로 버전에 붙는 선택지 ───────────────────────────────

  Stream<List<VnChoice>> watchChoices(int introVersionId) {
    return (_db.select(_db.vnChoices)
          ..where((c) => c.introVersionId.equals(introVersionId))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  Future<List<VnChoice>> getChoices(int introVersionId) {
    return (_db.select(_db.vnChoices)
          ..where((c) => c.introVersionId.equals(introVersionId))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  Future<int> addChoice({
    required int introVersionId,
    required String content,
    bool useDice = false,
    VnDiceDifficulty? difficulty,
  }) async {
    final maxOrderExp = _db.vnChoices.sortOrder.max();
    final query = _db.selectOnly(_db.vnChoices)
      ..addColumns([maxOrderExp])
      ..where(_db.vnChoices.introVersionId.equals(introVersionId));
    final row = await query.getSingle();
    final nextOrder = (row.read(maxOrderExp) ?? -1) + 1;
    return _db.into(_db.vnChoices).insert(
          VnChoicesCompanion.insert(
            introVersionId: introVersionId,
            content: content,
            sortOrder: Value(nextOrder),
            useDice: Value(useDice),
            difficulty: Value(difficulty),
          ),
        );
  }

  Future<void> updateChoice({
    required int id,
    String? content,
    bool? useDice,
    VnDiceDifficulty? difficulty,
    bool clearDifficulty = false,
  }) {
    return (_db.update(_db.vnChoices)..where((c) => c.id.equals(id))).write(
      VnChoicesCompanion(
        content: content != null ? Value(content) : const Value.absent(),
        useDice: useDice != null ? Value(useDice) : const Value.absent(),
        difficulty: clearDifficulty ? const Value(null) : (difficulty != null ? Value(difficulty) : const Value.absent()),
      ),
    );
  }

  Future<void> deleteChoice(int id) => (_db.delete(_db.vnChoices)..where((c) => c.id.equals(id))).go();

  Future<int> _nextSortOrder(int introVersionId) async {
    final maxOrderExp = _db.introEntries.sortOrder.max();
    final query = _db.selectOnly(_db.introEntries)
      ..addColumns([maxOrderExp])
      ..where(_db.introEntries.introVersionId.equals(introVersionId));
    final row = await query.getSingle();
    return (row.read(maxOrderExp) ?? -1) + 1;
  }

  /// 플롯에 플레이어블 캐릭터가 1개 이상 있는데 이 인트로 버전에 아직 '플레이어블 캐릭터
  /// 선택' 마커 엔트리(characterPick)가 없으면 맨 앞에 하나 추가한다. 이미 있으면 아무 것도
  /// 하지 않는다(위치는 작가가 드래그로 옮긴 그대로 유지) - 인트로 탭 진입 시마다 호출해도
  /// 안전한 idempotent 동작이다.
  Future<void> ensurePlayableCharacterPickEntry(int plotId, int introVersionId) async {
    final hasPlayable = await (_db.select(_db.characters)
          ..where((c) => c.plotId.equals(plotId) & c.isPlayable.equals(true))
          ..limit(1))
        .getSingleOrNull();
    if (hasPlayable == null) return;

    final existingPick = await (_db.select(_db.introEntries)
          ..where((e) =>
              e.introVersionId.equals(introVersionId) & e.type.equalsValue(IntroEntryType.characterPick))
          ..limit(1))
        .getSingleOrNull();
    if (existingPick != null) return;

    final currentEntries = await getByVersion(introVersionId);
    final pickId = await _db.into(_db.introEntries).insert(
          IntroEntriesCompanion.insert(
            plotId: plotId,
            introVersionId: Value(introVersionId),
            type: IntroEntryType.characterPick,
            content: '',
            sortOrder: Value(currentEntries.length),
          ),
        );
    await reorder([pickId, ...currentEntries.map((e) => e.id)]);
  }

  Future<void> updateContent(int id, String content) {
    return (_db.update(_db.introEntries)..where((e) => e.id.equals(id))).write(
      IntroEntriesCompanion(content: Value(content)),
    );
  }

  Future<void> delete(int id) => (_db.delete(_db.introEntries)..where((e) => e.id.equals(id))).go();

  /// 드래그로 순서를 바꾼 뒤, 새 순서 그대로 sortOrder를 다시 매긴다.
  Future<void> reorder(List<int> orderedEntryIds) async {
    for (var i = 0; i < orderedEntryIds.length; i++) {
      await (_db.update(_db.introEntries)..where((e) => e.id.equals(orderedEntryIds[i]))).write(
        IntroEntriesCompanion(sortOrder: Value(i)),
      );
    }
  }
}
