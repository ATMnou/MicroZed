import '../db/database.dart';

/// AI 응답 원문을 파싱해서 얻은 문단 하나. 그대로 [ChatMessage] 한 건으로 저장된다.
class ParsedSpeechSegment {
  const ParsedSpeechSegment({
    required this.senderType,
    required this.content,
    this.speakerName,
  });

  final MessageSender senderType;

  /// 캐릭터 발화일 때만 값이 있다. 실제 Character는 이름으로 매칭한다.
  final String? speakerName;
  final String content;
}

final _speakerLinePattern = RegExp(r'^@([^:\n]*):\s*(.*)$');

/// 클론 대상 플랫폼의 출력 규칙을 파싱한다.
///
/// - 어떤 줄이 `@이름:`으로 시작하면 그 줄부터 해당 캐릭터의 발화, `@:`이면 나레이션으로 전환된다.
///   (모델이 매번 빈 줄로 문단을 구분해 준다는 보장이 없어서, 빈 줄이 아니라 줄 단위로 `@` 태그를 찾는다.)
/// - `@`로 시작하지 않는 줄은 직전 발화자가 이어서 말하는 것으로 취급해 같은 말풍선에 이어붙인다.
/// - 빈 줄은 같은 발화자라도 말풍선을 새로 나눈다.
/// - `*텍스트*`(지문/행동)는 내용에 그대로 남겨두고, 렌더링 시점에 별도로 강조 처리한다.
class MessageFormatParser {
  static List<ParsedSpeechSegment> parse(String rawText) {
    final segments = <ParsedSpeechSegment>[];
    var currentSender = MessageSender.narrator;
    String? currentSpeakerName;
    final buffer = StringBuffer();

    void flush() {
      final content = buffer.toString().trim();
      buffer.clear();
      if (content.isEmpty) return;
      segments.add(ParsedSpeechSegment(
        senderType: currentSender,
        speakerName: currentSpeakerName,
        content: content,
      ));
    }

    for (final rawLine in rawText.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        flush();
        continue;
      }
      final match = _speakerLinePattern.firstMatch(line);
      if (match != null) {
        flush();
        final name = match.group(1)!.trim();
        final rest = match.group(2)!.trim();
        if (name.isEmpty) {
          currentSender = MessageSender.narrator;
          currentSpeakerName = null;
        } else {
          currentSender = MessageSender.character;
          currentSpeakerName = name;
        }
        if (rest.isNotEmpty) buffer.write(rest);
      } else {
        if (buffer.isNotEmpty) buffer.write('\n');
        buffer.write(line);
      }
    }
    flush();
    return segments;
  }

  /// 스트리밍 도중 미리보기용: 아직 완결되지 않은 텍스트에서 `@이름:` 표시만 지워
  /// 사람이 읽기 편한 형태로 보여준다(최종 말풍선 분리는 스트림이 끝난 뒤 [parse]가 담당).
  static String stripSpeakerTagsForPreview(String rawText) {
    return rawText.replaceAll(RegExp(r'^@[^:\n]*:[ \t]*', multiLine: true), '').trim();
  }
}
