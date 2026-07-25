import 'package:drift/drift.dart';

import 'database.dart';

/// 최초 실행 시(대화 프로필이 하나도 없을 때) 기본 대화 프로필/AI 프리셋을 DB에 심어둔다.
/// 플롯은 심지 않는다(유저가 직접 만든다). API 키는 secure storage에만 두므로 여기서는
/// 심지 않는다 — 필요하면 마이페이지 > AI 프리셋 설정에서 다시 입력하면 된다.
/// 이후 실행부터는 아무것도 하지 않는다.
Future<void> seedIfEmpty(AppDatabase db) async {
  final existing = await db.select(db.conversationProfiles).get();
  if (existing.isNotEmpty) return;

  await db.transaction(() async {
    await db.into(db.conversationProfiles).insert(
          ConversationProfilesCompanion.insert(
            name: 'John Doe',
            isDefault: const Value(true),
          ),
        );

    await db.into(db.aiPresets).insert(
          AiPresetsCompanion.insert(
            name: 'DeepSeek V3.2',
            description: const Value('기왕 찾아온 거 검열 없는 모델을 쓰는 게 좋잔아요? 아 근데 천안문 이런건 얘가 거절해요 예'),
            baseUrl: 'https://openrouter.ai/api/v1/',
            modelName: 'deepseek/deepseek-v3.2',
          ),
        );
    await db.into(db.aiPresets).insert(
          AiPresetsCompanion.insert(
            name: 'Claude Sonnet',
            description: const Value('다들 사랑하는 모델이라 넣어봤어요.'),
            baseUrl: 'https://openrouter.ai/api/v1/',
            modelName: '~anthropic/claude-sonnet-latest',
          ),
        );
  });
}
