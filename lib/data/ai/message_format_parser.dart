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
/// - 빈 줄만으로는 말풍선을 나누지 않는다(같은 화자가 문단을 여러 개 쓰더라도 새 `@` 태그가
///   나오기 전까지는 한 말풍선으로 합친다). 대신 문단 구분은 내용 안에 빈 줄로 보존한다.
/// - `*텍스트*`(지문/행동)는 내용에 그대로 남겨두고, 렌더링 시점에 별도로 강조 처리한다.
class MessageFormatParser {
  static List<ParsedSpeechSegment> parse(String rawText) {
    final segments = <ParsedSpeechSegment>[];
    var currentSender = MessageSender.narrator;
    String? currentSpeakerName;
    final buffer = StringBuffer();
    var pendingParagraphBreak = false;

    void flush() {
      final content = buffer.toString().trim();
      buffer.clear();
      pendingParagraphBreak = false;
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
        // 같은 화자가 이어지는 중이면 말풍선은 나누지 않고, 다음 내용이 나올 때
        // 문단 구분(빈 줄)만 내용 안에 남긴다. 새 `@` 태그로 바로 이어지면 flush()가
        // 버퍼를 비우면서 이 표시도 함께 사라진다.
        if (buffer.isNotEmpty) pendingParagraphBreak = true;
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
        if (buffer.isNotEmpty) {
          buffer.write(pendingParagraphBreak ? '\n\n' : '\n');
        }
        pendingParagraphBreak = false;
        buffer.write(line);
      }
    }
    flush();
    return segments;
  }
}
