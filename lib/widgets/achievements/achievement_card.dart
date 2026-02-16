import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/utils/achievement_utils.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final int index;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLocked = !achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.s + Spacing.xs),
      decoration: BoxDecoration(
        color: isLocked
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surface,
        borderRadius: RadiiBR.md,
        border: Border.all(
          color: isLocked
              ? theme.colorScheme.outline.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: isLocked
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: SpacingInsets.m,
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isLocked
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLocked
                      ? theme.colorScheme.outline
                      : theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Icon(
                AchievementUtils.getIcon(achievement.type),
                color: isLocked
                    ? theme.colorScheme.outline
                    : theme.colorScheme.primary,
                size: 28,
              ),
            ),
            HorizontalSpacing.m,

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AchievementUtils.getTitle(l10n, achievement.type),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLocked
                                ? theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  )
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isLocked)
                        Icon(
                          Icons.lock,
                          size: 18,
                          color: theme.colorScheme.outline,
                        ),
                    ],
                  ),
                  VerticalSpacing.xs,
                  Text(
                    AchievementUtils.getDescription(l10n, achievement.type),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isLocked
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!isLocked && achievement.unlockedAt != null) ...[
                    VerticalSpacing.s,
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        HorizontalSpacing.xs,
                        Text(
                          _formatDate(l10n, achievement.unlockedAt!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (achievement.progress < achievement.target) ...[
                    VerticalSpacing.s,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.progress,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${achievement.progress}/${achievement.target}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        VerticalSpacing.xs,
                        ClipRRect(
                          borderRadius: RadiiBR.xs,
                          child: LinearProgressIndicator(
                            value: achievement.progress / achievement.target,
                            minHeight: 6,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(delay: (index * 50).ms)
    .slideX(begin: 0.2);
  }

  String _formatDate(AppLocalizations l10n, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
