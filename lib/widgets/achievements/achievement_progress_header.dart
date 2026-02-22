import 'package:flutter/material.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/shadows.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/app_progress_bar.dart';

class AchievementProgressHeader extends StatelessWidget {
  final int unlocked;
  final int total;

  const AchievementProgressHeader({
    super.key,
    required this.unlocked,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final percentage = total > 0 ? (unlocked / total * 100).toInt() : 0;

    return Container(
      margin: SpacingInsets.m,
      padding: const EdgeInsets.all(Spacing.l - Spacing.xs),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: RadiiBR.lg,
        boxShadow: [
          AppShadows.colorMedium(theme.colorScheme.primary),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.progress,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                '$unlocked/$total',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          VerticalSpacing.s,
          AppProgressBar(
            value: total > 0 ? unlocked / total : 0,
            height: 16,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          VerticalSpacing.s,
          Text(
            '$percentage% Complete',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: Opacities.heavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
