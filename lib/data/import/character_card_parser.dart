import 'dart:convert';
import 'dart:typed_data';

import 'png_text_chunks.dart';

/// 캐릭터 카드의 로어북(character_book) 항목 하나.
class CharacterBookEntryData {
  const CharacterBookEntryData({required this.keys, required this.content, this.name});

  final List<String> keys;
  final String content;
  final String? name;
}

/// SillyTavern 캐릭터 카드(v1/v2/v3, JSON 또는 PNG 내장 형태)를 이 앱의 필드로 정규화한 결과.
class ParsedCharacterCard {
  const ParsedCharacterCard({
    required this.name,
    this.description = '',
    this.personality = '',
    this.scenario = '',
    this.firstMessage = '',
    this.alternateGreetings = const [],
    this.exampleDialogue = '',
    this.creatorNotes = '',
    this.tags = const [],
    this.avatarBytes,
    this.loreEntries = const [],
    this.bookName,
  });

  final String name;
  final String description;
  final String personality;
  final String scenario;
  final String firstMessage;
  final List<String> alternateGreetings;
  final String exampleDialogue;
  final String creatorNotes;
  final List<String> tags;
  final Uint8List? avatarBytes;
  final List<CharacterBookEntryData> loreEntries;
  final String? bookName;
}

class CharacterCardParseException implements Exception {
  CharacterCardParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CharacterCardParser {
  /// PNG 파일 바이트에서 카드를 읽는다. `ccv3`(v3)와 `chara`(v1/v2) 청크를 모두 찾아보고,
  /// ccv3가 있으면 그 쪽을 우선한다. 원본 PNG 바이트를 그대로 아바타 이미지로 사용한다.
  static ParsedCharacterCard parsePng(Uint8List bytes) {
    final chunks = PngTextChunks.extractAll(bytes);
    final raw = chunks['ccv3'] ?? chunks['chara'];
    if (raw == null) {
      throw CharacterCardParseException('이 PNG에서 캐릭터 카드 데이터를 찾지 못했어요.');
    }
    final jsonMap = _decodeEmbeddedJson(raw);
    final card = parseJson(jsonMap);
    return ParsedCharacterCard(
      name: card.name,
      description: card.description,
      personality: card.personality,
      scenario: card.scenario,
      firstMessage: card.firstMessage,
      alternateGreetings: card.alternateGreetings,
      exampleDialogue: card.exampleDialogue,
      creatorNotes: card.creatorNotes,
      tags: card.tags,
      avatarBytes: bytes,
      loreEntries: card.loreEntries,
      bookName: card.bookName,
    );
  }

  static Map<String, dynamic> _decodeEmbeddedJson(String raw) {
    final trimmed = raw.trim();
    try {
      final decodedBytes = base64.decode(_normalizeBase64(trimmed));
      final text = utf8.decode(decodedBytes);
      final parsed = jsonDecode(text);
      if (parsed is Map<String, dynamic>) return parsed;
    } catch (_) {
      // base64가 아닐 수도 있으니 원문을 JSON으로도 시도해본다.
    }
    final parsed = jsonDecode(trimmed);
    if (parsed is Map<String, dynamic>) return parsed;
    throw CharacterCardParseException('카드 JSON 형식을 해석하지 못했어요.');
  }

  static String _normalizeBase64(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'\s'), '');
    final targetLength = (cleaned.length + 3) ~/ 4 * 4;
    return cleaned.padRight(targetLength, '=');
  }

  /// 순수 JSON(파일 또는 사이트 API 응답)에서 카드를 읽는다.
  /// v1(플랫 필드)과 v2/v3(`spec`+`data` 래핑) 형식을 모두 지원한다.
  static ParsedCharacterCard parseJson(Map<String, dynamic> json, {Uint8List? avatarBytes}) {
    final spec = json['spec'];
    final data = (spec is String && spec.startsWith('chara_card') && json['data'] is Map)
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final name = _str(data, ['name', 'char_name']).trim();
    if (name.isEmpty) {
      throw CharacterCardParseException('카드에 캐릭터 이름이 없어요.');
    }

    final book = data['character_book'];
    final loreEntries = <CharacterBookEntryData>[];
    String? bookName;
    if (book is Map) {
      bookName = _strOrNull(book, ['name']);
      final entries = book['entries'];
      if (entries is List) {
        for (final e in entries) {
          if (e is! Map) continue;
          final keysRaw = e['keys'] ?? e['key'];
          final keys = keysRaw is List
              ? keysRaw.map((k) => k.toString()).where((k) => k.trim().isNotEmpty).toList()
              : <String>[];
          final content = _str(e, ['content']).trim();
          if (content.isEmpty) continue;
          loreEntries.add(CharacterBookEntryData(
            keys: keys,
            content: content,
            name: _strOrNull(e, ['name', 'comment']),
          ));
        }
      }
    }

    final greetingsRaw = data['alternate_greetings'];
    final alternateGreetings = greetingsRaw is List
        ? greetingsRaw.map((g) => g.toString().trim()).where((g) => g.isNotEmpty).toList()
        : <String>[];

    final tagsRaw = data['tags'];
    final tags = tagsRaw is List
        ? tagsRaw.map((t) => t.toString().trim()).where((t) => t.isNotEmpty).toList()
        : <String>[];

    return ParsedCharacterCard(
      name: name,
      description: _str(data, ['description']).trim(),
      personality: _str(data, ['personality']).trim(),
      scenario: _str(data, ['scenario']).trim(),
      firstMessage: _str(data, ['first_mes', 'first_message', 'greeting', 'char_greeting']).trim(),
      alternateGreetings: alternateGreetings,
      exampleDialogue: _str(data, ['mes_example', 'example_dialogue', 'example_dialogs']).trim(),
      creatorNotes: _str(data, ['creator_notes', 'creatorcomment']).trim(),
      tags: tags,
      avatarBytes: avatarBytes,
      loreEntries: loreEntries,
      bookName: bookName,
    );
  }

  static String _str(Map data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return '';
  }

  static String? _strOrNull(Map data, List<String> keys) {
    final v = _str(data, keys);
    return v.isEmpty ? null : v;
  }
}
