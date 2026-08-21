import 'package:drift/drift.dart';

import '../db/database.dart';
import '../secure/api_key_store.dart';

/// AI 프리셋 CRUD. API 키 원문은 DB가 아니라 [ApiKeyStore](보안 저장소)에 보관하고,
/// DB에는 프리셋 id로부터 계산되는 참조 키(`apiKeyRef`)만 남긴다.
class AiPresetRepository {
  AiPresetRepository(this._db, {ApiKeyStore? apiKeyStore}) : _apiKeyStore = apiKeyStore ?? ApiKeyStore();

  final AppDatabase _db;
  final ApiKeyStore _apiKeyStore;

  Stream<List<AiPreset>> watchAll() {
    return (_db.select(_db.aiPresets)..orderBy([(p) => OrderingTerm.asc(p.createdAt)])).watch();
  }

  Future<AiPreset?> getById(int id) => (_db.select(_db.aiPresets)..where((p) => p.id.equals(id))).getSingleOrNull();

  /// 프리셋 선택 화면 없이 대사를 생성해야 하는 곳(게임 등)에서 쓴다. 기본으로 표시된
  /// 프리셋이 있으면 그걸, 없으면 가장 먼저 만든 프리셋을 돌려주고, 하나도 없으면 null.
  Future<AiPreset?> getDefault() async {
    final marked =
        await (_db.select(_db.aiPresets)..where((p) => p.isDefault.equals(true))..limit(1)).getSingleOrNull();
    if (marked != null) return marked;
    return (_db.select(_db.aiPresets)
          ..orderBy([(p) => OrderingTerm.asc(p.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// 같은 로컬 모델 소스로 이미 만들어둔 프리셋이 있으면 재사용하기 위한 조회.
  Future<AiPreset?> getByLocalModelSource(String source) =>
      (_db.select(_db.aiPresets)..where((p) => p.isLocal.equals(true) & p.localModelSource.equals(source)))
          .getSingleOrNull();

  Future<String?> readApiKey(int presetId) => _apiKeyStore.read(presetId);

  /// apiKey가 null/empty면 기존 키를 건드리지 않는다(수정 화면에서 키를 비워두고 저장하는 경우).
  /// [applyAsDefault]가 true면 다른 프리셋의 기본 표시를 모두 내리고 이 프리셋만 기본으로
  /// 표시한다 - [ConversationProfileRepository.upsert]와 동일한 "기본은 하나만" 규칙.
  Future<int> upsert({
    int? id,
    required String name,
    required String description,
    required String baseUrl,
    required String modelName,
    String? apiKey,
    double temperature = 1.0,
    int? topK,
    int? maxTokens,
    int? contextLength,
    String additionalSystemPrompt = '',
    bool isLocal = false,
    String? localModelSource,
    String? reasoningEffort,
    bool openRouterZdrOnly = false,
    bool openRouterExcludeChinaProviders = false,
    bool openRouterExcludeTrainingProviders = false,
    AiEndpointFormat endpointFormat = AiEndpointFormat.openAiCompatible,
    bool supportsVision = false,
    bool applyAsDefault = false,
  }) async {
    final presetId = await _db.transaction(() async {
      late int presetId;
      if (applyAsDefault) {
        await _db.update(_db.aiPresets).write(const AiPresetsCompanion(isDefault: Value(false)));
      }
      if (id == null) {
        presetId = await _db.into(_db.aiPresets).insert(
              AiPresetsCompanion.insert(
                name: name,
                description: Value(description),
                baseUrl: baseUrl,
                modelName: modelName,
                temperature: Value(temperature),
                topK: Value(topK),
                maxTokens: Value(maxTokens),
                contextLength: Value(contextLength),
                additionalSystemPrompt: Value(additionalSystemPrompt),
                isLocal: Value(isLocal),
                localModelSource: Value(localModelSource),
                reasoningEffort: Value(reasoningEffort),
                openRouterZdrOnly: Value(openRouterZdrOnly),
                openRouterExcludeChinaProviders: Value(openRouterExcludeChinaProviders),
                openRouterExcludeTrainingProviders: Value(openRouterExcludeTrainingProviders),
                endpointFormat: Value(endpointFormat),
                supportsVision: Value(supportsVision),
                isDefault: Value(applyAsDefault),
              ),
            );
        await (_db.update(_db.aiPresets)..where((p) => p.id.equals(presetId))).write(
          AiPresetsCompanion(apiKeyRef: Value(ApiKeyStore.refFor(presetId))),
        );
      } else {
        presetId = id;
        await (_db.update(_db.aiPresets)..where((p) => p.id.equals(id))).write(
          AiPresetsCompanion(
            name: Value(name),
            description: Value(description),
            baseUrl: Value(baseUrl),
            modelName: Value(modelName),
            temperature: Value(temperature),
            topK: Value(topK),
            maxTokens: Value(maxTokens),
            contextLength: Value(contextLength),
            additionalSystemPrompt: Value(additionalSystemPrompt),
            isLocal: Value(isLocal),
            localModelSource: Value(localModelSource),
            reasoningEffort: Value(reasoningEffort),
            openRouterZdrOnly: Value(openRouterZdrOnly),
            openRouterExcludeChinaProviders: Value(openRouterExcludeChinaProviders),
            openRouterExcludeTrainingProviders: Value(openRouterExcludeTrainingProviders),
            endpointFormat: Value(endpointFormat),
            supportsVision: Value(supportsVision),
            isDefault: Value(applyAsDefault),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
      return presetId;
    });
    if (apiKey != null && apiKey.isNotEmpty) {
      await _apiKeyStore.save(presetId, apiKey);
    }
    return presetId;
  }

  Future<void> delete(int id) async {
    await _apiKeyStore.delete(id);
    await (_db.delete(_db.aiPresets)..where((p) => p.id.equals(id))).go();
  }
}
