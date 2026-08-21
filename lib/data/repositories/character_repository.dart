import 'package:drift/drift.dart';

import '../db/database.dart';

/// 플롯에 속한 캐릭터 CRUD. 채팅 화면에서 발화자 이름을 표시할 때도 사용한다.
class CharacterRepository {
  CharacterRepository(this._db);

  final AppDatabase _db;

  Stream<List<Character>> watchByPlot(int plotId) {
    return (_db.select(_db.characters)
          ..where((c) => c.plotId.equals(plotId))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  Future<Character?> getById(int id) =>
      (_db.select(_db.characters)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<List<Character>> getByPlot(int plotId) {
    return (_db.select(_db.characters)
          ..where((c) => c.plotId.equals(plotId))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  /// 게임 상대 캐릭터 픽커처럼 플롯 범위를 가리지 않고 등록된 모든 캐릭터가 필요할 때 쓴다.
  Future<List<Character>> getAll() {
    return (_db.select(_db.characters)..orderBy([(c) => OrderingTerm.asc(c.name)])).get();
  }

  /// 비주얼 노벨 편집 화면의 '등장인물' 목록(플레이어블 캐릭터 제외).
  Stream<List<Character>> watchNonPlayableByPlot(int plotId) {
    return (_db.select(_db.characters)
          ..where((c) => c.plotId.equals(plotId) & c.isPlayable.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  /// 비주얼 노벨 편집 화면의 '플레이어블 캐릭터' 목록, 플레이 화면의 캐릭터 선택 목록.
  Stream<List<Character>> watchPlayableByPlot(int plotId) {
    return (_db.select(_db.characters)
          ..where((c) => c.plotId.equals(plotId) & c.isPlayable.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  Future<int> add({
    required int plotId,
    required String name,
    String description = '',
    String? imagePath,
    bool isRepresentative = false,
    int sortOrder = 0,
    String aboutText = '',
    bool isPlayable = false,
    double spriteScale = 1.0,
    double spriteOffsetX = 0.0,
    double spriteOffsetY = 0.0,
  }) {
    return _db.into(_db.characters).insert(
          CharactersCompanion.insert(
            plotId: plotId,
            name: name,
            description: Value(description),
            imagePath: Value(imagePath),
            isRepresentative: Value(isRepresentative),
            sortOrder: Value(sortOrder),
            aboutText: Value(aboutText),
            isPlayable: Value(isPlayable),
            spriteScale: Value(spriteScale),
            spriteOffsetX: Value(spriteOffsetX),
            spriteOffsetY: Value(spriteOffsetY),
          ),
        );
  }

  Future<void> update({
    required int id,
    required String name,
    required String description,
    String? imagePath,
    int? sortOrder,
    String? aboutText,
    double? spriteScale,
    double? spriteOffsetX,
    double? spriteOffsetY,
  }) {
    return (_db.update(_db.characters)..where((c) => c.id.equals(id))).write(
      CharactersCompanion(
        name: Value(name),
        description: Value(description),
        imagePath: Value(imagePath),
        sortOrder: sortOrder != null ? Value(sortOrder) : const Value.absent(),
        aboutText: aboutText != null ? Value(aboutText) : const Value.absent(),
        spriteScale: spriteScale != null ? Value(spriteScale) : const Value.absent(),
        spriteOffsetX: spriteOffsetX != null ? Value(spriteOffsetX) : const Value.absent(),
        spriteOffsetY: spriteOffsetY != null ? Value(spriteOffsetY) : const Value.absent(),
      ),
    );
  }

  Future<void> delete(int id) => (_db.delete(_db.characters)..where((c) => c.id.equals(id))).go();

  /// 비주얼 노벨 편집 화면의 '등장인물 중 선택'(플레이어블로 승격/강등)에서 쓴다.
  Future<void> setPlayable(int id, bool isPlayable) {
    return (_db.update(_db.characters)..where((c) => c.id.equals(id)))
        .write(CharactersCompanion(isPlayable: Value(isPlayable)));
  }

  // ── 비주얼 노벨: 캐릭터 표정 세트 ──────────────────────────────────────

  Stream<List<VnCharacterExpression>> watchExpressions(int characterId) {
    return (_db.select(_db.vnCharacterExpressions)..where((e) => e.characterId.equals(characterId))).watch();
  }

  Future<List<VnCharacterExpression>> getExpressions(int characterId) {
    return (_db.select(_db.vnCharacterExpressions)..where((e) => e.characterId.equals(characterId))).get();
  }

  /// 같은 감정으로 이미 등록된 이미지가 있으면 교체하고, 없으면 새로 추가한다.
  Future<void> setExpressionImage({
    required int characterId,
    required VnEmotion emotion,
    required String imagePath,
  }) async {
    final existing = await (_db.select(_db.vnCharacterExpressions)
          ..where((e) => e.characterId.equals(characterId) & e.emotion.equalsValue(emotion))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.vnCharacterExpressions)..where((e) => e.id.equals(existing.id)))
          .write(VnCharacterExpressionsCompanion(imagePath: Value(imagePath)));
      return;
    }
    await _db.into(_db.vnCharacterExpressions).insert(
          VnCharacterExpressionsCompanion.insert(
            characterId: characterId,
            emotion: emotion,
            imagePath: imagePath,
          ),
        );
  }

  Future<void> deleteExpression(int id) =>
      (_db.delete(_db.vnCharacterExpressions)..where((e) => e.id.equals(id))).go();
}
