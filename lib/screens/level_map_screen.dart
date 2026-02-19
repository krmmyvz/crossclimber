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

// ─── Difficulty Zone ─────────────────────────────────────────────────────────

class _Zone {
  final String labelKey;
  final int minId;
  final int maxId;
  final Color color;
  final IconData icon;

  const _Zone({
    required this.labelKey,
    required this.minId,
    required this.maxId,
    required this.color,
    required this.icon,
  });

  bool containsLevel(int id) => id >= minId && id <= maxId;
  String label(AppLocalizations l10n) {
    switch (labelKey) {
      case 'easy':
        return l10n.easy;
      case 'medium':
        return l10n.medium;
      case 'hard':
        return l10n.hard;
      default:
        return l10n.expert;
    }
  }
}

const _zones = [
  _Zone(
    labelKey: 'easy',
    minId: 1,
    maxId: 10,
    color: Color(0xFF4CAF50),
    icon: Icons.flag_outlined,
  ),
  _Zone(
    labelKey: 'medium',
    minId: 11,
    maxId: 30,
    color: Color(0xFF2196F3),
    icon: Icons.trending_up,
  ),
  _Zone(
    labelKey: 'hard',
    minId: 31,
    maxId: 60,
    color: Color(0xFF9C27B0),
    icon: Icons.whatshot_outlined,
  ),
  _Zone(
    labelKey: 'expert',
    minId: 61,
    maxId: 9999,
    color: Color(0xFFFF5722),
    icon: Icons.workspace_premium_outlined,
  ),
];

String _getDifficultyLabel(int levelId) {
  if (levelId <= 10) return '⭐';
  if (levelId <= 30) return '⭐⭐';
  if (levelId <= 60) return '⭐⭐⭐';
  return '⭐⭐⭐⭐';
}

// ─── LevelMapScreen ───────────────────────────────────────────────────────────

class LevelMapScreen extends ConsumerWidget {
  const LevelMapScreen({super.key});

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

          // Group levels by zone
          final List<Widget> slivers = [];

          // Progress header
          slivers.add(SliverToBoxAdapter(
            child: _ProgressHeader(
              unlockedCount: unlockedLevelCount - 1,
              statistics: statistics,
              gameColors: gameColors,
              l10n: l10n,
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
          ));

          // Zone sections
          for (final zone in _zones) {
            final zoneLevels =
                levels.where((l) => zone.containsLevel(l.id)).toList();
            if (zoneLevels.isEmpty) continue;

            final completedInZone = zoneLevels
                .where((l) => l.id < unlockedLevelCount)
                .length;
            final unlockedInZone = zoneLevels
                .where((l) => l.id < unlockedLevelCount + 1)
                .length;

            // Only show zones that have at least 1 visible level
            if (unlockedInZone == 0 &&
                zoneLevels.first.id > unlockedLevelCount) {
              // Show lock header for completely locked zones
              slivers.add(SliverToBoxAdapter(
                child: _ZoneHeader(
                  zone: zone,
                  l10n: l10n,
                  completed: 0,
                  total: zoneLevels.length,
                  isLocked: true,
                ),
              ));
              continue;
            }

            // Zone header
            slivers.add(SliverToBoxAdapter(
              child: _ZoneHeader(
                zone: zone,
                l10n: l10n,
                completed: completedInZone,
                total: zoneLevels.length,
                isLocked: false,
              ),
            ));

            // Zone grid

            slivers.add(SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.m,
                0,
                Spacing.m,
                Spacing.s,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 120,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final level = zoneLevels[index];
                    final levelIndex = levels.indexOf(level);
                    final isUnlocked = levelIndex < unlockedLevelCount;
                    final isCompleted = levelIndex < unlockedLevelCount - 1;
                    final isCurrent =
                        levelIndex == unlockedLevelCount - 1 && isUnlocked;
                    final levelStats = statistics?.levelStats[level.id];
                    final delay = (index * 25).ms;

                    return _LevelCard(
                      level: level,
                      isUnlocked: isUnlocked,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                      levelStats: levelStats,
                      zone: zone,
                      difficulty: _getDifficultyLabel(level.id),
                      semanticsLabel: l10n.semanticsLevelCard(
                        level.id,
                        isCompleted
                            ? l10n.semanticsCompleted
                            : (isUnlocked
                                ? l10n.semanticsUnlocked
                                : l10n.semanticsLocked),
                        levelStats?.bestStars ?? 0,
                      ),
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
                  },
                  childCount: zoneLevels.length,
                ),
              ),
            ));
          }

          slivers.add(const SliverToBoxAdapter(child: SizedBox(height: Spacing.xxl)));

          return CustomScrollView(
            key: const PageStorageKey('level_map_scroll'),
            slivers: slivers,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

// ─── Progress Header ─────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  final int unlockedCount;
  final Statistics? statistics;
  final GameColors gameColors;
  final AppLocalizations l10n;

  const _ProgressHeader({
    required this.unlockedCount,
    required this.statistics,
    required this.gameColors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ProgressStat(
            icon: Icons.emoji_events,
            label: l10n.levelsLabel,
            value: '$unlockedCount',
            color: gameColors.warning,
          ),
          _ProgressStat(
            icon: Icons.star,
            label: l10n.starsLabel,
            value: '${(statistics?.threeStarLevels ?? 0) * 3 + (statistics?.twoStarLevels ?? 0) * 2 + (statistics?.oneStarLevels ?? 0)}',
            color: gameColors.star,
          ),
          _ProgressStat(
            icon: Icons.local_fire_department,
            label: l10n.streakLabel,
            value: '${statistics?.currentStreak ?? 0}',
            color: gameColors.streak,
          ),
        ],
      ),
    );
  }
}

// ─── Zone Header ─────────────────────────────────────────────────────────────

class _ZoneHeader extends StatelessWidget {
  final _Zone zone;
  final AppLocalizations l10n;
  final int completed;
  final int total;
  final bool isLocked;

  const _ZoneHeader({
    required this.zone,
    required this.l10n,
    required this.completed,
    required this.total,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total > 0 ? completed / total : 0.0;
    final color = isLocked
        ? theme.colorScheme.outlineVariant
        : zone.color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.m, Spacing.m, Spacing.m, Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: RadiiBR.sm,
                ),
                child: Icon(zone.icon, color: color, size: 18),
              ),
              HorizontalSpacing.s,
              Text(
                zone.label(l10n),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (isLocked) ...[
                HorizontalSpacing.xs,
                Icon(Icons.lock_outline, color: color, size: 14),
              ],
              const Spacer(),
              Text(
                l10n.zoneProgress(completed, total),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          VerticalSpacing.xs,
          ClipRRect(
            borderRadius: RadiiBR.sm,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Stat ────────────────────────────────────────────────────────────

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
        Icon(icon, color: color, size: Responsive.getIconSize(context)),
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

// ─── Level Card ───────────────────────────────────────────────────────────────

class _LevelCard extends StatefulWidget {
  final dynamic level;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isCurrent;
  final LevelStats? levelStats;
  final _Zone zone;
  final String difficulty;
  final String semanticsLabel;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.levelStats,
    required this.zone,
    required this.difficulty,
    required this.semanticsLabel,
    required this.onTap,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    if (widget.isCurrent) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_LevelCard old) {
    super.didUpdateWidget(old);
    if (widget.isCurrent && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isCurrent && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;
    final stars = widget.levelStats?.bestStars ?? 0;
    final isCompact = Responsive.isCompact(context);

    final color = widget.isUnlocked
        ? widget.zone.color
        : theme.colorScheme.surfaceContainerHighest;

    return Semantics(
      label: widget.semanticsLabel,
      button: widget.onTap != null,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          final borderWidth = widget.isCurrent
              ? 2.0 + _pulseAnim.value * 2.5
              : (widget.isUnlocked ? 1.5 : 1.0);
          final borderColor = widget.isCurrent
              ? Color.lerp(
                    widget.zone.color,
                    Colors.white,
                    _pulseAnim.value * 0.5,
                  )!
                  .withValues(alpha: 0.9)
              : (widget.isUnlocked
                    ? widget.zone.color.withValues(alpha: 0.5)
                    : theme.colorScheme.outline.withValues(alpha: 0.3));

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: RadiiBR.lg,
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.isUnlocked
                      ? LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.85),
                            color.withValues(alpha: 0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: !widget.isUnlocked
                      ? theme.colorScheme.surfaceContainerHighest
                      : null,
                  borderRadius: RadiiBR.lg,
                  border: Border.all(color: borderColor, width: borderWidth),
                  boxShadow: widget.isUnlocked
                      ? [
                          BoxShadow(
                            color: widget.isCurrent
                                ? widget.zone.color
                                      .withValues(alpha: 0.4 + _pulseAnim.value * 0.3)
                                : color.withValues(alpha: 0.2),
                            blurRadius: widget.isCurrent ? 12 : 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: ColorFiltered(
                  colorFilter: !widget.isUnlocked
                      ? const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0,      0,      0,      0.6, 0,
                        ])
                      : const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.dst,
                        ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!widget.isUnlocked)
                        Icon(
                          Icons.lock,
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                          size: isCompact ? 28 : 36,
                        )
                      else
                        Hero(
                          tag: 'level_title_${widget.level.id}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              '${widget.level.id}',
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
                      if (widget.isCompleted && stars > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final isFilled = i < stars;
                            return Icon(
                              isFilled ? Icons.star : Icons.star_border,
                              color: isFilled
                                  ? gameColors.star
                                  : Colors.white.withValues(alpha: 0.5),
                              size: isCompact ? 12 : 16,
                            );
                          }),
                        ),
                        if (widget.levelStats?.bestTime != null)
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
                                  Icon(Icons.timer, size: isCompact ? 9 : 10, color: Colors.white),
                                  HorizontalSpacing.xxs,
                                  Text(
                                    _formatTime(widget.levelStats!.bestTime!),
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
                      ] else if (widget.isCompleted)
                        Icon(
                          Icons.check_circle,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: isCompact ? 12 : 16,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
