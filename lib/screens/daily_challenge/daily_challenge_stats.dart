import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/daily_challenge_service.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';

/// Mixin for daily challenge statistics widgets
mixin DailyChallengeStats {
  Widget buildStatsCard(
    ThemeData theme,
    AppLocalizations l10n,
    DailyChallenge challenge,
  ) {
    final stats = challenge.stats;

    return Container(
      padding: const EdgeInsets.all(Spacing.l - Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: theme.colorScheme.primary),
              HorizontalSpacing.s,
              Text(
                l10n.yourStats,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          VerticalSpacing.l,
          Row(
            children: [
              Expanded(
                child: buildStatItem(
                  theme,
                  l10n.completedLabel,
                  '${stats['completed'] ?? 0}',
                  Icons.check_circle_outline,
                  theme.gameColors.success,
                ),
              ),
              Expanded(
                child: buildStatItem(
                  theme,
                  l10n.bestStreak,
                  '${stats['bestStreak'] ?? 0}',
                  Icons.local_fire_department,
                  theme.gameColors.streak,
                ),
              ),
              Expanded(
                child: buildStatItem(
                  theme,
                  l10n.totalStarsEarned,
                  '${stats['totalStars'] ?? 0}',
                  Icons.star,
                  theme.gameColors.star,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0);
  }

  Widget buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(Spacing.s + Spacing.xs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        VerticalSpacing.s,
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget buildCompletionStat(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: SpacingInsets.s,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        VerticalSpacing.xs,
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
