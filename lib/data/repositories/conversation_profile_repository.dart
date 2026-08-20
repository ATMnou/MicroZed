import 'package:drift/drift.dart';

import '../db/database.dart';

/// 마이페이지 > 대화 프로필 편집이 사용하는 리포지토리.
class ConversationProfileRepository {
  ConversationProfileRepository(this._db);

  final AppDatabase _db;

  /// [scope]를 넘기면 그 [PlotType] 전용 프로필 + 공용(scope=null) 프로필만 반환한다.
  /// 넘기지 않으면(마이페이지 전체 목록 등) 전부 반환한다.
  Stream<List<ConversationProfile>> watchAll({PlotType? scope}) {
    final query = _db.select(_db.conversationProfiles);
    if (scope != null) {
      query.where((p) => p.scope.isNull() | p.scope.equalsValue(scope));
    }
    return query.watch();
  }

  Future<ConversationProfile?> getById(int id) {
    return (_db.select(_db.conversationProfiles)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<ConversationProfile?> getDefault() {
    return (_db.select(_db.conversationProfiles)..where((p) => p.isDefault.equals(true))).getSingleOrNull();
  }

  Future<int> upsert({
    int? id,
    required String name,
    required String description,
    bool applyAsDefault = false,
    String? imagePath,
    PlotType? scope,
  }) {
    return _db.transaction(() async {
      if (applyAsDefault) {
        await _db.update(_db.conversationProfiles).write(
              const ConversationProfilesCompanion(isDefault: Value(false)),
            );
      }
      if (id == null) {
        return _db.into(_db.conversationProfiles).insert(
              ConversationProfilesCompanion.insert(
                name: name,
                description: Value(description),
                isDefault: Value(applyAsDefault),
                imagePath: Value(imagePath),
                scope: Value(scope),
              ),
            );
      }
      await (_db.update(_db.conversationProfiles)..where((p) => p.id.equals(id))).write(
        ConversationProfilesCompanion(
          name: Value(name),
          description: Value(description),
          isDefault: Value(applyAsDefault),
          imagePath: Value(imagePath),
          scope: Value(scope),
        ),
      );
      return id;
    });
  }

  Future<void> delete(int id) => (_db.delete(_db.conversationProfiles)..where((p) => p.id.equals(id))).go();
}
