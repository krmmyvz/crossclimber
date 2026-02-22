import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/screens/level_map_screen.dart';

class WinRateCard extends StatelessWidget {
  final Statistics stats;

  const WinRateCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final wins = stats.totalGamesWon;
    final losses = stats.totalGamesPlayed - stats.totalGamesWon;
    final total = stats.totalGamesPlayed;

    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(Spacing.xl + Spacing.xs),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: RadiiBR.lg,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: IconSizes.display,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: Opacities.half),
            ),
            VerticalSpacing.m,
            Text(
              l10n.noGamesPlayedYet,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            VerticalSpacing.l,
            FilledButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  AppPageRoute(builder: (context) => const LevelMapScreen()),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.play),
            ),
          ],
        ),
      );
    }

    final winPercentage = (wins / total);
    final lossPercentage = (losses / total);

    return Container(
      padding: const EdgeInsets.all(Spacing.m + Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          // Win/Loss Bar
          ClipRRect(
            borderRadius: RadiiBR.sm,
            child: Row(
              children: [
                if (winPercentage > 0)
                  Expanded(
                    flex: (winPercentage * 100).round(),
                    child: Container(
                      height: 40,
                      color: theme.gameColors.success,
                      child: Center(
                        child: Text(
                          '${(winPercentage * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.gameColors.onSuccess,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (lossPercentage > 0)
                  Expanded(
                    flex: (lossPercentage * 100).round(),
                    child: Container(
                      height: 40,
                      color: theme.gameColors.incorrect,
                      child: Center(
                        child: Text(
                          '${(lossPercentage * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.gameColors.onIncorrect,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          VerticalSpacing.m,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WinLossItem(
                label: l10n.wins,
                value: '$wins',
                color: theme.gameColors.success,
              ),
              _WinLossItem(
                label: l10n.losses,
                value: '$losses',
                color: theme.gameColors.incorrect,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: AnimDurations.fastNormal).slideY(begin: 0.2, end: 0);
  }
}

class _WinLossItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _WinLossItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        HorizontalSpacing.xs,
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        HorizontalSpacing.xs,
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
