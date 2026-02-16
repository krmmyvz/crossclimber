import 'package:flutter/animation.dart';

/// Standardized animation duration tokens for consistent motion design.
///
/// Based on Material Design motion guidelines:
/// - Micro: instant feedback (key presses, toggles)
/// - Fast: small UI elements (fade-in, highlights)
/// - Normal: standard transitions (cards, dialogs)
/// - Slow: large/complex animations (page transitions)
/// - Slower: emphasis animations (celebrations, onboarding)
abstract final class AnimDurations {
  /// 100ms — micro interactions (key press feedback, toggle state)
  static const Duration micro = Duration(milliseconds: 100);

  /// 200ms — fast transitions (fade-in, small slides)
  static const Duration fast = Duration(milliseconds: 200);

  /// 300ms — standard/normal transitions (dialogs, cards)
  static const Duration normal = Duration(milliseconds: 300);

  /// 400ms — medium transitions (panel reveals, page elements)
  static const Duration medium = Duration(milliseconds: 400);

  /// 500ms — slow transitions (complex transitions, stagger base)
  static const Duration slow = Duration(milliseconds: 500);

  /// 800ms — slower transitions (emphasis, celebrations)
  static const Duration slower = Duration(milliseconds: 800);

  /// 1200ms — slowest visible animations (star reveals, score count-up)
  static const Duration slowest = Duration(milliseconds: 1200);

  /// 1500ms — extra long (completion sequences, auto-dismiss delays)
  static const Duration extraLong = Duration(milliseconds: 1500);
}

/// Standardized animation curve tokens.
abstract final class AppCurves {
  /// Default ease-out for most UI transitions
  static const Curve easeOut = Curves.easeOutCubic;

  /// Elastic bounce for celebratory/attention elements
  static const Curve elastic = Curves.elasticOut;

  /// Standard ease-in-out for bidirectional animations
  static const Curve standard = Curves.easeInOut;

  /// Decelerate for elements entering the screen
  static const Curve decelerate = Curves.decelerate;

  /// Fast out, slow in — for elements leaving then re-entering
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
}

/// Stagger delay helpers for list/grid item animations.
abstract final class StaggerDelay {
  /// 50ms per item — fast stagger for short lists
  static Duration fast(int index) => Duration(milliseconds: index * 50);

  /// 100ms per item — standard stagger
  static Duration normal(int index) => Duration(milliseconds: index * 100);

  /// 200ms per item — slow stagger for emphasis
  static Duration slow(int index) => Duration(milliseconds: index * 200);
}
