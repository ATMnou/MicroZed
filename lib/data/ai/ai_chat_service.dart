import 'dart:convert';

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
import 'system_prompt_store.dart';

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
        _apiKeyStore = ApiKeyStore(),
        _systemPromptStore = SystemPromptStore();

  final OpenAiCompatibleClient _client;
  final CharacterRepository _characterRepo;
  final PlotRepository _plotRepo;
  final ChatTurnRepository _turnRepo;
  final TokenUsageRepository _tokenUsageRepo;
  final LorebookRepository _lorebookRepo;
  final ApiKeyStore _apiKeyStore;
  final SystemPromptStore _systemPromptStore;

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

  /// 채팅 화면의 번개 버튼. 지금까지의 대화를 보고 유저가 다음에 보낼 법한 메시지 후보를
  /// 서로 다른 방향으로 3개 만들어 돌려준다. 대화 기록에는 아무것도 남기지 않는다.
  Future<List<String>> generateSuggestions({
    required int sessionId,
    required int plotId,
    required AiPreset preset,
    required String userProfileName,
  }) async {
    final buffer = StringBuffer();
    await for (final delta in _streamAuxCompletion(
      sessionId: sessionId,
      plotId: plotId,
      preset: preset,
      userProfileName: userProfileName,
      instruction: '지금까지의 대화를 참고해서, $userProfileName(플레이어)가 다음에 보낼 법한 메시지 후보를 서로 다른 방향으로 3개 제안해줘. '
          '각 후보는 채팅 입력창에 그대로 넣을 수 있는 짧은 대사/행동 묘사(1~2문장)로 써. '
          '다른 설명 없이 다음 형식의 JSON 배열만 출력해: ["후보1", "후보2", "후보3"]',
    )) {
      buffer.write(delta);
    }
    return _parseSuggestionArray(buffer.toString());
  }

  /// 채팅 화면의 스냅샷 버튼. 지금까지의 장면을 이미지 생성 AI에게 줄 한 문단짜리
  /// 묘사 프롬프트로 요약해서 돌려준다. 실제 이미지 생성은 [ImageGenClient]가 담당한다.
  Future<String> summarizeSceneForSnapshot({
    required int sessionId,
    required int plotId,
    required AiPreset preset,
    required String userProfileName,
  }) async {
    final buffer = StringBuffer();
    await for (final delta in _streamAuxCompletion(
      sessionId: sessionId,
      plotId: plotId,
      preset: preset,
      userProfileName: userProfileName,
      instruction: '방금까지의 장면을 한 장의 삽화로 그린다면 어떤 모습일지, 등장인물의 외모/표정/포즈, 배경, 분위기를 이미지 생성 AI가 '
          '이해할 수 있도록 한 문단으로 구체적으로 묘사해줘. 다른 설명이나 따옴표 없이 묘사 내용만 출력해.',
    )) {
      buffer.write(delta);
    }
    final result = buffer.toString().trim();
    if (result.isEmpty) {
      throw StateError('장면을 요약하지 못했어요.');
    }
    return result;
  }

  /// [generateSuggestions]/[summarizeSceneForSnapshot]가 공유하는 보조 호출.
  /// 지금까지의 대화 기록 + [instruction]을 전달해 스트리밍 응답을 그대로 넘긴다.
  Stream<String> _streamAuxCompletion({
    required int sessionId,
    required int plotId,
    required AiPreset preset,
    required String userProfileName,
    required String instruction,
  }) async* {
    final apiKey = await _apiKeyStore.read(preset.id);
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('선택한 프리셋에 API 키가 설정되어 있지 않아요.');
    }

    final plot = await _plotRepo.getById(plotId);
    final characters = await _characterRepo.getByPlot(plotId);
    final history = (await _turnRepo.timelineOnce(sessionId)).map((i) => i.message).toList();
    final conversationText = history.map((m) => m.content).join('\n');
    final loreContext = await _lorebookRepo.buildLoreContext(plotId, conversationText);
    final customTemplate = await _systemPromptStore.read();

    final systemPrompt = PromptBuilder.buildSystemPrompt(
      plot: plot,
      characters: characters,
      userProfileName: userProfileName,
      additionalSystemPrompt: preset.additionalSystemPrompt,
      loreContext: loreContext,
      customTemplate: customTemplate,
    );
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      ...PromptBuilder.buildHistoryMessages(
        history: history,
        characters: characters,
        contextLength: preset.contextLength,
      ),
      {'role': 'user', 'content': instruction},
    ];

    yield* _client.streamChatCompletion(
      baseUrl: preset.baseUrl,
      apiKey: apiKey,
      model: preset.modelName,
      messages: messages,
      temperature: preset.temperature,
      topK: preset.topK,
      maxTokens: preset.maxTokens,
    );
  }

  List<String> _parseSuggestionArray(String raw) {
    final trimmed = raw.trim();
    final start = trimmed.indexOf('[');
    final end = trimmed.lastIndexOf(']');
    if (start == -1 || end == -1 || end <= start) return const [];
    try {
      final decoded = jsonDecode(trimmed.substring(start, end + 1));
      if (decoded is List) {
        return decoded.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).take(3).toList();
      }
    } catch (_) {
      // 모델이 JSON 형식을 안 지켰으면 빈 목록으로 처리한다.
    }
    return const [];
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
    final customTemplate = await _systemPromptStore.read();

    final systemPrompt = PromptBuilder.buildSystemPrompt(
      plot: plot,
      characters: characters,
      userProfileName: userProfileName,
      additionalSystemPrompt: preset.additionalSystemPrompt,
      loreContext: loreContext,
      customTemplate: customTemplate,
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
