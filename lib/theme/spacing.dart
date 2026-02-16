import 'package:flutter/widgets.dart';

/// Design system spacing constants for consistent layout rhythm
/// 
/// Usage:
/// ```dart
/// Padding(
///   padding: const EdgeInsets.all(Spacing.m),
///   child: Column(
///     children: [
///       Text('Title'),
///       SizedBox(height: Spacing.s),
///       Text('Subtitle'),
///     ],
///   ),
/// )
/// ```
class Spacing {
  Spacing._(); // Private constructor to prevent instantiation

  // Base spacing scale (4px grid)
  static const double xxs = 2.0;  // Micro spacing (rare use)
  static const double xs = 4.0;   // Extra small - tight spacing
  static const double s = 8.0;    // Small - between related items
  static const double m = 16.0;   // Medium - default spacing
  static const double l = 24.0;   // Large - section spacing
  static const double xl = 32.0;  // Extra large - major sections
  static const double xxl = 48.0; // Extra extra large - screen margins

  // Semantic spacing (for clarity in specific contexts)
  static const double cardPadding = l;        // Standard card internal padding
  static const double screenPadding = m;      // Screen edge padding
  static const double sectionGap = xl;        // Gap between major sections
  static const double itemGap = s;            // Gap between list items
  static const double buttonHeight = 48.0;    // Standard button height
  static const double iconSize = 24.0;        // Standard icon size
  static const double largeIconSize = 64.0;   // Large decorative icon
}

/// EdgeInsets presets for common use cases
class SpacingInsets {
  SpacingInsets._();

  // All sides
  static const EdgeInsets xs = EdgeInsets.all(Spacing.xs);
  static const EdgeInsets s = EdgeInsets.all(Spacing.s);
  static const EdgeInsets m = EdgeInsets.all(Spacing.m);
  static const EdgeInsets l = EdgeInsets.all(Spacing.l);
  static const EdgeInsets xl = EdgeInsets.all(Spacing.xl);

  // Horizontal only
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: Spacing.xs);
  static const EdgeInsets horizontalS = EdgeInsets.symmetric(horizontal: Spacing.s);
  static const EdgeInsets horizontalM = EdgeInsets.symmetric(horizontal: Spacing.m);
  static const EdgeInsets horizontalL = EdgeInsets.symmetric(horizontal: Spacing.l);

  // Vertical only
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: Spacing.xs);
  static const EdgeInsets verticalS = EdgeInsets.symmetric(vertical: Spacing.s);
  static const EdgeInsets verticalM = EdgeInsets.symmetric(vertical: Spacing.m);
  static const EdgeInsets verticalL = EdgeInsets.symmetric(vertical: Spacing.l);

  // Screen padding (safe area friendly)
  static const EdgeInsets screen = EdgeInsets.all(Spacing.screenPadding);
  static const EdgeInsets card = EdgeInsets.all(Spacing.cardPadding);
}

/// SizedBox presets for vertical spacing
class VerticalSpacing {
  VerticalSpacing._();

  static const xxs = SizedBox(height: Spacing.xxs);
  static const xs = SizedBox(height: Spacing.xs);
  static const s = SizedBox(height: Spacing.s);
  static const m = SizedBox(height: Spacing.m);
  static const l = SizedBox(height: Spacing.l);
  static const xl = SizedBox(height: Spacing.xl);
  static const xxl = SizedBox(height: Spacing.xxl);
}

/// SizedBox presets for horizontal spacing
class HorizontalSpacing {
  HorizontalSpacing._();

  static const xxs = SizedBox(width: Spacing.xxs);
  static const xs = SizedBox(width: Spacing.xs);
  static const s = SizedBox(width: Spacing.s);
  static const m = SizedBox(width: Spacing.m);
  static const l = SizedBox(width: Spacing.l);
  static const xl = SizedBox(width: Spacing.xl);
  static const xxl = SizedBox(width: Spacing.xxl);
}
