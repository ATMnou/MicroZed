import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../db/database.dart';
import '../secure/api_key_store.dart';
import 'anthropic_client.dart';
import 'openai_compatible_client.dart';

/// ZedTalk 전용 시스템 프롬프트. 롤플레이용 [PromptBuilder]의 장문 설정 템플릿과 달리,
/// 카카오톡처럼 짧고 일상적인 대화 톤을 유도한다. [now]는 실제 기기 시각을 그대로 실어서,
/// AI가 "지금 몇 시야?" 같은 질문이나 날짜가 바뀌는 상황에 자연스럽게 반응하게 한다.
String buildTalkSystemPrompt({
  required String characterName,
  required String characterDescription,
  required String userProfileName,
  required DateTime now,
}) {
  final nowText = DateFormat('yyyy년 M월 d일 EEEE a h시 mm분', 'ko').format(now);
  return '지금은 $nowText이야.\n\n'
      '너는 메신저 앱에서 "$characterName"(이)라는 사람으로서 "$userProfileName"과 1:1로 대화하는 중이야.\n'
      '캐릭터 설정: $characterDescription\n\n'
      '롤플레이 소설처럼 길게 서술하지 말고, 실제 메신저에서 친구랑 대화하듯 짧고 자연스러운 문장(1~3문장) 위주로 답해. '
      '이모티콘이나 줄임말을 과하지 않게 섞어도 좋아. 나레이션이나 행동 묘사(*...* 같은 표현)는 쓰지 마.';
}

/// ZedTalk이 사용하는 경량 AI 오케스트레이터. 롤플레이용 [AiChatService]와 달리 턴/버전
/// 관리가 없고(재시도/AI수정 없음), 세션/메시지 저장도 호출부(화면)가 [TalkMessageRepository]로
/// 직접 처리한다 - 여기서는 순수하게 "지금까지의 메시지로 다음 답장을 스트리밍한다"만 담당한다.
class TalkChatService {
  TalkChatService({OpenAiCompatibleClient? client, AnthropicClient? anthropicClient})
      : _client = client ?? OpenAiCompatibleClient(),
        _anthropicClient = anthropicClient ?? AnthropicClient(),
        _apiKeyStore = ApiKeyStore();

  final OpenAiCompatibleClient _client;
  final AnthropicClient _anthropicClient;
  final ApiKeyStore _apiKeyStore;

  /// [history]는 시간순(오래된 것 -> 최신). 가장 마지막 메시지가 이미지 첨부를 갖고 있고
  /// [preset.supportsVision]이 켜져 있으면(OpenAI 호환 엔드포인트 한정) 그 이미지를 함께
  /// 보낸다 - 그 외에는 첨부가 있어도 텍스트만 보낸다.
  Stream<String> streamReply({
    required AiPreset preset,
    required String systemPrompt,
    required List<TalkMessage> history,
  }) async* {
    final apiKey = await _apiKeyStore.read(preset.id);
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('선택한 프리셋에 API 키가 설정되어 있지 않아요.');
    }

    if (preset.endpointFormat == AiEndpointFormat.anthropic) {
      final messages = history
          .map((m) => {
                'role': m.sender == TalkMessageSender.user ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList();
      yield* _anthropicClient.streamMessages(
        baseUrl: preset.baseUrl,
        apiKey: apiKey,
        model: preset.modelName,
        system: systemPrompt,
        messages: messages,
        temperature: preset.temperature,
        maxTokens: preset.maxTokens,
      );
      return;
    }

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
    ];
    for (var i = 0; i < history.length; i++) {
      final message = history[i];
      final role = message.sender == TalkMessageSender.user ? 'user' : 'assistant';
      final isLast = i == history.length - 1;
      final hasVisibleImage =
          isLast && preset.supportsVision && message.attachmentType == TalkAttachmentType.image && message.attachmentPath != null;
      if (hasVisibleImage) {
        final dataUrl = await _imageDataUrl(message.attachmentPath!);
        messages.add({
          'role': role,
          'content': [
            {'type': 'text', 'text': message.content},
            {
              'type': 'image_url',
              'image_url': {'url': dataUrl},
            },
          ],
        });
      } else {
        messages.add({'role': role, 'content': message.content});
      }
    }

    yield* _client.streamChatCompletion(
      baseUrl: preset.baseUrl,
      apiKey: apiKey,
      model: preset.modelName,
      messages: messages,
      temperature: preset.temperature,
      maxTokens: preset.maxTokens,
      openRouterZdrOnly: preset.openRouterZdrOnly,
      openRouterExcludeChinaProviders: preset.openRouterExcludeChinaProviders,
      openRouterExcludeTrainingProviders: preset.openRouterExcludeTrainingProviders,
    );
  }

  Future<String> _imageDataUrl(String path) async {
    final bytes = await File(path).readAsBytes();
    final ext = p.extension(path).replaceFirst('.', '').toLowerCase();
    final mime = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/png',
    };
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }
}
