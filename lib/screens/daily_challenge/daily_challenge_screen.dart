import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/daily_challenge_service.dart';
import 'package:crossclimber/services/level_repository.dart';
import 'package:crossclimber/screens/game_screen.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/screens/daily_challenge/daily_challenge_stats.dart';
import 'package:crossclimber/screens/daily_challenge/daily_challenge_calendar.dart';
import 'package:crossclimber/widgets/skeleton_loading.dart';

class DailyChallengeScreen extends ConsumerWidget
    with DailyChallengeStats, DailyChallengeCalendar {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dailyChallengeService = DailyChallengeService();
    final levelRepository = LevelRepository();

    return Scaffold(
      appBar: CommonAppBar(
        title: l10n.dailyChallenge,
        type: AppBarType.standard,
      ),
      body: FutureBuilder<DailyChallenge>(
        future: dailyChallengeService.getDailyChallenge(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton(theme);
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: Spacing.largeIconSize,
                    color: theme.colorScheme.error,
                  ),
                  VerticalSpacing.m,
                  Text(
                    l10n.failedToLoadDailyChallenge,
                    style: theme.textTheme.titleLarge,
                  ),
                  VerticalSpacing.s,
                  Text(
                    'Error: ${snapshot.error}',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return _buildLoadingSkeleton(theme);
          }

          final challenge = snapshot.data!;
          final isCompleted = challenge.isCompleted;
          final currentStreak = challenge.streak;

          return SingleChildScrollView(
            padding: SpacingInsets.m,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Streak Card
                _buildStreakCard(theme, l10n, currentStreak, isCompleted),

                VerticalSpacing.l,

                // Today's Challenge Card
                FutureBuilder(
                  future: levelRepository.getDailyLevelById(challenge.levelId),
                  builder: (context, levelSnapshot) {
                    if (levelSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(Spacing.xl),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (levelSnapshot.hasError) {
                      return Container(
                        padding: SpacingInsets.l,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: RadiiBR.xl,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 48,
                            ),
                            VerticalSpacing.s,
                            Text(
                              l10n.failedToLoadChallenge,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      );
                    }

                    if (!levelSnapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final level = levelSnapshot.data!;
                    return _buildChallengeCard(
                      context,
                      theme,
                      l10n,
                      challenge,
                      level,
                      isCompleted,
                    );
                  },
                ),

                VerticalSpacing.l,

                // Stats Card
                buildStatsCard(theme, l10n, challenge),

                VerticalSpacing.l,

                // Calendar View
                buildCalendarView(theme, dailyChallengeService, challenge),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakCard(
    ThemeData theme,
    AppLocalizations l10n,
    int streak,
    bool completedToday,
  ) {
    return Container(
      padding: SpacingInsets.l,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.gameColors.streak,
            theme.gameColors.streak.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: RadiiBR.xl,
        boxShadow: [
          BoxShadow(
            color: theme.gameColors.streak.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                    Icons.local_fire_department,
                    color: theme.gameColors.onStreak,
                    size: Spacing.buttonHeight,
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2.seconds, color: theme.gameColors.star)
                  .scaleXY(
                    begin: 1.0,
                    end: 1.1,
                    duration: 1.seconds,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .scaleXY(
                    begin: 1.1,
                    end: 1.0,
                    duration: 1.seconds,
                    curve: Curves.easeInOut,
                  ),
              HorizontalSpacing.m,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.currentStreak,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.gameColors.onStreak.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$streak ${streak == 1 ? 'day' : 'days'}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.gameColors.onStreak,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (completedToday) ...[
            VerticalSpacing.m,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.m,
                vertical: Spacing.s,
              ),
              decoration: BoxDecoration(
                color: theme.gameColors.onStreak.withValues(alpha: 0.2),
                borderRadius: RadiiBR.xl,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.gameColors.onStreak,
                    size: 20,
                  ),
                  HorizontalSpacing.s,
                  Text(
                    'Completed Today!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.gameColors.onStreak,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildChallengeCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    DailyChallenge challenge,
    dynamic level,
    bool isCompleted,
  ) {
    return Container(
      padding: const EdgeInsets.all(Spacing.m + Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: RadiiBR.lg,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.s + Spacing.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: RadiiBR.md,
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              HorizontalSpacing.m,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Challenge',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(l10n, challenge.date),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: SpacingInsets.s,
                  decoration: BoxDecoration(
                    color: theme.gameColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: theme.gameColors.success,
                    size: Spacing.iconSize,
                  ),
                ),
            ],
          ),
          const SizedBox(height: Spacing.m + Spacing.xs),
          Container(
            padding: SpacingInsets.m,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: RadiiBR.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    HorizontalSpacing.s,
                    Text(
                      'Level ${challenge.levelId}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                VerticalSpacing.s,
                Row(
                  children: [
                    _buildLevelInfo(
                      theme,
                      Icons.trending_up,
                      l10n.difficultyLabel,
                      _getDifficultyText(l10n, level.difficulty),
                    ),
                    const SizedBox(width: Spacing.l),
                    _buildLevelInfo(
                      theme,
                      Icons.format_list_numbered,
                      l10n.wordsLabel,
                      '${level.solution.length}',
                    ),
                  ],
                ),
                if (isCompleted && challenge.completionScore != null) ...[
                  VerticalSpacing.m,
                  Container(
                    padding: const EdgeInsets.all(Spacing.s + Spacing.xs),
                    decoration: BoxDecoration(
                      color: theme.gameColors.success.withValues(alpha: 0.1),
                      borderRadius: RadiiBR.md,
                      border: Border.all(
                        color: theme.gameColors.success.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        buildCompletionStat(
                          theme,
                          icon: Icons.stars,
                          value: '${challenge.completionStars ?? 0}',
                          label: l10n.starsLabel,
                          color: theme.gameColors.success,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        buildCompletionStat(
                          theme,
                          icon: Icons.timer,
                          value: _formatCompletionTime(
                            challenge.completionTime,
                          ),
                          label: l10n.timeLabel,
                          color: theme.gameColors.success,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        buildCompletionStat(
                          theme,
                          icon: Icons.emoji_events,
                          value: '${challenge.completionScore ?? 0}',
                          label: l10n.scoreLabel,
                          color: theme.gameColors.success,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Spacing.m + Spacing.xs),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  AppPageRoute(
                    builder: (context) => GameScreen(
                      level: level,
                      isDailyChallenge: !isCompleted,
                    ),
                  ),
                );
              },
              icon: Icon(isCompleted ? Icons.visibility : Icons.play_arrow),
              label: Text(isCompleted ? l10n.viewResult : l10n.playNow),
              style: FilledButton.styleFrom(
                padding: SpacingInsets.verticalM,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (isCompleted && challenge.completionScore != null) ...[
            VerticalSpacing.s,
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Add share functionality with completion data
              },
              icon: const Icon(Icons.share),
              label: Text(AppLocalizations.of(context)!.shareResult),
              style: OutlinedButton.styleFrom(padding: SpacingInsets.verticalM),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildLevelInfo(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        HorizontalSpacing.xs,
        Text(
          '$label: $value',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDate(AppLocalizations l10n, DateTime date) {
    final months = [
      l10n.monthJanuary,
      l10n.monthFebruary,
      l10n.monthMarch,
      l10n.monthApril,
      l10n.monthMay,
      l10n.monthJune,
      l10n.monthJuly,
      l10n.monthAugust,
      l10n.monthSeptember,
      l10n.monthOctober,
      l10n.monthNovember,
      l10n.monthDecember,
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getDifficultyText(AppLocalizations l10n, int difficulty) {
    switch (difficulty) {
      case 1:
        return l10n.easy;
      case 2:
        return l10n.medium;
      case 3:
        return l10n.hard;
      case 4:
        return l10n.expert;
      default:
        return l10n.unknown;
    }
  }

  String _formatCompletionTime(Duration? time) {
    if (time == null) return '--:--';
    final minutes = time.inMinutes;
    final seconds = time.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return const SingleChildScrollView(
      padding: SpacingInsets.m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Streak Card Skeleton
          SkeletonCard(height: 140),
          VerticalSpacing.l,
          // Today's Challenge Card Skeleton
          SkeletonCard(height: 180),
          VerticalSpacing.l,
          // Stats Card Skeleton
          SkeletonCard(height: 120),
          VerticalSpacing.l,
          // Calendar View Skeleton
          SkeletonCard(height: 300),
        ],
      ),
    );
  }
}
