import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:win32/win32.dart';

/// Windows 전용 로컬 보안 저장소.
///
/// `flutter_secure_storage`의 Windows 구현은 빌드 시 Visual Studio의 ATL(Active
/// Template Library) 컴포넌트가 있어야 컴파일된다. 이 컴포넌트는 관리자 권한 GUI
/// 설치가 필요해 모든 개발 환경에 있다고 보장할 수 없으므로, 네이티브 플러그인 빌드가
/// 필요 없는 순수 Dart FFI로 Win32 DPAPI(CryptProtectData/CryptUnprotectData)를
/// 직접 호출한다. 암호화된 값은 현재 로그인한 Windows 계정에 묶여 저장된다.
class WindowsDpapiStore {
  Future<File> _fileFor(String key) async {
    final dir = await getApplicationSupportDirectory();
    final safeName = key.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    return File('${dir.path}${Platform.pathSeparator}secure_$safeName.bin');
  }

  Future<void> write(String key, String value) async {
    final file = await _fileFor(key);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(_protect(Uint8List.fromList(utf8.encode(value))));
  }

  Future<String?> read(String key) async {
    final file = await _fileFor(key);
    if (!await file.exists()) return null;
    final decrypted = _unprotect(await file.readAsBytes());
    return decrypted == null ? null : utf8.decode(decrypted);
  }

  Future<void> delete(String key) async {
    final file = await _fileFor(key);
    if (await file.exists()) await file.delete();
  }

  Uint8List _protect(Uint8List data) {
    return using((arena) {
      final inputBuffer = arena<Uint8>(data.length);
      inputBuffer.asTypedList(data.length).setAll(0, data);
      final input = arena<CRYPT_INTEGER_BLOB>()
        ..ref.cbData = data.length
        ..ref.pbData = inputBuffer;
      final output = arena<CRYPT_INTEGER_BLOB>();

      final result = CryptProtectData(input, null, nullptr, nullptr, 0, output);
      if (!result.value) {
        throw StateError('CryptProtectData failed (Win32 error ${result.error})');
      }
      final encrypted = Uint8List.fromList(output.ref.pbData.asTypedList(output.ref.cbData));
      HLOCAL(output.ref.pbData).close();
      return encrypted;
    });
  }

  Uint8List? _unprotect(Uint8List data) {
    return using((arena) {
      final inputBuffer = arena<Uint8>(data.length);
      inputBuffer.asTypedList(data.length).setAll(0, data);
      final input = arena<CRYPT_INTEGER_BLOB>()
        ..ref.cbData = data.length
        ..ref.pbData = inputBuffer;
      final output = arena<CRYPT_INTEGER_BLOB>();

      final result = CryptUnprotectData(input, nullptr, nullptr, nullptr, 0, output);
      if (!result.value) return null;
      final decrypted = Uint8List.fromList(output.ref.pbData.asTypedList(output.ref.cbData));
      HLOCAL(output.ref.pbData).close();
      return decrypted;
    });
  }
}
