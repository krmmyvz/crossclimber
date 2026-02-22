import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Responsive {
  // ── Breakpoints ──────────────────────────────────────────────────────────
  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool isWeb() => kIsWeb;

  // ── Sizing Helpers ───────────────────────────────────────────────────────

  static double getTileSize(BuildContext context, int wordLength) {
    final width = MediaQuery.of(context).size.width;
    final landscape = isLandscape(context);
    // Landscape'te game board sola sıkıştırılacak, mevcut genişliğin ~%55'i
    final effectiveWidth = landscape ? width * 0.55 : width;
    final availableWidth = effectiveWidth - 32; // 16 padding each side
    return (availableWidth / (wordLength + 1)).clamp(24.0, 50.0);
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

  /// Game board max width constraint for tablets/desktop
  static double getGameBoardMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 600;
    if (isTablet(context)) return 600;
    return double.infinity;
  }

  /// Dialog max width for tablets/desktop
  static double getDialogMaxWidth(BuildContext context) {
    if (isTablet(context)) return 500;
    return double.infinity;
  }

  /// Keyboard max width for tablets/desktop
  static double getKeyboardMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 700;
    if (isTablet(context)) return 600;
    return double.infinity;
  }

  /// Level map columns based on orientation + screen size
  static int getLevelMapColumns(BuildContext context) {
    final landscape = isLandscape(context);
    if (isDesktop(context)) return landscape ? 6 : 5;
    if (isTablet(context)) return landscape ? 5 : 4;
    if (landscape) return 4;
    return 3; // default phone portrait
  }

  /// Home grid columns based on orientation + screen size
  static int getHomeGridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context) && isLandscape(context)) return 4;
    return 2;
  }

  /// Settings columns (1 on phone, 2 on tablet)
  static int getSettingsColumns(BuildContext context) {
    if (isTablet(context)) return 2;
    return 1;
  }
}
