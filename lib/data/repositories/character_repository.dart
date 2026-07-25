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

  Future<List<Character>> getByPlot(int plotId) {
    return (_db.select(_db.characters)
          ..where((c) => c.plotId.equals(plotId))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  Future<int> add({
    required int plotId,
    required String name,
    String description = '',
    String? imagePath,
    bool isRepresentative = false,
    int sortOrder = 0,
  }) {
    return _db.into(_db.characters).insert(
          CharactersCompanion.insert(
            plotId: plotId,
            name: name,
            description: Value(description),
            imagePath: Value(imagePath),
            isRepresentative: Value(isRepresentative),
            sortOrder: Value(sortOrder),
          ),
        );
  }

  Future<void> update({
    required int id,
    required String name,
    required String description,
    String? imagePath,
    int? sortOrder,
  }) {
    return (_db.update(_db.characters)..where((c) => c.id.equals(id))).write(
      CharactersCompanion(
        name: Value(name),
        description: Value(description),
        imagePath: Value(imagePath),
        sortOrder: sortOrder != null ? Value(sortOrder) : const Value.absent(),
      ),
    );
  }

  Future<void> delete(int id) => (_db.delete(_db.characters)..where((c) => c.id.equals(id))).go();
}
