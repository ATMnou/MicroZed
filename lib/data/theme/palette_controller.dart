import 'dart:convert';

import 'package:flutter/material.dart';

import '../secure/local_file_store.dart';
import 'color_palette.dart';

const _selectedKey = 'palette_selected_id';
const _customKey = 'palette_custom_list';

/// 시스템 설정을 그대로 따르는 걸 고르면 밝기에 따라 다크/화이트 빌트인 중 하나로 매핑된다.
const String kSystemPaletteId = 'system';

/// 마이페이지 > 환경설정 > 테마에서 고르는 컬러 팔레트 전체(빌트인 3종 + 유저 커스텀)를 관리한다.
///
/// 기존 [AppThemePreferences]/`app_theme.dart`를 대체한다. 상태관리는 이 프로젝트의 다른
/// 전역 컨트롤러들(localeController 등)과 마찬가지로 [ChangeNotifier] + 전역 싱글턴 패턴을 쓴다.
class PaletteController extends ChangeNotifier {
  final _store = LocalFileStore();

  String _selectedId = BuiltInPalettes.darkId;
  List<ColorPalette> _custom = [];
  Brightness _platformBrightness = Brightness.dark;

  String get selectedId => _selectedId;

  List<ColorPalette> get customPalettes => List.unmodifiable(_custom);

  /// 선택 가능한 전체 목록(빌트인 3종이 항상 먼저 온다).
  List<ColorPalette> get allPalettes => [...BuiltInPalettes.all, ..._custom];

  /// 지금 실제로 적용 중인 팔레트. `system` 선택 시 OS 밝기에 따라 다크/화이트로 해석한다.
  ColorPalette get active {
    if (_selectedId == kSystemPaletteId) {
      return _platformBrightness == Brightness.light ? BuiltInPalettes.light : BuiltInPalettes.dark;
    }
    return allPalettes.firstWhere(
      (p) => p.id == _selectedId,
      orElse: () => BuiltInPalettes.dark,
    );
  }

  bool get isSystemSelected => _selectedId == kSystemPaletteId;

  /// MaterialApp의 MediaQuery가 바뀔 때(OS 다크모드 전환 등) 호출해서 system 선택을 갱신한다.
  void updatePlatformBrightness(Brightness brightness) {
    if (_platformBrightness == brightness) return;
    _platformBrightness = brightness;
    if (_selectedId == kSystemPaletteId) notifyListeners();
  }

  Future<void> load() async {
    final savedId = await _store.read(_selectedKey);
    final savedCustom = await _store.read(_customKey);

    if (savedCustom != null && savedCustom.isNotEmpty) {
      try {
        final list = jsonDecode(savedCustom) as List<dynamic>;
        _custom = list
            .whereType<Map<String, dynamic>>()
            .map(ColorPalette.fromJson)
            .toList();
      } catch (_) {
        _custom = [];
      }
    }

    if (savedId != null && (savedId == kSystemPaletteId || allPalettes.any((p) => p.id == savedId))) {
      _selectedId = savedId;
    }
    notifyListeners();
  }

  Future<void> _persistCustom() async {
    await _store.write(_customKey, jsonEncode(_custom.map((p) => p.toJson()).toList()));
  }

  Future<void> select(String id) async {
    if (id != kSystemPaletteId && !allPalettes.any((p) => p.id == id)) return;
    _selectedId = id;
    notifyListeners();
    await _store.write(_selectedKey, id);
  }

  /// 새 커스텀 프리셋을 추가한다. id가 비어 있으면 자동으로 만들어준다.
  Future<ColorPalette> addCustom(ColorPalette palette) async {
    final withId = palette.id.isEmpty || BuiltInPalettes.isBuiltInId(palette.id)
        ? palette.copyWith(id: 'custom_${DateTime.now().microsecondsSinceEpoch}', isBuiltIn: false)
        : palette.copyWith(isBuiltIn: false);
    _custom = [..._custom, withId];
    notifyListeners();
    await _persistCustom();
    return withId;
  }

  Future<void> updateCustom(ColorPalette palette) async {
    if (BuiltInPalettes.isBuiltInId(palette.id)) {
      throw ArgumentError('빌트인 프리셋은 수정할 수 없어요.');
    }
    final index = _custom.indexWhere((p) => p.id == palette.id);
    if (index == -1) return;
    _custom = [..._custom]..[index] = palette.copyWith(isBuiltIn: false);
    notifyListeners();
    await _persistCustom();
  }

  Future<void> deleteCustom(String id) async {
    if (BuiltInPalettes.isBuiltInId(id)) {
      throw ArgumentError('빌트인 프리셋은 삭제할 수 없어요.');
    }
    final wasSelected = _selectedId == id;
    _custom = _custom.where((p) => p.id != id).toList();
    if (wasSelected) _selectedId = BuiltInPalettes.darkId;
    notifyListeners();
    await _persistCustom();
    if (wasSelected) await _store.write(_selectedKey, _selectedId);
  }
}
