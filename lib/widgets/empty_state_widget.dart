import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: 450.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 350.ms),

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
                .animate(delay: 80.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.15, end: 0, duration: 350.ms),

            VerticalSpacing.s,

            // ── Description ──────────────────────────────────────────
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            )
                .animate(delay: 140.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.15, end: 0, duration: 350.ms),

            if (action != null) ...[
              VerticalSpacing.l,
              action!
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.15, end: 0, duration: 350.ms),
            ],
          ],
        ),
      ),
    );
  }
}
