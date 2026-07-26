import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;

import 'character_card_parser.dart';

const _pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];

bool _looksLikePng(Uint8List bytes) {
  if (bytes.length < _pngSignature.length) return false;
  for (var i = 0; i < _pngSignature.length; i++) {
    if (bytes[i] != _pngSignature[i]) return false;
  }
  return true;
}

/// SillyTavern 캐릭터 카드를 로컬 파일(PNG/JSON) 또는 URL에서 가져와
/// [ParsedCharacterCard]로 정규화한다.
class CharacterCardSource {
  static const _cardTypeGroup = XTypeGroup(
    label: 'character card',
    extensions: ['png', 'json'],
  );

  /// 파일 선택 다이얼로그로 PNG/JSON 카드를 고른다. 취소하면 null.
  static Future<ParsedCharacterCard?> pickFromFile() async {
    final picked = await openFile(acceptedTypeGroups: [_cardTypeGroup]);
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return _parseBytes(bytes, hintJson: picked.name.toLowerCase().endsWith('.json'));
  }

  /// URL에서 카드를 가져온다. 카드 파일(PNG/JSON) 직링크는 그대로 파싱하고,
  /// 일반 페이지 링크는 og:image/이미지 태그에서 카드 PNG로 보이는 것을 최선 노력으로 찾아본다.
  static Future<ParsedCharacterCard> fetchFromUrl(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || !uri.hasScheme) {
      throw CharacterCardParseException('올바른 URL이 아니에요.');
    }

    final response = await http.get(uri, headers: {
      'User-Agent': 'Mozilla/5.0 (compatible; MicroZed/1.0)',
      'Accept': 'image/png,application/json,text/html;q=0.8,*/*;q=0.5',
    });
    if (response.statusCode != 200) {
      throw CharacterCardParseException('다운로드에 실패했어요 (HTTP ${response.statusCode}).');
    }

    final bytes = response.bodyBytes;
    if (_looksLikePng(bytes)) {
      return CharacterCardParser.parsePng(bytes);
    }

    final directJson = _tryDecodeJson(bytes);
    if (directJson != null) {
      return CharacterCardParser.parseJson(directJson);
    }

    final html = _tryDecodeText(bytes);
    if (html != null) {
      final candidate = await _tryScrapeHtml(html, uri);
      if (candidate != null) return candidate;
    }

    throw CharacterCardParseException(
      '이 링크에서는 카드를 자동으로 찾지 못했어요. 카드 PNG/JSON 파일의 직접 링크를 사용해보세요.',
    );
  }

  /// HTML 페이지에서 카드 이미지로 보이는 후보(og:image, <img src=*.png>)를 찾아
  /// 하나씩 내려받아 캐릭터 카드 데이터가 들어있는지 시도해본다.
  static Future<ParsedCharacterCard?> _tryScrapeHtml(String html, Uri pageUri) async {
    final candidates = <Uri>[];

    void addCandidate(String? url) {
      if (url == null || url.isEmpty) return;
      final resolved = Uri.tryParse(url);
      if (resolved == null) return;
      candidates.add(pageUri.resolveUri(resolved));
    }

    for (final m in RegExp(
      '''<meta[^>]+property=["']og:image["'][^>]+content=["']([^"']+)["']''',
      caseSensitive: false,
    ).allMatches(html)) {
      addCandidate(m.group(1));
    }
    for (final m in RegExp(
      '''<img[^>]+src=["']([^"']+\\.png[^"']*)["']''',
      caseSensitive: false,
    ).allMatches(html)) {
      addCandidate(m.group(1));
    }

    final seen = <String>{};
    for (final candidate in candidates) {
      final key = candidate.toString();
      if (!seen.add(key)) continue;
      if (seen.length > 6) break;
      try {
        final resp = await http.get(candidate);
        if (resp.statusCode != 200) continue;
        if (!_looksLikePng(resp.bodyBytes)) continue;
        return CharacterCardParser.parsePng(resp.bodyBytes);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static ParsedCharacterCard _parseBytes(Uint8List bytes, {bool hintJson = false}) {
    if (!hintJson && _looksLikePng(bytes)) {
      return CharacterCardParser.parsePng(bytes);
    }
    final json = _tryDecodeJson(bytes);
    if (json != null) {
      return CharacterCardParser.parseJson(json);
    }
    if (_looksLikePng(bytes)) {
      return CharacterCardParser.parsePng(bytes);
    }
    throw CharacterCardParseException('PNG 캐릭터 카드나 JSON 파일만 불러올 수 있어요.');
  }

  static Map<String, dynamic>? _tryDecodeJson(Uint8List bytes) {
    try {
      final text = utf8.decode(bytes);
      final parsed = jsonDecode(text);
      if (parsed is Map<String, dynamic>) return parsed;
    } catch (_) {
      // JSON이 아니면 무시하고 다른 경로를 시도한다.
    }
    return null;
  }

  static String? _tryDecodeText(Uint8List bytes) {
    try {
      return utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return null;
    }
  }
}
