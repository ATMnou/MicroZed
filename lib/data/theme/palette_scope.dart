import 'package:flutter/material.dart';

import '../../main.dart';
import 'color_palette.dart';
import 'palette_controller.dart';

/// [paletteController]를 트리 전체에 InheritedWidget으로 노출한다. `main.dart`의
/// `MaterialApp.builder`에 감싸두면, Navigator/Overlay 안쪽(각 화면)에서도
/// `PaletteScope.of(context)`로 지금 선택된 팔레트를 읽을 수 있고, 팔레트가 바뀌면
/// 이 위젯에 의존하는 화면들만 정확히 다시 그려진다(전체 앱을 강제로 다시 만들 필요 없음).
class PaletteScope extends InheritedNotifier<PaletteController> {
  PaletteScope({super.key, required super.child}) : super(notifier: paletteController);

  static ColorPalette of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PaletteScope>();
    return (scope?.notifier ?? paletteController).active;
  }
}
