import 'dart:convert';

import 'package:http/http.dart' as http;

/// 한 번의 요청에서 소모한 토큰(+ 알 수 있으면 가격). 엔드포인트가 응답에 `usage`를
/// 실어주지 않으면 만들어지지 않는다.
class TokenUsage {
  const TokenUsage({required this.promptTokens, required this.completionTokens, this.costUsd});

  final int promptTokens;
  final int completionTokens;

  /// USD 기준. OpenRouter처럼 가격을 알려주는 엔드포인트에서만 값이 있다.
  final double? costUsd;
}

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
  Stream<String> streamChatCompletion({
    required String baseUrl,
    required String apiKey,
    required String model,
    required List<Map<String, String>> messages,
    double temperature = 1.0,
    int? topK,
    int? maxTokens,
    void Function(TokenUsage usage)? onUsage,
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
          onUsage(TokenUsage(promptTokens: prompt, completionTokens: completion, costUsd: cost));
        }
        final choices = json['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) continue;
        final delta = choices.first['delta'] as Map<String, dynamic>?;
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
