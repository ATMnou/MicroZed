import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Windows 이외 플랫폼(Android/iOS/macOS/Linux)용 임시 폴백 저장소.
///
/// 앱 전용 저장 공간(OS가 다른 앱으로부터 격리해주는 디렉터리)에 평문으로 저장한다.
/// 추후 플랫폼별 Keychain/Keystore/libsecret 연동으로 교체하는 게 더 안전하지만,
/// 지금 단계에서는 Windows의 flutter_secure_storage ATL 빌드 이슈를 피하기 위해
/// 모든 플랫폼에서 자체 저장소로 통일했다.
class LocalFileStore {
  Future<File> _fileFor(String key) async {
    final dir = await getApplicationSupportDirectory();
    final safeName = key.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    return File('${dir.path}${Platform.pathSeparator}secure_$safeName.txt');
  }

  Future<void> write(String key, String value) async {
    final file = await _fileFor(key);
    await file.parent.create(recursive: true);
    await file.writeAsString(value);
  }

  Future<String?> read(String key) async {
    final file = await _fileFor(key);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  Future<void> delete(String key) async {
    final file = await _fileFor(key);
    if (await file.exists()) await file.delete();
  }
}
