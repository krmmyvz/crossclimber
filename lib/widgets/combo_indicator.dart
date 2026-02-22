import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/shadows.dart';
import 'package:crossclimber/theme/spacing.dart';

/// Widget that displays the current combo count and multiplier
/// Shows animations when combo increases or breaks
class ComboIndicator extends StatelessWidget {
  final int comboCount;
  final double multiplier;
  final bool isActive; // true when combo is active (>= 2)

  const ComboIndicator({
    super.key,
    required this.comboCount,
    required this.multiplier,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (comboCount < 2) {
      return const SizedBox.shrink(); // Hide when combo < 2
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = _getComboColor(context, comboCount);
    final icon = _getComboIcon(comboCount);

    return RepaintBoundary(
      child: Semantics(
      label: l10n.semanticsComboMultiplier(
        comboCount,
        multiplier.toStringAsFixed(1),
      ),
      child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.s,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: Opacities.heavy),
                color.withValues(alpha: Opacities.strong),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: RadiiBR.xl,
            boxShadow: [
              AppShadows.colorMedium(color),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: IconSizes.lg),
              HorizontalSpacing.s,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.comboLabel(comboCount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (multiplier > 1.0)
                    Text(
                      l10n.comboMultiplierLabel(multiplier.toStringAsFixed(1)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: Opacities.near),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: AnimDurations.ultraLong, color: Colors.white.withValues(alpha: Opacities.medium))
        .animate() // Entrance animation
        .scale(
          duration: AnimDurations.normal,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          curve: AppCurves.elastic,
        )
        .fadeIn(duration: AnimDurations.fast),
    ),
    );
  }

  Color _getComboColor(BuildContext context, int combo) {
    final theme = Theme.of(context);
    if (combo >= 8) return theme.gameColors.star; // 8+ = Gold (2.5x)
    if (combo >= 5) return theme.gameColors.streak; // 5-7 = Fire (2.0x)
    if (combo >= 3) return theme.colorScheme.primary; // 3-4 = Primary (1.5x)
    return theme.colorScheme.secondary; // 2 = Secondary (1.0x)
  }

  IconData _getComboIcon(int combo) {
    if (combo >= 8) return Icons.bolt;
    if (combo >= 5) return Icons.whatshot;
    if (combo >= 3) return Icons.local_fire_department;
    return Icons.trending_up;
  }
}

/// Widget that displays combo increase animation with points
class ComboPopup extends StatelessWidget {
  final int comboCount;
  final int points;
  final double multiplier;

  const ComboPopup({
    super.key,
    required this.comboCount,
    required this.points,
    required this.multiplier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = _getComboColor(context, comboCount);

    return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.l - Spacing.xs,
            vertical: Spacing.s + Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: RadiiBR.lg,
            boxShadow: [
              AppShadows.colorStrong(color),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_circle, color: Colors.white, size: IconSizes.md),
                  HorizontalSpacing.s,
                  Text(
                    '+$points',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              VerticalSpacing.xs,
              Text(
                l10n.comboXLabel(comboCount, multiplier.toStringAsFixed(1)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: Opacities.near),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
        .animate()
        .scale(
          duration: AnimDurations.fast,
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          curve: AppCurves.elastic,
        )
        .fadeIn(duration: AnimDurations.microFast)
        .then(delay: AnimDurations.slower)
        .slideY(begin: 0, end: -1, duration: AnimDurations.normal, curve: Curves.easeInBack)
        .fadeOut(duration: AnimDurations.fast);
  }

  Color _getComboColor(BuildContext context, int combo) {
    final theme = Theme.of(context);
    if (combo >= 8) return theme.gameColors.star;
    if (combo >= 5) return theme.gameColors.streak;
    if (combo >= 3) return theme.colorScheme.primary;
    return theme.colorScheme.secondary;
  }
}

/// Widget that displays combo break animation
class ComboBreakIndicator extends StatelessWidget {
  final int lostCombo;

  const ComboBreakIndicator({super.key, required this.lostCombo});

  @override
  Widget build(BuildContext context) {
    if (lostCombo < 2) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    final gameColors = theme.gameColors;
    final l10n = AppLocalizations.of(context)!;

    return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.l - Spacing.xs,
            vertical: Spacing.s + Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: gameColors.incorrect,
            borderRadius: RadiiBR.lg,
            boxShadow: [
              AppShadows.colorStrong(gameColors.incorrect),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.close, color: Colors.white, size: IconSizes.xxl),
              VerticalSpacing.xs,
              Text(
                l10n.comboBreak,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                l10n.comboLostLabel(lostCombo),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: Opacities.near),
                ),
              ),
            ],
          ),
        )
        .animate()
        .shake(duration: AnimDurations.medium, hz: 5, rotation: 0.05)
        .fadeIn(duration: AnimDurations.microFast)
        .then(delay: AnimDurations.long)
        .fadeOut(duration: AnimDurations.normal);
  }
}

/// Compact combo counter for top bar
class ComboCounter extends StatelessWidget {
  final int comboCount;
  final double multiplier;

  const ComboCounter({
    super.key,
    required this.comboCount,
    required this.multiplier,
  });

  @override
  Widget build(BuildContext context) {
    if (comboCount < 2) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final color = _getComboColor(context, comboCount);

    return RepaintBoundary(
      child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.s + Spacing.xs,
            vertical: Spacing.xs + Spacing.xxs,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: RadiiBR.md,
            boxShadow: [
              AppShadows.colorMedium(color),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getComboIcon(comboCount), color: Colors.white, size: IconSizes.sm),
              HorizontalSpacing.xs,
              Text(
                '${comboCount}x',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (multiplier > 1.0) ...[
                HorizontalSpacing.xs,
                Text(
                  '(${multiplier.toStringAsFixed(1)}x)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: Opacities.near),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: AnimDurations.extraLong, color: Colors.white.withValues(alpha: Opacities.medium))
        .animate()
        .scale(duration: AnimDurations.fast, curve: AppCurves.elastic),
    );
  }

  Color _getComboColor(BuildContext context, int combo) {
    final theme = Theme.of(context);
    if (combo >= 8) return theme.gameColors.star;
    if (combo >= 5) return theme.gameColors.streak;
    if (combo >= 3) return theme.colorScheme.primary;
    return theme.colorScheme.secondary;
  }

  IconData _getComboIcon(int combo) {
    if (combo >= 8) return Icons.bolt;
    if (combo >= 5) return Icons.whatshot;
    if (combo >= 3) return Icons.local_fire_department;
    return Icons.trending_up;
  }
}
