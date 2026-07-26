import 'package:flutter/material.dart';

import '../data/secure/local_file_store.dart';

const _localeStoreKey = 'app_locale';
const supportedLocales = [Locale('ko'), Locale('en'), Locale('ja')];

/// 앱의 현재 언어를 관리한다. 사용자가 설정에서 언어를 고르면 값을 저장하고,
/// 앱 시작 시 저장된 값을 읽어 복원한다. 저장된 값이 없으면 null(시스템 언어 따라감).
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController() : super(null);

  final _store = LocalFileStore();

  Future<void> load() async {
    final saved = await _store.read(_localeStoreKey);
    if (saved != null && supportedLocales.any((l) => l.languageCode == saved)) {
      value = Locale(saved);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    value = locale;
    if (locale == null) {
      await _store.delete(_localeStoreKey);
    } else {
      await _store.write(_localeStoreKey, locale.languageCode);
    }
  }
}
