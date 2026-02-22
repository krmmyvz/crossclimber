/// Design token: Standardized opacity values
///
/// Replaces 17+ different alpha values across the codebase
/// with a consistent, semantic scale.
///
/// Usage:
/// ```dart
/// color.withValues(alpha: Opacities.subtle)
/// ```
abstract final class Opacities {
  /// 0.04 – Barely visible tint, surface highlights
  static const double faintest = 0.04;

  /// 0.08 – Very faint backgrounds, hover states
  static const double faint = 0.08;

  /// 0.1 – Subtle tints, disabled backgrounds
  static const double subtle = 0.1;

  /// 0.12 – Light backgrounds, chip fills, badges
  static const double light = 0.12;

  /// 0.15 – Soft overlays, container tints
  static const double soft = 0.15;

  /// 0.2 – Gentle overlays, border colors
  static const double gentle = 0.2;

  /// 0.25 – Light borders, selected backgrounds
  static const double quarter = 0.25;

  /// 0.3 – Medium-light shadows, borders, dividers
  static const double medium = 0.3;

  /// 0.4 – Medium overlays, secondary borders
  static const double semi = 0.4;

  /// 0.5 – Half opacity, balanced overlays
  static const double half = 0.5;

  /// 0.6 – Strong overlays, secondary text
  static const double strong = 0.6;

  /// 0.7 – Bold overlays, prominent text
  static const double bold = 0.7;

  /// 0.8 – Heavy overlays, near-opaque elements
  static const double heavy = 0.8;

  /// 0.9 – Near-opaque, active states
  static const double near = 0.9;

  /// 1.0 – Fully opaque
  static const double full = 1.0;
}
