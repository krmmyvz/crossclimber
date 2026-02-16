import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';

class StatsOverviewCard extends StatelessWidget {
  final Statistics stats;
  final int unlockedAchievements;

  const StatsOverviewCard({
    super.key,
    required this.stats,
    required this.unlockedAchievements,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: SpacingInsets.l,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: RadiiBR.xl,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.yourStatistics,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          VerticalSpacing.l,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _OverviewStatItem(
                value: '${stats.totalGamesPlayed}',
                label: l10n.gamesPlayed,
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.3),
              ),
              _OverviewStatItem(
                value: '${stats.totalGamesWon}',
                label: l10n.gamesWon,
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.3),
              ),
              _OverviewStatItem(
                value: '$unlockedAchievements',
                label: l10n.achievements,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }
}

class _OverviewStatItem extends StatelessWidget {
  final String value;
  final String label;

  const _OverviewStatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        VerticalSpacing.xxs,
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
