import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/app_progress_bar.dart';

class AchievementProgressCard extends StatelessWidget {
  final int unlocked;
  final int total;

  const AchievementProgressCard({
    super.key,
    required this.unlocked,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total > 0 ? unlocked / total : 0.0;
    final percentage = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(Spacing.m + Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: Opacities.medium),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$unlocked / $total Unlocked',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$percentage%',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          VerticalSpacing.m,
          AppProgressBar(
            value: progress,
            height: 16,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    ).animate().fadeIn(delay: AnimDurations.fast).slideX(begin: 0.2, end: 0);
  }
}
