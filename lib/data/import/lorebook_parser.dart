/// 파싱된 로어북 항목 하나(SillyTavern World Info 또는 JanitorAI 스크립트에서 정규화한 결과).
class ParsedLorebookEntryData {
  const ParsedLorebookEntryData({required this.keywords, required this.content, this.title});

  final List<String> keywords;
  final String content;
  final String? title;
}

class LorebookParseException implements Exception {
  LorebookParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// SillyTavern World Info JSON(`{"entries": {...}}`)과 JanitorAI 스타일 평평한 배열
/// (`hogwart.json`과 동일한 구조 - 최상위가 항목 객체들의 배열)을 모두 이 앱의 필드로 정규화한다.
///
/// 두 포맷 모두 이 앱의 [LorebookEntries]가 갖지 않는 필드(probability/case_sensitive/
/// selectiveLogic/matchWholeWords/priority/insertion_order 등)를 가질 수 있는데, 이 앱의
/// 런타임 매칭이 단순 부분 문자열 매칭이라 애초에 활용할 수 없어서 의도적으로 버린다.
class LorebookParser {
  static List<ParsedLorebookEntryData> parseJson(dynamic json) {
    if (json is Map) {
      return _parseWorldInfo(Map<String, dynamic>.from(json));
    }
    if (json is List) {
      return _parseJanitorArray(json);
    }
    throw LorebookParseException('로어북 JSON 형식을 해석하지 못했어요.');
  }

  /// SillyTavern World Info: `{"entries": {"0": {...}, "1": {...}}}` (배열 형태도 허용).
  static List<ParsedLorebookEntryData> _parseWorldInfo(Map<String, dynamic> json) {
    final entriesRaw = json['entries'];
    final rawEntries = <dynamic>[];
    if (entriesRaw is Map) {
      rawEntries.addAll(entriesRaw.values);
    } else if (entriesRaw is List) {
      rawEntries.addAll(entriesRaw);
    } else {
      throw LorebookParseException('이 JSON에서 로어북 항목(entries)을 찾지 못했어요.');
    }

    final result = <ParsedLorebookEntryData>[];
    for (final e in rawEntries) {
      if (e is! Map) continue;
      final entry = Map<String, dynamic>.from(e);
      if (entry['disable'] == true || entry['enabled'] == false) continue;
      final keywords = _stringList(entry, ['key', 'keys']);
      final content = _str(entry, ['content']).trim();
      if (content.isEmpty) continue;
      result.add(ParsedLorebookEntryData(
        keywords: keywords,
        content: content,
        title: _strOrNull(entry, ['comment', 'name']),
      ));
    }
    return result;
  }

  /// JanitorAI 스타일: 최상위가 항목 객체들의 배열(`hogwart.json` 참고).
  static List<ParsedLorebookEntryData> _parseJanitorArray(List<dynamic> entries) {
    final result = <ParsedLorebookEntryData>[];
    for (final e in entries) {
      if (e is! Map) continue;
      final entry = Map<String, dynamic>.from(e);
      if (entry['enabled'] == false) continue;
      final keywords = _stringList(entry, ['key', 'keys']);
      final content = _str(entry, ['content']).trim();
      if (content.isEmpty) continue;
      result.add(ParsedLorebookEntryData(
        keywords: keywords,
        content: content,
        title: _strOrNull(entry, ['comment', 'name']),
      ));
    }
    return result;
  }

  static List<String> _stringList(Map data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v is List) {
        return v.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
      if (v is String && v.trim().isNotEmpty) {
        return v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }
    return const [];
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
