import 'dart:convert';
import 'dart:io';

import '../secure/local_file_store.dart';
import '../secure/windows_dpapi_store.dart';

/// 스냅샷이 이미지를 생성할 때 사용할 엔드포인트.
enum SnapshotImageProvider {
  openRouter,
  atlasCloud;

  static const _defaultModel = {
    SnapshotImageProvider.openRouter: 'google/gemini-2.5-flash-image',
    SnapshotImageProvider.atlasCloud: 'seedream-3.0',
  };

  String get defaultModelName => _defaultModel[this]!;
}

class SnapshotSettings {
  const SnapshotSettings({
    required this.provider,
    required this.apiKey,
    required this.modelName,
  });

  final SnapshotImageProvider provider;
  final String apiKey;
  final String modelName;

  bool get isConfigured => apiKey.trim().isNotEmpty && modelName.trim().isNotEmpty;
}

const _settingsKey = 'snapshot_image_settings';

/// 마이페이지 > 스냅샷 설정에서 저장한 이미지 생성 엔드포인트 설정을 보관한다.
/// API 키가 포함돼 있어서 AI 프리셋 키와 동일한 보안 저장소(Windows는 DPAPI, 그 외는
/// 앱 전용 격리 저장소)에 JSON 한 덩어리로 저장한다.
class SnapshotSettingsStore {
  SnapshotSettingsStore()
      : _windowsStore = Platform.isWindows ? WindowsDpapiStore() : null,
        _fallbackStore = Platform.isWindows ? null : LocalFileStore();

  final WindowsDpapiStore? _windowsStore;
  final LocalFileStore? _fallbackStore;

  Future<SnapshotSettings?> read() async {
    final raw = _windowsStore != null ? await _windowsStore.read(_settingsKey) : await _fallbackStore!.read(_settingsKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final provider = SnapshotImageProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => SnapshotImageProvider.openRouter,
      );
      return SnapshotSettings(
        provider: provider,
        apiKey: json['apiKey'] as String? ?? '',
        modelName: json['modelName'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(SnapshotSettings settings) async {
    final raw = jsonEncode({
      'provider': settings.provider.name,
      'apiKey': settings.apiKey,
      'modelName': settings.modelName,
    });
    if (_windowsStore != null) {
      await _windowsStore.write(_settingsKey, raw);
    } else {
      await _fallbackStore!.write(_settingsKey, raw);
    }
  }
}
