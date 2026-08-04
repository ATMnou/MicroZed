import 'dart:convert';

import '../secure/local_file_store.dart';

class SummarySettings {
  const SummarySettings({
    this.enabled = true,
    this.customPrompt,
    this.presetId,
  });

  /// 꺼져 있으면 프리셋에 contextLength가 설정돼 있어도 장기 기억 요약을 만들지 않는다.
  final bool enabled;

  /// null이면 [AiChatService]에 내장된 기본 요약 프롬프트를 그대로 쓴다.
  final String? customPrompt;

  /// null이면 예전처럼 그 채팅에서 쓰는 프리셋으로 요약도 함께 생성한다.
  final int? presetId;
}

const _settingsKey = 'summary_settings';

/// 마이페이지 > 요약(장기 기억) 설정에서 저장한 값을 보관한다. API 키 같은 비밀이 없어서
/// [SnapshotSettingsStore]와 달리 플랫폼 구분 없이 [LocalFileStore]에 평문 JSON으로 저장한다.
class SummarySettingsStore {
  final _fileStore = LocalFileStore();

  Future<SummarySettings> read() async {
    final raw = await _fileStore.read(_settingsKey);
    if (raw == null || raw.trim().isEmpty) return const SummarySettings();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return SummarySettings(
        enabled: json['enabled'] as bool? ?? true,
        customPrompt: json['customPrompt'] as String?,
        presetId: (json['presetId'] as num?)?.toInt(),
      );
    } catch (_) {
      return const SummarySettings();
    }
  }

  Future<void> save(SummarySettings settings) async {
    final raw = jsonEncode({
      'enabled': settings.enabled,
      'customPrompt': settings.customPrompt,
      'presetId': settings.presetId,
    });
    await _fileStore.write(_settingsKey, raw);
  }
}
