import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/responsive.dart';

class PerformanceGrid extends StatelessWidget {
  final Statistics stats;

  const PerformanceGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final winRate = stats.totalGamesPlayed > 0
        ? (stats.totalGamesWon / stats.totalGamesPlayed * 100).toStringAsFixed(1)
        : '0.0';

    final avgStars = stats.totalGamesWon > 0
        ? (stats.totalStars / stats.totalGamesWon).toStringAsFixed(1)
        : '0.0';

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.show_chart,
            label: l10n.winRate,
            value: '$winRate%',
            color: theme.gameColors.success,
          ).animate().fadeIn(delay: AnimDurations.micro).slideX(begin: -0.2, end: 0),
        ),
        HorizontalSpacing.s,
        Expanded(
          child: _StatCard(
            icon: Icons.star_half,
            label: l10n.avgStars,
            value: avgStars,
            color: theme.gameColors.star,
          ).animate().fadeIn(delay: AnimDurations.micro).slideX(begin: 0.2, end: 0),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = Responsive.isCompact(context);

    return Container(
      padding: EdgeInsets.all(
        isCompact ? Spacing.s : Spacing.m + Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: SpacingInsets.s,
            decoration: BoxDecoration(
              color: color.withValues(alpha: Opacities.subtle),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: Responsive.getIconSize(context),
            ),
          ),
          VerticalSpacing.s,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: isCompact ? 20 : null,
              ),
            ),
          ),
          VerticalSpacing.xxs,
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: isCompact ? 10 : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
