import '../db/database.dart';
import '../korean_josa.dart';

/// 플롯/캐릭터/대화 기록으로부터 OpenAI 호환 chat completions 요청에 넣을
/// 시스템 프롬프트와 메시지 히스토리를 만든다.
class PromptBuilder {
  /// 마이페이지 > 시스템 프롬프트 설정에서 사용자가 통째로 덮어쓸 수 있는 기본 템플릿.
  /// {{plot_title}}, {{plot_description}}, {{characters_block}}, {{example_character_name}},
  /// {{user_profile_name}}, {{user_profile_description_block}}, {{lore_block}}, {{extra_block}}는
  /// 실제 값으로 치환된다.
  /// `{{user}}`는 치환 대상이 아니라 AI가 응답에 그대로 남겨야 하는 리터럴 토큰이니 그대로 둔다.
  /// `{{char}}`는 이 템플릿이 아니라 캐릭터 소개글(Character.description) 안에서만 그 캐릭터
  /// 자신의 이름으로 치환된다({{characters_block}}가 만들어질 때).
  static const String defaultSystemPromptTemplate = '''
당신은 아래 설정에 따라 롤플레잉 인터랙티브 픽션을 진행하는 스토리텔러입니다.

[플롯]
제목: {{plot_title}}
설명: {{plot_description}}

[캐릭터]
{{characters_block}}

[플레이어]
플레이어를 지칭할 때는 반드시 {{user}}라고 쓰세요. (현재 이름: {{user_profile_name}}){{user_profile_description_block}}

[출력 형식 규칙 - 매우 중요]
- 화자가 바뀔 때만 새 줄 맨 앞에 "@이름:"(캐릭터 발화) 또는 "@:"(나레이션)을 붙이세요.
- 한 화자의 이번 차례는 대사와 행동 묘사를 전부 합쳐서 하나의 말풍선(문단)으로 이어서 쓰세요. 같은 화자가 계속 말하는 동안에는 "@"를 다시 붙이거나 중간에 빈 줄을 넣어 끊지 마세요 — 여러 문장, 여러 행동 묘사가 있어도 전부 한 문단 안에 자연스럽게 이어붙이세요.
- 정말로 다른 화자로 넘어갈 때만(예: 다른 캐릭터가 말하거나 나레이션으로 전환될 때) 새로운 "@" 태그와 함께 새 말풍선을 시작하세요. 한 화자가 굳이 여러 번 끊어 말할 이유가 없다면 절대로 나누지 마세요.
- 위 [캐릭터] 목록에 있는 인물을 지칭할 때는 반드시 목록에 적힌 이름을 한 글자도 바꾸지 말고 정확히 그대로 쓰세요. 플롯 제목, 존칭, 그 외 어떤 수식어도 이름 앞뒤에 붙이지 마세요. (예: 목록의 이름이 "캐릭터 1"이면 "캐릭터 1"이라고만 쓰고, "테스트용 캐릭터 1"처럼 다른 단어를 덧붙이지 마세요.)
- 목록에 없는 새로운 인물을 즉석에서 등장시키는 것은 괜찮습니다. 다만 그 인물에게도 짧고 자연스러운 고유한 이름을 지어 "@이름:"으로 표시하세요. 위와 마찬가지로 그 이름에도 수식어를 붙이지 말고, 한 번 지은 이름은 이후에도 똑같이 유지하세요.
- 지문이나 행동 묘사는 *별표*로 감싸고, 대사는 별표 없이 그대로 쓰세요.

[줄바꿈 규칙 - 매우 중요]
- "@이름:" 또는 "@:" 태그는 항상 새로운 줄의 맨 앞에서 시작하세요. 이전 문장 뒤에 이어붙이거나 같은 줄에 두 개 이상의 "@" 태그를 넣지 마세요.
- 화자가 실제로 바뀔 때만 줄바꿈 후 빈 줄을 하나 넣어 이전 화자와 명확히 구분하세요. 같은 화자가 이어서 말할 때는 빈 줄 없이 바로 다음 줄(또는 같은 문단 안)에 이어 쓰세요.

[예시 - 캐릭터 1의 차례는 대사와 행동 묘사를 하나로 이어붙인다]
@: *나레이션 예시*

@{{example_character_name}}: *행동 묘사* 대사 1. 같은 차례 안에서 대사 2까지 끊지 않고 이어서 씁니다.

@다른캐릭터: 화자가 실제로 바뀔 때만 새 태그로 전환하세요.
{{lore_block}}{{extra_block}}''';

  /// [customTemplate]이 있으면(마이페이지 > 시스템 프롬프트 설정에서 저장한 값) 그 템플릿을,
  /// 없으면 [defaultSystemPromptTemplate]을 사용해서 자리표시자를 실제 값으로 치환한다.
  static String buildSystemPrompt({
    required Plot? plot,
    required List<Character> characters,
    required String userProfileName,
    String userProfileDescription = '',
    String additionalSystemPrompt = '',
    String loreContext = '',
    String? customTemplate,
    String extraSystemBlock = '',
  }) {
    // {{char}}는 캐릭터 소개글 안에서 그 캐릭터 자신의 이름을 가리키는 자리표시자다(SillyTavern
    // 캐릭터 카드 관례). 캐릭터별로 자기 이름으로 치환해서, 소개글을 여러 캐릭터에 재사용해도
    // 그대로 동작하게 한다.
    final charactersBlock = characters.isEmpty
        ? '(등록된 캐릭터가 없어요)'
        : characters.map((c) => '- ${c.name}: ${c.description.replaceAll('{{char}}', c.name)}').join('\n');
    final exampleCharacterName = characters.isNotEmpty ? characters.first.name : '캐릭터 1';

    final profileDesc = userProfileDescription.trim();
    final profileDescBlock = profileDesc.isEmpty ? '' : '\n설명: $profileDesc';

    final lore = loreContext.trim();
    final loreBlock = lore.isEmpty ? '' : '\n\n[로어북]\n$lore';

    final extra = additionalSystemPrompt.trim();
    final extraBlock = extra.isEmpty ? '' : '\n\n[추가 지침]\n$extra';

    final template = (customTemplate != null && customTemplate.trim().isNotEmpty)
        ? customTemplate
        : defaultSystemPromptTemplate;

    final filled = template
        .replaceAll('{{plot_title}}', plot?.title ?? '')
        .replaceAll('{{plot_description}}', plot?.description ?? '')
        .replaceAll('{{characters_block}}', charactersBlock)
        .replaceAll('{{example_character_name}}', exampleCharacterName)
        .replaceAll('{{user_profile_name}}', userProfileName)
        .replaceAll('{{user_profile_description_block}}', profileDescBlock)
        .replaceAll('{{lore_block}}', loreBlock)
        .replaceAll('{{extra_block}}', extraBlock);

    // {{user}}는 여기서 치환하지 않고 리터럴로 남기지만(모델이 응답에 그대로 써야 하는 토큰),
    // 조사 매크로(`{{user}}[을;를]` 같은)는 실제 프로필 이름 기준으로 지금 풀어준다.
    final resolved = KoreanJosaMacro.resolve(filled, aliases: {'{{user}}': userProfileName});

    // 비주얼 노벨 연출 지침은 사용자가 커스텀 템플릿을 쓰더라도 항상 붙는다(모드 자체의 요구사항이라서).
    final vnBlock = extraSystemBlock.trim();
    return vnBlock.isEmpty ? resolved : '$resolved\n\n$vnBlock';
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
