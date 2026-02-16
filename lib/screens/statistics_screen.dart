import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/services/share_service.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/skeleton_loading.dart';
import 'package:crossclimber/screens/level_map_screen.dart';
import 'package:crossclimber/theme/page_transitions.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final statisticsRepo = StatisticsRepository();
    final achievementService = AchievementService();

    return Scaffold(
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
            return _buildLoadingSkeleton(theme);
          }

          final stats = snapshot.data![0] as Statistics;
          final achievements = snapshot.data![1] as List<Achievement>;
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;

          return SingleChildScrollView(
            padding: SpacingInsets.m,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Overview Card
                _buildOverviewCard(theme, l10n, stats, unlockedCount),

                const SizedBox(height: Spacing.m + Spacing.xs), // 20
                // Performance Stats
                _buildSectionTitle(theme, Icons.trending_up, l10n.performance),
                VerticalSpacing.s,
                _buildPerformanceGrid(theme, l10n, stats),

                VerticalSpacing.l,

                // Time Stats
                _buildSectionTitle(theme, Icons.timer, l10n.timeStatistics),
                VerticalSpacing.s,
                _buildTimeStatsCard(theme, l10n, stats),

                VerticalSpacing.l,

                // Achievement Progress
                _buildSectionTitle(
                  theme,
                  Icons.emoji_events,
                  l10n.achievements,
                ),
                VerticalSpacing.s,
                _buildAchievementProgressCard(
                  theme,
                  unlockedCount,
                  achievements.length,
                ),

                VerticalSpacing.l,

                // Win Rate Chart
                _buildSectionTitle(theme, Icons.pie_chart, l10n.winRate),
                VerticalSpacing.s,
                _buildWinRateCard(context, theme, l10n, stats),

                VerticalSpacing.l,

                // Star Distribution
                _buildSectionTitle(theme, Icons.stars, l10n.starDistribution),
                VerticalSpacing.s,
                _buildStarDistributionCard(theme, l10n, stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(
    ThemeData theme,
    AppLocalizations l10n,
    Statistics stats,
    int unlockedAchievements,
  ) {
    return Container(
      padding: SpacingInsets.l,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: RadiiBR.xl,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.yourStatistics,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          VerticalSpacing.l,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewStat(
                theme,
                '${stats.totalGamesPlayed}',
                l10n.gamesPlayed,
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.3),
              ),
              _buildOverviewStat(
                theme,
                '${stats.totalGamesWon}',
                l10n.gamesWon,
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.3),
              ),
              _buildOverviewStat(
                theme,
                '$unlockedAchievements',
                l10n.achievements,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildOverviewStat(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        VerticalSpacing.xxs,
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: Spacing.iconSize),
        HorizontalSpacing.s,
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceGrid(
    ThemeData theme,
    AppLocalizations l10n,
    Statistics stats,
  ) {
    final winRate = stats.totalGamesPlayed > 0
        ? (stats.totalGamesWon / stats.totalGamesPlayed * 100).toStringAsFixed(
            1,
          )
        : '0.0';

    final avgStars = stats.totalGamesWon > 0
        ? (stats.totalStars / stats.totalGamesWon).toStringAsFixed(1)
        : '0.0';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            Icons.show_chart,
            l10n.winRate,
            '$winRate%',
            theme.gameColors.success,
          ).animate().fadeIn(delay: 50.ms).slideX(begin: -0.2, end: 0),
        ),
        HorizontalSpacing.s,
        Expanded(
          child: _buildStatCard(
            theme,
            Icons.star_half,
            l10n.avgStars,
            avgStars,
            theme.gameColors.star,
          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.2, end: 0),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(Spacing.m + Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: SpacingInsets.s,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          VerticalSpacing.s,
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          VerticalSpacing.xxs,
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStatsCard(
    ThemeData theme,
    AppLocalizations l10n,
    Statistics stats,
  ) {
    return Container(
      padding: const EdgeInsets.all(Spacing.m + Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _buildTimeStatRow(
            theme,
            l10n.totalTimePlayed,
            _formatDuration(stats.totalPlayTime.inSeconds),
            Icons.hourglass_full,
          ),
          const Divider(height: 24),
          _buildTimeStatRow(
            theme,
            l10n.bestTime,
            stats.bestTime > 0 ? _formatDuration(stats.bestTime) : 'N/A',
            Icons.speed,
          ),
          const Divider(height: 24),
          _buildTimeStatRow(
            theme,
            l10n.averageTime,
            stats.totalGamesWon > 0
                ? _formatDuration(stats.averageTime.round())
                : 'N/A',
            Icons.av_timer,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildTimeStatRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: Spacing.iconSize),
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
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementProgressCard(
    ThemeData theme,
    int unlocked,
    int total,
  ) {
    final progress = total > 0 ? unlocked / total : 0.0;
    final percentage = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(Spacing.m + Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
          ClipRRect(
            borderRadius: RadiiBR.sm,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildWinRateCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    Statistics stats,
  ) {
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
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
              _buildWinLossItem(
                theme,
                l10n.wins,
                '$wins',
                theme.gameColors.success,
              ),
              _buildWinLossItem(
                theme,
                l10n.losses,
                '$losses',
                theme.gameColors.incorrect,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildWinLossItem(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
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

  Widget _buildStarDistributionCard(
    ThemeData theme,
    AppLocalizations l10n,
    Statistics stats,
  ) {
    return Container(
      padding: const EdgeInsets.all(Spacing.m + Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _buildStarItem(
            theme,
            l10n.totalStarsEarned,
            stats.totalStars,
            theme.gameColors.star,
          ),
          const Divider(height: 24),
          _buildStarItem(
            theme,
            l10n.perfectGames,
            stats.perfectGames,
            theme.colorScheme.tertiary,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStarItem(ThemeData theme, String label, int value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(Spacing.s + Spacing.xxs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
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

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return const SingleChildScrollView(
      padding: SpacingInsets.m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Overview Card
          SkeletonCard(height: 160),
          VerticalSpacing.l,
          // Performance Grid
          Row(
            children: [
              Expanded(child: SkeletonCard(height: 120)),
              HorizontalSpacing.s,
              Expanded(child: SkeletonCard(height: 120)),
            ],
          ),
          VerticalSpacing.l,
          // Time Stats
          SkeletonCard(height: 200),
          VerticalSpacing.l,
          // Achievement Progress
          SkeletonCard(height: 120),
        ],
      ),
    );
  }
}
