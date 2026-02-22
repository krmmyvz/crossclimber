import 'package:flutter/material.dart';

import 'package:crossclimber/theme/border_radius.dart';

/// Standardized progress bar widget replacing repeated
/// `ClipRRect + LinearProgressIndicator` patterns.
///
/// ```dart
/// AppProgressBar(
///   value: 0.65,
///   color: gameColors.star,
///   height: 8,
/// )
/// ```
class AppProgressBar extends StatelessWidget {
  /// Progress value from 0.0 to 1.0.
  final double value;

  /// Bar height in logical pixels. Defaults to 8.
  final double height;

  /// Fill color. Defaults to `theme.colorScheme.primary`.
  final Color? color;

  /// Track (background) color. Defaults to `color.withValues(alpha: 0.12)`.
  final Color? backgroundColor;

  /// Corner radius. Defaults to [RadiiBR.sm].
  final BorderRadius? borderRadius;

  /// Minimum visible value — ensures a tiny sliver is visible even at 0.
  /// Set to `null` to allow fully empty bar.
  final double? minValue;

  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color,
    this.backgroundColor,
    this.borderRadius,
    this.minValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveBg =
        backgroundColor ?? effectiveColor.withValues(alpha: 0.12);
    final effectiveValue =
        minValue != null ? value.clamp(minValue!, 1.0) : value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: borderRadius ?? RadiiBR.sm,
      child: LinearProgressIndicator(
        value: effectiveValue,
        minHeight: height,
        backgroundColor: effectiveBg,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );
  }
}
