import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// SillyTavern 호환 캐릭터 카드 PNG를 만들 때 쓰는 PNG 바이트 조립 유틸.
/// 새로 인코딩하지 않고, 기존 PNG의 청크 스트림에 `tEXt` 청크 하나를 IEND 직전에
/// 끼워 넣는 방식이라 캐릭터/커버 이미지의 픽셀 데이터를 건드리지 않는다.
class PngCardWriter {
  static const _signature = [137, 80, 78, 71, 13, 10, 26, 10];

  /// [basePng]가 유효한 PNG인지 확인한다.
  static bool isPng(Uint8List bytes) {
    if (bytes.length < _signature.length) return false;
    for (var i = 0; i < _signature.length; i++) {
      if (bytes[i] != _signature[i]) return false;
    }
    return true;
  }

  /// [basePng]에 `keyword`\0`base64Text` 형태의 tEXt 청크를 IEND 청크 바로 앞에 삽입한다.
  static Uint8List embedTextChunk(Uint8List basePng, String keyword, String text) {
    if (!isPng(basePng)) {
      throw ArgumentError('embedTextChunk는 유효한 PNG 바이트에만 쓸 수 있어요.');
    }

    final iendOffset = _findIendOffset(basePng);
    final chunkBytes = _buildChunk('tEXt', [...ascii.encode(keyword), 0, ...ascii.encode(text)]);

    final result = BytesBuilder();
    result.add(basePng.sublist(0, iendOffset));
    result.add(chunkBytes);
    result.add(basePng.sublist(iendOffset));
    return result.toBytes();
  }

  /// 아바타/커버 이미지가 없거나 PNG가 아닐 때 카드 데이터를 담을 최소 유효 PNG를 만든다.
  /// 단색 사각형 하나짜리 이미지다.
  static Uint8List generatePlaceholder({int size = 256, List<int> rgb = const [30, 30, 30]}) {
    final builder = BytesBuilder();
    builder.add(_signature);

    final ihdr = ByteData(13);
    ihdr.setUint32(0, size); // width
    ihdr.setUint32(4, size); // height
    ihdr.setUint8(8, 8); // bit depth
    ihdr.setUint8(9, 2); // color type 2 = truecolor (RGB)
    ihdr.setUint8(10, 0); // compression method
    ihdr.setUint8(11, 0); // filter method
    ihdr.setUint8(12, 0); // interlace method
    builder.add(_buildChunk('IHDR', ihdr.buffer.asUint8List()));

    final raw = BytesBuilder();
    final row = Uint8List(1 + size * 3);
    for (var x = 0; x < size; x++) {
      row[1 + x * 3] = rgb[0];
      row[1 + x * 3 + 1] = rgb[1];
      row[1 + x * 3 + 2] = rgb[2];
    }
    for (var y = 0; y < size; y++) {
      raw.add(row);
    }
    final compressed = zlib.encode(raw.toBytes());
    builder.add(_buildChunk('IDAT', compressed));

    builder.add(_buildChunk('IEND', const []));
    return builder.toBytes();
  }

  static int _findIendOffset(Uint8List bytes) {
    var offset = 8;
    while (offset + 8 <= bytes.length) {
      final length = (bytes[offset] << 24) | (bytes[offset + 1] << 16) | (bytes[offset + 2] << 8) | bytes[offset + 3];
      final type = ascii.decode(bytes.sublist(offset + 4, offset + 8));
      if (type == 'IEND') return offset;
      offset += 8 + length + 4;
    }
    throw const FormatException('IEND 청크를 찾지 못했어요. 손상된 PNG일 수 있어요.');
  }

  static List<int> _buildChunk(String type, List<int> data) {
    final out = BytesBuilder();
    final length = data.length;
    out.add([(length >> 24) & 0xFF, (length >> 16) & 0xFF, (length >> 8) & 0xFF, length & 0xFF]);
    final typeAndData = [...ascii.encode(type), ...data];
    out.add(typeAndData);
    out.add(_uint32(_crc32(typeAndData)));
    return out.toBytes();
  }

  static List<int> _uint32(int value) {
    return [(value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF];
  }

  static final List<int> _crcTable = _buildCrcTable();

  static List<int> _buildCrcTable() {
    final table = List<int>.filled(256, 0);
    for (var n = 0; n < 256; n++) {
      var c = n;
      for (var k = 0; k < 8; k++) {
        c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1);
      }
      table[n] = c;
    }
    return table;
  }

  static int _crc32(List<int> data) {
    var c = 0xFFFFFFFF;
    for (final byte in data) {
      c = _crcTable[(c ^ byte) & 0xFF] ^ (c >> 8);
    }
    return c ^ 0xFFFFFFFF;
  }
}
