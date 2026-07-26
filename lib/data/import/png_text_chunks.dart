import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// SillyTavern 캐릭터 카드가 PNG의 tEXt/zTXt/iTXt 청크에 `chara`(v1/v2) 또는 `ccv3`(v3)
/// 키워드로 base64 JSON을 심어두는 규칙을 그대로 읽어들인다.
class PngTextChunks {
  static const _signature = [137, 80, 78, 71, 13, 10, 26, 10];

  /// PNG 바이트에서 텍스트 청크를 전부 추출한다. (키워드 -> 디코딩된 텍스트)
  static Map<String, String> extractAll(Uint8List bytes) {
    final result = <String, String>{};
    if (bytes.length < 8 || !_matchesSignature(bytes)) return result;

    var offset = 8;
    while (offset + 8 <= bytes.length) {
      final length = _readUint32(bytes, offset);
      final type = ascii.decode(bytes.sublist(offset + 4, offset + 8));
      final dataStart = offset + 8;
      final dataEnd = dataStart + length;
      if (length < 0 || dataEnd + 4 > bytes.length) break;
      final data = bytes.sublist(dataStart, dataEnd);

      switch (type) {
        case 'tEXt':
          _parseTExt(data, result);
          break;
        case 'zTXt':
          _parseZText(data, result);
          break;
        case 'iTXt':
          _parseIText(data, result);
          break;
        case 'IEND':
          return result;
      }
      offset = dataEnd + 4; // CRC 4바이트 건너뜀
    }
    return result;
  }

  static bool _matchesSignature(Uint8List bytes) {
    for (var i = 0; i < _signature.length; i++) {
      if (bytes[i] != _signature[i]) return false;
    }
    return true;
  }

  static int _readUint32(Uint8List bytes, int offset) {
    return (bytes[offset] << 24) | (bytes[offset + 1] << 16) | (bytes[offset + 2] << 8) | bytes[offset + 3];
  }

  static void _parseTExt(Uint8List data, Map<String, String> out) {
    final nullIndex = data.indexOf(0);
    if (nullIndex < 0) return;
    final keyword = latin1.decode(data.sublist(0, nullIndex));
    final text = latin1.decode(data.sublist(nullIndex + 1));
    out[keyword] = text;
  }

  static void _parseZText(Uint8List data, Map<String, String> out) {
    final nullIndex = data.indexOf(0);
    if (nullIndex < 0 || nullIndex + 1 >= data.length) return;
    final keyword = latin1.decode(data.sublist(0, nullIndex));
    final compressed = data.sublist(nullIndex + 2);
    try {
      final decompressed = zlib.decode(compressed);
      out[keyword] = latin1.decode(decompressed);
    } catch (_) {
      // 손상된 청크는 무시한다.
    }
  }

  static void _parseIText(Uint8List data, Map<String, String> out) {
    var i = data.indexOf(0);
    if (i < 0) return;
    final keyword = latin1.decode(data.sublist(0, i));
    i++;
    if (i + 1 >= data.length) return;
    final compressionFlag = data[i];
    i += 2; // 압축 플래그 + 압축 방식 건너뜀
    final langEnd = data.indexOf(0, i);
    if (langEnd < 0) return;
    i = langEnd + 1;
    final translatedEnd = data.indexOf(0, i);
    if (translatedEnd < 0) return;
    i = translatedEnd + 1;
    final rest = data.sublist(i);
    try {
      final textBytes = compressionFlag == 1 ? zlib.decode(rest) : rest;
      out[keyword] = utf8.decode(textBytes);
    } catch (_) {
      // 손상된 청크는 무시한다.
    }
  }
}
