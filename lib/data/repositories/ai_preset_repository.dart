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

  Future<String?> readApiKey(int presetId) => _apiKeyStore.read(presetId);

  /// apiKey가 null/empty면 기존 키를 건드리지 않는다(수정 화면에서 키를 비워두고 저장하는 경우).
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
  }) async {
    late int presetId;
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
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
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
