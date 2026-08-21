import '../ai/ai_chat_service.dart';
import '../db/database.dart';

/// 게임 상대의 수를 CPU 알고리즘 대신 LLM으로 판단하게 할 때 쓰는 공용 헬퍼. [GameFlavorDialogue]와
/// 같은 철학 - 실패(프리셋 없음/응답 파싱 실패/범위 밖/예외)하면 항상 null을 돌려주고, 호출부는
/// null이면 기존 알고리즘 AI로 조용히 폴백해야 한다. LLM은 게임 상태를 직접 조작하지 않고 항상
/// 이미 유효성이 보장된 후보 목록 중 번호만 고른다 - 그래서 어떤 응답이 와도 불법적인 수가 나올
/// 수 없다.
class GameLlmChoice {
  GameLlmChoice({required AiChatService aiChatService}) : _aiChatService = aiChatService;

  final AiChatService _aiChatService;

  Future<int?> chooseIndex({
    required AiPreset? preset,
    required Character character,
    required String gameNameKo,
    required String stateKo,
    required List<String> options,
  }) async {
    if (preset == null || options.isEmpty) return null;
    final persona = character.description.trim();
    final personaBlock = persona.isEmpty ? '' : '\n성격/설정: $persona';
    final optionsBlock = [for (var i = 0; i < options.length; i++) '${i + 1}. ${options[i]}'].join('\n');
    try {
      final response = await _aiChatService.completeOneShot(
        preset: preset,
        messages: [
          {
            'role': 'system',
            'content': '당신은 "${character.name}"이고 지금 $gameNameKo을(를) 두고 있습니다.$personaBlock\n'
                '아래 상황을 보고 선택지 중 가장 유리하다고 생각하는 것을 하나만 고르세요. '
                '반드시 그 선택지의 번호만(다른 말, 설명, 기호 없이) 숫자로 출력하세요.',
          },
          {'role': 'user', 'content': '$stateKo\n\n선택지:\n$optionsBlock'},
        ],
      );
      final match = RegExp(r'\d+').firstMatch(response);
      if (match == null) return null;
      final index = int.parse(match.group(0)!) - 1;
      if (index < 0 || index >= options.length) return null;
      return index;
    } catch (_) {
      return null;
    }
  }
}
