import 'package:flutter/material.dart';

import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/shadows.dart';
import 'package:crossclimber/theme/spacing.dart';

/// Standardized hero/showcase card with gradient background.
///
/// Used across screens for prominent summary sections — stats overview,
/// progress headers, tournament headers, etc.
///
/// ```dart
/// HeroCard(
///   child: Row(
///     children: [
///       Text('42', style: theme.textTheme.headlineMedium),
///       Text('Games Won'),
///     ],
///   ),
/// )
/// ```
class HeroCard extends StatelessWidget {
  /// Card content.
  final Widget child;

  /// Gradient colors. Defaults to
  /// `[primaryContainer, secondaryContainer]`.
  final List<Color>? gradientColors;

  /// Gradient begin alignment. Defaults to [Alignment.topLeft].
  final Alignment gradientBegin;

  /// Gradient end alignment. Defaults to [Alignment.bottomRight].
  final Alignment gradientEnd;

  /// Corner radius. Defaults to [RadiiBR.lg].
  final BorderRadius? borderRadius;

  /// Box shadow. Defaults to colored medium shadow based on primary.
  /// Pass `AppShadows.none` to disable.
  final List<BoxShadow>? boxShadow;

  /// Optional border. If provided, replaces boxShadow.
  final Border? border;

  /// Internal padding. Defaults to [SpacingInsets.m].
  final EdgeInsets padding;

  /// External margin. Defaults to [SpacingInsets.m].
  final EdgeInsets margin;

  const HeroCard({
    super.key,
    required this.child,
    this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.padding = SpacingInsets.m,
    this.margin = SpacingInsets.m,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors ??
        [
          theme.colorScheme.primaryContainer,
          theme.colorScheme.secondaryContainer,
        ];
    final effectiveShadow = boxShadow ??
        (border != null
            ? AppShadows.none
            : [AppShadows.colorMedium(theme.colorScheme.primary)]);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: gradientBegin,
          end: gradientEnd,
        ),
        borderRadius: borderRadius ?? RadiiBR.lg,
        border: border,
        boxShadow: effectiveShadow,
      ),
      child: child,
    );
  }
}
