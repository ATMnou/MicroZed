import 'package:flutter/material.dart';

/// 앱 전역 시드 색상. 채팅 화면의 유저 말풍선/포인트 컬러와 동일하다.
const kSeedColor = Color(0xFF7A6FF0);

/// 기존 다크 테마. 대부분의 화면이 아직 이 배경/카드 색을 하드코딩해서 직접 쓰고 있어서,
/// 값 자체는 그대로 유지한다(화면들을 Theme 기반으로 옮기는 작업은 점진적으로 진행).
final ThemeData kDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF141414),
  colorScheme: ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.dark,
  ).copyWith(surface: const Color(0xFF141414)),
);

/// AMOLED 블랙. 다크 테마와 배색 구조는 같고 배경만 완전한 검정으로 바꿔서,
/// OLED 화면에서 소비 전력을 아끼고 싶은 사용자를 위한 변형이다.
final ThemeData kAmoledTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.dark,
  ).copyWith(surface: Colors.black),
);

/// 화이트 테마.
final ThemeData kLightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF5F5F7),
  colorScheme: ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.light,
  ),
);
