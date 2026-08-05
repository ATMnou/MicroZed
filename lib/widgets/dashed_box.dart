import 'package:flutter/material.dart';
import '../data/theme/palette_scope.dart';

/// 점선 테두리 박스. 이미지/커버 업로드 자리표시자에 사용한다.
class DashedBox extends StatelessWidget {
  const DashedBox({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.color,
    this.borderRadius = 12,
  });

  final Widget child;
  final double? width;
  final double? height;
  final Color? color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: color ?? PaletteScope.of(context).primary, radius: borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(child: child),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
