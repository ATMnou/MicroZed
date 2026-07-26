import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/import/character_card_parser.dart';

/// PNG tEXt 청크 하나를 만든다. (SillyTavern가 실제로 쓰는 것과 동일한 구조)
Uint8List _buildPngWithTextChunk(String keyword, String text) {
  final bytes = BytesBuilder();
  bytes.add(const [137, 80, 78, 71, 13, 10, 26, 10]); // PNG signature

  void writeChunk(String type, List<int> data) {
    final length = data.length;
    bytes.add([
      (length >> 24) & 0xFF,
      (length >> 16) & 0xFF,
      (length >> 8) & 0xFF,
      length & 0xFF,
    ]);
    bytes.add(ascii.encode(type));
    bytes.add(data);
    bytes.add([0, 0, 0, 0]); // CRC (검증 안 하므로 더미 값)
  }

  // IHDR: 최소한의 더미 헤더 (파서가 실제로 읽지는 않지만 형태를 갖춘다)
  final ihdr = <int>[
    0, 0, 0, 1, // width
    0, 0, 0, 1, // height
    8, 6, 0, 0, 0, // bit depth, color type, compression, filter, interlace
  ];
  writeChunk('IHDR', ihdr);

  final textData = <int>[...ascii.encode(keyword), 0, ...ascii.encode(text)];
  writeChunk('tEXt', textData);

  writeChunk('IEND', const []);
  return bytes.toBytes();
}

void main() {
  test('PNG tEXt 청크에서 SillyTavern v2 카드를 파싱한다', () {
    final cardJson = {
      'spec': 'chara_card_v2',
      'spec_version': '2.0',
      'data': {
        'name': '테스트 캐릭터',
        'description': '설명입니다.',
        'personality': '차분함',
        'scenario': '어느 카페에서 처음 만난다.',
        'first_mes': '*손을 흔든다* 안녕, {{user}}. 나는 {{char}}야.',
        'mes_example': '<START>\n{{user}}: 안녕\n{{char}}: 반가워',
        'alternate_greetings': ['다른 인사말 1', '다른 인사말 2'],
        'creator_notes': '테스트용 카드',
        'tags': ['테스트', '카페'],
        'character_book': {
          'name': '세계관북',
          'entries': [
            {
              'keys': ['카페', '커피'],
              'content': '이 카페는 마을에서 가장 오래된 곳이다.',
              'name': '카페 설정',
            },
          ],
        },
      },
    };
    final base64Json = base64.encode(utf8.encode(jsonEncode(cardJson)));
    final png = _buildPngWithTextChunk('chara', base64Json);

    final card = CharacterCardParser.parsePng(png);

    expect(card.name, '테스트 캐릭터');
    expect(card.description, '설명입니다.');
    expect(card.personality, '차분함');
    expect(card.scenario, '어느 카페에서 처음 만난다.');
    expect(card.firstMessage, contains('{{user}}'));
    expect(card.firstMessage, contains('{{char}}'));
    expect(card.alternateGreetings, ['다른 인사말 1', '다른 인사말 2']);
    expect(card.tags, ['테스트', '카페']);
    expect(card.bookName, '세계관북');
    expect(card.loreEntries, hasLength(1));
    expect(card.loreEntries.first.keys, ['카페', '커피']);
    expect(card.avatarBytes, isNotNull);
  });

  test('ccv3 청크가 있으면 chara보다 우선한다', () {
    final v2Json = {'name': 'V2 이름', 'description': 'v2'};
    final v3Json = {
      'spec': 'chara_card_v3',
      'spec_version': '3.0',
      'data': {'name': 'V3 이름', 'description': 'v3'},
    };
    final bytes = BytesBuilder();
    bytes.add(const [137, 80, 78, 71, 13, 10, 26, 10]);

    void writeChunk(String type, List<int> data) {
      final length = data.length;
      bytes.add([
        (length >> 24) & 0xFF,
        (length >> 16) & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
      ]);
      bytes.add(ascii.encode(type));
      bytes.add(data);
      bytes.add([0, 0, 0, 0]);
    }

    writeChunk('tEXt', [...ascii.encode('chara'), 0, ...ascii.encode(base64.encode(utf8.encode(jsonEncode(v2Json))))]);
    writeChunk('tEXt', [...ascii.encode('ccv3'), 0, ...ascii.encode(base64.encode(utf8.encode(jsonEncode(v3Json))))]);
    writeChunk('IEND', const []);

    final card = CharacterCardParser.parsePng(bytes.toBytes());
    expect(card.name, 'V3 이름');
  });

  test('v1(플랫) JSON도 파싱한다', () {
    final v1Json = {
      'name': '플랫 캐릭터',
      'description': '플랫 설명',
      'first_mes': '안녕!',
    };
    final card = CharacterCardParser.parseJson(v1Json);
    expect(card.name, '플랫 캐릭터');
    expect(card.description, '플랫 설명');
    expect(card.firstMessage, '안녕!');
  });

  test('카드 데이터가 없는 PNG는 예외를 던진다', () {
    final bytes = BytesBuilder();
    bytes.add(const [137, 80, 78, 71, 13, 10, 26, 10]);
    bytes.add([0, 0, 0, 0, ...ascii.encode('IEND'), 0, 0, 0, 0]);
    expect(() => CharacterCardParser.parsePng(bytes.toBytes()), throwsA(isA<CharacterCardParseException>()));
  });
}
