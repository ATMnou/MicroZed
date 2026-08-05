import 'dart:convert';

import '../db/database.dart';
import 'ai_chat_service.dart';

/// 제작 탭의 '로어 길이' 옵션. 정확한 개수를 강제하지 않고 모델에게 대략적인 분량
/// 가이드로만 전달한다.
enum PlotLoreLength { short, medium, long }

/// '정확도' 옵션. Accurate는 웹 검색 결과에 근거한 사실 위주로, Mixed는 검색 결과를
/// 참고하되 빈 곳은 창작으로 채우도록 지시한다.
enum PlotGenerationAccuracy { accurate, mixed }

class PlotGenerationOptions {
  const PlotGenerationOptions({
    required this.userPrompt,
    this.webSearch = false,
    this.loreLength = PlotLoreLength.medium,
    this.accuracy = PlotGenerationAccuracy.mixed,
  });

  final String userPrompt;
  final bool webSearch;
  final PlotLoreLength loreLength;
  final PlotGenerationAccuracy accuracy;
}

class GeneratedCharacterDraft {
  const GeneratedCharacterDraft({required this.name, required this.description});
  final String name;
  final String description;
}

class GeneratedLoreEntryDraft {
  const GeneratedLoreEntryDraft({required this.title, required this.keywords, required this.content});
  final String title;
  final String keywords;
  final String content;
}

/// 인트로(첫 상황) 한 줄. [characterName]은 type이 character일 때만 쓰고, 실제 저장 시
/// 호출부가 이름으로 등록된 캐릭터를 찾아 characterId를 연결한다(못 찾으면 나레이션으로 취급).
class GeneratedIntroLineDraft {
  const GeneratedIntroLineDraft({required this.isCharacterLine, this.characterName, required this.content});
  final bool isCharacterLine;
  final String? characterName;
  final String content;
}

class PlotGenerationResult {
  const PlotGenerationResult({
    required this.title,
    required this.description,
    required this.shortIntro,
    required this.hashtags,
    required this.characters,
    required this.loreEntries,
    required this.introLines,
  });

  final String title;
  final String description;
  final String shortIntro;
  final List<String> hashtags;
  final List<GeneratedCharacterDraft> characters;
  final List<GeneratedLoreEntryDraft> loreEntries;
  final List<GeneratedIntroLineDraft> introLines;
}

/// 제작 탭 > 'AI로 생성'이 쓰는 플롯 생성기. 사용자가 고른 AI 프리셋으로 구조화된 JSON을
/// 요청하고 파싱해서 돌려준다. 실제 DB 저장은 호출부(화면)가 [PlotRepository] 등으로
/// 따로 처리한다 - 생성 직후 바로 커밋하지 않고 검토할 여지를 남기기 위해서다.
class PlotAiGeneratorService {
  PlotAiGeneratorService(AppDatabase db) : _chatService = AiChatService(db: db);

  final AiChatService _chatService;

  String _loreLengthInstruction(PlotLoreLength length) {
    switch (length) {
      case PlotLoreLength.short:
        return '로어북 항목은 3~5개, 각 항목은 2~3문장으로 짧게 작성해.';
      case PlotLoreLength.medium:
        return '로어북 항목은 5~8개, 각 항목은 4~6문장으로 작성해.';
      case PlotLoreLength.long:
        return '로어북 항목은 8~12개, 각 항목은 6문장 이상으로 상세하게 작성해.';
    }
  }

  String _accuracyInstruction(PlotGenerationAccuracy accuracy) {
    switch (accuracy) {
      case PlotGenerationAccuracy.accurate:
        return '웹 검색 결과로 확인된 사실만 사용하고, 확인되지 않은 내용은 만들어내지 마. '
            '검색으로 못 찾은 부분은 비워두거나 최소한으로만 채워.';
      case PlotGenerationAccuracy.mixed:
        return '웹 검색 결과를 참고하되, 부족한 부분은 롤플레이에 어울리게 자유롭게 창작해서 채워.';
    }
  }

  Future<PlotGenerationResult> generate({
    required AiPreset preset,
    required PlotGenerationOptions options,
  }) async {
    final systemPrompt =
        '너는 롤플레이 채팅 앱의 플롯(세계관 + 캐릭터 + 로어북) 생성기야. 사용자의 요청을 바탕으로 '
        '롤플레이용 플롯 하나를 만들어줘. ${_accuracyInstruction(options.accuracy)} '
        '${_loreLengthInstruction(options.loreLength)} '
        '캐릭터를 만들었으면 대화가 시작될 때 보여줄 인트로(첫 상황)도 3~6줄 정도로 같이 만들어줘 - '
        '나레이션으로 배경/상황을 설명하고, 등장 캐릭터가 최소 한 줄은 직접 대사를 치게 해.\n'
        '다른 설명 없이 아래 형식의 JSON 객체만 출력해(마크다운 코드블록도 쓰지 마):\n'
        '{"title":"플롯 제목(20자 이내)","description":"AI에게 전달될 플롯 설명/시스템 프롬프트용 설명",'
        '"short_intro":"목록에 보일 짧은 한 줄 소개","hashtags":["태그1","태그2"],'
        '"characters":[{"name":"이름(10자 이내)","description":"성격/말투/외모 등 AI 페르소나 설명"}],'
        '"lore_entries":[{"title":"항목 제목","keywords":"쉼표로 구분된 트리거 키워드","content":"본문"}],'
        '"intro_lines":[{"type":"narrator 또는 character","character_name":"character 타입일 때만, characters 목록의 이름과 정확히 일치",'
        '"content":"이 줄의 본문"}]}';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': options.userPrompt},
    ];

    final raw = await _chatService.completeOneShot(
      preset: preset,
      messages: messages,
      webSearch: options.webSearch,
    );
    return _parseResult(raw);
  }

  /// 제작 탭이 아니라 플롯 편집 화면(프롬프트 탭)에서 '캐릭터만' 하나 추가로 생성할 때 쓴다.
  /// 이미 있는 플롯 제목/설명을 맥락으로 줘서 세계관에 어울리는 캐릭터를 만들게 한다.
  Future<GeneratedCharacterDraft> generateCharacter({
    required AiPreset preset,
    required String plotTitle,
    required String plotDescription,
    String userPrompt = '',
  }) async {
    final systemPrompt =
        '너는 롤플레이 채팅 앱의 캐릭터 생성기야. 아래 플롯 설정에 어울리는 새 캐릭터 1명을 만들어줘.\n'
        '플롯 제목: $plotTitle\n플롯 설명: $plotDescription\n'
        '다른 설명 없이 아래 형식의 JSON 객체만 출력해(마크다운 코드블록도 쓰지 마):\n'
        '{"name":"이름(10자 이내)","description":"성격/말투/외모 등 AI 페르소나 설명"}';
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      {
        'role': 'user',
        'content': userPrompt.trim().isEmpty ? '플롯에 어울리는 캐릭터를 자유롭게 만들어줘.' : userPrompt.trim(),
      },
    ];
    final raw = await _chatService.completeOneShot(preset: preset, messages: messages);
    final trimmed = raw.trim();
    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw StateError('AI가 올바른 형식으로 응답하지 않았어요.');
    }
    final json = jsonDecode(trimmed.substring(start, end + 1)) as Map<String, dynamic>;
    return GeneratedCharacterDraft(
      name: (json['name'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
    );
  }

  /// 플롯 편집 화면(인트로 탭)의 'AI로 생성' 버튼. 이미 등록된 캐릭터 목록을 맥락으로 줘서,
  /// 그 캐릭터들이 실제로 등장하는 첫 상황(나레이션 + 캐릭터 대사)을 몇 줄 만들어준다.
  Future<List<GeneratedIntroLineDraft>> generateIntro({
    required AiPreset preset,
    required String plotTitle,
    required String plotDescription,
    required List<String> characterNames,
    String userPrompt = '',
  }) async {
    final charactersText = characterNames.isEmpty ? '(등록된 캐릭터 없음)' : characterNames.join(', ');
    final systemPrompt =
        '너는 롤플레이 채팅 앱의 인트로(첫 상황) 생성기야. 아래 플롯/캐릭터 설정에 어울리는 대화 시작 장면을 '
        '3~6줄로 만들어줘. 나레이션으로 배경/상황을 설명하고, 등장 캐릭터가 최소 한 줄은 직접 대사를 치게 해. '
        '캐릭터 줄의 character_name은 아래 목록에 있는 이름과 정확히 같아야 해.\n'
        '플롯 제목: $plotTitle\n플롯 설명: $plotDescription\n등장 캐릭터: $charactersText\n'
        '다른 설명 없이 아래 형식의 JSON 객체만 출력해(마크다운 코드블록도 쓰지 마):\n'
        '{"intro_lines":[{"type":"narrator 또는 character","character_name":"character 타입일 때만",'
        '"content":"이 줄의 본문"}]}';
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      {
        'role': 'user',
        'content': userPrompt.trim().isEmpty ? '플롯에 어울리는 인트로를 자유롭게 만들어줘.' : userPrompt.trim(),
      },
    ];
    final raw = await _chatService.completeOneShot(preset: preset, messages: messages);
    final trimmed = raw.trim();
    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw StateError('AI가 올바른 형식으로 응답하지 않았어요.');
    }
    final json = jsonDecode(trimmed.substring(start, end + 1)) as Map<String, dynamic>;
    return _parseIntroLines(json);
  }

  List<GeneratedIntroLineDraft> _parseIntroLines(Map<String, dynamic> json) {
    return (json['intro_lines'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((l) {
          final isCharacterLine = l['type'] == 'character';
          return GeneratedIntroLineDraft(
            isCharacterLine: isCharacterLine,
            characterName: isCharacterLine ? (l['character_name'] as String?)?.trim() : null,
            content: (l['content'] as String? ?? '').trim(),
          );
        })
        .where((l) => l.content.isNotEmpty)
        .toList();
  }

  PlotGenerationResult _parseResult(String raw) {
    final trimmed = raw.trim();
    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw StateError('AI가 올바른 형식으로 응답하지 않았어요.');
    }
    final json = jsonDecode(trimmed.substring(start, end + 1)) as Map<String, dynamic>;

    final characters = (json['characters'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((c) => GeneratedCharacterDraft(
              name: (c['name'] as String? ?? '').trim(),
              description: (c['description'] as String? ?? '').trim(),
            ))
        .where((c) => c.name.isNotEmpty)
        .toList();

    final loreEntries = (json['lore_entries'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((e) => GeneratedLoreEntryDraft(
              title: (e['title'] as String? ?? '').trim(),
              keywords: (e['keywords'] as String? ?? '').trim(),
              content: (e['content'] as String? ?? '').trim(),
            ))
        .where((e) => e.content.isNotEmpty)
        .toList();

    final hashtags = (json['hashtags'] as List<dynamic>? ?? const [])
        .map((h) => h.toString().trim())
        .where((h) => h.isNotEmpty)
        .take(10)
        .toList();

    return PlotGenerationResult(
      title: (json['title'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      shortIntro: (json['short_intro'] as String? ?? '').trim(),
      hashtags: hashtags,
      characters: characters,
      loreEntries: loreEntries,
      introLines: _parseIntroLines(json),
    );
  }
}
