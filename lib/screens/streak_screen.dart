import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/daily_challenge_service.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/shadows.dart';
import 'package:crossclimber/widgets/app_progress_bar.dart';
import 'package:crossclimber/widgets/skeleton_loading.dart';
import 'package:crossclimber/widgets/section_header.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final clampedTextScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
      child: Scaffold(
        appBar: CommonAppBar(
          title: l10n.currentStreak,
          type: AppBarType.standard,
        ),
        body: FutureBuilder<_StreakData>(
          future: _loadStreakData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingSkeleton();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(child: Text(l10n.failedToLoadDailyChallenge));
            }
            final data = snapshot.data!;
            return _StreakContent(data: data);
          },
        ),
      ),
    );
  }

  Future<_StreakData> _loadStreakData() async {
    final service = DailyChallengeService();
    final streak = await service.getCurrentStreak();
    final completedToday = await service.isTodayChallengeCompleted();
    final freezeCount = await service.getStreakFreezeCount();
    return _StreakData(
      streak: streak,
      completedToday: completedToday,
      freezeCount: freezeCount,
    );
  }
}

class _StreakData {
  final int streak;
  final bool completedToday;
  final int freezeCount;
  const _StreakData({
    required this.streak,
    required this.completedToday,
    required this.freezeCount,
  });
}

// ── Loading skeleton ─────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: SpacingInsets.m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonCard(height: 160),
          VerticalSpacing.l,
          SkeletonCard(height: 80),
          VerticalSpacing.l,
          SkeletonCard(height: 100),
          VerticalSpacing.l,
          SkeletonCard(height: 250),
        ],
      ),
    );
  }
}

// ── Content ──────────────────────────────────────────────────────────────────

class _StreakContent extends StatelessWidget {
  final _StreakData data;
  const _StreakContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;

    // Next milestone
    int? nextMilestone;
    for (final m in DailyChallengeService.kMilestoneCredits.keys) {
      if (m > data.streak) {
        nextMilestone = m;
        break;
      }
    }
    final milestoneProgress = nextMilestone != null
        ? (data.streak / nextMilestone).clamp(0.0, 1.0)
        : 1.0;

    return SingleChildScrollView(
      padding: SpacingInsets.m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Streak summary card ──────────────────────────────────────
          _buildStreakSummaryCard(theme, gameColors, l10n),

          VerticalSpacing.l,

          // ── Status card ──────────────────────────────────────────────
          _buildStatusCard(theme, gameColors, l10n),

          VerticalSpacing.l,

          // ── Milestone progress ───────────────────────────────────────
          if (nextMilestone != null) ...[
            _buildMilestoneProgressCard(
              theme,
              gameColors,
              l10n,
              nextMilestone,
              milestoneProgress,
            ),
            VerticalSpacing.l,
          ],

          // ── All milestones ───────────────────────────────────────────
          _buildMilestonesCard(theme, gameColors, l10n),

          VerticalSpacing.xl,
        ],
      ),
    );
  }

  // ── Streak summary (matches challenge card style) ──────────────────────────

  Widget _buildStreakSummaryCard(
    ThemeData theme,
    GameColors gameColors,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(Spacing.m + Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: RadiiBR.lg,
        border: Border.all(
          color: gameColors.streak.withValues(alpha: Opacities.medium),
          width: 2,
        ),
        boxShadow: [
          AppShadows.colorMedium(gameColors.streak),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon container matching challenge card style
              Container(
                padding: const EdgeInsets.all(Spacing.s + Spacing.xs),
                decoration: BoxDecoration(
                  color: gameColors.streak.withValues(alpha: Opacities.light),
                  borderRadius: RadiiBR.md,
                ),
                child:
                    Icon(
                          Icons.local_fire_department,
                          color: gameColors.streak,
                          size: IconSizes.xl,
                        )
                        .animate(onPlay: (c) => c.repeat())
                        .scaleXY(
                          begin: 1.0,
                          end: 1.1,
                          duration: 1.seconds,
                          curve: AppCurves.standard,
                        )
                        .then()
                        .scaleXY(
                          begin: 1.1,
                          end: 1.0,
                          duration: 1.seconds,
                          curve: AppCurves.standard,
                        ),
              ),
              HorizontalSpacing.m,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currentStreak,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.streakDays,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Streak count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.m,
                  vertical: Spacing.s,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gameColors.streak,
                      gameColors.streak.withValues(alpha: Opacities.heavy),
                    ],
                  ),
                  borderRadius: RadiiBR.lg,
                ),
                child: Text(
                  '${data.streak}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: gameColors.onStreak,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.m + Spacing.xs),
          // Inner info section matching challenge card inner container
          Container(
            padding: SpacingInsets.m,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: RadiiBR.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoStat(
                  theme,
                  icon: data.completedToday
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  value: data.completedToday
                      ? l10n.streakTodayCompleted
                      : l10n.streakTodayIncomplete,
                  color: data.completedToday
                      ? gameColors.success
                      : gameColors.incorrect,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.2,
                  ),
                ),
                _buildInfoStat(
                  theme,
                  icon: Icons.ac_unit_rounded,
                  value: l10n.streakFreezeCount(data.freezeCount),
                  color: Colors.lightBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildInfoStat(
    ThemeData theme, {
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(Spacing.s + Spacing.xs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: Opacities.subtle),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: IconSizes.lg),
        ),
        VerticalSpacing.s,
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Status card ────────────────────────────────────────────────────────────

  Widget _buildStatusCard(
    ThemeData theme,
    GameColors gameColors,
    AppLocalizations l10n,
  ) {
    final isAtRisk = data.streak > 0 && !data.completedToday;

    return Container(
      padding: const EdgeInsets.all(Spacing.l - Spacing.xs),
      decoration: BoxDecoration(
        color: isAtRisk
            ? gameColors.incorrect.withValues(alpha: Opacities.faint)
            : gameColors.success.withValues(alpha: Opacities.faint),
        borderRadius: RadiiBR.lg,
        border: Border.all(
          color: isAtRisk
              ? gameColors.incorrect.withValues(alpha: Opacities.medium)
              : gameColors.success.withValues(alpha: Opacities.medium),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAtRisk ? Icons.warning_amber_rounded : Icons.verified_rounded,
            color: isAtRisk ? gameColors.incorrect : gameColors.success,
            size: IconSizes.xl,
          ),
          HorizontalSpacing.m,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAtRisk
                      ? l10n.streakLossWarningTitle
                      : l10n.streakTodayCompleted,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isAtRisk ? gameColors.incorrect : gameColors.success,
                  ),
                ),
                if (isAtRisk)
                  Text(
                    l10n.streakLossWarning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: gameColors.incorrect.withValues(alpha: Opacities.heavy),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: AnimDurations.micro).fadeIn().slideX(begin: 0.2, end: 0);
  }

  // ── Milestone progress ─────────────────────────────────────────────────────

  Widget _buildMilestoneProgressCard(
    ThemeData theme,
    GameColors gameColors,
    AppLocalizations l10n,
    int nextMilestone,
    double progress,
  ) {
    final reward = DailyChallengeService.kMilestoneCredits[nextMilestone] ?? 0;

    return Container(
      padding: const EdgeInsets.all(Spacing.l - Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.flag_rounded,
            title: l10n.streakNextMilestone(nextMilestone),
            color: gameColors.streak,
          ),
          VerticalSpacing.m,
          AppProgressBar(
            value: progress,
            height: 10,
            color: gameColors.streak,
            backgroundColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.08,
            ),
          ),
          VerticalSpacing.s,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${data.streak} / $nextMilestone',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: gameColors.streak,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.diamond_rounded,
                    size: IconSizes.sm,
                    color: gameColors.star,
                  ),
                  HorizontalSpacing.xxs,
                  Text(
                    l10n.streakMilestoneReward(reward),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: AnimDurations.fast).fadeIn().slideX(begin: -0.2, end: 0);
  }

  // ── Milestones list ────────────────────────────────────────────────────────

  Widget _buildMilestonesCard(
    ThemeData theme,
    GameColors gameColors,
    AppLocalizations l10n,
  ) {
    final entries = DailyChallengeService.kMilestoneCredits.entries.toList();

    return Container(
      padding: const EdgeInsets.all(Spacing.l - Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.emoji_events_rounded,
            title: l10n.streakMilestones,
            color: gameColors.star,
          ),
          VerticalSpacing.m,
          ...entries.map((e) {
            final reached = data.streak >= e.key;
            final isCurrent =
                !reached &&
                (entries.indexOf(e) == 0 ||
                    data.streak >= entries[entries.indexOf(e) - 1].key);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.m,
                  vertical: Spacing.s,
                ),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? gameColors.streak.withValues(alpha: Opacities.faint)
                      : reached
                      ? gameColors.success.withValues(alpha: Opacities.faint)
                      : Colors.transparent,
                  borderRadius: RadiiBR.md,
                  border: isCurrent
                      ? Border.all(
                          color: gameColors.streak.withValues(alpha: Opacities.medium),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      reached
                          ? Icons.check_circle_rounded
                          : isCurrent
                          ? Icons.local_fire_department_rounded
                          : Icons.circle_outlined,
                      size: IconSizes.mld,
                      color: reached
                          ? gameColors.success
                          : isCurrent
                          ? gameColors.streak
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.25,
                            ),
                    ),
                    HorizontalSpacing.m,
                    Expanded(
                      child: Text(
                        '${e.key} ${l10n.streakDays}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: reached || isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: reached || isCurrent
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.diamond_rounded,
                          size: IconSizes.sm,
                          color: reached
                              ? gameColors.star
                              : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.4,
                                ),
                        ),
                        HorizontalSpacing.xxs,
                        Text(
                          '+${e.value}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: reached
                                ? gameColors.star
                                : theme.colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.4,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ).animate(delay: AnimDurations.normal).fadeIn().slideX(begin: 0.2, end: 0);
  }
}
