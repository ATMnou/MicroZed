import 'dart:convert';

import 'package:http/http.dart' as http;

/// 한 번의 요청에서 소모한 토큰(+ 알 수 있으면 가격). 엔드포인트가 응답에 `usage`를
/// 실어주지 않으면 만들어지지 않는다.
class TokenUsage {
  const TokenUsage({
    required this.promptTokens,
    required this.completionTokens,
    this.costUsd,
    this.provider,
  });

  final int promptTokens;
  final int completionTokens;

  /// USD 기준. OpenRouter처럼 가격을 알려주는 엔드포인트에서만 값이 있다.
  final double? costUsd;

  /// OpenRouter처럼 여러 업스트림으로 라우팅하는 엔드포인트가 실제로 요청을 처리한
  /// 제공자명을 응답에 실어줄 때만 값이 있다(예: "DeepInfra"). OpenRouter 자신은
  /// 라우터일 뿐 제공자가 아니므로, 있으면 이 값을 baseUrl host 대신 표시해야 한다.
  final String? provider;
}

/// OpenRouter에서 알려진 중국 소재 제공자 슬러그. OpenRouter가 "지역별 제공자 제외"를
/// 공식 API로 제공하지 않아서 수동으로 유지보수하는 목록이다 - 새 중국 제공자가
/// OpenRouter에 추가되면 여기에 추가해줘야 한다.
const kOpenRouterChinaProviderSlugs = [
  'alibaba',
  'baidu',
  'tencent',
  'minimax',
  'moonshotai',
  'zhipu',
  'stepfun',
  'baichuan',
  '01ai',
];

/// OpenAI 호환 `/chat/completions` 엔드포인트에 스트리밍 요청을 보낸다.
/// BYOK이므로 baseUrl/apiKey/model은 전부 AI 프리셋에서 온다.
class OpenAiCompatibleClient {
  OpenAiCompatibleClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  Uri _endpoint(String baseUrl) {
    final trimmed = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$trimmed/chat/completions');
  }

  /// SSE(`data: {...}`) 라인을 파싱해 델타 텍스트 조각을 순서대로 방출한다.
  /// 토큰/가격 정보가 오면(보통 마지막 청크) [onUsage]로 한 번 알려준다.
  ///
  /// [messages]의 각 `content`는 보통 String이지만, ZedTalk의 비전 지원 프리셋처럼 이미지를
  /// 함께 보낼 때는 OpenAI 스타일 `[{type:'text',...}, {type:'image_url',...}]` 배열일 수도
  /// 있다 - 그래서 값 타입을 `String`이 아니라 `dynamic`으로 느슨하게 받는다.
  Stream<String> streamChatCompletion({
    required String baseUrl,
    required String apiKey,
    required String model,
    required List<Map<String, dynamic>> messages,
    double temperature = 1.0,
    int? topK,
    int? maxTokens,
    String? reasoningEffort,
    bool openRouterZdrOnly = false,
    bool openRouterExcludeChinaProviders = false,
    bool openRouterExcludeTrainingProviders = false,
    bool webSearch = false,
    void Function(TokenUsage usage)? onUsage,
    void Function(String reasoning)? onReasoning,
  }) async* {
    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      'stream': true,
      'temperature': temperature,
      // OpenAI 표준 확장(표준 호환 서버는 무시해도 무방) + OpenRouter 전용 확장(가격까지 포함).
      'stream_options': {'include_usage': true},
      'usage': {'include': true},
    };
    if (topK != null) body['top_k'] = topK;
    if (maxTokens != null) body['max_tokens'] = maxTokens;
    if (reasoningEffort != null && reasoningEffort.isNotEmpty) {
      body['reasoning_effort'] = reasoningEffort;
    }
    // 네이티브 웹 검색: OpenRouter는 web 플러그인, OpenAI 계열은 web_search_options로 켠다.
    // 실제 지원 여부는 선택한 모델에 달려 있어서(모두가 지원하지는 않음) 베스트에포트다.
    if (webSearch) {
      if (baseUrl.toLowerCase().contains('openrouter.ai')) {
        body['plugins'] = [
          {'id': 'web'},
        ];
      } else {
        body['web_search_options'] = <String, dynamic>{};
      }
    }
    // OpenRouter 전용 라우팅 옵션(AI 프리셋 편집 화면에서 baseUrl이 openrouter.ai일 때만
    // 노출됨). 표준 OpenAI 호환 서버는 알 수 없는 최상위 필드를 무시하므로 안전하다.
    if (openRouterZdrOnly || openRouterExcludeChinaProviders || openRouterExcludeTrainingProviders) {
      final provider = <String, dynamic>{};
      if (openRouterZdrOnly) provider['zdr'] = true;
      if (openRouterExcludeTrainingProviders) provider['data_collection'] = 'deny';
      if (openRouterExcludeChinaProviders) provider['ignore'] = kOpenRouterChinaProviderSlugs;
      body['provider'] = provider;
    }

    final request = http.Request('POST', _endpoint(baseUrl))
      ..headers['Content-Type'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..body = jsonEncode(body);

    final response = await _client.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      throw Exception('AI 요청이 실패했어요 (${response.statusCode}): $body');
    }

    final lines = response.stream.transform(utf8.decoder).transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final data = line.substring(5).trim();
      if (data.isEmpty || data == '[DONE]') continue;
      try {
        final json = jsonDecode(data) as Map<String, dynamic>;
        final usage = json['usage'] as Map<String, dynamic>?;
        if (usage != null && onUsage != null) {
          final prompt = (usage['prompt_tokens'] as num?)?.toInt() ?? 0;
          final completion = (usage['completion_tokens'] as num?)?.toInt() ?? 0;
          final cost = (usage['cost'] as num?)?.toDouble();
          // OpenRouter는 청크 최상위(usage와 같은 레벨)에 실제 라우팅된 제공자명을 실어준다.
          final provider = json['provider'] as String?;
          onUsage(
            TokenUsage(
              promptTokens: prompt,
              completionTokens: completion,
              costUsd: cost,
              provider: (provider != null && provider.isNotEmpty) ? provider : null,
            ),
          );
        }
        final choices = json['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) continue;
        final delta = choices.first['delta'] as Map<String, dynamic>?;
        // 추론 모델은 본문(content)과 별개로 reasoning_content/reasoning 필드에
        // 사고 과정을 실어 보낸다(OpenRouter/DeepSeek류 관례).
        final reasoning = (delta?['reasoning_content'] ?? delta?['reasoning']) as String?;
        if (reasoning != null && reasoning.isNotEmpty && onReasoning != null) {
          onReasoning(reasoning);
        }
        final content = delta?['content'] as String?;
        if (content != null && content.isNotEmpty) {
          yield content;
        }
      } catch (_) {
        // keep-alive 등 JSON이 아닌 조각은 건너뛴다.
      }
    }
  }
}
