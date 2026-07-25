import 'package:drift/drift.dart';

import '../db/database.dart';

/// 로어북 1건 + 목록 표시용 부가 정보(연결된 플롯들의 대화량 총합, 연결 플롯 수).
class LorebookSummary {
  const LorebookSummary({
    required this.lorebook,
    required this.conversationCount,
    required this.linkedPlotCount,
  });

  final Lorebook lorebook;
  final int conversationCount;
  final int linkedPlotCount;
}

/// 로어북(세계관/설정 모음집) CRUD + 플롯 연결 + AI에게 넘길 로어 컨텍스트 조립.
class LorebookRepository {
  LorebookRepository(this._db);

  final AppDatabase _db;

  Stream<List<LorebookSummary>> watchAll() {
    final query = _db.select(_db.lorebooks)..orderBy([(l) => OrderingTerm.desc(l.updatedAt)]);
    return query.watch().asyncMap((rows) async {
      final summaries = <LorebookSummary>[];
      for (final lorebook in rows) {
        summaries.add(LorebookSummary(
          lorebook: lorebook,
          conversationCount: await _conversationCount(lorebook.id),
          linkedPlotCount: await _linkedPlotCount(lorebook.id),
        ));
      }
      return summaries;
    });
  }

  Future<Lorebook?> getById(int id) => (_db.select(_db.lorebooks)..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<int> upsert({int? id, required String title, String shortIntro = ''}) async {
    if (id == null) {
      return _db.into(_db.lorebooks).insert(
            LorebooksCompanion.insert(title: title, shortIntro: Value(shortIntro)),
          );
    }
    await (_db.update(_db.lorebooks)..where((l) => l.id.equals(id))).write(
      LorebooksCompanion(
        title: Value(title),
        shortIntro: Value(shortIntro),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return id;
  }

  Future<void> delete(int id) => (_db.delete(_db.lorebooks)..where((l) => l.id.equals(id))).go();

  Stream<List<LorebookEntry>> watchEntries(int lorebookId) {
    return (_db.select(_db.lorebookEntries)
          ..where((e) => e.lorebookId.equals(lorebookId))
          ..orderBy([(e) => OrderingTerm.asc(e.sortOrder)]))
        .watch();
  }

  Future<List<LorebookEntry>> getEntries(int lorebookId) {
    return (_db.select(_db.lorebookEntries)
          ..where((e) => e.lorebookId.equals(lorebookId))
          ..orderBy([(e) => OrderingTerm.asc(e.sortOrder)]))
        .get();
  }

  Future<int> addEntry(int lorebookId) async {
    final nextOrder = await _nextEntrySortOrder(lorebookId);
    return _db.into(_db.lorebookEntries).insert(
          LorebookEntriesCompanion.insert(lorebookId: lorebookId, sortOrder: Value(nextOrder)),
        );
  }

  Future<int> _nextEntrySortOrder(int lorebookId) async {
    final maxExp = _db.lorebookEntries.sortOrder.max();
    final query = _db.selectOnly(_db.lorebookEntries)
      ..addColumns([maxExp])
      ..where(_db.lorebookEntries.lorebookId.equals(lorebookId));
    final row = await query.getSingle();
    return (row.read(maxExp) ?? -1) + 1;
  }

  Future<void> updateEntry({
    required int id,
    String? title,
    String? keywords,
    String? content,
  }) {
    return (_db.update(_db.lorebookEntries)..where((e) => e.id.equals(id))).write(
      LorebookEntriesCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        keywords: keywords != null ? Value(keywords) : const Value.absent(),
        content: content != null ? Value(content) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteEntry(int id) => (_db.delete(_db.lorebookEntries)..where((e) => e.id.equals(id))).go();

  Stream<List<Plot>> watchLinkedPlots(int lorebookId) {
    final query = _db.select(_db.plots).join([
      innerJoin(_db.lorebookPlotLinks, _db.lorebookPlotLinks.plotId.equalsExp(_db.plots.id)),
    ])
      ..where(_db.lorebookPlotLinks.lorebookId.equals(lorebookId));
    return query.watch().map((rows) => rows.map((r) => r.readTable(_db.plots)).toList());
  }

  Stream<List<Lorebook>> watchLinkedLorebooks(int plotId) {
    final query = _db.select(_db.lorebooks).join([
      innerJoin(_db.lorebookPlotLinks, _db.lorebookPlotLinks.lorebookId.equalsExp(_db.lorebooks.id)),
    ])
      ..where(_db.lorebookPlotLinks.plotId.equals(plotId));
    return query.watch().map((rows) => rows.map((r) => r.readTable(_db.lorebooks)).toList());
  }

  Future<Set<int>> linkedPlotIds(int lorebookId) async {
    final rows = await (_db.select(_db.lorebookPlotLinks)..where((l) => l.lorebookId.equals(lorebookId))).get();
    return rows.map((r) => r.plotId).toSet();
  }

  Future<Set<int>> linkedLorebookIds(int plotId) async {
    final rows = await (_db.select(_db.lorebookPlotLinks)..where((l) => l.plotId.equals(plotId))).get();
    return rows.map((r) => r.lorebookId).toSet();
  }

  Future<void> setPlotLinksForLorebook(int lorebookId, Set<int> plotIds) async {
    await (_db.delete(_db.lorebookPlotLinks)..where((l) => l.lorebookId.equals(lorebookId))).go();
    for (final plotId in plotIds) {
      await _db.into(_db.lorebookPlotLinks).insert(
            LorebookPlotLinksCompanion.insert(lorebookId: lorebookId, plotId: plotId),
          );
    }
  }

  Future<void> setLorebookLinksForPlot(int plotId, Set<int> lorebookIds) async {
    await (_db.delete(_db.lorebookPlotLinks)..where((l) => l.plotId.equals(plotId))).go();
    for (final lorebookId in lorebookIds) {
      await _db.into(_db.lorebookPlotLinks).insert(
            LorebookPlotLinksCompanion.insert(lorebookId: lorebookId, plotId: plotId),
          );
    }
  }

  Future<int> _conversationCount(int lorebookId) async {
    final countExp = _db.chatMessages.id.count();
    final query = _db.selectOnly(_db.chatMessages)
      ..addColumns([countExp])
      ..join([
        innerJoin(_db.chatSessions, _db.chatSessions.id.equalsExp(_db.chatMessages.sessionId)),
        innerJoin(_db.lorebookPlotLinks, _db.lorebookPlotLinks.plotId.equalsExp(_db.chatSessions.plotId)),
      ])
      ..where(_db.lorebookPlotLinks.lorebookId.equals(lorebookId));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<int> _linkedPlotCount(int lorebookId) async {
    final countExp = _db.lorebookPlotLinks.id.count();
    final query = _db.selectOnly(_db.lorebookPlotLinks)
      ..addColumns([countExp])
      ..where(_db.lorebookPlotLinks.lorebookId.equals(lorebookId));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  /// 플롯에 연결된 로어북들의 항목 중 [conversationText]에서 키워드가 언급된 것만 골라,
  /// AI 시스템 프롬프트에 실을 본문을 만든다. 언급된 게 없으면 빈 문자열.
  Future<String> buildLoreContext(int plotId, String conversationText) async {
    final lorebookIds = await linkedLorebookIds(plotId);
    if (lorebookIds.isEmpty) return '';
    final lowerText = conversationText.toLowerCase();
    final matched = <String>[];
    for (final lorebookId in lorebookIds) {
      final entries = await getEntries(lorebookId);
      for (final entry in entries) {
        if (entry.content.trim().isEmpty) continue;
        final keywords = entry.keywords.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty);
        if (keywords.any((k) => lowerText.contains(k.toLowerCase()))) {
          matched.add(entry.content.trim());
        }
      }
    }
    return matched.join('\n\n');
  }
}
