import 'package:drift/drift.dart';

import '../db/database.dart';
import 'conversation_profile_repository.dart';

/// 플롯 편집 > 프롬프트 탭의 '플롯 전용 대화 프로필' CRUD. 마이페이지의 전역
/// [ConversationProfileRepository]와 별개이고, 개수 제한이 없다.
class PlotConversationProfileRepository {
  PlotConversationProfileRepository(this._db) : _globalProfileRepo = ConversationProfileRepository(_db);

  final AppDatabase _db;
  final ConversationProfileRepository _globalProfileRepo;

  Stream<List<PlotConversationProfile>> watchByPlot(int plotId) {
    return (_db.select(_db.plotConversationProfiles)
          ..where((p) => p.plotId.equals(plotId))
          ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
        .watch();
  }

  Future<List<PlotConversationProfile>> getByPlot(int plotId) => watchByPlot(plotId).first;

  Future<PlotConversationProfile?> getById(int id) =>
      (_db.select(_db.plotConversationProfiles)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> upsert({
    int? id,
    required int plotId,
    required String name,
    bool useGlobalName = false,
    required String shortIntro,
    String description = '',
    String? imagePath,
  }) async {
    if (id == null) {
      final existing = await getByPlot(plotId);
      final nextSortOrder =
          existing.isEmpty ? 0 : existing.map((p) => p.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
      return _db.into(_db.plotConversationProfiles).insert(
            PlotConversationProfilesCompanion.insert(
              plotId: plotId,
              name: name,
              useGlobalName: Value(useGlobalName),
              shortIntro: shortIntro,
              description: Value(description),
              imagePath: Value(imagePath),
              sortOrder: Value(nextSortOrder),
            ),
          );
    }
    await (_db.update(_db.plotConversationProfiles)..where((p) => p.id.equals(id))).write(
      PlotConversationProfilesCompanion(
        name: Value(name),
        useGlobalName: Value(useGlobalName),
        shortIntro: Value(shortIntro),
        description: Value(description),
        imagePath: Value(imagePath),
      ),
    );
    return id;
  }

  Future<void> delete(int id) => (_db.delete(_db.plotConversationProfiles)..where((p) => p.id.equals(id))).go();

  /// [PlotConversationProfile.useGlobalName]이 켜져 있으면 표시 시점의 전역 기본 프로필
  /// 이름으로, 아니면 저장된 이름 그대로 돌려준다.
  Future<String> resolveDisplayName(PlotConversationProfile profile) async {
    if (!profile.useGlobalName) return profile.name;
    final globalDefault = await _globalProfileRepo.getDefault();
    return globalDefault?.name ?? profile.name;
  }
}
