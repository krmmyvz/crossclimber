import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/shadows.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/app_progress_bar.dart';
import 'package:crossclimber/screens/game_screen.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/widgets/skeleton_loading.dart';
import 'package:crossclimber/widgets/ad_banner_widget.dart';
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

int _getDifficultyStars(int levelId) {
  if (levelId <= 10) return 1;
  if (levelId <= 30) return 2;
  if (levelId <= 60) return 3;
  return 4;
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

    final clampedTextScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
      child: Scaffold(
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
            slivers.add(
              SliverToBoxAdapter(
                child: _ProgressHeader(
                  unlockedCount: unlockedLevelCount - 1,
                  statistics: statistics,
                  gameColors: gameColors,
                  l10n: l10n,
                ).animate().fadeIn(duration: AnimDurations.medium).slideY(begin: -0.2),
              ),
            );

            // Zone sections
            for (final zone in _zones) {
              final zoneLevels = levels
                  .where((l) => zone.containsLevel(l.id))
                  .toList();
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
                slivers.add(
                  SliverToBoxAdapter(
                    child: _ZoneHeader(
                      zone: zone,
                      l10n: l10n,
                      completed: 0,
                      total: zoneLevels.length,
                      isLocked: true,
                    ),
                  ),
                );
                continue;
              }

              // Zone header
              slivers.add(
                SliverToBoxAdapter(
                  child: _ZoneHeader(
                    zone: zone,
                    l10n: l10n,
                    completed: completedInZone,
                    total: zoneLevels.length,
                    isLocked: false,
                  ),
                ),
              );

              // Path-based zone layout
              slivers.add(
                SliverToBoxAdapter(
                  child: _PathZoneLayout(
                    levels: zoneLevels,
                    zone: zone,
                    unlockedLevelCount: unlockedLevelCount,
                    statistics: statistics,
                    l10n: l10n,
                    allLevels: levels,
                    onLevelTap: (level) {
                      Navigator.push(
                        context,
                        AppPageRoute(
                          builder: (context) =>
                              ProviderScope(child: GameScreen(level: level)),
                        ),
                      );
                    },
                  ),
                ),
              );

              // Checkpoint / Boss divider between zones
              final zoneIndex = _zones.indexOf(zone);
              if (zoneIndex < _zones.length - 1) {
                final nextZone = _zones[zoneIndex + 1];
                final isZoneComplete = zoneLevels.every(
                  (l) => levels.indexOf(l) < unlockedLevelCount - 1,
                );
                slivers.add(
                  SliverToBoxAdapter(
                    child: _CheckpointDivider(
                      completedZone: zone,
                      nextZone: nextZone,
                      isComplete: isZoneComplete,
                      l10n: l10n,
                    ).animate().fadeIn(duration: AnimDurations.medium),
                  ),
                );
              }
            }

            // Banner ad at the bottom of the level list
            slivers.add(
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: Spacing.m),
                  child: Center(child: AdBannerWidget()),
                ),
              ),
            );

            slivers.add(
              const SliverToBoxAdapter(child: SizedBox(height: Spacing.xxl)),
            );

            return CustomScrollView(
              key: const PageStorageKey('level_map_scroll'),
              slivers: slivers,
            );
          },
          loading: () => _buildLevelMapSkeleton(),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildLevelMapSkeleton() {
    return Padding(
      padding: SpacingInsets.m,
      child: Column(
        children: [
          // Progress header skeleton
          const SkeletonCard(height: 80),
          VerticalSpacing.m,
          // Zone header skeleton
          const SkeletonCard(height: 32, width: 120),
          VerticalSpacing.s,
          // Level grid skeleton (2 columns x 3 rows)
          for (int i = 0; i < 3; i++) ...[
            const SkeletonRow(itemCount: 2, height: 88),
            VerticalSpacing.s,
          ],
          VerticalSpacing.m,
          // Another zone header
          const SkeletonCard(height: 32, width: 120),
          VerticalSpacing.s,
          for (int i = 0; i < 2; i++) ...[
            const SkeletonRow(itemCount: 2, height: 88),
            VerticalSpacing.s,
          ],
        ],
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
          AppShadows.colorMedium(theme.colorScheme.primary),
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
            value:
                '${(statistics?.threeStarLevels ?? 0) * 3 + (statistics?.twoStarLevels ?? 0) * 2 + (statistics?.oneStarLevels ?? 0)}',
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
    final color = isLocked ? theme.colorScheme.outlineVariant : zone.color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.m,
        Spacing.m,
        Spacing.m,
        Spacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: Opacities.soft),
                  borderRadius: RadiiBR.sm,
                ),
                child: Icon(zone.icon, color: color, size: IconSizes.smd),
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
                Icon(Icons.lock_outline, color: color, size: IconSizes.xsm),
              ],
              const Spacer(),
              Text(
                l10n.zoneProgress(completed, total),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: Opacities.strong),
                ),
              ),
            ],
          ),
          VerticalSpacing.xs,
          AppProgressBar(
            value: progress,
            height: 5,
            color: color,
            backgroundColor: color.withValues(alpha: Opacities.light),
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
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: Opacities.heavy),
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
  final int difficulty;
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
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: AnimDurations.slowest,
    );
    _pulseAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: AppCurves.standard));
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

  /// Shows a tooltip overlay with level statistics on long press.
  void _showStatsTooltip(BuildContext context) {
    final theme = Theme.of(context);
    final stats = widget.levelStats;
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _LevelStatsTooltip(
          position: position,
          cardSize: size,
          theme: theme,
          level: widget.level,
          stats: stats,
          difficulty: widget.difficulty,
          onDismiss: () => entry.remove(),
        );
      },
    );
    overlay.insert(entry);

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
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

    // WCAG: pick text color (white or dark) based on background luminance
    final onCardColor = widget.isUnlocked
        ? (ThemeData.estimateBrightnessForColor(color) == Brightness.light
              ? Colors.black87
              : Colors.white)
        : theme.colorScheme.onSurfaceVariant;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: AnimatedScale(
        scale: _isHovered && widget.isUnlocked ? 1.05 : 1.0,
        duration: AnimDurations.microFast,
        curve: Curves.easeOut,
        child: Semantics(
          label: widget.semanticsLabel,
          button: widget.onTap != null,
          onTapHint: widget.onTap != null
              ? AppLocalizations.of(context)!.semanticsActionPlay
              : null,
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
                    )!.withValues(alpha: Opacities.near)
                  : (widget.isUnlocked
                        ? widget.zone.color.withValues(alpha: Opacities.half)
                        : theme.colorScheme.outline.withValues(alpha: Opacities.medium));

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  onLongPress: widget.isUnlocked
                      ? () => _showStatsTooltip(context)
                      : null,
                  borderRadius: RadiiBR.lg,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: widget.isUnlocked
                          ? LinearGradient(
                              colors: [
                                color.withValues(alpha: Opacities.heavy),
                                color.withValues(alpha: Opacities.half),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: !widget.isUnlocked
                          ? theme.colorScheme.surfaceContainerHighest
                          : null,
                      borderRadius: RadiiBR.lg,
                      border: Border.all(
                        color: borderColor,
                        width: borderWidth,
                      ),
                      boxShadow: widget.isUnlocked
                          ? [
                              BoxShadow(
                                color: widget.isCurrent
                                    ? widget.zone.color.withValues(
                                        alpha: 0.4 + _pulseAnim.value * 0.3,
                                      )
                                    : color.withValues(alpha: Opacities.gentle),
                                blurRadius: widget.isCurrent ? 12 : 6,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: ColorFiltered(
                      colorFilter: !widget.isUnlocked
                          ? const ColorFilter.matrix([
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              0.6,
                              0,
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
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.5,
                              ),
                              size: isCompact ? 28 : 36,
                            )
                          else if (widget.isCurrent)
                            // Lock-break animation for the current (just unlocked) level:
                            // Lock icon shakes, splits, fades out → level number springs in
                            Hero(
                              tag: 'level_title_${widget.level.id}',
                              child: Material(
                                type: MaterialType.transparency,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Lock fragments fading out
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Left fragment — slides left + rotates
                                        ClipRect(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                widthFactor: 0.5,
                                                child: Icon(
                                                  Icons.lock,
                                                  color:
                                                      theme.colorScheme.outline,
                                                  size: isCompact ? 28 : 36,
                                                ),
                                              ),
                                            )
                                            .animate()
                                            .shake(
                                              hz: 6,
                                              duration: AnimDurations.normal,
                                            )
                                            .then()
                                            .slideX(
                                              begin: 0,
                                              end: -1,
                                              duration: AnimDurations.fast,
                                            )
                                            .rotate(
                                              begin: 0,
                                              end: -0.1,
                                              duration: AnimDurations.fast,
                                            )
                                            .fadeOut(
                                              duration: AnimDurations.fast,
                                            ),
                                        // Right fragment — slides right + rotates
                                        ClipRect(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                widthFactor: 0.5,
                                                child: Icon(
                                                  Icons.lock,
                                                  color:
                                                      theme.colorScheme.outline,
                                                  size: isCompact ? 28 : 36,
                                                ),
                                              ),
                                            )
                                            .animate()
                                            .shake(
                                              hz: 6,
                                              duration: AnimDurations.normal,
                                            )
                                            .then()
                                            .slideX(
                                              begin: 0,
                                              end: 1,
                                              duration: AnimDurations.fast,
                                            )
                                            .rotate(
                                              begin: 0,
                                              end: 0.1,
                                              duration: AnimDurations.fast,
                                            )
                                            .fadeOut(
                                              duration: AnimDurations.fast,
                                            ),
                                      ],
                                    ),
                                    // Level number springs in after lock breaks
                                    Text(
                                          '${widget.level.id}',
                                          style: theme.textTheme.headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: onCardColor,
                                                fontSize: isCompact ? 24 : null,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withValues(alpha: Opacities.medium),
                                                    offset: const Offset(0, 1),
                                                    blurRadius: 3,
                                                  ),
                                                ],
                                              ),
                                        )
                                        .animate(delay: AnimDurations.medium)
                                        .fadeIn(duration: AnimDurations.fast)
                                        .scaleXY(
                                          begin: 0.5,
                                          end: 1.0,
                                          duration: AnimDurations.normal,
                                          curve: AppCurves.spring,
                                        ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Hero(
                              tag: 'level_title_${widget.level.id}',
                              child: Material(
                                type: MaterialType.transparency,
                                child: Text(
                                  '${widget.level.id}',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: onCardColor,
                                        fontSize: isCompact ? 24 : null,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                            offset: const Offset(0, 1),
                                            blurRadius: 3,
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
                                          : onCardColor.withValues(alpha: Opacities.semi),
                                      size: isCompact ? 12 : 16,
                                    )
                                    .animate()
                                    .fadeIn(
                                      delay: StaggerDelay.fast(i),
                                      duration: AnimDurations.normal,
                                    )
                                    .scaleXY(
                                      begin: 0,
                                      end: 1,
                                      delay: StaggerDelay.fast(i),
                                      duration: AnimDurations.normal,
                                      curve: AppCurves.elastic,
                                    );
                              }),
                            ),
                            if (widget.levelStats?.bestTime != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: Spacing.xxs,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Spacing.xs + Spacing.xxs,
                                    vertical: isCompact ? 2 : Spacing.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: Opacities.medium),
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
                                        _formatTime(
                                          widget.levelStats!.bestTime!,
                                        ),
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
                              color: onCardColor.withValues(alpha: Opacities.near),
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
        ), // closes Semantics
      ), // closes AnimatedScale
    ); // closes MouseRegion
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// ─── Path Zone Layout ─────────────────────────────────────────────────────────

class _PathZoneLayout extends StatelessWidget {
  final List<Level> levels;
  final _Zone zone;
  final int unlockedLevelCount;
  final Statistics? statistics;
  final AppLocalizations l10n;
  final List<Level> allLevels;
  final void Function(Level) onLevelTap;

  const _PathZoneLayout({
    required this.levels,
    required this.zone,
    required this.unlockedLevelCount,
    required this.statistics,
    required this.l10n,
    required this.allLevels,
    required this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    final perRow = Responsive.getLevelMapColumns(context);
    final rows = <List<Level>>[];
    for (var i = 0; i < levels.length; i += perRow) {
      rows.add(levels.sublist(i, (i + perRow).clamp(0, levels.length)));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.m, 0, Spacing.m, Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _PathRow(
              rowLevels: rows[i],
              reversed: i.isOdd,
              zone: zone,
              unlockedLevelCount: unlockedLevelCount,
              statistics: statistics,
              l10n: l10n,
              allLevels: allLevels,
              onLevelTap: onLevelTap,
              slots: perRow,
            ),
            if (i < rows.length - 1)
              _PathConnector(connectorOnRight: i.isEven, color: zone.color),
          ],
        ],
      ),
    );
  }
}

// ─── Path Row ─────────────────────────────────────────────────────────────────

class _PathRow extends StatelessWidget {
  final List<Level> rowLevels;
  final bool reversed;
  final _Zone zone;
  final int unlockedLevelCount;
  final Statistics? statistics;
  final AppLocalizations l10n;
  final List<Level> allLevels;
  final void Function(Level) onLevelTap;
  final int slots;

  const _PathRow({
    required this.rowLevels,
    required this.reversed,
    required this.zone,
    required this.unlockedLevelCount,
    required this.statistics,
    required this.l10n,
    required this.allLevels,
    required this.onLevelTap,
    this.slots = 3,
  });

  @override
  Widget build(BuildContext context) {
    final displayLevels = reversed
        ? rowLevels.reversed.toList()
        : List<Level>.from(rowLevels);

    final cardHeight = Responsive.isTablet(context) ? 110.0 : 90.0;
    final rowChildren = <Widget>[];
    for (var i = 0; i < slots; i++) {
      if (i < displayLevels.length) {
        if (i > 0) rowChildren.add(_PathHorizontalLine(color: zone.color));
        rowChildren.add(
          Expanded(
            child: _buildLevelCard(context, displayLevels[i], i, cardHeight),
          ),
        );
      } else {
        if (rowChildren.isNotEmpty) {
          rowChildren.add(const _PathHorizontalLine(color: Colors.transparent));
        }
        rowChildren.add(Expanded(child: SizedBox(height: cardHeight)));
      }
    }

    return Row(children: rowChildren);
  }

  Widget _buildLevelCard(
    BuildContext context,
    Level level,
    int displayIndex,
    double cardHeight,
  ) {
    final levelIndex = allLevels.indexOf(level);
    final isUnlocked = levelIndex < unlockedLevelCount;
    final isCompleted = levelIndex < unlockedLevelCount - 1;
    final isCurrent = levelIndex == unlockedLevelCount - 1 && isUnlocked;
    final levelStats = statistics?.levelStats[level.id];
    final delay = (displayIndex * 50).ms;

    return SizedBox(
      height: cardHeight,
      child:
          _LevelCard(
                level: level,
                isUnlocked: isUnlocked,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                levelStats: levelStats,
                zone: zone,
                difficulty: _getDifficultyStars(level.id),
                semanticsLabel: l10n.semanticsLevelCard(
                  level.id,
                  isCompleted
                      ? l10n.semanticsCompleted
                      : (isUnlocked
                            ? l10n.semanticsUnlocked
                            : l10n.semanticsLocked),
                  levelStats?.bestStars ?? 0,
                ),
                onTap: isUnlocked ? () => onLevelTap(level) : null,
              )
              .animate(delay: delay)
              .fadeIn(duration: AnimDurations.normal)
              .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1.0, 1.0),
                curve: AppCurves.spring,
              ),
    );
  }
}

// ─── Path Horizontal Line (connector between cards in same row) ───────────────

class _PathHorizontalLine extends StatelessWidget {
  final Color color;
  const _PathHorizontalLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      child: Center(
        child: Container(
          height: 3,
          decoration: BoxDecoration(
            color: color.withValues(alpha: Opacities.half),
            borderRadius: RadiiBR.xxs,
          ),
        ),
      ),
    );
  }
}

// ─── Path Connector (vertical turn between rows) ──────────────────────────────

class _PathConnector extends StatelessWidget {
  final bool connectorOnRight;
  final Color color;

  const _PathConnector({required this.connectorOnRight, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: CustomPaint(
        size: Size.infinite,
        painter: _PathConnectorPainter(
          connectorOnRight: connectorOnRight,
          color: color.withValues(alpha: Opacities.half),
        ),
      ),
    );
  }
}

class _PathConnectorPainter extends CustomPainter {
  final bool connectorOnRight;
  final Color color;

  const _PathConnectorPainter({
    required this.connectorOnRight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Vertical line on the side where the row "turns"
    // Positioned at the center of the edge card (~1/6 of total width from edge)
    final edgeX = connectorOnRight
        ? size.width - (size.width / 6)
        : size.width / 6;

    final path = Path()
      ..moveTo(edgeX, 0)
      ..lineTo(edgeX, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PathConnectorPainter old) =>
      old.connectorOnRight != connectorOnRight || old.color != color;
}

// ─── Checkpoint Divider (between zones) ──────────────────────────────────────

class _CheckpointDivider extends StatelessWidget {
  final _Zone completedZone;
  final _Zone nextZone;
  final bool isComplete;
  final AppLocalizations l10n;

  const _CheckpointDivider({
    required this.completedZone,
    required this.nextZone,
    required this.isComplete,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zoneColor = isComplete
        ? completedZone.color
        : theme.colorScheme.outlineVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m,
          vertical: Spacing.s,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: RadiiBR.lg,
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Boss icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: zoneColor.withValues(alpha: Opacities.soft),
                shape: BoxShape.circle,
                border: Border.all(
                  color: zoneColor.withValues(alpha: Opacities.semi),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isComplete ? Icons.emoji_events_rounded : Icons.shield_outlined,
                color: zoneColor,
                size: IconSizes.mld,
              ),
            ),
            HorizontalSpacing.m,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isComplete
                        ? '${completedZone.label(l10n)} ${l10n.tournamentLevelCompleted}'
                        : 'Checkpoint',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: zoneColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  VerticalSpacing.xxs,
                  Text(
                    '${completedZone.label(l10n)} → ${nextZone.label(l10n)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: Opacities.strong),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            HorizontalSpacing.s,
            // Next zone badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.s,
                vertical: Spacing.xxs + 1,
              ),
              decoration: BoxDecoration(
                color: nextZone.color.withValues(alpha: Opacities.light),
                borderRadius: RadiiBR.sm,
                border: Border.all(
                  color: nextZone.color.withValues(alpha: Opacities.medium),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    nextZone.icon,
                    color: nextZone.color,
                    size: IconSizes.xsm,
                  ),
                  HorizontalSpacing.xxs,
                  Flexible(
                    child: Text(
                      nextZone.label(l10n),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: nextZone.color,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Level Stats Tooltip (long-press overlay) ─────────────────────────────────

class _LevelStatsTooltip extends StatelessWidget {
  final Offset position;
  final Size cardSize;
  final ThemeData theme;
  final dynamic level;
  final LevelStats? stats;
  final int difficulty;
  final VoidCallback onDismiss;

  const _LevelStatsTooltip({
    required this.position,
    required this.cardSize,
    required this.theme,
    required this.level,
    required this.stats,
    required this.difficulty,
    required this.onDismiss,
  });

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const tooltipWidth = 200.0;
    final tooltipLeft = (position.dx + cardSize.width / 2 - tooltipWidth / 2)
        .clamp(8.0, screenSize.width - tooltipWidth - 8);
    // Position above the card if there's room, below otherwise
    final tooltipTop = position.dy > 200
        ? position.dy - 8
        : position.dy + cardSize.height + 8;

    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: tooltipLeft,
              top: tooltipTop,
              child:
                  Container(
                        width: tooltipWidth,
                        padding: const EdgeInsets.all(Spacing.s),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: RadiiBR.md,
                          boxShadow: AppShadows.elevation3,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level ${level.id}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                difficulty,
                                (_) => Icon(
                                  Icons.star_rounded,
                                  size: IconSizes.xs,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const Divider(height: 12),
                            if (stats != null && stats!.timesPlayed > 0) ...[
                              _tooltipIconRow(
                                Icons.star_rounded,
                                '${stats!.bestStars}/3',
                              ),
                              if (stats!.bestTime != null)
                                _tooltipIconRow(
                                  Icons.timer_outlined,
                                  _formatDuration(stats!.bestTime!),
                                ),
                              _tooltipIconRow(
                                Icons.emoji_events_rounded,
                                '${stats!.bestScore}',
                              ),
                              _tooltipIconRow(
                                Icons.videogame_asset_rounded,
                                '${stats!.timesPlayed}×',
                              ),
                            ] else
                              Text(
                                'Not played yet',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: AnimDurations.fast)
                      .scaleXY(
                        begin: 0.9,
                        end: 1.0,
                        duration: AnimDurations.fast,
                        curve: AppCurves.spring,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tooltipIconRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(
            icon,
            size: IconSizes.xsm,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          HorizontalSpacing.xs,
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
