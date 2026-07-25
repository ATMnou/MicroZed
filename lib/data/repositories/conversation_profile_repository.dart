import 'package:drift/drift.dart';

import '../db/database.dart';

/// 마이페이지 > 대화 프로필 편집이 사용하는 리포지토리.
class ConversationProfileRepository {
  ConversationProfileRepository(this._db);

  final AppDatabase _db;

  Stream<List<ConversationProfile>> watchAll() => _db.select(_db.conversationProfiles).watch();

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
              ),
            );
      }
      await (_db.update(_db.conversationProfiles)..where((p) => p.id.equals(id))).write(
        ConversationProfilesCompanion(
          name: Value(name),
          description: Value(description),
          isDefault: Value(applyAsDefault),
          imagePath: Value(imagePath),
        ),
      );
      return id;
    });
  }

  Future<void> delete(int id) => (_db.delete(_db.conversationProfiles)..where((p) => p.id.equals(id))).go();
}
