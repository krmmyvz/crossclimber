import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/shadows.dart';
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
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: RadiiBR.xl,
        boxShadow: [
          AppShadows.colorMedium(theme.colorScheme.primary),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.yourStatistics,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
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
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: Opacities.medium),
              ),
              _OverviewStatItem(
                value: '${stats.totalGamesWon}',
                label: l10n.gamesWon,
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: Opacities.medium),
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
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        VerticalSpacing.xxs,
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: Opacities.near),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
