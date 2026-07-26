import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/export/png_card_writer.dart';
import 'package:microzed/data/import/png_text_chunks.dart';

void main() {
  test('생성한 placeholder PNG는 유효한 PNG로 인식된다', () {
    final png = PngCardWriter.generatePlaceholder(size: 32);
    expect(PngCardWriter.isPng(png), isTrue);
  });

  test('placeholder PNG에 tEXt 청크를 심으면 다시 읽어낼 수 있다', () {
    final png = PngCardWriter.generatePlaceholder(size: 16);
    final withChunk = PngCardWriter.embedTextChunk(png, 'chara', 'aGVsbG8=');

    expect(PngCardWriter.isPng(withChunk), isTrue);
    final chunks = PngTextChunks.extractAll(withChunk);
    expect(chunks['chara'], 'aGVsbG8=');
  });

  test('PNG가 아닌 바이트에 청크 삽입을 시도하면 예외를 던진다', () {
    final notPng = Uint8List.fromList(List<int>.filled(20, 0));
    expect(
      () => PngCardWriter.embedTextChunk(notPng, 'chara', 'x'),
      throwsA(isA<ArgumentError>()),
    );
  });
}
