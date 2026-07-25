import '../db/database.dart';

/// 플롯/캐릭터/대화 기록으로부터 OpenAI 호환 chat completions 요청에 넣을
/// 시스템 프롬프트와 메시지 히스토리를 만든다.
class PromptBuilder {
  static String buildSystemPrompt({
    required Plot? plot,
    required List<Character> characters,
    required String userProfileName,
    String additionalSystemPrompt = '',
    String loreContext = '',
  }) {
    final charactersBlock = characters.isEmpty
        ? '(등록된 캐릭터가 없어요)'
        : characters.map((c) => '- ${c.name}: ${c.description}').join('\n');
    final exampleCharacterName = characters.isNotEmpty ? characters.first.name : '캐릭터 1';

    final lore = loreContext.trim();
    final loreBlock = lore.isEmpty ? '' : '\n\n[로어북]\n$lore';

    final extra = additionalSystemPrompt.trim();
    final extraBlock = extra.isEmpty ? '' : '\n\n[추가 지침]\n$extra';

    return '''
당신은 아래 설정에 따라 롤플레잉 인터랙티브 픽션을 진행하는 스토리텔러입니다.

[플롯]
제목: ${plot?.title ?? ''}
설명: ${plot?.description ?? ''}

[캐릭터]
$charactersBlock

[플레이어]
플레이어를 지칭할 때는 반드시 {{user}}라고 쓰세요. (현재 이름: $userProfileName)

[출력 형식 규칙]
- 화자가 바뀔 때만 문단 맨 앞에 "@이름:"(캐릭터 발화) 또는 "@:"(나레이션)을 붙이세요.
- "@"로 시작하지 않는 문단은 직전 화자가 이어서 말하는 것으로 취급되니, 같은 화자가 계속 말할 때는 "@"를 다시 붙이지 마세요.
- 위 [캐릭터] 목록에 있는 인물을 지칭할 때는 반드시 목록에 적힌 이름을 한 글자도 바꾸지 말고 정확히 그대로 쓰세요. 플롯 제목, 존칭, 그 외 어떤 수식어도 이름 앞뒤에 붙이지 마세요. (예: 목록의 이름이 "캐릭터 1"이면 "캐릭터 1"이라고만 쓰고, "테스트용 캐릭터 1"처럼 다른 단어를 덧붙이지 마세요.)
- 목록에 없는 새로운 인물을 즉석에서 등장시키는 것은 괜찮습니다. 다만 그 인물에게도 짧고 자연스러운 고유한 이름을 지어 "@이름:"으로 표시하세요. 위와 마찬가지로 그 이름에도 수식어를 붙이지 말고, 한 번 지은 이름은 이후에도 똑같이 유지하세요.
- 지문이나 행동 묘사는 *별표*로 감싸고, 대사는 별표 없이 그대로 쓰세요.
- 문단(빈 줄로 구분되는 단위) 하나에 한 가지 내용만 담으세요.

[줄바꿈 규칙 - 매우 중요]
- "@이름:" 또는 "@:" 태그는 항상 새로운 줄의 맨 앞에서 시작하세요. 이전 문장 뒤에 이어붙이거나 같은 줄에 두 개 이상의 "@" 태그를 넣지 마세요.
- 화자가 바뀔 때나 새로운 문단을 시작할 때는 반드시 줄바꿈을 하고, 가능하면 그 사이에 빈 줄을 하나 넣어 문단을 명확히 구분하세요.

[예시]
@: *나레이션 예시*

@$exampleCharacterName: 대사 1

@$exampleCharacterName: *행동 묘사*

대사 2
$loreBlock$extraBlock''';
  }

  static List<Map<String, String>> buildHistoryMessages({
    required List<ChatMessage> history,
    required List<Character> characters,
    int? contextLength,
  }) {
    // 이미지 첨부는 관리용일 뿐이라 AI에게는 절대 전달하지 않는다.
    final withoutImages = history.where((m) => m.senderType != MessageSender.image).toList();
    final trimmed = (contextLength != null && contextLength > 0 && withoutImages.length > contextLength)
        ? withoutImages.sublist(withoutImages.length - contextLength)
        : withoutImages;

    return trimmed.map((m) {
      switch (m.senderType) {
        case MessageSender.user:
          return {'role': 'user', 'content': m.content};
        case MessageSender.character:
          return {'role': 'assistant', 'content': '@${_nameFor(m, characters)}: ${m.content}'};
        case MessageSender.narrator:
          return {'role': 'assistant', 'content': '@: ${m.content}'};
        case MessageSender.image:
          throw StateError('image messages are filtered out above');
      }
    }).toList();
  }

  /// 지금 활성화된 버전의 원문을 "@이름: 내용" 형식으로 재구성한다.
  /// '수정' 화면의 편집 가능한 원문 미리 채우기, 'AI 수정' 시 이전 답변을 모델에게
  /// 다시 알려줄 때 공통으로 쓴다.
  static String reconstructRawText({
    required List<ChatMessage> messages,
    required List<Character> characters,
  }) {
    return messages
        .where((m) => m.senderType != MessageSender.image)
        .map((m) {
          switch (m.senderType) {
            case MessageSender.narrator:
              return '@: ${m.content}';
            case MessageSender.character:
              return '@${_nameFor(m, characters)}: ${m.content}';
            case MessageSender.user:
              return m.content;
            case MessageSender.image:
              throw StateError('image messages are filtered out above');
          }
        })
        .join('\n\n');
  }

  static String _nameFor(ChatMessage message, List<Character> characters) {
    if (message.characterId != null) {
      final match = characters.where((c) => c.id == message.characterId);
      if (match.isNotEmpty) return match.first.name;
    }
    return message.speakerNameOverride ?? '';
  }
}
