import 'package:flutter/material.dart';

class Responsive {
  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  static double getTileSize(BuildContext context, int wordLength) {
    final width = MediaQuery.of(context).size.width;
    final availableWidth = width - 32; // 16 padding each side
    // Maksimum tile boyutu 50, minimum 28 olsun
    return (availableWidth / (wordLength + 1)).clamp(28.0, 50.0);
  }

  static double getFontSize(BuildContext context, double baseSize) {
    if (isCompact(context)) return baseSize * 0.85;
    if (isTablet(context)) return baseSize * 1.2;
    return baseSize;
  }

  static double getIconSize(BuildContext context) {
    if (isCompact(context)) return 20.0;
    if (isTablet(context)) return 32.0;
    return 24.0;
  }
}
