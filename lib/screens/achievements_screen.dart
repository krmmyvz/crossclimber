import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/widgets/skeleton_loading.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final achievementService = AchievementService();

    return Scaffold(
      appBar: CommonAppBar(
        title: l10n.achievements,
        type: AppBarType.standard,
        showCredits: false,
      ),
      body: FutureBuilder<List<Achievement>>(
        future: achievementService.getAllAchievements(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _buildLoadingSkeleton(theme);
          }

          final achievements = snapshot.data!;
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;
          final totalCount = achievements.length;

          return Column(
            children: [
              // Progress Header
              _buildProgressHeader(
                context,
                theme,
                l10n,
                unlockedCount,
                totalCount,
              ),

              // Achievements List
              Expanded(
                child: ListView.builder(
                  padding: SpacingInsets.m,
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    return _buildAchievementCard(
                          context,
                          theme,
                          l10n,
                          achievements[index],
                          index,
                        )
                        .animate()
                        .fadeIn(delay: (index * 50).ms)
                        .slideX(begin: 0.2);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    int unlocked,
    int total,
  ) {
    final percentage = (unlocked / total * 100).toInt();

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
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
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
          ClipRRect(
            borderRadius: RadiiBR.sm,
            child: LinearProgressIndicator(
              value: unlocked / total,
              minHeight: 12,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
          VerticalSpacing.s,
          Text(
            '$percentage% Complete',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    Achievement achievement,
    int index,
  ) {
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
                _getAchievementIcon(achievement.type),
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
                          _getAchievementTitle(l10n, achievement.type),
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
                    _getAchievementDescription(l10n, achievement.type),
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
    );
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.firstWin:
        return Icons.emoji_events;
      case AchievementType.tenLevels:
        return Icons.star;
      case AchievementType.speedDemon:
        return Icons.flash_on;
      case AchievementType.marathonRunner:
        return Icons.directions_run;
      case AchievementType.thirtyLevels:
        return Icons.stars;
      case AchievementType.perfectStreak5:
        return Icons.calendar_today;
      case AchievementType.hundredLevels:
        return Icons.military_tech;
      case AchievementType.hintlessHero:
        return Icons.lightbulb;
      case AchievementType.errorFree:
        return Icons.done_all;
      case AchievementType.earlyBird:
        return Icons.wb_sunny;
      case AchievementType.nightOwl:
        return Icons.nightlight;
      case AchievementType.perfectStreak10:
        return Icons.event_available;
      case AchievementType.fiftyLevels:
        return Icons.workspace_premium;
      case AchievementType.threeStarPerfectionist:
        return Icons.diamond;
      case AchievementType.noHintsMaster:
        return Icons.auto_awesome;
    }
  }

  String _getAchievementTitle(AppLocalizations l10n, AchievementType type) {
    switch (type) {
      case AchievementType.firstWin:
        return l10n.achievementFirstWin;
      case AchievementType.tenLevels:
        return l10n.achievementTenLevels;
      case AchievementType.speedDemon:
        return l10n.achievementSpeedDemon;
      case AchievementType.marathonRunner:
        return l10n.achievementMarathonRunner;
      case AchievementType.thirtyLevels:
        return l10n.achievementThirtyLevels;
      case AchievementType.perfectStreak5:
        return l10n.achievementPerfectStreak5;
      case AchievementType.hundredLevels:
        return l10n.achievementCenturyClub;
      case AchievementType.hintlessHero:
        return l10n.achievementHintlessHero;
      case AchievementType.errorFree:
        return l10n.achievementErrorFree;
      case AchievementType.earlyBird:
        return l10n.achievementEarlyBird;
      case AchievementType.nightOwl:
        return l10n.achievementNightOwl;
      case AchievementType.perfectStreak10:
        return l10n.achievementPerfectStreak10;
      case AchievementType.fiftyLevels:
        return l10n.achievementFiftyLevels;
      case AchievementType.threeStarPerfectionist:
        return l10n.achievementThreeStarPerfectionist;
      case AchievementType.noHintsMaster:
        return l10n.achievementNoHintsMaster;
    }
  }

  String _getAchievementDescription(
    AppLocalizations l10n,
    AchievementType type,
  ) {
    switch (type) {
      case AchievementType.firstWin:
        return l10n.achievementDescFirstWin;
      case AchievementType.tenLevels:
        return l10n.achievementDescTenLevels;
      case AchievementType.speedDemon:
        return l10n.achievementDescSpeedDemon;
      case AchievementType.marathonRunner:
        return l10n.achievementDescMarathonRunner;
      case AchievementType.thirtyLevels:
        return l10n.achievementDescThirtyLevels;
      case AchievementType.perfectStreak5:
        return l10n.achievementDescPerfectStreak5;
      case AchievementType.hundredLevels:
        return l10n.achievementDescCenturyClub;
      case AchievementType.hintlessHero:
        return l10n.achievementDescHintlessHero;
      case AchievementType.errorFree:
        return l10n.achievementDescErrorFree;
      case AchievementType.earlyBird:
        return l10n.achievementDescEarlyBird;
      case AchievementType.nightOwl:
        return l10n.achievementDescNightOwl;
      case AchievementType.perfectStreak10:
        return l10n.achievementDescPerfectStreak10;
      case AchievementType.fiftyLevels:
        return l10n.achievementDescFiftyLevels;
      case AchievementType.threeStarPerfectionist:
        return l10n.achievementDescThreeStarPerfectionist;
      case AchievementType.noHintsMaster:
        return l10n.achievementDescNoHintsMaster;
    }
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

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return const Column(
      children: [
        // Progress Header Skeleton
        Padding(
          padding: SpacingInsets.m,
          child: SkeletonCard(height: 120),
        ),
        // Achievements List Skeleton
        Expanded(child: SkeletonList(itemCount: 6, itemHeight: 100)),
      ],
    );
  }
}
