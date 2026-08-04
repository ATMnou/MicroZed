import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/import/lorebook_parser.dart';

void main() {
  test('SillyTavern World Info(entries 맵) JSON을 파싱한다', () {
    final json = {
      'entries': {
        '0': {
          'key': ['호그와트', '학교'],
          'content': '호그와트는 마법 학교다.',
          'comment': '호그와트 설정',
          'disable': false,
        },
        '1': {
          'key': ['금지된 숲'],
          'content': '금지된 숲에는 위험한 생물들이 산다.',
          'disable': true, // 비활성 항목은 제외돼야 한다
        },
      },
    };
    final parsed = LorebookParser.parseJson(json);
    expect(parsed, hasLength(1));
    expect(parsed.first.keywords, ['호그와트', '학교']);
    expect(parsed.first.content, '호그와트는 마법 학교다.');
    expect(parsed.first.title, '호그와트 설정');
  });

  test('JanitorAI 스타일 평평한 배열 JSON을 파싱한다', () {
    final json = [
      {
        'key': ['그리핀도르', '그리핀도르 탑'],
        'content': '그리핀도르는 용감함을 중시하는 기숙사다.',
        'comment': '',
        'name': '',
        'enabled': true,
      },
      {
        'key': ['비활성 항목'],
        'content': '이건 안 보여야 한다.',
        'enabled': false,
      },
    ];
    final parsed = LorebookParser.parseJson(json);
    expect(parsed, hasLength(1));
    expect(parsed.first.keywords, ['그리핀도르', '그리핀도르 탑']);
    expect(parsed.first.title, isNull);
  });

  test('hogwart.json(실제 JanitorAI 로어북 스크립트)을 손실 없이 파싱한다', () {
    final file = File('hogwart.json');
    final json = jsonDecode(file.readAsStringSync());
    final parsed = LorebookParser.parseJson(json);
    expect(parsed, isNotEmpty);
    for (final entry in parsed) {
      expect(entry.content, isNotEmpty);
    }
    final ravenclaw = parsed.firstWhere((e) => e.keywords.contains('ravenclaw tower'));
    expect(ravenclaw.content, contains('Ravenclaw common room'));
  });

  test('알 수 없는 형식은 예외를 던진다', () {
    expect(() => LorebookParser.parseJson('그냥 문자열'), throwsA(isA<LorebookParseException>()));
  });
}
