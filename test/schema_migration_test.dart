import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/db/database.dart';
import 'package:path/path.dart' as p;

/// v9(로컬 LLM까지만 있던, 실제 배포된 1.1.1 스키마) -> v11(reasoningEffort +
/// PlotConversationProfiles + ChatSessions.plotConversationProfileId 추가) 마이그레이션이
/// 실제 파일 기반 sqlite에서 데이터 손실 없이 동작하는지 검증한다.
void main() {
  test('upgrades from schema v9 to v11 without losing existing data', () async {
    final tempPath = p.join(
      Directory.systemTemp.path,
      'microzed_migration_test_${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    final file = File(tempPath);
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });

    // 1) 지금 코드 기준 최신 스키마(v11)로 실 파일 DB를 만들고 데이터를 하나씩 넣는다.
    var db = AppDatabase.forTesting(NativeDatabase(file));
    final currentSchemaVersion = db.schemaVersion;
    final presetId = await db.into(db.aiPresets).insert(
          AiPresetsCompanion.insert(
            name: 'Existing Preset',
            baseUrl: 'https://api.example.com/v1',
            modelName: 'some-model',
          ),
        );
    final plotId = await db.into(db.plots).insert(
          PlotsCompanion.insert(title: 'Existing Plot', description: 'desc'),
        );
    final sessionId = await db.into(db.chatSessions).insert(
          ChatSessionsCompanion.insert(plotId: plotId),
        );
    await db.close();

    // 2) v11에서 새로 생긴 것들을 지워서 '마이그레이션 전 v9 상태'를 흉내내고, drift가
    //    실제로 참조하는 user_version pragma도 9로 되돌린다. ensureOpen에는 지금 파일에
    //    실제로 적힌 버전(currentSchemaVersion)을 그대로 넘겨서, 버전 비교 로직이 다운그레이드로
    //    오해해 엉뚱한 동작을 하지 않게 한다 - 실제 버전 조작은 바로 아래 raw PRAGMA 문으로
    //    명시적으로 한다.
    final raw = NativeDatabase(file);
    await raw.ensureOpen(_NoopUser(currentSchemaVersion));
    await raw.runCustom('ALTER TABLE ai_presets DROP COLUMN reasoning_effort');
    await raw.runCustom('ALTER TABLE chat_sessions DROP COLUMN plot_conversation_profile_id');
    await raw.runCustom('DROP TABLE plot_conversation_profiles');
    await raw.runCustom('PRAGMA user_version = 9');
    await raw.close();

    // 3) 지금 앱 코드로 다시 열면 onUpgrade(9, 11)이 실행돼야 한다. 예외 없이 열리고,
    //    기존 데이터는 그대로 남아 있고, 새로 생긴 것들은 정상적으로 쓸 수 있어야 한다.
    db = AppDatabase.forTesting(NativeDatabase(file));
    final preset = await (db.select(db.aiPresets)..where((p) => p.id.equals(presetId))).getSingle();
    expect(preset.name, 'Existing Preset');
    expect(preset.baseUrl, 'https://api.example.com/v1');
    expect(preset.reasoningEffort, isNull);

    final plot = await (db.select(db.plots)..where((p) => p.id.equals(plotId))).getSingle();
    expect(plot.title, 'Existing Plot');

    final session = await (db.select(db.chatSessions)..where((s) => s.id.equals(sessionId))).getSingle();
    expect(session.plotId, plotId);
    expect(session.plotConversationProfileId, isNull);

    final newPlotProfileId = await db.into(db.plotConversationProfiles).insert(
          PlotConversationProfilesCompanion.insert(
            plotId: plotId,
            name: 'Test Profile',
            shortIntro: 'hi',
          ),
        );
    final plotProfile =
        await (db.select(db.plotConversationProfiles)..where((p) => p.id.equals(newPlotProfileId))).getSingle();
    expect(plotProfile.name, 'Test Profile');

    await db.close();
  });
}

class _NoopUser extends QueryExecutorUser {
  _NoopUser(this.schemaVersion);

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}

  @override
  final int schemaVersion;
}
