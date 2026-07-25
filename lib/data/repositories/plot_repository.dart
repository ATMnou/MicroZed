import 'package:drift/drift.dart';

import '../db/database.dart';

/// 플롯 1건 + 대화량(해당 플롯의 모든 세션에 쌓인 메시지 수) 요약.
/// 제작 탭의 플롯 목록이 사용한다.
class PlotSummary {
  const PlotSummary({required this.plot, required this.conversationCount});

  final Plot plot;
  final int conversationCount;
}

/// 플롯/대표 캐릭터를 함께 다루는 리포지토리.
/// 플롯 편집 화면의 '프롬프트' 탭(제목/설명 + 대표 캐릭터 이름/설명)이 이 리포지토리로 저장된다.
class PlotRepository {
  PlotRepository(this._db);

  final AppDatabase _db;

  Stream<List<PlotSummary>> watchAll({PlotVisibility? visibility}) {
    final query = _db.select(_db.plots)
      ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)]);
    if (visibility != null) {
      query.where((p) => p.visibility.equalsValue(visibility));
    }
    return query.watch().asyncMap((plots) async {
      final summaries = <PlotSummary>[];
      for (final plot in plots) {
        summaries.add(PlotSummary(plot: plot, conversationCount: await _conversationCount(plot.id)));
      }
      return summaries;
    });
  }

  Future<int> conversationCount(int plotId) => _conversationCount(plotId);

  Future<int> _conversationCount(int plotId) async {
    final countExp = _db.chatMessages.id.count();
    final query = _db.selectOnly(_db.chatMessages)
      ..addColumns([countExp])
      ..join([innerJoin(_db.chatSessions, _db.chatSessions.id.equalsExp(_db.chatMessages.sessionId))])
      ..where(_db.chatSessions.plotId.equals(plotId));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<Plot?> getById(int id) => (_db.select(_db.plots)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<Plot?> getByTitle(String title) {
    return (_db.select(_db.plots)..where((p) => p.title.equals(title))..limit(1)).getSingleOrNull();
  }

  Future<Character?> representativeCharacter(int plotId) {
    return (_db.select(_db.characters)
          ..where((c) => c.plotId.equals(plotId) & c.isRepresentative.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  /// 플롯 편집 화면 저장 버튼에서 호출한다. plotId가 null이면 신규 생성.
  /// hashtags는 콤마로 join해서 저장하고, [getById] 등으로 읽을 때는 `Plot.hashtags.split(',')`로 복원한다.
  /// 캐릭터(여러 개일 수 있음)는 [CharacterRepository]가 별도로 저장한다.
  Future<int> upsertPlot({
    int? plotId,
    required String title,
    required String description,
    String shortIntro = '',
    List<String> hashtags = const [],
    String? coverImagePath,
  }) async {
    final hashtagsCsv = hashtags.join(',');
    if (plotId == null) {
      return _db.into(_db.plots).insert(
            PlotsCompanion.insert(
              title: title,
              description: description,
              shortIntro: Value(shortIntro),
              hashtags: Value(hashtagsCsv),
              coverImagePath: Value(coverImagePath),
            ),
          );
    }
    await (_db.update(_db.plots)..where((p) => p.id.equals(plotId))).write(
      PlotsCompanion(
        title: Value(title),
        description: Value(description),
        shortIntro: Value(shortIntro),
        hashtags: Value(hashtagsCsv),
        coverImagePath: Value(coverImagePath),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return plotId;
  }

  Future<void> deletePlot(int id) => (_db.delete(_db.plots)..where((p) => p.id.equals(id))).go();
}
