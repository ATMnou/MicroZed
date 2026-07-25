import '../db/database.dart';
import '../repositories/character_repository.dart';
import '../repositories/chat_turn_repository.dart';
import '../repositories/lorebook_repository.dart';
import '../repositories/plot_repository.dart';
import '../repositories/token_usage_repository.dart';
import '../secure/api_key_store.dart';
import 'message_format_parser.dart';
import 'openai_compatible_client.dart';
import 'prompt_builder.dart';

/// 채팅 화면이 사용자의 메시지에 대한 AI 응답을 생성할 때 쓰는 오케스트레이터.
/// 프롬프트 조립 → 스트리밍 요청 → 응답 파싱 → 턴/버전별 저장까지 담당한다.
class AiChatService {
  AiChatService({required AppDatabase db, OpenAiCompatibleClient? client})
      : _client = client ?? OpenAiCompatibleClient(),
        _characterRepo = CharacterRepository(db),
        _plotRepo = PlotRepository(db),
        _turnRepo = ChatTurnRepository(db),
        _tokenUsageRepo = TokenUsageRepository(db),
        _lorebookRepo = LorebookRepository(db),
        _apiKeyStore = ApiKeyStore();

  final OpenAiCompatibleClient _client;
  final CharacterRepository _characterRepo;
  final PlotRepository _plotRepo;
  final ChatTurnRepository _turnRepo;
  final TokenUsageRepository _tokenUsageRepo;
  final LorebookRepository _lorebookRepo;
  final ApiKeyStore _apiKeyStore;

  /// 새 유저 메시지에 대한 첫 응답. 새 턴을 만들고 버전 0을 채운다.
  Future<void> generateReply({
    required int sessionId,
    required int plotId,
    required AiPreset preset,
    required String userProfileName,
    required void Function(String accumulatedText) onDelta,
  }) async {
    final turnId = await _turnRepo.createTurn(sessionId);
    await _generateVersion(
      sessionId: sessionId,
      plotId: plotId,
      preset: preset,
      userProfileName: userProfileName,
      turnId: turnId,
      versionIndex: 0,
      onDelta: onDelta,
    );
  }

  /// '재시도'. 같은 턴 아래 새 버전을 만들어서 활성 버전으로 전환한다.
  Future<void> retryReply({
    required int sessionId,
    required int plotId,
    required AiPreset preset,
    required String userProfileName,
    required int turnId,
    required void Function(String accumulatedText) onDelta,
  }) async {
    final nextIndex = await _turnRepo.nextVersionIndex(turnId);
    await _generateVersion(
      sessionId: sessionId,
      plotId: plotId,
      preset: preset,
      userProfileName: userProfileName,
      turnId: turnId,
      versionIndex: nextIndex,
      onDelta: onDelta,
    );
    await _turnRepo.setActiveVersion(turnId, nextIndex);
  }

  /// 'AI 수정'. 현재 활성 버전 내용 + 사용자 지시를 모델에게 함께 전달해 다시 쓰게 하고,
  /// 결과를 새 버전으로 저장한 뒤 활성 버전으로 전환한다.
  Future<void> reviseReply({
    required int sessionId,
    required int plotId,
    required AiPreset preset,
    required String userProfileName,
    required int turnId,
    required String instruction,
    required void Function(String accumulatedText) onDelta,
  }) async {
    final turn = await _turnRepo.getTurn(turnId);
    if (turn == null) return;
    final currentMessages = await _turnRepo.getVersionMessages(turnId, turn.activeVersionIndex);
    final characters = await _characterRepo.getByPlot(plotId);
    final currentRawText = PromptBuilder.reconstructRawText(messages: currentMessages, characters: characters);

    final nextIndex = await _turnRepo.nextVersionIndex(turnId);
    await _generateVersion(
      sessionId: sessionId,
      plotId: plotId,
      preset: preset,
      userProfileName: userProfileName,
      turnId: turnId,
      versionIndex: nextIndex,
      onDelta: onDelta,
      extraMessages: [
        {'role': 'assistant', 'content': currentRawText},
        {'role': 'user', 'content': '방금 그 답변을 다음 지시에 따라 다시 써 주세요: ${instruction.trim()}'},
      ],
    );
    await _turnRepo.setActiveVersion(turnId, nextIndex);
  }

  /// '수정'(직접 편집). 편집한 원문을 다시 파싱해서 지금 활성 버전의 말풍선들을 통째로 교체한다.
  /// AI 호출은 일어나지 않는다.
  Future<void> applyManualEdit({
    required int turnId,
    required int plotId,
    required int activeVersionIndex,
    required String editedRawText,
  }) async {
    final characters = await _characterRepo.getByPlot(plotId);
    final segments = MessageFormatParser.parse(editedRawText);
    await _turnRepo.replaceVersionMessages(
      turnId: turnId,
      versionIndex: activeVersionIndex,
      segments: segments,
      resolveCharacterId: (name) => _matchCharacter(characters, name)?.id,
    );
  }

  Future<void> _generateVersion({
    required int sessionId,
    required int plotId,
    required AiPreset preset,
    required String userProfileName,
    required int turnId,
    required int versionIndex,
    required void Function(String accumulatedText) onDelta,
    List<Map<String, String>> extraMessages = const [],
  }) async {
    final apiKey = await _apiKeyStore.read(preset.id);
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('선택한 프리셋에 API 키가 설정되어 있지 않아요.');
    }

    final plot = await _plotRepo.getById(plotId);
    final characters = await _characterRepo.getByPlot(plotId);
    final history = await _turnRepo.historyBeforeTurn(sessionId, turnId);
    final conversationText = history.map((m) => m.content).join('\n');
    final loreContext = await _lorebookRepo.buildLoreContext(plotId, conversationText);

    final systemPrompt = PromptBuilder.buildSystemPrompt(
      plot: plot,
      characters: characters,
      userProfileName: userProfileName,
      additionalSystemPrompt: preset.additionalSystemPrompt,
      loreContext: loreContext,
    );
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      ...PromptBuilder.buildHistoryMessages(
        history: history,
        characters: characters,
        contextLength: preset.contextLength,
      ),
      ...extraMessages,
    ];

    final buffer = StringBuffer();
    TokenUsage? usage;
    await for (final delta in _client.streamChatCompletion(
      baseUrl: preset.baseUrl,
      apiKey: apiKey,
      model: preset.modelName,
      messages: messages,
      temperature: preset.temperature,
      topK: preset.topK,
      maxTokens: preset.maxTokens,
      onUsage: (u) => usage = u,
    )) {
      buffer.write(delta);
      onDelta(buffer.toString());
    }

    if (usage != null) {
      await _tokenUsageRepo.log(
        presetName: preset.name,
        baseUrl: preset.baseUrl,
        modelName: preset.modelName,
        promptTokens: usage!.promptTokens,
        completionTokens: usage!.completionTokens,
        costUsd: usage!.costUsd,
      );
    }

    final fullText = buffer.toString().trim();
    if (fullText.isEmpty) return;

    final segments = MessageFormatParser.parse(fullText);
    await _turnRepo.addVersionMessages(
      sessionId: sessionId,
      turnId: turnId,
      versionIndex: versionIndex,
      segments: segments,
      resolveCharacterId: (name) => _matchCharacter(characters, name)?.id,
    );
  }

  /// AI가 등록된 캐릭터 이름을 그대로 쓰지 않고 앞뒤에 수식어를 붙이는 경우가 있어서,
  /// 정확히 일치하지 않으면 서로 포함 관계인지도 확인해 최대한 매칭을 살린다.
  Character? _matchCharacter(List<Character> characters, String speakerName) {
    final normalized = speakerName.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    for (final c in characters) {
      if (c.name.trim().toLowerCase() == normalized) return c;
    }
    for (final c in characters) {
      final name = c.name.trim().toLowerCase();
      if (name.isEmpty) continue;
      if (normalized.contains(name) || name.contains(normalized)) return c;
    }
    return null;
  }
}
