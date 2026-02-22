import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';

/// A consistent, animated empty-state illustration widget.
///
/// Usage:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.emoji_events_outlined,
///   title: l10n.emptyAchievementsTitle,
///   description: l10n.emptyAchievementsDesc,
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: SpacingInsets.xl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon circle ──────────────────────────────────────────
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: IconSizes.hero,
                color: theme.colorScheme.onSurface.withValues(alpha: Opacities.medium),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: AnimDurations.slow,
                  curve: AppCurves.spring,
                )
                .fadeIn(duration: AnimDurations.normalSlow),

            VerticalSpacing.l,

            // ── Title ────────────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            )
                .animate(delay: AnimDurations.micro)
                .fadeIn(duration: AnimDurations.normalSlow)
                .slideY(begin: 0.15, end: 0, duration: AnimDurations.normalSlow),

            VerticalSpacing.s,

            // ── Description ──────────────────────────────────────────
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: Opacities.strong),
                height: 1.5,
              ),
            )
                .animate(delay: AnimDurations.microFast)
                .fadeIn(duration: AnimDurations.normalSlow)
                .slideY(begin: 0.15, end: 0, duration: AnimDurations.normalSlow),

            if (action != null) ...[
              VerticalSpacing.l,
              action!
                  .animate(delay: AnimDurations.fast)
                  .fadeIn(duration: AnimDurations.normalSlow)
                  .slideY(begin: 0.15, end: 0, duration: AnimDurations.normalSlow),
            ],
          ],
        ),
      ),
    );
  }
}
