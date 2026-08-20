import 'package:drift/drift.dart';

import '../db/database.dart';

/// 비주얼 노벨 플롯의 배경 이미지 라이브러리 CRUD.
class VnBackgroundRepository {
  VnBackgroundRepository(this._db);

  final AppDatabase _db;

  Stream<List<VnBackground>> watchByPlot(int plotId) {
    return (_db.select(_db.vnBackgrounds)
          ..where((b) => b.plotId.equals(plotId))
          ..orderBy([(b) => OrderingTerm.asc(b.sortOrder)]))
        .watch();
  }

  Future<List<VnBackground>> getByPlot(int plotId) {
    return (_db.select(_db.vnBackgrounds)
          ..where((b) => b.plotId.equals(plotId))
          ..orderBy([(b) => OrderingTerm.asc(b.sortOrder)]))
        .get();
  }

  Future<VnBackground?> getById(int id) =>
      (_db.select(_db.vnBackgrounds)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<int> add({required int plotId, required String title, required String imagePath}) async {
    final maxOrderExp = _db.vnBackgrounds.sortOrder.max();
    final query = _db.selectOnly(_db.vnBackgrounds)
      ..addColumns([maxOrderExp])
      ..where(_db.vnBackgrounds.plotId.equals(plotId));
    final row = await query.getSingle();
    final nextOrder = (row.read(maxOrderExp) ?? -1) + 1;
    return _db.into(_db.vnBackgrounds).insert(
          VnBackgroundsCompanion.insert(
            plotId: plotId,
            title: title,
            imagePath: imagePath,
            sortOrder: Value(nextOrder),
          ),
        );
  }

  Future<void> update({required int id, required String title, String? imagePath}) {
    return (_db.update(_db.vnBackgrounds)..where((b) => b.id.equals(id))).write(
      VnBackgroundsCompanion(
        title: Value(title),
        imagePath: imagePath != null ? Value(imagePath) : const Value.absent(),
      ),
    );
  }

  Future<void> delete(int id) => (_db.delete(_db.vnBackgrounds)..where((b) => b.id.equals(id))).go();
}
