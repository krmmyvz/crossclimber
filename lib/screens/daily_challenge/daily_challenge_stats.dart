import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/daily_challenge_service.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/widgets/section_header.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/opacities.dart';

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
          SectionHeader.large(
            icon: Icons.bar_chart,
            title: l10n.yourStats,
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
          // Streak freeze info (D-2 fix: make freeze count visible)
          FutureBuilder<int>(
            future: DailyChallengeService().getStreakFreezeCount(),
            builder: (context, snapshot) {
              final freezeCount = snapshot.data ?? 0;
              if (freezeCount <= 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: Spacing.m),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.m,
                    vertical: Spacing.s,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.withValues(alpha: Opacities.faint),
                    borderRadius: RadiiBR.md,
                    border: Border.all(
                      color: Colors.lightBlue.withValues(alpha: Opacities.quarter),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.ac_unit, size: IconSizes.smd, color: Colors.lightBlue),
                      const SizedBox(width: Spacing.s),
                      Text(
                        l10n.streakFreezeCount(freezeCount),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.lightBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: AnimDurations.fast).slideX(begin: -0.2, end: 0);
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
            color: color.withValues(alpha: Opacities.subtle),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: IconSizes.lg),
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
          textAlign: TextAlign.center,
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
            color: color.withValues(alpha: Opacities.subtle),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: IconSizes.md, color: color),
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
