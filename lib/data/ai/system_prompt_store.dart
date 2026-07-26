import '../secure/local_file_store.dart';

const _systemPromptKey = 'custom_system_prompt_template';

/// 마이페이지 > 시스템 프롬프트 설정에서 사용자가 저장한 커스텀 템플릿을 보관한다.
/// 저장된 값이 없으면 [PromptBuilder.defaultSystemPromptTemplate]을 그대로 쓴다.
class SystemPromptStore {
  final _store = LocalFileStore();

  Future<String?> read() => _store.read(_systemPromptKey);

  Future<void> save(String template) => _store.write(_systemPromptKey, template);

  Future<void> resetToDefault() => _store.delete(_systemPromptKey);
}
