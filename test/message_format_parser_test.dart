import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/ai/message_format_parser.dart';
import 'package:microzed/data/db/database.dart';

void main() {
  group('MessageFormatParser.parse', () {
    test('merges same-speaker paragraphs separated only by blank lines into one bubble', () {
      const raw = '''
@: *나레이션 예시*

@캐릭터1: *행동 묘사* 대사 1.

대사 2까지 이어집니다.
''';
      final segments = MessageFormatParser.parse(raw);

      expect(segments.length, 2);
      expect(segments[0].senderType, MessageSender.narrator);
      expect(segments[1].senderType, MessageSender.character);
      expect(segments[1].speakerName, '캐릭터1');
      expect(segments[1].content, contains('행동 묘사'));
      expect(segments[1].content, contains('대사 1.'));
      expect(segments[1].content, contains('대사 2까지 이어집니다.'));
    });

    test('starts a new bubble only when the @ tag actually changes speaker', () {
      const raw = '''
@캐릭터1: 첫 번째 대사.

@캐릭터2: 다른 캐릭터의 대사.

@캐릭터1: 다시 캐릭터1로 돌아옴.
''';
      final segments = MessageFormatParser.parse(raw);

      expect(segments.length, 3);
      expect(segments[0].speakerName, '캐릭터1');
      expect(segments[1].speakerName, '캐릭터2');
      expect(segments[2].speakerName, '캐릭터1');
    });

    test('preserves paragraph breaks inside a merged bubble as blank lines', () {
      const raw = '''
@캐릭터1: 첫 문단.

두 번째 문단.
''';
      final segments = MessageFormatParser.parse(raw);

      expect(segments.length, 1);
      expect(segments[0].content, '첫 문단.\n\n두 번째 문단.');
    });
  });
}
