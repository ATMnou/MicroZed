import 'dart:convert';

import '../db/database.dart';
import '../repositories/ai_preset_repository.dart';
import '../repositories/character_repository.dart';
import '../repositories/chat_memory_repository.dart';
import '../repositories/chat_turn_repository.dart';
import '../repositories/lorebook_repository.dart';
import '../repositories/plot_repository.dart';
import '../repositories/token_usage_repository.dart';
import '../secure/api_key_store.dart';
import 'anthropic_client.dart';
import 'local_llm/local_llm_engine.dart';
import 'message_format_parser.dart';
import 'openai_compatible_client.dart';
import 'prompt_builder.dart';
import 'summary_settings_store.dart';
import 'system_prompt_store.dart';

/// 스트리밍 생성을 도중에 멈출 수 있게 해주는 토큰. 채팅 화면에서 전송 버튼이 중지
/// 버튼으로 바뀌었을 때 눌리면 [cancel]이 호출된다. `await for` 루프 안에서 매 델타마다
/// [isCancelled]를 확인해 break하면, Dart가 하위 스트림 구독(HTTP 커넥션 포함)까지
/// 알아서 정리해준다.
class AiGenerationCancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

/// 채팅 화면이 사용자의 메시지에 대한 AI 응답을 생성할 때 쓰는 오케스트레이터.
/// 프롬프트 조립 → 스트리밍 요청 → 응답 파싱 → 턴/버전별 저장까지 담당한다.
class AiChatService {
  AiChatService({required AppDatabase db, OpenAiCompatibleClient? client, AnthropicClient? anthropicClient})
      : _client = client ?? OpenAiCompatibleClient(),
        _anthropicClient = anthropicClient ?? AnthropicClient(),
        _characterRepo = CharacterRepository(db),
        _plotRepo = PlotRepository(db),
        _turnRepo = ChatTurnRepository(db),
        _tokenUsageRepo = TokenUsageRepository(db),
        _lorebookRepo = LorebookRepository(db),
        _memoryRepo = ChatMemoryRepository(db),
        _presetRepo = AiPresetRepository(db),
        _apiKeyStore = ApiKeyStore(),
        _systemPromptStore = SystemPromptStore(),
        _summarySettingsStore = SummarySettingsStore();

  final OpenAiCompatibleClient _client;
  final AnthropicClient _anthropicClient;
  final CharacterRepository _characterRepo;
  final PlotRepository _plotRepo;
  final ChatTurnRepository _turnRepo;
  final TokenUsageRepository _tokenUsageRepo;
  final LorebookRepository _lorebookRepo;
  final ChatMemoryRepository _memoryRepo;
  final AiPresetRepository _presetRepo;
  final ApiKeyStore _apiKeyStore;
  final SystemPromptStore _systemPromptStore;
  final SummarySettingsStore _summarySettingsStore;

  /// 새 유저 메시지에 대한 첫 응답. 새 턴을 만들고 버전 0을 채운다.
  Future<void> generateReply({
    required int sessionId,
    required int plotId,
    required AiPreset preset,
    required String userProfileName,
    String userProfileDescription = '',
    required void Function(String accumulatedText) onDelta,
    void Function(String reasoning)? onReasoning,
    AiGenerationCancelToken? cancelToken,
  }) async {
    final turnId = await _turnRepo.createTurn(sessionId);
    await _generateVersion(
      sessionId: sessionId,
      plotId: plotId,
      preset: preset,
      userProfileName: userProfileName,
      userProfileDescription: userProfileDescription,
      turnId: turnId,
      versionIndex: 0,
      onDelta: onDelta,
      onReasoning: onReasoning,
      cancelToken: cancelToken,
    );
  }

  /// '재시도'. 같은 턴 아래 새 버전을 만들어서 활성 버전으로 전환한다.
  Future<void> retryReply({
    required int sessionId,
    required int plotId,
    required AiPreset preset,
    required String userProfileName,
    String userProfileDescription = '',
    required int turnId,
    required void Function(String accumulatedText) onDelta,
    void Function(String reasoning)? onReasoning,
    AiGenerationCancelToken? cancelToken,
  }) async {
    final nextIndex = await _turnRepo.nextVersionIndex(turnId);
    await _generateVersion(
      sessionId: sessionId,
      plotId: plotId,
      preset: preset,
      userProfileName: userProfileName,
      userProfileDescription: userProfileDescription,
      turnId: turnId,
      versionIndex: nextIndex,
      onDelta: onDelta,
      onReasoning: onReasoning,
      cancelToken: cancelToken,
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
    String userProfileDescription = '',
    required int turnId,
    required String instruction,
    required void Function(String accumulatedText) onDelta,
    void Function(String reasoning)? onReasoning,
    AiGenerationCancelToken? cancelToken,
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
      userProfileDescription: userProfileDescription,
      turnId: turnId,
      versionIndex: nextIndex,
      onDelta: onDelta,
      onReasoning: onReasoning,
      cancelToken: cancelToken,
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

  /// 세션/턴에 저장하지 않는 단발성 생성(플롯 AI 생성 등)에 쓰는 범용 호출.
  /// 스트리밍을 다 모아서 완성된 텍스트만 돌려준다.
  Future<String> completeOneShot({
    required AiPreset preset,
    required List<Map<String, String>> messages,
    bool webSearch = false,
  }) async {
    final buffer = StringBuffer();
    await for (final delta in _streamCompletion(preset: preset, messages: messages, webSearch: webSearch)) {
      buffer.write(delta);
    }
    return buffer.toString().trim();
  }

  /// 네이티브 웹 검색을 켤 수 있는 조합인지(로컬 모델은 지원 안 함, 원격은 OpenRouter 또는
  /// OpenAI 계열 OpenAI 호환 엔드포인트만 - Anthropic 형식은 이 앱에서 아직 별도 지원 안 함).
  static bool supportsWebSearch(AiPreset preset) {
    if (preset.isLocal) return false;
    if (preset.endpointFormat == AiEndpointFormat.anthropic) return false;
    final host = Uri.tryParse(preset.baseUrl)?.host.toLowerCase() ?? '';
    return host.contains('openrouter.ai') || host.contains('openai.com');
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

    yield* _streamCompletion(preset: preset, messages: messages);
  }

  /// [preset.isLocal]이면 기기 내장 llama.cpp 엔진으로, 아니면 원격 OpenAI 호환
  /// 엔드포인트로 스트리밍 요청을 보낸다. 두 경로 모두 같은 메시지 배열을 공유한다.
  Stream<String> _streamCompletion({
    required AiPreset preset,
    required List<Map<String, String>> messages,
    void Function(TokenUsage usage)? onUsage,
    void Function(String reasoning)? onReasoning,
    bool webSearch = false,
  }) async* {
    if (preset.isLocal) {
      final source = preset.localModelSource;
      if (source == null || source.isEmpty) {
        throw StateError('선택한 프리셋에 로컬 모델이 설정되어 있지 않아요.');
      }
      if (LocalLlmEngine.instance.current?.source != source) {
        await LocalLlmEngine.instance.load(source: source, label: preset.modelName);
      }
      yield* LocalLlmEngine.instance.streamChat(
        messages: messages,
        temperature: preset.temperature,
        topK: preset.topK,
        maxTokens: preset.maxTokens,
        reasoningEffort: preset.reasoningEffort,
        onReasoning: onReasoning,
      );
      return;
    }

    final apiKey = await _apiKeyStore.read(preset.id);
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('선택한 프리셋에 API 키가 설정되어 있지 않아요.');
    }

    if (preset.endpointFormat == AiEndpointFormat.anthropic) {
      String? system;
      final rest = <Map<String, String>>[];
      for (final message in messages) {
        if (message['role'] == 'system' && system == null) {
          system = message['content'];
        } else {
          rest.add(message);
        }
      }
      yield* _anthropicClient.streamMessages(
        baseUrl: preset.baseUrl,
        apiKey: apiKey,
        model: preset.modelName,
        system: system,
        messages: rest,
        temperature: preset.temperature,
        maxTokens: preset.maxTokens,
        onUsage: onUsage,
        onReasoning: onReasoning,
      );
      return;
    }

    yield* _client.streamChatCompletion(
      baseUrl: preset.baseUrl,
      apiKey: apiKey,
      model: preset.modelName,
      messages: messages,
      temperature: preset.temperature,
      topK: preset.topK,
      maxTokens: preset.maxTokens,
      reasoningEffort: preset.reasoningEffort,
      openRouterZdrOnly: preset.openRouterZdrOnly,
      openRouterExcludeChinaProviders: preset.openRouterExcludeChinaProviders,
      openRouterExcludeTrainingProviders: preset.openRouterExcludeTrainingProviders,
      webSearch: webSearch,
      onUsage: onUsage,
      onReasoning: onReasoning,
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

  /// [PromptBuilder.buildHistoryMessages]가 `contextLength`를 넘는 오래된 메시지를 그냥
  /// 잘라내기만 하는 것과 별개로, 잘려나가는 구간을 장기 기억(요약)으로 남겨서 시스템
  /// 프롬프트에 얹어준다. 잘리는 경계가 이전과 같으면(대부분의 턴이 그렇다) 저장된 요약을
  /// 그대로 재사용하고, 경계가 더 늘어났을 때만 잘려나간 구간 전체를 다시 요약한다
  /// (요약을 요약하는 식으로 점점 부정확해지는 걸 피하려고, 매번 원본 대화에서 다시 만든다).
  Future<String?> _ensureMemorySummary({
    required int sessionId,
    required AiPreset preset,
    required List<ChatMessage> history,
    required List<Character> characters,
  }) async {
    final contextLength = preset.contextLength;
    if (contextLength == null || contextLength <= 0) return null;

    final summarySettings = await _summarySettingsStore.read();
    if (!summarySettings.enabled) return null;

    final withoutImages = history.where((m) => m.senderType != MessageSender.image).toList();
    if (withoutImages.length <= contextLength) return null;

    final droppedCount = withoutImages.length - contextLength;
    final dropped = withoutImages.sublist(0, droppedCount);
    final lastDroppedId = dropped.last.id;

    final existing = await _memoryRepo.getForSession(sessionId);
    if (existing != null && existing.coveredUpToMessageId == lastDroppedId) {
      return existing.summaryText;
    }

    final droppedText = PromptBuilder.reconstructRawText(messages: dropped, characters: characters);
    final summaryPreset = summarySettings.presetId == null
        ? preset
        : (await _presetRepo.getById(summarySettings.presetId!)) ?? preset;
    final summary = await _summarizeHistory(summaryPreset, droppedText, customPrompt: summarySettings.customPrompt);
    await _memoryRepo.upsert(sessionId: sessionId, coveredUpToMessageId: lastDroppedId, summaryText: summary);
    return summary;
  }

  Future<String> _summarizeHistory(AiPreset preset, String rawText, {String? customPrompt}) async {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': customPrompt?.trim().isNotEmpty == true
            ? customPrompt!.trim()
            : '너는 롤플레이 채팅의 오래된 대화 기록을 요약하는 도우미야. 아래 대화 기록을 앞으로 이어질 롤플레이에 '
                '필요한 핵심 사실/설정/관계 변화 위주로 5~10문장 정도로 압축해줘. 대화체가 아니라 요약문으로 쓰고, '
                '다른 설명 없이 요약 내용만 출력해.',
      },
      {'role': 'user', 'content': rawText},
    ];
    final summary = await completeOneShot(preset: preset, messages: messages);
    return summary.isEmpty ? '(요약 실패)' : summary;
  }

  Future<void> _generateVersion({
    required int sessionId,
    required int plotId,
    required AiPreset preset,
    required String userProfileName,
    String userProfileDescription = '',
    required int turnId,
    required int versionIndex,
    required void Function(String accumulatedText) onDelta,
    void Function(String reasoning)? onReasoning,
    AiGenerationCancelToken? cancelToken,
    List<Map<String, String>> extraMessages = const [],
  }) async {
    final plot = await _plotRepo.getById(plotId);
    final characters = await _characterRepo.getByPlot(plotId);
    final history = await _turnRepo.historyBeforeTurn(sessionId, turnId);
    final conversationText = history.map((m) => m.content).join('\n');
    final loreContext = await _lorebookRepo.buildLoreContext(plotId, conversationText);
    final customTemplate = await _systemPromptStore.read();
    final memorySummary = await _ensureMemorySummary(
      sessionId: sessionId,
      preset: preset,
      history: history,
      characters: characters,
    );

    final systemPrompt = PromptBuilder.buildSystemPrompt(
      plot: plot,
      characters: characters,
      userProfileName: userProfileName,
      userProfileDescription: userProfileDescription,
      additionalSystemPrompt: preset.additionalSystemPrompt,
      loreContext: loreContext,
      customTemplate: customTemplate,
    );
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      if (memorySummary != null) {'role': 'system', 'content': '이전 대화 요약:\n$memorySummary'},
      ...PromptBuilder.buildHistoryMessages(
        history: history,
        characters: characters,
        contextLength: preset.contextLength,
      ),
      ...extraMessages,
    ];

    final buffer = StringBuffer();
    TokenUsage? usage;
    await for (final delta in _streamCompletion(
      preset: preset,
      messages: messages,
      onUsage: (u) => usage = u,
      onReasoning: onReasoning,
    )) {
      buffer.write(delta);
      onDelta(buffer.toString());
      if (cancelToken?.isCancelled == true) break;
    }

    if (usage != null) {
      await _tokenUsageRepo.log(
        presetName: preset.name,
        baseUrl: preset.baseUrl,
        modelName: preset.modelName,
        promptTokens: usage!.promptTokens,
        completionTokens: usage!.completionTokens,
        costUsd: usage!.costUsd,
        provider: usage!.provider,
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
