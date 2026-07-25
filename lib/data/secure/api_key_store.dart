import 'dart:io';

import 'local_file_store.dart';
import 'windows_dpapi_store.dart';

/// AI 프리셋의 BYOK API 키를 로컬 보안 저장소에 보관한다.
/// Drift DB에는 프리셋별 참조 키(`apiKeyRef`)만 저장하고, 키 원문은 여기서만 다룬다.
///
/// Windows는 Win32 DPAPI로 암호화해서 저장하고(windows_dpapi_store.dart 참고),
/// 그 외 플랫폼은 앱 전용 격리 저장 공간에 저장한다(local_file_store.dart 참고).
class ApiKeyStore {
  ApiKeyStore()
      : _windowsStore = Platform.isWindows ? WindowsDpapiStore() : null,
        _fallbackStore = Platform.isWindows ? null : LocalFileStore();

  final WindowsDpapiStore? _windowsStore;
  final LocalFileStore? _fallbackStore;

  static String refFor(int presetId) => 'ai_preset_api_key_$presetId';

  Future<void> save(int presetId, String apiKey) {
    final key = refFor(presetId);
    return _windowsStore != null ? _windowsStore.write(key, apiKey) : _fallbackStore!.write(key, apiKey);
  }

  Future<String?> read(int presetId) {
    final key = refFor(presetId);
    return _windowsStore != null ? _windowsStore.read(key) : _fallbackStore!.read(key);
  }

  Future<void> delete(int presetId) {
    final key = refFor(presetId);
    return _windowsStore != null ? _windowsStore.delete(key) : _fallbackStore!.delete(key);
  }
}
