import 'dart:convert';

import 'package:http/http.dart' as http;

import 'openai_compatible_client.dart' show TokenUsage;

const _anthropicVersion = '2023-06-01';

/// Anthropic Messages API(`/v1/messages`)에 스트리밍 요청을 보낸다. [OpenAiCompatibleClient]와
/// 스트리밍 인터페이스(`Stream<String>` 델타 + onUsage/onReasoning 콜백)를 맞춰서
/// [AiChatService]가 두 클라이언트를 동일하게 다룰 수 있게 한다.
///
/// OpenAI 호환 형식과의 주요 차이:
/// - system 프롬프트는 messages 배열이 아니라 최상위 `system` 필드로 분리해서 보낸다.
/// - 인증은 `Authorization: Bearer`가 아니라 `x-api-key` 헤더 + `anthropic-version` 헤더.
/// - user/assistant 메시지가 반드시 번갈아 나와야 하므로, 같은 역할이 연달아 나오면
///   하나로 합쳐서 보낸다(나레이터/캐릭터 대사가 모두 'assistant'로 매핑되는 이 앱의 프롬프트
///   구조상 실제로 자주 발생한다).
class AnthropicClient {
  AnthropicClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  Uri _endpoint(String baseUrl) {
    final trimmed = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$trimmed/v1/messages');
  }

  /// 같은 role이 연달아 나오면 내용을 줄바꿈으로 이어붙여 하나로 합친다.
  List<Map<String, String>> _mergeConsecutiveRoles(List<Map<String, String>> messages) {
    final merged = <Map<String, String>>[];
    for (final message in messages) {
      if (merged.isNotEmpty && merged.last['role'] == message['role']) {
        merged.last['content'] = '${merged.last['content']}\n${message['content']}';
      } else {
        merged.add({'role': message['role']!, 'content': message['content']!});
      }
    }
    return merged;
  }

  Stream<String> streamMessages({
    required String baseUrl,
    required String apiKey,
    required String model,
    String? system,
    required List<Map<String, String>> messages,
    double temperature = 1.0,
    int? maxTokens,
    void Function(TokenUsage usage)? onUsage,
    void Function(String reasoning)? onReasoning,
  }) async* {
    final body = <String, dynamic>{
      'model': model,
      'max_tokens': maxTokens ?? 1024,
      'messages': _mergeConsecutiveRoles(messages),
      'stream': true,
      'temperature': temperature,
    };
    if (system != null && system.isNotEmpty) body['system'] = system;

    final request = http.Request('POST', _endpoint(baseUrl))
      ..headers['Content-Type'] = 'application/json'
      ..headers['x-api-key'] = apiKey
      ..headers['anthropic-version'] = _anthropicVersion
      ..body = jsonEncode(body);

    final response = await _client.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errBody = await response.stream.bytesToString();
      throw Exception('AI 요청이 실패했어요 (${response.statusCode}): $errBody');
    }

    var inputTokens = 0;
    var outputTokens = 0;
    final lines = response.stream.transform(utf8.decoder).transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final data = line.substring(5).trim();
      if (data.isEmpty) continue;
      try {
        final json = jsonDecode(data) as Map<String, dynamic>;
        switch (json['type'] as String?) {
          case 'message_start':
            final usage = (json['message'] as Map<String, dynamic>?)?['usage'] as Map<String, dynamic>?;
            inputTokens = (usage?['input_tokens'] as num?)?.toInt() ?? 0;
          case 'content_block_delta':
            final delta = json['delta'] as Map<String, dynamic>?;
            switch (delta?['type'] as String?) {
              case 'text_delta':
                final text = delta?['text'] as String?;
                if (text != null && text.isNotEmpty) yield text;
              case 'thinking_delta':
                final thinking = delta?['thinking'] as String?;
                if (thinking != null && thinking.isNotEmpty && onReasoning != null) {
                  onReasoning(thinking);
                }
            }
          case 'message_delta':
            final usage = json['usage'] as Map<String, dynamic>?;
            final completion = (usage?['output_tokens'] as num?)?.toInt();
            if (completion != null) outputTokens = completion;
          case 'message_stop':
            if (onUsage != null) {
              onUsage(TokenUsage(promptTokens: inputTokens, completionTokens: outputTokens));
            }
        }
      } catch (_) {
        // ping 등 JSON이 아니거나 알 수 없는 이벤트는 건너뛴다.
      }
    }
  }
}
