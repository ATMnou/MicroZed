import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/db/database.dart';
import 'package:path/path.dart' as p;

/// v9(로컬 LLM까지만 있던, 실제 배포된 1.1.1 스키마) -> 최신 버전(reasoningEffort +
/// PlotConversationProfiles + ChatSessions.plotConversationProfileId +
/// TokenUsageLogs.provider + AiPresets의 OpenRouter 전용 라우팅 옵션 3종 + endpointFormat +
/// ChatMemorySummaries 테이블 + AiPresets.supportsVision + TalkSessions/TalkMessages 테이블 +
/// TalkSessions.characterId/conversationProfileId/plotConversationProfileId +
/// 비주얼 노벨 관련 컬럼/테이블 일체 + v19의 Characters 스프라이트 배치 컬럼/
/// ConversationProfiles.scope 추가)
/// 마이그레이션이 실제 파일 기반 sqlite에서 데이터 손실 없이 동작하는지 검증한다.
void main() {
  test('upgrades from schema v9 to the latest schema without losing existing data', () async {
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
    await raw.runCustom('ALTER TABLE token_usage_logs DROP COLUMN provider');
    await raw.runCustom('ALTER TABLE ai_presets DROP COLUMN open_router_zdr_only');
    await raw.runCustom('ALTER TABLE ai_presets DROP COLUMN open_router_exclude_china_providers');
    await raw.runCustom('ALTER TABLE ai_presets DROP COLUMN open_router_exclude_training_providers');
    await raw.runCustom('ALTER TABLE ai_presets DROP COLUMN endpoint_format');
    await raw.runCustom('DROP TABLE chat_memory_summaries');
    await raw.runCustom('ALTER TABLE ai_presets DROP COLUMN supports_vision');
    await raw.runCustom('DROP TABLE talk_messages');
    await raw.runCustom('DROP TABLE talk_sessions');
    await raw.runCustom('DROP TABLE vn_choices');
    await raw.runCustom('DROP TABLE vn_character_expressions');
    await raw.runCustom('DROP TABLE vn_backgrounds');
    await raw.runCustom('ALTER TABLE plots DROP COLUMN plot_type');
    await raw.runCustom('ALTER TABLE plots DROP COLUMN vn_input_mode');
    await raw.runCustom('ALTER TABLE plots DROP COLUMN vn_ai_input_assist');
    await raw.runCustom('ALTER TABLE plots DROP COLUMN vn_dice_enabled');
    await raw.runCustom('ALTER TABLE characters DROP COLUMN is_playable');
    await raw.runCustom('ALTER TABLE intro_entries DROP COLUMN vn_background_id');
    await raw.runCustom('ALTER TABLE intro_entries DROP COLUMN vn_expression');
    await raw.runCustom('ALTER TABLE intro_entries DROP COLUMN vn_scene_type');
    await raw.runCustom('ALTER TABLE chat_messages DROP COLUMN vn_background_id');
    await raw.runCustom('ALTER TABLE chat_messages DROP COLUMN vn_expression');
    await raw.runCustom('ALTER TABLE chat_sessions DROP COLUMN vn_playable_character_id');
    await raw.runCustom('ALTER TABLE characters DROP COLUMN sprite_scale');
    await raw.runCustom('ALTER TABLE characters DROP COLUMN sprite_offset_x');
    await raw.runCustom('ALTER TABLE characters DROP COLUMN sprite_offset_y');
    await raw.runCustom('ALTER TABLE conversation_profiles DROP COLUMN scope');
    await raw.runCustom('PRAGMA user_version = 9');
    await raw.close();

    // 3) 지금 앱 코드로 다시 열면 onUpgrade(9, 16)이 실행돼야 한다. 예외 없이 열리고,
    //    기존 데이터는 그대로 남아 있고, 새로 생긴 것들은 정상적으로 쓸 수 있어야 한다.
    db = AppDatabase.forTesting(NativeDatabase(file));
    final preset = await (db.select(db.aiPresets)..where((p) => p.id.equals(presetId))).getSingle();
    expect(preset.name, 'Existing Preset');
    expect(preset.baseUrl, 'https://api.example.com/v1');
    expect(preset.reasoningEffort, isNull);
    expect(preset.openRouterZdrOnly, false);
    expect(preset.openRouterExcludeChinaProviders, false);
    expect(preset.openRouterExcludeTrainingProviders, false);
    expect(preset.endpointFormat, AiEndpointFormat.openAiCompatible);
    expect(preset.supportsVision, false);

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

    final logId = await db.into(db.tokenUsageLogs).insert(
          TokenUsageLogsCompanion.insert(
            presetName: 'Existing Preset',
            baseUrl: 'https://openrouter.ai/api/v1',
            modelName: 'some-model',
            provider: const Value('DeepInfra'),
          ),
        );
    final log = await (db.select(db.tokenUsageLogs)..where((l) => l.id.equals(logId))).getSingle();
    expect(log.provider, 'DeepInfra');

    final memoryId = await db.into(db.chatMemorySummaries).insert(
          ChatMemorySummariesCompanion.insert(
            sessionId: sessionId,
            coveredUpToMessageId: 1,
            summaryText: '요약',
          ),
        );
    final memory =
        await (db.select(db.chatMemorySummaries)..where((m) => m.id.equals(memoryId))).getSingle();
    expect(memory.summaryText, '요약');

    final characterId = await db.into(db.characters).insert(
          CharactersCompanion.insert(plotId: plotId, name: 'Test Character'),
        );
    final talkSessionId = await db.into(db.talkSessions).insert(
          TalkSessionsCompanion.insert(plotId: plotId, characterId: const Value(null)),
        );
    final talkMessageId = await db.into(db.talkMessages).insert(
          TalkMessagesCompanion.insert(
            sessionId: talkSessionId,
            sender: TalkMessageSender.user,
            content: const Value('안녕'),
          ),
        );
    final talkMessage =
        await (db.select(db.talkMessages)..where((m) => m.id.equals(talkMessageId))).getSingle();
    expect(talkMessage.content, '안녕');
    expect(talkMessage.sender, TalkMessageSender.user);

    final talkSession = await (db.select(db.talkSessions)..where((s) => s.id.equals(talkSessionId))).getSingle();
    expect(talkSession.characterId, isNull);
    await (db.update(db.talkSessions)..where((s) => s.id.equals(talkSessionId))).write(
      TalkSessionsCompanion(characterId: Value(characterId)),
    );
    final updatedTalkSession =
        await (db.select(db.talkSessions)..where((s) => s.id.equals(talkSessionId))).getSingle();
    expect(updatedTalkSession.characterId, characterId);

    // v18: 비주얼 노벨 관련 컬럼/테이블도 마이그레이션 후 정상적으로 읽고 쓸 수 있어야 한다.
    expect(plot.plotType, PlotType.storyChat);
    final character = await (db.select(db.characters)..where((c) => c.id.equals(characterId))).getSingle();
    expect(character.isPlayable, false);

    final backgroundId = await db.into(db.vnBackgrounds).insert(
          VnBackgroundsCompanion.insert(plotId: plotId, title: '교실', imagePath: '/tmp/bg.png'),
        );
    final expressionId = await db.into(db.vnCharacterExpressions).insert(
          VnCharacterExpressionsCompanion.insert(
            characterId: characterId,
            emotion: VnEmotion.joy,
            imagePath: '/tmp/expr.png',
          ),
        );
    final expression =
        await (db.select(db.vnCharacterExpressions)..where((e) => e.id.equals(expressionId))).getSingle();
    expect(expression.emotion, VnEmotion.joy);

    final vnPlotId = await db.into(db.plots).insert(
          PlotsCompanion.insert(
            title: 'VN Plot',
            description: 'vn desc',
            plotType: const Value(PlotType.visualNovel),
          ),
        );
    final vnPlot = await (db.select(db.plots)..where((p) => p.id.equals(vnPlotId))).getSingle();
    expect(vnPlot.plotType, PlotType.visualNovel);

    final introVersionId = await db.into(db.introVersions).insert(IntroVersionsCompanion.insert(plotId: vnPlotId));
    final introEntryId = await db.into(db.introEntries).insert(
          IntroEntriesCompanion.insert(
            plotId: vnPlotId,
            introVersionId: const Value(null),
            type: IntroEntryType.narrator,
            content: '한 학생이 교문 앞에 섰다',
            vnBackgroundId: Value(backgroundId),
            vnSceneType: const Value(VnSceneType.direction),
          ),
        );
    final introEntry = await (db.select(db.introEntries)..where((e) => e.id.equals(introEntryId))).getSingle();
    expect(introEntry.vnBackgroundId, backgroundId);
    expect(introEntry.vnSceneType, VnSceneType.direction);
    // introVersionId 컬럼 자체는 계속 nullable이어야 한다(예전 스키마 호환용) - 위 insert에
    // null을 명시적으로 넘겼는데도 예외 없이 저장됐다는 사실 자체가 검증이다.
    expect(introVersionId, isNonNegative);

    final vnSessionId = await db.into(db.chatSessions).insert(
          ChatSessionsCompanion.insert(plotId: vnPlotId, vnPlayableCharacterId: Value(characterId)),
        );
    final vnSession = await (db.select(db.chatSessions)..where((s) => s.id.equals(vnSessionId))).getSingle();
    expect(vnSession.vnPlayableCharacterId, characterId);

    final vnMessageId = await db.into(db.chatMessages).insert(
          ChatMessagesCompanion.insert(
            sessionId: vnSessionId,
            senderType: MessageSender.narrator,
            content: '교문이 열렸다',
            vnBackgroundId: Value(backgroundId),
            vnExpression: const Value(VnEmotion.surprised),
          ),
        );
    final vnMessage = await (db.select(db.chatMessages)..where((m) => m.id.equals(vnMessageId))).getSingle();
    expect(vnMessage.vnBackgroundId, backgroundId);
    expect(vnMessage.vnExpression, VnEmotion.surprised);

    final choiceId = await db.into(db.vnChoices).insert(
          VnChoicesCompanion.insert(
            introVersionId: introVersionId,
            content: '문을 연다',
            useDice: const Value(true),
            difficulty: const Value(VnDiceDifficulty.medium),
          ),
        );
    final choice = await (db.select(db.vnChoices)..where((c) => c.id.equals(choiceId))).getSingle();
    expect(choice.useDice, true);
    expect(choice.difficulty, VnDiceDifficulty.medium);

    // v19: 인물 배치(스프라이트 크기 배율/X·Y 좌표) + 대화 프로필 적용 범위 컬럼도 마이그레이션
    // 후 기본값으로 채워지고 정상적으로 읽고 쓸 수 있어야 한다.
    final characterAfterMigration =
        await (db.select(db.characters)..where((c) => c.id.equals(characterId))).getSingle();
    expect(characterAfterMigration.spriteScale, 1.0);
    expect(characterAfterMigration.spriteOffsetX, 0.0);
    expect(characterAfterMigration.spriteOffsetY, 0.0);

    final vnProfileId = await db.into(db.conversationProfiles).insert(
          ConversationProfilesCompanion.insert(name: 'VN Profile', scope: const Value(PlotType.visualNovel)),
        );
    final vnProfile =
        await (db.select(db.conversationProfiles)..where((p) => p.id.equals(vnProfileId))).getSingle();
    expect(vnProfile.scope, PlotType.visualNovel);

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
