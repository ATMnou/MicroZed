import 'dart:io';

import 'package:flutter/material.dart';

/// 로컬 파일 경로가 있으면 그 이미지를, 없으면 기본 아이콘을 보여주는 원형 아바타.
class LocalAvatar extends StatelessWidget {
  const LocalAvatar({
    super.key,
    required this.imagePath,
    this.radius = 20,
    this.icon = Icons.person,
    this.backgroundColor = const Color(0xFF3A3A3A),
    this.iconColor = Colors.white54,
  });

  final String? imagePath;
  final double radius;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: FileImage(File(path)),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Icon(icon, color: iconColor, size: radius),
    );
  }
}
