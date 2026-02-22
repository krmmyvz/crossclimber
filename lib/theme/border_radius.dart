import 'package:flutter/material.dart';

/// Standardized border radius tokens for the application.
///
/// Provides a consistent set of border radius values following
/// a semantic scale from extra-small to full (pill shape).
///
/// Usage:
/// ```dart
/// borderRadius: BorderRadius.circular(Radii.md),
/// // or use the pre-built BorderRadius constants:
/// borderRadius: RadiiBR.md,
/// ```
class Radii {
  Radii._(); // Prevent instantiation

  /// Extra extra small - tiny indicators, progress dots
  static const double xxs = 2.0;

  /// Extra small - letter tiles, small interactive elements
  static const double xs = 4.0;

  /// Small - chips, badges, progress bars
  static const double sm = 8.0;

  /// Medium - cards, list items, notifications
  static const double md = 12.0;

  /// Large - large cards, input fields, containers
  static const double lg = 16.0;

  /// Extra large - hero cards, streak cards, prominent sections
  static const double xl = 20.0;

  /// Extra extra large - dialogs, bottom sheets, modals
  static const double xxl = 24.0;

  /// Triple extra large - prominent pill buttons, large chips
  static const double xxxl = 32.0;

  /// Full - pill shapes, circular buttons
  static const double full = 999.0;
}

/// Pre-built [BorderRadius] constants using [Radii] values.
///
/// Usage:
/// ```dart
/// decoration: BoxDecoration(
///   borderRadius: RadiiBR.lg,
/// ),
/// ```
class RadiiBR {
  RadiiBR._();

  static final BorderRadius xxs = BorderRadius.circular(Radii.xxs);
  static final BorderRadius xs = BorderRadius.circular(Radii.xs);
  static final BorderRadius sm = BorderRadius.circular(Radii.sm);
  static final BorderRadius md = BorderRadius.circular(Radii.md);
  static final BorderRadius lg = BorderRadius.circular(Radii.lg);
  static final BorderRadius xl = BorderRadius.circular(Radii.xl);
  static final BorderRadius xxl = BorderRadius.circular(Radii.xxl);
  static final BorderRadius xxxl = BorderRadius.circular(Radii.xxxl);
  static final BorderRadius full = BorderRadius.circular(Radii.full);
}
