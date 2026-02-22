import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/services/share_service.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/widgets/section_header.dart';
import 'package:crossclimber/widgets/empty_state_widget.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/statistics/stats_overview_card.dart';
import 'package:crossclimber/widgets/statistics/performance_grid.dart';
import 'package:crossclimber/widgets/statistics/time_stats_card.dart';
import 'package:crossclimber/widgets/statistics/achievement_progress_card.dart';
import 'package:crossclimber/widgets/statistics/win_rate_card.dart';
import 'package:crossclimber/widgets/statistics/star_distribution_card.dart';
import 'package:crossclimber/widgets/statistics/statistics_loading_skeleton.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statisticsRepo = StatisticsRepository();
    final achievementService = AchievementService();

    final clampedTextScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
      child: Scaffold(
        appBar: CommonAppBar(
          title: l10n.statistics,
          type: AppBarType.standard,
          showCredits: false,
          additionalActions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                final stats = await statisticsRepo.getStatistics();
                ShareService.shareStatistics(
                  l10n: l10n,
                  totalGames: stats.totalGamesPlayed,
                  totalWins: stats.totalGamesWon,
                  totalStars: stats.totalStars,
                  bestTime: stats.bestTime,
                );
              },
              tooltip: l10n.shareStatistics,
            ),
          ],
        ),
        body: FutureBuilder(
          future: Future.wait([
            statisticsRepo.getStatistics(),
            achievementService.getAllAchievements(),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (!snapshot.hasData) {
              return const StatisticsLoadingSkeleton();
            }

            final stats = snapshot.data![0] as Statistics;
            final achievements = snapshot.data![1] as List<Achievement>;
            final unlockedCount = achievements
                .where((a) => a.isUnlocked)
                .length;

            // Empty state when no games played yet
            if (stats.totalGamesPlayed == 0) {
              return EmptyStateWidget(
                icon: Icons.bar_chart_outlined,
                title: l10n.emptyStatisticsTitle,
                description: l10n.emptyStatisticsDesc,
              );
            }

            return SingleChildScrollView(
              padding: SpacingInsets.m,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StatsOverviewCard(
                        stats: stats,
                        unlockedAchievements: unlockedCount,
                      )
                      .animate()
                      .fadeIn(delay: StaggerDelay.fast(0))
                      .slideY(begin: 0.05),
                  const SizedBox(height: Spacing.m + Spacing.xs),
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader.large(
                            icon: Icons.trending_up,
                            title: l10n.performance,
                          ),
                          VerticalSpacing.s,
                          PerformanceGrid(stats: stats),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: StaggerDelay.fast(1))
                      .slideY(begin: 0.05),
                  VerticalSpacing.l,
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader.large(
                            icon: Icons.timer,
                            title: l10n.timeStatistics,
                          ),
                          VerticalSpacing.s,
                          TimeStatsCard(stats: stats),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: StaggerDelay.fast(2))
                      .slideY(begin: 0.05),
                  VerticalSpacing.l,
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader.large(
                            icon: Icons.emoji_events,
                            title: l10n.achievements,
                          ),
                          VerticalSpacing.s,
                          AchievementProgressCard(
                            unlocked: unlockedCount,
                            total: achievements.length,
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: StaggerDelay.fast(3))
                      .slideY(begin: 0.05),
                  VerticalSpacing.l,
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader.large(
                            icon: Icons.pie_chart,
                            title: l10n.winRate,
                          ),
                          VerticalSpacing.s,
                          WinRateCard(stats: stats),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: StaggerDelay.fast(4))
                      .slideY(begin: 0.05),
                  VerticalSpacing.l,
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader.large(
                            icon: Icons.stars,
                            title: l10n.starDistribution,
                          ),
                          VerticalSpacing.s,
                          StarDistributionCard(stats: stats),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: StaggerDelay.fast(5))
                      .slideY(begin: 0.05),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


