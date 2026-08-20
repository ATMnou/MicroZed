import '../db/database.dart';
import 'message_format_parser.dart';

/// AI가 [SCENE ...] 대신 위험한 시도의 성패를 주사위로 정하고 싶을 때 내는 요청 한 건.
class VnDiceRequest {
  const VnDiceRequest({required this.goal, this.target = 12, this.bonus = 0});

  final String goal;
  final int target;
  final int bonus;
}

class VnParsedTurn {
  const VnParsedTurn({required this.segments, this.diceRequest});

  final List<ParsedSpeechSegment> segments;
  final VnDiceRequest? diceRequest;
}

final _speakerLinePattern = RegExp(r'^@([^:\n]*):\s*(.*)$');

/// 비주얼 노벨 모드에서 AI 응답에 섞여 나오는 `[SCENE bg=... expr=...]` / `[DICE ...]`
/// 연출 태그를 걷어내고, [MessageFormatParser]가 만든 말풍선(segment)마다 어떤 배경/표정으로
/// 보여줄지를 붙여준다.
///
/// - `[SCENE]` 태그는 그 태그 뒤에 이어지는 화자 줄부터 적용되고, 다음 `[SCENE]`이 나오기
///   전까지(태그를 생략한 줄들에도) 그대로 유지된다 - 매 줄마다 배경/표정을 반복할 필요가 없다.
/// - `[DICE]` 태그는 [MessageFormatParser]에는 전달하지 않고 [VnParsedTurn.diceRequest]로만
///   뽑아낸다(대화 로그에 남기지 않는 UI 트리거).
/// - [MessageFormatParser] 자체는 건드리지 않는다 - 스토리챗 경로에 영향이 가지 않게 하기 위해서다.
class VnDirectiveParser {
  static final _sceneTagPattern = RegExp(r'^\[SCENE([^\]]*)\]$', caseSensitive: false);
  static final _diceTagPattern = RegExp(r'^\[DICE([^\]]*)\]$', caseSensitive: false);
  static final _attrPattern = RegExp(r'(\w+)\s*=\s*(?:"([^"]*)"|(\S+))');

  static VnParsedTurn parse(String rawText, {required List<VnBackground> backgrounds}) {
    final idByTitle = {for (final b in backgrounds) b.title.trim(): b.id};
    final cleanedLines = <String>[];

    int? pendingBg;
    VnEmotion? pendingExpr;
    VnDiceRequest? diceRequest;
    var segmentIndex = 0;
    final metaForSegment = <int, ({int? bg, VnEmotion? expr})>{0: (bg: null, expr: null)};

    for (final rawLine in rawText.split('\n')) {
      final line = rawLine.trim();

      final sceneMatch = _sceneTagPattern.firstMatch(line);
      if (sceneMatch != null) {
        final attrs = _parseAttrs(sceneMatch.group(1) ?? '');
        final bgName = attrs['bg']?.trim();
        final exprName = attrs['expr']?.trim();
        if (bgName != null && bgName.isNotEmpty && idByTitle.containsKey(bgName)) {
          pendingBg = idByTitle[bgName];
        }
        if (exprName != null && exprName.isNotEmpty) {
          pendingExpr = emotionFromLabel(exprName) ?? pendingExpr;
        }
        metaForSegment[segmentIndex] = (bg: pendingBg, expr: pendingExpr);
        continue;
      }

      final diceMatch = _diceTagPattern.firstMatch(line);
      if (diceMatch != null) {
        final attrs = _parseAttrs(diceMatch.group(1) ?? '');
        diceRequest = VnDiceRequest(
          goal: attrs['goal']?.trim() ?? '',
          target: int.tryParse(attrs['target'] ?? '') ?? 12,
          bonus: int.tryParse(attrs['bonus'] ?? '') ?? 0,
        );
        continue;
      }

      if (_speakerLinePattern.hasMatch(line)) {
        segmentIndex++;
        metaForSegment[segmentIndex] = (bg: pendingBg, expr: pendingExpr);
      }
      cleanedLines.add(rawLine);
    }

    final segments = MessageFormatParser.parse(cleanedLines.join('\n'));
    final orderedMeta = (metaForSegment.keys.toList()..sort()).map((k) => metaForSegment[k]!).toList();
    final merged = List.generate(segments.length, (i) {
      final meta = i < orderedMeta.length ? orderedMeta[i] : null;
      return segments[i].copyWith(vnBackgroundId: meta?.bg, vnExpression: meta?.expr);
    });

    return VnParsedTurn(segments: merged, diceRequest: diceRequest);
  }

  static Map<String, String> _parseAttrs(String raw) {
    final result = <String, String>{};
    for (final m in _attrPattern.allMatches(raw)) {
      result[m.group(1)!] = m.group(2) ?? m.group(3) ?? '';
    }
    return result;
  }

  static VnEmotion? emotionFromLabel(String label) {
    switch (label.trim().toLowerCase()) {
      case '기쁨':
      case 'joy':
        return VnEmotion.joy;
      case '슬픔':
      case 'sad':
        return VnEmotion.sad;
      case '분노':
      case 'angry':
        return VnEmotion.angry;
      case '걱정':
      case 'worried':
        return VnEmotion.worried;
      case '놀람':
      case 'surprised':
        return VnEmotion.surprised;
      case '의문':
      case 'confused':
        return VnEmotion.confused;
      case '기본':
      case 'default':
        return VnEmotion.defaultEmotion;
      default:
        return null;
    }
  }

  static String emotionLabel(VnEmotion emotion) {
    switch (emotion) {
      case VnEmotion.joy:
        return '기쁨';
      case VnEmotion.sad:
        return '슬픔';
      case VnEmotion.angry:
        return '분노';
      case VnEmotion.worried:
        return '걱정';
      case VnEmotion.surprised:
        return '놀람';
      case VnEmotion.confused:
        return '의문';
      case VnEmotion.defaultEmotion:
        return '기본';
    }
  }

  /// [AiChatService]가 시스템 프롬프트에 덧붙이는 비주얼 노벨 연출 지침.
  static String buildSystemInstructions({required List<VnBackground> backgrounds, required bool diceEnabled}) {
    final bgList = backgrounds.isEmpty ? '(등록된 배경 없음)' : backgrounds.map((b) => b.title).join(', ');
    final buffer = StringBuffer()
      ..writeln('[비주얼 노벨 연출 규칙 - 매우 중요]')
      ..writeln(
          '이 플롯은 비주얼 노벨 형식입니다. 각 화자 줄("@이름:" 또는 "@:") 바로 앞에, 장면이 바뀔 때만 별도의 줄로 다음 형식의 태그를 붙이세요:')
      ..writeln('[SCENE bg=배경이름 expr=감정]')
      ..writeln('- bg는 다음 배경 목록 중 하나의 이름을 한 글자도 바꾸지 말고 정확히 그대로 씁니다: $bgList. 장소/시간대가 바뀔 때만 쓰고, 그대로 유지되면 생략하세요.')
      ..writeln(
          '- expr는 그 줄에서 말하는 캐릭터의 표정입니다. 다음 중 하나만 쓰세요: 기쁨, 슬픔, 분노, 걱정, 놀람, 의문, 기본. "기본"은 특별한 표정 없이 평범한 기본 이미지로 되돌리라는 뜻입니다. 표정이 그대로면(직전과 같으면) 생략하세요.')
      ..writeln('- bg/expr 둘 중 하나만 바뀌어도 됩니다(예: [SCENE expr=놀람]). 아무것도 안 바뀌면 태그 자체를 생략하세요.');
    if (diceEnabled) {
      buffer
        ..writeln()
        ..writeln('[주사위 판정 - 결정적 순간에만]')
        ..writeln(
            '결과가 불확실하고 극적인 행동(위험한 시도, 설득, 전투 등)에는 성패를 임의로 정해 서술하지 말고, 화자 줄 앞에 다음 태그를 붙여 플레이어가 직접 주사위를 굴리게 하세요:')
        ..writeln('[DICE goal="시도의 목표를 짧게" target=숫자(8~18) bonus=숫자(0~4)]')
        ..writeln(
            '이 태그를 낸 턴에서는 그 행동을 시도하는 상황까지만 서술하고 성패는 서술하지 마세요. 다음 사용자 메시지에 "[주사위 결과: 성공]" 또는 "[주사위 결과: 실패]"가 포함되어 있으면 그 결과에 맞춰 이야기를 이어가세요. 사소하거나 결과가 뻔한 행동에는 이 태그를 쓰지 마세요.');
    }
    return buffer.toString().trim();
  }
}
