import 'package:flutter/material.dart';

/// 화면 전체가 공유하는 색상 슬롯 하나. 예전에는 각 화면이 `Color(0xFF1E1E1E)` 같은 값을
/// 직접 들고 있었지만, 이제는 전부 이 팔레트를 통해서만 색을 얻는다.
///
/// 빌트인 3종(다크/AMOLED/화이트)과 유저가 만드는 커스텀 프리셋이 전부 이 클래스의 인스턴스다.
/// `id`가 `builtin_`로 시작하는 3개(다크/AMOLED/화이트)는 [PaletteController]에서 수정/삭제를
/// 막는다.
@immutable
class ColorPalette {
  const ColorPalette({
    required this.id,
    required this.name,
    required this.isBuiltIn,
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.primary,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textFaint,
    required this.textGhost,
    this.danger = const Color(0xFFFF5252),
  });

  final String id;
  final String name;
  final bool isBuiltIn;
  final Brightness brightness;

  /// Scaffold 배경.
  final Color background;

  /// 카드/시트/다이얼로그 표면.
  final Color surface;

  /// surface보다 한 단계 더 있는 톤(입력창 필/보조 말풍선 배경 등).
  final Color surfaceAlt;

  /// 카드 테두리, 구분선.
  final Color border;

  /// 포인트(액센트) 컬러 - 버튼, 선택 상태, 유저 말풍선 등.
  final Color primary;

  /// [primary] 위에 올라가는 텍스트/아이콘 색.
  final Color onPrimary;

  /// 본문 텍스트(기존 Colors.white 자리).
  final Color textPrimary;

  /// 보조 텍스트(기존 Colors.white70 자리).
  final Color textSecondary;

  /// 흐린 텍스트/힌트(기존 Colors.white54 자리).
  final Color textMuted;

  /// 더 흐린 텍스트(기존 Colors.white38 자리).
  final Color textFaint;

  /// 거의 안 보이는 텍스트/아이콘(기존 Colors.white24 등 자리).
  final Color textGhost;

  /// 위험/삭제 액션 강조색. 프리셋마다 크게 다를 이유가 없어서 기본값을 공유한다.
  final Color danger;

  ColorPalette copyWith({
    String? id,
    String? name,
    bool? isBuiltIn,
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? primary,
    Color? onPrimary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textFaint,
    Color? textGhost,
    Color? danger,
  }) {
    return ColorPalette(
      id: id ?? this.id,
      name: name ?? this.name,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      textGhost: textGhost ?? this.textGhost,
      danger: danger ?? this.danger,
    );
  }

  static Color _colorOf(Map<String, dynamic> json, String key, Color fallback) {
    final value = json[key];
    if (value is int) return Color(value);
    return fallback;
  }

  factory ColorPalette.fromJson(Map<String, dynamic> json) {
    const fallback = BuiltInPalettes.dark;
    return ColorPalette(
      id: json['id'] as String? ?? UniqueKey().toString(),
      name: json['name'] as String? ?? fallback.name,
      isBuiltIn: false,
      brightness: json['brightness'] == 'light' ? Brightness.light : Brightness.dark,
      background: _colorOf(json, 'background', fallback.background),
      surface: _colorOf(json, 'surface', fallback.surface),
      surfaceAlt: _colorOf(json, 'surfaceAlt', fallback.surfaceAlt),
      border: _colorOf(json, 'border', fallback.border),
      primary: _colorOf(json, 'primary', fallback.primary),
      onPrimary: _colorOf(json, 'onPrimary', fallback.onPrimary),
      textPrimary: _colorOf(json, 'textPrimary', fallback.textPrimary),
      textSecondary: _colorOf(json, 'textSecondary', fallback.textSecondary),
      textMuted: _colorOf(json, 'textMuted', fallback.textMuted),
      textFaint: _colorOf(json, 'textFaint', fallback.textFaint),
      textGhost: _colorOf(json, 'textGhost', fallback.textGhost),
      danger: _colorOf(json, 'danger', fallback.danger),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brightness': brightness == Brightness.light ? 'light' : 'dark',
      'background': background.toARGB32(),
      'surface': surface.toARGB32(),
      'surfaceAlt': surfaceAlt.toARGB32(),
      'border': border.toARGB32(),
      'primary': primary.toARGB32(),
      'onPrimary': onPrimary.toARGB32(),
      'textPrimary': textPrimary.toARGB32(),
      'textSecondary': textSecondary.toARGB32(),
      'textMuted': textMuted.toARGB32(),
      'textFaint': textFaint.toARGB32(),
      'textGhost': textGhost.toARGB32(),
      'danger': danger.toARGB32(),
    };
  }

  /// 이 팔레트로 만든 [ThemeData]. MaterialApp이 그대로 쓴다.
  ThemeData toThemeData() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      surface: background,
      primary: primary,
      onPrimary: onPrimary,
    );
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      textSelectionTheme: TextSelectionThemeData(cursorColor: primary, selectionHandleColor: primary),
    );
  }

  @override
  bool operator ==(Object other) => other is ColorPalette && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// 빌트인 3종 프리셋. 값 자체는 기존 app_theme.dart의 하드코딩 값을 그대로 옮겼다 -
/// 마이그레이션으로 기존 사용자들이 보던 색이 바뀌면 안 되기 때문.
class BuiltInPalettes {
  const BuiltInPalettes._();

  static const String darkId = 'builtin_dark';
  static const String amoledId = 'builtin_amoled';
  static const String lightId = 'builtin_light';

  static const dark = ColorPalette(
    id: darkId,
    name: '다크',
    isBuiltIn: true,
    brightness: Brightness.dark,
    background: Color(0xFF141414),
    surface: Color(0xFF1E1E1E),
    surfaceAlt: Color(0xFF262626),
    border: Color(0xFF3A3A3A),
    primary: Color(0xFF7A6FF0),
    onPrimary: Colors.white,
    textPrimary: Colors.white,
    textSecondary: Colors.white70,
    textMuted: Colors.white54,
    textFaint: Colors.white38,
    textGhost: Colors.white24,
  );

  static const amoled = ColorPalette(
    id: amoledId,
    name: 'AMOLED',
    isBuiltIn: true,
    brightness: Brightness.dark,
    background: Colors.black,
    surface: Color(0xFF141414),
    surfaceAlt: Color(0xFF1E1E1E),
    border: Color(0xFF3A3A3A),
    primary: Color(0xFF7A6FF0),
    onPrimary: Colors.white,
    textPrimary: Colors.white,
    textSecondary: Colors.white70,
    textMuted: Colors.white54,
    textFaint: Colors.white38,
    textGhost: Colors.white24,
  );

  static const light = ColorPalette(
    id: lightId,
    name: '화이트',
    isBuiltIn: true,
    brightness: Brightness.light,
    background: Color(0xFFF5F5F7),
    surface: Colors.white,
    surfaceAlt: Color(0xFFEDEDF2),
    border: Color(0xFFDDDDE3),
    primary: Color(0xFF7A6FF0),
    onPrimary: Colors.white,
    textPrimary: Color(0xFF1A1A1E),
    textSecondary: Color(0xB31A1A1E),
    textMuted: Color(0x8A1A1A1E),
    textFaint: Color(0x611A1A1E),
    textGhost: Color(0x3D1A1A1E),
  );

  static const List<ColorPalette> all = [dark, amoled, light];

  static bool isBuiltInId(String id) => all.any((p) => p.id == id);
}
