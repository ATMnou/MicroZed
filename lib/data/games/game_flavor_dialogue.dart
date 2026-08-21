import '../ai/ai_chat_service.dart';
import '../db/database.dart';

/// 게임 화면에서 상대 캐릭터의 짧은 한 줄 대사를 받아오는 헬퍼. 세션/턴에 아무것도
/// 남기지 않는 단발성 호출([AiChatService.completeOneShot])만 쓴다 - 프리셋이 없거나
/// 호출이 실패해도 게임 진행에는 지장이 없어야 하므로 실패 시 null을 돌려준다.
class GameFlavorDialogue {
  GameFlavorDialogue({required AiChatService aiChatService}) : _aiChatService = aiChatService;

  final AiChatService _aiChatService;

  Future<String?> requestLine({
    required AiPreset? preset,
    required Character character,
    required String situationKo,
  }) async {
    if (preset == null) return null;
    final persona = character.description.trim();
    final personaBlock = persona.isEmpty ? '' : '\n성격/설정: $persona';
    try {
      final line = await _aiChatService.completeOneShot(
        preset: preset,
        messages: [
          {
            'role': 'system',
            'content': '당신은 지금부터 "${character.name}"이라는 인물이 되어 게임 중 짧은 한마디를 던집니다.$personaBlock\n'
                '규칙: 반드시 한국어 1문장, 20자 내외의 짧은 대사만 출력하세요. 따옴표, 캐릭터 이름, 설명, 이모지 없이 '
                '대사 내용만 출력하세요.',
          },
          {'role': 'user', 'content': situationKo},
        ],
      );
      final trimmed = line.trim();
      return trimmed.isEmpty ? null : trimmed;
    } catch (_) {
      return null;
    }
  }
}
