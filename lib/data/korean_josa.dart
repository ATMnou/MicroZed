/// 플롯/캐릭터/로어북 텍스트에 쓰는 한국어 조사 매크로: `[받침있음;받침없음]`.
///
/// 예: `{{user}}[을;를] 만났다` → `{{user}}`가 "민준"으로 치환되면 "민준을 만났다",
/// "철수"로 치환되면 "철수를 만났다"가 된다. 바로 앞 글자의 받침 유무로 두 옵션 중 하나를 고른다.
/// SillyTavern 등 롤플레이 채팅 커뮤니티에서 흔히 쓰는 표기 그대로다.
///
/// `{{user}}`/`{{char}}` 치환 *다음*에 호출해야 한다 - 자리표시자 문자열 자체가 아니라
/// 실제로 채워진 이름의 마지막 글자를 봐야 하기 때문이다.
class KoreanJosaMacro {
  const KoreanJosaMacro._();

  static final RegExp _pattern = RegExp(r'\[([^\[\]\n;]{1,12});([^\[\]\n;]{1,12})\]');

  /// 문자열 안의 모든 `[A;B]` 매크로를 앞 글자 받침 유무에 맞는 값으로 바꾼다.
  /// [aliases]는 `{{user}}`처럼 최종 텍스트에서도 리터럴로 남아있어야 하는 자리표시자를 위한
  /// 것이다 - 매크로 바로 앞이 그 자리표시자 문자열로 끝나면, 실제 글자 대신 [aliases]에 매핑된
  /// 이름의 마지막 글자로 받침 유무를 판단한다(자리표시자 자체는 바꾸지 않는다).
  static String resolve(String text, {Map<String, String> aliases = const {}}) {
    if (!text.contains('[') || !text.contains(';')) return text;
    return text.replaceAllMapped(_pattern, (match) {
      final withBatchim = match.group(1)!;
      final withoutBatchim = match.group(2)!;
      var precedingChar = _charBefore(text, match.start);
      final before = text.substring(0, match.start);
      for (final entry in aliases.entries) {
        if (entry.value.isNotEmpty && before.endsWith(entry.key)) {
          precedingChar = entry.value[entry.value.length - 1];
          break;
        }
      }
      return _hasBatchim(precedingChar) ? withBatchim : withoutBatchim;
    });
  }

  static String? _charBefore(String text, int index) {
    if (index <= 0) return null;
    return text[index - 1];
  }

  /// 한글 완성형 음절이면 종성(받침) 유무를 정확히 계산하고, 영문/숫자는 발음 관례에 따른
  /// 근사치를 쓴다. 판단할 수 없으면(공백, 기호, 문자열 시작 등) 받침 없음으로 취급한다 -
  /// 실전에서는 '를/는/와' 계열이 더 무난하게 읽히는 경우가 많아서다.
  static bool _hasBatchim(String? char) {
    if (char == null || char.isEmpty) return false;
    final code = char.codeUnitAt(0);

    // 완성형 한글 음절: AC00(가) ~ D7A3(힣). 종성 인덱스 = (code - AC00) % 28, 0이면 받침 없음.
    if (code >= 0xAC00 && code <= 0xD7A3) {
      return (code - 0xAC00) % 28 != 0;
    }

    // 아라비아 숫자: 한국어 발음 기준(0영 1일 2이 3삼 4사 5오 6육 7칠 8팔 9구) 받침 유무.
    const digitBatchim = {
      '0': true, // 영
      '1': true, // 일
      '2': false, // 이
      '3': true, // 삼
      '4': false, // 사
      '5': false, // 오
      '6': true, // 육
      '7': true, // 칠
      '8': true, // 팔
      '9': false, // 구
    };
    if (digitBatchim.containsKey(char)) return digitBatchim[char]!;

    // 로마자: 알파벳 자체를 한국어로 읽을 때의 마지막 소리 기준 근사치.
    // 모음으로 끝나는 발음(a,i,o,u,e,y,g,j,k,q,w)은 받침 없음, 나머지는 받침 있음으로 본다.
    final lower = char.toLowerCase();
    if (RegExp(r'[a-z]').hasMatch(lower)) {
      const noBatchimEndings = {'a', 'i', 'o', 'u', 'e', 'y', 'g', 'j', 'k', 'q', 'w'};
      return !noBatchimEndings.contains(lower);
    }

    return false;
  }
}
