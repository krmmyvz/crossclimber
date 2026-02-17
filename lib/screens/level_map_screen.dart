import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/screens/game_screen.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/theme/responsive.dart';

final statisticsRepositoryProvider = Provider((ref) => StatisticsRepository());

final statisticsProvider = FutureProvider<Statistics>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return await repository.getStatistics();
});

class LevelMapScreen extends ConsumerWidget {
  const LevelMapScreen({super.key});

  Color _getLevelColor(
    BuildContext context,
    int index,
    bool isUnlocked,
    bool isCompleted,
  ) {
    final theme = Theme.of(context);
    if (!isUnlocked) return theme.colorScheme.surfaceContainerHighest;

    if (isCompleted) {
      // Cycle through theme colors for completed levels
      final colors = [
        theme.colorScheme.primary,
        theme.colorScheme.secondary,
        theme.colorScheme.tertiary,
        theme.colorScheme.error, // Use error color as a distinct accent
      ];
      return colors[index % colors.length];
    }

    // Current unlocked but not completed level
    return theme.colorScheme.primaryContainer;
  }

  String _getDifficultyLabel(int levelId) {
    if (levelId <= 10) return '⭐';
    if (levelId <= 30) return '⭐⭐';
    if (levelId <= 60) return '⭐⭐⭐';
    return '⭐⭐⭐⭐';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final levelsAsync = ref.watch(levelsProvider(locale));
    final unlockedLevelAsync = ref.watch(unlockedLevelProvider);
    final statisticsAsync = ref.watch(statisticsProvider);
    final unlockedLevelCount = unlockedLevelAsync.value ?? 1;
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;

    return Scaffold(
      appBar: CommonAppBar(
        title: l10n.appTitle,
        type: AppBarType.standard,
        showLives: true,
      ),
      body: levelsAsync.when(
        data: (levels) {
          final statistics = statisticsAsync.value;

          return CustomScrollView(
            slivers: [
              // Progress header
              SliverToBoxAdapter(
                child: Container(
                  margin: SpacingInsets.m,
                  padding: SpacingInsets.m,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: RadiiBR.lg,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ProgressStat(
                            icon: Icons.emoji_events,
                            label: 'Levels',
                            value: '${unlockedLevelCount - 1}',
                            color: gameColors.warning,
                          ),
                          _ProgressStat(
                            icon: Icons.star,
                            label: 'Stars',
                            value:
                                '${(statistics?.threeStarLevels ?? 0) * 3 + (statistics?.twoStarLevels ?? 0) * 2 + (statistics?.oneStarLevels ?? 0)}',
                            color: gameColors.star,
                          ),
                          _ProgressStat(
                            icon: Icons.local_fire_department,
                            label: 'Streak',
                            value: '${statistics?.currentStreak ?? 0}',
                            color: gameColors.streak,
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
              ),

              // Levels grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.m,
                  0,
                  Spacing.m,
                  Spacing.m,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final level = levels[index];
                    final isUnlocked = index < unlockedLevelCount;
                    final isCompleted = index < unlockedLevelCount - 1;
                    final levelStats = statistics?.levelStats[level.id];
                    final delay = (index * 30).ms;

                    return _LevelCard(
                          level: level,
                          isUnlocked: isUnlocked,
                          isCompleted: isCompleted,
                          levelStats: levelStats,
                          color: _getLevelColor(
                            context,
                            index,
                            isUnlocked,
                            isCompleted,
                          ),
                          difficulty: _getDifficultyLabel(level.id),
                          onTap: isUnlocked
                              ? () {
                                  Navigator.push(
                                    context,
                                    AppPageRoute(
                                      builder: (context) => ProviderScope(
                                        child: GameScreen(level: level),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        )
                        .animate(delay: delay)
                        .fadeIn(duration: 300.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          curve: Curves.easeOutBack,
                        );
                  }, childCount: levels.length),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProgressStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = Responsive.isCompact(context);

    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: Responsive.getIconSize(context),
        ),
        VerticalSpacing.xxs,
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: isCompact ? 18 : null,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            fontSize: isCompact ? 10 : null,
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final dynamic level;
  final bool isUnlocked;
  final bool isCompleted;
  final LevelStats? levelStats;
  final Color color;
  final String difficulty;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.isUnlocked,
    required this.isCompleted,
    required this.levelStats,
    required this.color,
    required this.difficulty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;
    final stars = levelStats?.bestStars ?? 0;
    final isCompact = Responsive.isCompact(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiiBR.lg,
        child: Container(
          decoration: BoxDecoration(
            gradient: isUnlocked
                ? LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.8),
                      color.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: !isUnlocked
                ? theme.colorScheme.surfaceContainerHighest
                : null,
            borderRadius: RadiiBR.lg,
            border: Border.all(
              color: isUnlocked
                  ? color.withValues(alpha: 0.5)
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Level number or lock
              if (!isUnlocked)
                Icon(
                  Icons.lock,
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  size: isCompact ? 28 : 36,
                )
              else
                Hero(
                  tag: 'level_title_${level.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      '${level.id}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: isCompact ? 24 : null,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              VerticalSpacing.xxs,

              // Stars earned
              if (isCompleted && stars > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isFilled = index < stars;
                    return Icon(
                      isFilled ? Icons.star : Icons.star_border,
                      color: isFilled
                          ? gameColors.star
                          : Colors.white.withValues(alpha: 0.5),
                      size: isCompact ? 12 : 16,
                    );
                  }),
                ),
                if (levelStats?.bestScore != null &&
                    levelStats!.bestScore > 0) ...[
                  VerticalSpacing.xxs,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.xs,
                      vertical: isCompact ? 2 : Spacing.xxs + 1,
                    ),
                    decoration: BoxDecoration(
                      color: gameColors.star.withValues(alpha: 0.2),
                      borderRadius: RadiiBR.md,
                      border: Border.all(
                        color: gameColors.star.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: gameColors.star,
                          size: isCompact ? 10 : 12,
                        ),
                        HorizontalSpacing.xxs,
                        Text(
                          '${levelStats!.bestScore}',
                          style: TextStyle(
                            fontSize: isCompact ? 9 : 11,
                            fontWeight: FontWeight.bold,
                            color: gameColors.star,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else if (isCompleted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: isCompact ? 12 : 16,
                    ),
                  ],
                ),

              // Best time
              if (isCompleted && levelStats?.bestTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.xxs),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.xs + Spacing.xxs,
                      vertical: isCompact ? 2 : Spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: RadiiBR.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          size: isCompact ? 9 : 10,
                          color: Colors.white,
                        ),
                        HorizontalSpacing.xxs,
                        Text(
                          _formatTime(levelStats!.bestTime!),
                          style: TextStyle(
                            fontSize: isCompact ? 9 : 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
