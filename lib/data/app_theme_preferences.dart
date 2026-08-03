import 'package:flutter/foundation.dart';

import 'secure/local_file_store.dart';

/// 다크(기존)/화이트/AMOLED 블랙/시스템 자동.
enum AppThemeMode { dark, light, amoled, system }

const _storeKey = 'app_theme_mode';

/// 마이페이지 > 환경설정에서 고른 테마를 관리한다. 앱 시작 시 저장된 값을 읽어
/// 복원하고, 바뀌면 [ValueNotifier]를 통해 MaterialApp에 즉시 반영된다.
class AppThemePreferences extends ValueNotifier<AppThemeMode> {
  AppThemePreferences() : super(AppThemeMode.dark);

  final _store = LocalFileStore();

  Future<void> load() async {
    final saved = await _store.read(_storeKey);
    value = AppThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => AppThemeMode.dark,
    );
  }

  Future<void> setMode(AppThemeMode mode) async {
    value = mode;
    await _store.write(_storeKey, mode.name);
  }
}
