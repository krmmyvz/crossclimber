import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/game_colors.dart';

class StarDistributionCard extends StatelessWidget {
  final Statistics stats;

  const StarDistributionCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(Spacing.m + Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _StarItem(
            label: l10n.totalStarsEarned,
            value: stats.totalStars,
            color: theme.gameColors.star,
          ),
          const Divider(height: 24),
          _StarItem(
            label: l10n.perfectGames,
            value: stats.perfectGames,
            color: theme.colorScheme.tertiary,
          ),
        ],
      ),
    ).animate().fadeIn(delay: AnimDurations.normal).slideY(begin: 0.2, end: 0);
  }
}

class _StarItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StarItem({
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
          padding: const EdgeInsets.all(Spacing.s + Spacing.xxs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: Opacities.subtle),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.star, color: color, size: Spacing.iconSize),
        ),
        HorizontalSpacing.m,
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '$value',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
