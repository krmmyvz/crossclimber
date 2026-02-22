import 'package:flutter/material.dart';

/// Design token: Standardized shadow presets
///
/// Replaces 26 hardcoded BoxShadow instances across the codebase
/// with a consistent, reusable shadow system.
///
/// Usage:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     boxShadow: [AppShadows.subtle],
///   ),
/// )
/// ```
abstract final class AppShadows {
  // ─── Neutral shadows (black-based) ─────────────────────────

  /// Minimal shadow – cards at rest, subtle depth
  /// blur: 4, offset: (0,1)
  static const BoxShadow subtle = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.08),
    blurRadius: 4,
    offset: Offset(0, 1),
  );

  /// Standard shadow – elevated cards, buttons
  /// blur: 8, offset: (0,4)
  static const BoxShadow medium = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.15),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  /// Prominent shadow – dialogs, floating elements
  /// blur: 12, offset: (0,4)
  static const BoxShadow strong = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.2),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  /// Heavy shadow – popovers, dropdowns
  /// blur: 16, offset: (0,6)
  static const BoxShadow heavy = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.25),
    blurRadius: 16,
    offset: Offset(0, 6),
  );

  // ─── Colored shadow helpers ────────────────────────────────

  /// Create a subtle colored shadow for glow effects
  static BoxShadow colorSubtle(Color color) => BoxShadow(
        color: color.withValues(alpha: 0.15),
        blurRadius: 6,
        spreadRadius: 1,
      );

  /// Create a medium colored shadow for accented cards
  static BoxShadow colorMedium(Color color) => BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  /// Create a strong colored shadow for glowing effects
  static BoxShadow colorStrong(Color color) => BoxShadow(
        color: color.withValues(alpha: 0.4),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );

  /// Create a glow effect (no offset, with spread)
  static BoxShadow glow(Color color, {double alpha = 0.3}) => BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: 24,
        spreadRadius: 4,
      );

  // ─── Pre-built shadow lists ────────────────────────────────

  /// No shadow
  static const List<BoxShadow> none = [];

  /// Subtle elevation – resting cards
  static const List<BoxShadow> elevation1 = [subtle];

  /// Medium elevation – active/hover cards
  static const List<BoxShadow> elevation2 = [medium];

  /// Strong elevation – dialogs, modals
  static const List<BoxShadow> elevation3 = [strong];
}
