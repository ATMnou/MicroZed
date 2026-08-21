import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:meta/meta.dart';

import 'tables.dart';

export 'tables.dart'
    show
        PlotVisibility,
        IntroEntryType,
        MessageSender,
        AiEndpointFormat,
        TalkMessageSender,
        TalkAttachmentType,
        PlotType,
        VnEmotion,
        VnSceneType,
        VnInputMode,
        VnDiceDifficulty,
        GameType,
        GameDifficulty,
        GameOutcome;

part 'database.g.dart';

/// 앱 전역에서 쓰는 로컬 SQLite(Drift) 데이터베이스.
/// 플롯/캐릭터/인트로/대화 프로필/AI 프리셋/대화 세션/메시지를 담당한다.
/// API 키 원문은 여기 저장하지 않고 자체 보안 저장소(secure/)에 별도 보관한다.
@DriftDatabase(tables: [
  Plots,
  Characters,
  IntroVersions,
  IntroEntries,
  ConversationProfiles,
  PlotConversationProfiles,
  AiPresets,
  ChatSessions,
  ChatTurns,
  ChatMessages,
  ChatMemorySummaries,
  TalkSessions,
  TalkMessages,
  TokenUsageLogs,
  Lorebooks,
  LorebookEntries,
  LorebookPlotLinks,
  VnBackgrounds,
  VnCharacterExpressions,
  VnChoices,
  GameResults,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  /// 테스트 전용. 프로덕션 코드는 항상 [instance]를 써야 한다.
  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  static final AppDatabase instance = AppDatabase._();

  @override
  int get schemaVersion => 21;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(chatSessions, chatSessions.archivedAt);
          }
          if (from < 3) {
            await m.database.customStatement(
              'ALTER TABLE ai_presets RENAME COLUMN provider TO base_url',
            );
          }
          if (from < 4) {
            await m.addColumn(chatMessages, chatMessages.speakerNameOverride);
          }
          if (from < 5) {
            await m.createTable(introVersions);
            await m.addColumn(introEntries, introEntries.introVersionId);
            await m.createTable(chatTurns);
            await m.addColumn(chatMessages, chatMessages.turnId);
            await m.addColumn(chatMessages, chatMessages.versionIndex);
            await m.addColumn(chatMessages, chatMessages.turnSortOrder);
            await m.addColumn(aiPresets, aiPresets.topK);
            await m.addColumn(aiPresets, aiPresets.maxTokens);
            await m.addColumn(aiPresets, aiPresets.contextLength);
            await m.addColumn(aiPresets, aiPresets.additionalSystemPrompt);
          }
          if (from < 6) {
            await m.createTable(tokenUsageLogs);
          }
          if (from < 7) {
            await m.createTable(lorebooks);
            await m.createTable(lorebookEntries);
            await m.createTable(lorebookPlotLinks);
          }
          if (from < 8) {
            await m.addColumn(characters, characters.aboutText);
          }
          if (from < 9) {
            await m.addColumn(aiPresets, aiPresets.isLocal);
            await m.addColumn(aiPresets, aiPresets.localModelSource);
          }
          if (from < 10) {
            await m.addColumn(aiPresets, aiPresets.reasoningEffort);
          }
          if (from < 11) {
            await m.createTable(plotConversationProfiles);
            await m.addColumn(chatSessions, chatSessions.plotConversationProfileId);
          }
          if (from < 12) {
            await m.addColumn(tokenUsageLogs, tokenUsageLogs.provider);
          }
          if (from < 13) {
            await m.addColumn(aiPresets, aiPresets.openRouterZdrOnly);
            await m.addColumn(aiPresets, aiPresets.openRouterExcludeChinaProviders);
            await m.addColumn(aiPresets, aiPresets.openRouterExcludeTrainingProviders);
          }
          if (from < 14) {
            await m.addColumn(aiPresets, aiPresets.endpointFormat);
          }
          if (from < 15) {
            await m.createTable(chatMemorySummaries);
          }
          if (from < 16) {
            await m.addColumn(aiPresets, aiPresets.supportsVision);
            await m.createTable(talkSessions);
            await m.createTable(talkMessages);
          }
          // from < 16이었던 사용자는 바로 위 블록의 createTable(talkSessions)가 이미 현재
          // Dart 스키마(character_id 등 포함) 그대로 테이블을 만들어주므로, 여기서 또
          // addColumn을 하면 '컬럼 중복' 에러가 난다. v16에서 이미 talk_sessions가 있었던
          // 사용자만 컬럼을 추가하면 된다.
          if (from >= 16 && from < 17) {
            await m.addColumn(talkSessions, talkSessions.characterId);
            await m.addColumn(talkSessions, talkSessions.conversationProfileId);
            await m.addColumn(talkSessions, talkSessions.plotConversationProfileId);
          }
          if (from < 18) {
            await m.addColumn(plots, plots.plotType);
            await m.addColumn(plots, plots.vnInputMode);
            await m.addColumn(plots, plots.vnAiInputAssist);
            await m.addColumn(plots, plots.vnDiceEnabled);
            await m.addColumn(characters, characters.isPlayable);
            await m.createTable(vnBackgrounds);
            await m.createTable(vnCharacterExpressions);
            await m.createTable(vnChoices);
            await m.addColumn(introEntries, introEntries.vnBackgroundId);
            await m.addColumn(introEntries, introEntries.vnExpression);
            await m.addColumn(introEntries, introEntries.vnSceneType);
            await m.addColumn(chatMessages, chatMessages.vnBackgroundId);
            await m.addColumn(chatMessages, chatMessages.vnExpression);
            await m.addColumn(chatSessions, chatSessions.vnPlayableCharacterId);
          }
          if (from < 19) {
            await m.addColumn(characters, characters.spriteScale);
            await m.addColumn(characters, characters.spriteOffsetX);
            await m.addColumn(characters, characters.spriteOffsetY);
            await m.addColumn(conversationProfiles, conversationProfiles.scope);
          }
          if (from < 20) {
            await m.addColumn(conversationProfiles, conversationProfiles.vnStandingImagePath);
            // plot_conversation_profiles는 v11에서 createTable()로 처음 생겼는데, 그 createTable()이
            // 이미 지금 Dart 스키마(vn_standing_image_path 포함) 그대로 테이블을 만들어준다. from < 11
            // (v11 이전, 즉 이번에 createTable까지 함께 타는 사용자)은 여기서 또 addColumn하면 컬럼
            // 중복 에러가 나므로, 이미 v11 이상이어서 테이블은 있었지만 이 컬럼만 없던 사용자만 추가한다.
            if (from >= 11) {
              await m.addColumn(plotConversationProfiles, plotConversationProfiles.vnStandingImagePath);
            }
          }
          if (from < 21) {
            await m.createTable(gameResults);
          }
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'microzed');
}
