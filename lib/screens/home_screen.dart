import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/screens/level_map_screen.dart'
    hide statisticsRepositoryProvider;
import 'package:crossclimber/screens/settings_screen.dart';
import 'package:crossclimber/screens/achievements_screen.dart';
import 'package:crossclimber/screens/daily_challenge_screen.dart';
import 'package:crossclimber/screens/streak_screen.dart';
import 'package:crossclimber/screens/statistics_screen.dart';
import 'package:crossclimber/screens/shop/shop_screen.dart';
import 'package:crossclimber/screens/game_screen.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/widgets/app_progress_bar.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/services/daily_reward_service.dart';
import 'package:crossclimber/services/daily_challenge_service.dart';
import 'package:crossclimber/widgets/modern_dialog.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/providers/locale_provider.dart';
import 'package:crossclimber/services/sound_service.dart';
import 'package:crossclimber/services/haptic_service.dart';
import 'package:crossclimber/theme/responsive.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/widgets/profile_card.dart';
import 'package:crossclimber/widgets/daily_reward_calendar.dart';
import 'package:crossclimber/screens/tournament_screen.dart';
import 'package:crossclimber/services/tournament_service.dart';
import 'package:crossclimber/models/tournament.dart';

// ─── Local providers for home screen data ────────────────────────────────────

final _homeStatsProvider = FutureProvider.autoDispose<Statistics>((ref) {
  return ref.read(statisticsRepositoryProvider).getStatistics();
});

final _homeStreakProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.read(dailyRewardServiceProvider).getStreakCount();
});

typedef _AchievementProgress = ({int unlocked, int total});

final _homeAchievementsProvider =
    FutureProvider.autoDispose<_AchievementProgress>((ref) async {
      final achievements = await AchievementService().getAllAchievements();
      return (
        unlocked: achievements.where((a) => a.isUnlocked).length,
        total: achievements.length,
      );
    });

typedef _DailyChallengeStatus = ({
  int streak,
  bool completedToday,
  int freezeCount,
});

final _homeDailyChallengeStatusProvider =
    FutureProvider.autoDispose<_DailyChallengeStatus>((ref) async {
      final service = DailyChallengeService();
      final streak = await service.getCurrentStreak();
      final completed = await service.isTodayChallengeCompleted();
      final freezeCount = await service.getStreakFreezeCount();
      return (
        streak: streak,
        completedToday: completed,
        freezeCount: freezeCount,
      );
    });

final _homeQuoteProvider = Provider.autoDispose<Map<String, String>>((ref) {
  final locale = ref.watch(localeProvider).languageCode;
  final remoteConfig = ref.read(remoteConfigServiceProvider);
  return remoteConfig.getDailyQuote(locale);
});

// ─── HomeScreen ──────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gradientCtrl;

  @override
  void initState() {
    super.initState();
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    super.dispose();
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _goToLevelMap() {
    ref.read(soundServiceProvider).play(SoundEffect.tap);
    ref.read(hapticServiceProvider).trigger(HapticType.selection);
    Navigator.push(
      context,
      AppPageRoute(builder: (_) => const LevelMapScreen()),
    );
  }

  /// Navigate directly to the current (next unfinished) level game.
  Future<void> _playCurrentLevel() async {
    ref.read(soundServiceProvider).play(SoundEffect.tap);
    ref.read(hapticServiceProvider).trigger(HapticType.selection);

    final highestLevel = ref.read(unlockedLevelProvider).value ?? 1;
    final locale = Localizations.localeOf(context).languageCode;

    try {
      final levels = await ref.read(levelsProvider(locale).future);
      final currentLevel = levels.firstWhere(
        (l) => l.id == highestLevel,
        orElse: () => levels.first,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        AppPageRoute(builder: (_) => GameScreen(level: currentLevel)),
      );
    } catch (_) {
      if (mounted) _goToLevelMap();
    }
  }

  Future<void> _quickPlay() async {
    ref.read(soundServiceProvider).play(SoundEffect.tap);
    ref.read(hapticServiceProvider).trigger(HapticType.selection);

    final highestLevel = ref.read(unlockedLevelProvider).value ?? 1;
    final locale = Localizations.localeOf(context).languageCode;

    try {
      final levels = await ref.read(levelsProvider(locale).future);
      final available = levels.where((l) => l.id <= highestLevel).toList();
      if (available.isEmpty || !mounted) {
        _goToLevelMap();
        return;
      }
      final random = available[math.Random().nextInt(available.length)];
      if (!mounted) return;
      Navigator.push(
        context,
        AppPageRoute(builder: (_) => GameScreen(level: random)),
      );
    } catch (_) {
      if (mounted) _goToLevelMap();
    }
  }

  // ── Streak ───────────────────────────────────────────────────────────────

  void _goToStreakScreen() {
    ref.read(soundServiceProvider).play(SoundEffect.tap);
    ref.read(hapticServiceProvider).trigger(HapticType.selection);
    Navigator.push(
      context,
      FadeThroughPageRoute(builder: (_) => const StreakScreen()),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;
    final screenHeight = MediaQuery.of(context).size.height;

    final statsAsync = ref.watch(_homeStatsProvider);
    final streakAsync = ref.watch(_homeStreakProvider);
    final creditsAsync = ref.watch(creditsProvider);
    final achievementsAsync = ref.watch(_homeAchievementsProvider);
    final unlockedLevelAsync = ref.watch(unlockedLevelProvider);
    final dailyChallengeStatusAsync = ref.watch(
      _homeDailyChallengeStatusProvider,
    );

    // Streak milestone notification
    ref.listen<int?>(streakMilestoneProvider, (_, int? days) {
      if (days != null && context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        final credits = DailyChallengeService.kMilestoneCredits[days] ?? 0;
        ModernNotification.show(
          context: context,
          message: l10n.streakMilestoneDesc(days, credits),
          icon: Icons.local_fire_department,
          backgroundColor: const Color(0xFFFFB300),
          iconColor: Colors.white,
          duration: const Duration(seconds: 4),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(streakMilestoneProvider.notifier).clear();
        });
      }
    });

    final clampedTextScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const CommonAppBar(
          title: '',
          type: AppBarType.home,
          showCredits: true,
          showStreak: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero Banner ──────────────────────────────────────────────
              _HeroBanner(
                gradientCtrl: _gradientCtrl,
                theme: theme,
                l10n: l10n,
                screenHeight: screenHeight,
                onPlay: _playCurrentLevel,
              ),

              // ── Profile / Rank Card ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.m,
                  Spacing.m,
                  Spacing.m,
                  0,
                ),
                child: const ProfileCard()
                    .animate()
                    .fadeIn(delay: 30.ms)
                    .slideY(begin: 0.06),
              ),
              // ── Streak Status Card ──────────────────────────────────────
              dailyChallengeStatusAsync.whenOrNull(
                    data: (status) {
                      if (status.streak == 0 && status.completedToday) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.m,
                          Spacing.s,
                          Spacing.m,
                          0,
                        ),
                        child: _StreakStatusCard(
                          streak: status.streak,
                          completedToday: status.completedToday,
                          freezeCount: status.freezeCount,
                          onTap: _goToStreakScreen,
                        ).animate().fadeIn(delay: 40.ms).slideY(begin: 0.06),
                      );
                    },
                  ) ??
                  const SizedBox.shrink(),

              // ── Daily Reward Calendar ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.m,
                  Spacing.s,
                  Spacing.m,
                  0,
                ),
                child: const DailyRewardCalendar()
                    .animate()
                    .fadeIn(delay: 50.ms)
                    .slideY(begin: 0.06),
              ),
              // ── Weekly Tournament Banner ────────────────────────────────
              const _TournamentBannerWrapper(),
              // ── Quick Access 2×2 Grid ────────────────────────────────────
              FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.m,
                    Spacing.s,
                    Spacing.m,
                    Spacing.s,
                  ),
                  child: GridView.count(
                    crossAxisCount: Responsive.getHomeGridColumns(context),
                    crossAxisSpacing: Spacing.s,
                    mainAxisSpacing: Spacing.s,
                    childAspectRatio: 1.5,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _GridCard(
                        icon: Icons.event_rounded,
                        label: l10n.dailyChallenge,
                        color: theme.colorScheme.secondary,
                        badgeColor: gameColors.streak,
                        badge: streakAsync.whenOrNull(
                          data: (v) => v > 0 ? '$v' : null,
                        ),
                        badgeIcon: Icons.local_fire_department,
                        isLoading: streakAsync.isLoading,
                        onTap: () => Navigator.push(
                          context,
                          FadeThroughPageRoute(
                            builder: (_) => const DailyChallengeScreen(),
                          ),
                        ),
                      ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.06),
                      _GridCard(
                        icon: Icons.emoji_events_rounded,
                        label: l10n.achievements,
                        color: gameColors.star,
                        badgeColor: gameColors.star,
                        badge: achievementsAsync.whenOrNull(
                          data: (v) => '${v.unlocked}/${v.total}',
                        ),
                        badgeIcon: Icons.emoji_events_rounded,
                        isLoading: achievementsAsync.isLoading,
                        onTap: () => Navigator.push(
                          context,
                          FadeThroughPageRoute(
                            builder: (_) => const AchievementsScreen(),
                          ),
                        ),
                      ).animate().fadeIn(delay: AnimDurations.micro).slideY(begin: 0.06),
                      _GridCard(
                        icon: Icons.bar_chart_rounded,
                        label: l10n.statistics,
                        color: theme.colorScheme.tertiary,
                        badgeColor: theme.colorScheme.tertiary,
                        badge: statsAsync.whenOrNull(
                          data: (v) =>
                              v.totalStars > 0 ? '${v.totalStars}' : null,
                        ),
                        badgeIcon: Icons.star_rounded,
                        isLoading: statsAsync.isLoading,
                        onTap: () => Navigator.push(
                          context,
                          FadeThroughPageRoute(
                            builder: (_) => const StatisticsScreen(),
                          ),
                        ),
                      ).animate().fadeIn(delay: AnimDurations.microFast).slideY(begin: 0.06),
                      _GridCard(
                        icon: Icons.store_rounded,
                        label: l10n.shopTitle,
                        color: theme.colorScheme.primary,
                        badgeColor: theme.colorScheme.primary,
                        badge: creditsAsync.whenOrNull(data: (v) => '$v'),
                        badgeIcon: Icons.diamond_rounded,
                        isLoading: creditsAsync.isLoading,
                        onTap: () => Navigator.push(
                          context,
                          FadeThroughPageRoute(
                            builder: (_) => const ShopScreen(),
                          ),
                        ),
                      ).animate().fadeIn(delay: AnimDurations.fast).slideY(begin: 0.06),
                    ],
                  ),
                ),
              ), // FocusTraversalGroup
              // ── Levels / Quick Play ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FilledButton.tonalIcon(
                        onPressed: _goToLevelMap,
                        icon: const Icon(
                          Icons.map_rounded,
                          size: IconSizes.smd,
                        ),
                        label: Text(
                          unlockedLevelAsync.whenOrNull(
                                data: (v) => l10n.homeLevelsWithProgress(v),
                              ) ??
                              l10n.levelsLabel,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: Spacing.m,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: RadiiBR.lg,
                          ),
                        ),
                      ),
                    ),
                    HorizontalSpacing.s,
                    Expanded(
                      flex: 2,
                      child: FilledButton.tonalIcon(
                        onPressed: _quickPlay,
                        icon: const Icon(
                          Icons.shuffle_rounded,
                          size: IconSizes.smd,
                        ),
                        label: Text(l10n.homeQuickPlay),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: Spacing.m,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: RadiiBR.lg,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: AnimDurations.fastNormal),
              // ── Daily Quote ──────────────────────────────────────────────
              _QuoteCard(quote: ref.watch(_homeQuoteProvider))
                  .animate()
                  .fadeIn(delay: AnimDurations.normal)
                  .slideY(begin: 0.06, end: 0, delay: AnimDurations.normal),
              // ── Settings ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.m,
                  Spacing.m,
                  Spacing.m,
                  Spacing.xxl,
                ),
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    FadeThroughPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.settings_rounded, size: IconSizes.smd),
                  label: Text(l10n.settings),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.s),
                    foregroundColor: theme.colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: RadiiBR.lg),
                  ),
                ).animate().fadeIn(delay: AnimDurations.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero Banner ─────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final AnimationController gradientCtrl;
  final ThemeData theme;
  final AppLocalizations l10n;
  final double screenHeight;
  final VoidCallback onPlay;

  const _HeroBanner({
    required this.gradientCtrl,
    required this.theme,
    required this.l10n,
    required this.screenHeight,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = Responsive.isLandscape(context);
    final heroHeight = isLandscape
        ? (screenHeight * 0.55).clamp(180.0, 280.0)
        : (screenHeight * 0.42).clamp(260.0, 400.0);

    return AnimatedBuilder(
      animation: gradientCtrl,
      builder: (context, child) {
        final t = gradientCtrl.value;
        final topColor = Color.lerp(
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
          t,
        )!;
        // Blend primary toward surface instead of using container colors
        // so that onPrimary text stays readable across all themes.
        final midColor = Color.lerp(
          topColor,
          theme.colorScheme.surface,
          Opacities.medium,
        )!;

        return Container(
          height: heroHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topColor, midColor, theme.colorScheme.surface],
              stops: const [0.0, 0.65, 1.0],
            ),
          ),
          child: child,
        );
      },
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              l10n.appTitle,
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onPrimary,
                letterSpacing: -1.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: Opacities.quarter),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: AnimDurations.mediumSlow).slideY(begin: -0.1),

            VerticalSpacing.xs,

            // Subtitle
            Text(
              l10n.homeSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: Opacities.near),
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(duration: AnimDurations.mediumSlow, delay: AnimDurations.micro),

            const SizedBox(height: Spacing.xl),

            // Large pulsing play button
            _PulsingPlayButton(theme: theme, l10n: l10n, onPressed: onPlay),
          ],
        ),
      ),
    );
  }
}

// ─── Pulsing Play Button ──────────────────────────────────────────────────────

class _PulsingPlayButton extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onPressed;

  const _PulsingPlayButton({
    required this.theme,
    required this.l10n,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.play_arrow_rounded, size: IconSizes.xl),
          label: Text(l10n.play),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.onPrimary,
            foregroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xl + Spacing.s,
              vertical: Spacing.m,
            ),
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: Opacities.medium),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        // Shimmer BEFORE scale so the effect covers 100% of the button 
        // surface even when scaled up (Transform.scale doesn't change
        // layout bounds, so a shimmer applied after scale would be
        // calculated at 1.0x while the visual is 1.05x).
        .shimmer(
          duration: AnimDurations.ultraLong,
          color: theme.colorScheme.primary.withValues(alpha: Opacities.quarter),
        )
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: AnimDurations.slowest,
          curve: AppCurves.standard,
        );
  }
}

// ─── Grid Card ────────────────────────────────────────────────────────────────

class _GridCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? badgeColor;
  final String? badge;
  final IconData? badgeIcon;
  final bool isLoading;
  final VoidCallback onTap;

  const _GridCard({
    required this.icon,
    required this.label,
    required this.color,
    this.badgeColor,
    this.badge,
    this.badgeIcon,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  State<_GridCard> createState() => _GridCardState();
}

class _GridCardState extends State<_GridCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Skeleton loading state
    if (widget.isLoading) {
      return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: RadiiBR.lg,
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            duration: AnimDurations.slowest,
            color: theme.colorScheme.onSurface.withValues(alpha: Opacities.faintest),
          );
    }

    return Semantics(
      label: widget.badge != null
          ? '${widget.label}, ${widget.badge}'
          : widget.label,
      button: true,
      onTapHint: AppLocalizations.of(context)!.semanticsActionOpen,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: AnimDurations.micro,
            curve: AppCurves.easeOut,
            child: Material(
              color: widget.color.withValues(alpha: Opacities.faint),
              borderRadius: RadiiBR.lg,
              child: InkWell(
                onTap: widget.onTap,
                hoverColor: widget.color.withValues(alpha: Opacities.soft),
                borderRadius: RadiiBR.lg,
                child: Container(
                  padding: const EdgeInsets.all(Spacing.m),
                  decoration: BoxDecoration(
                    borderRadius: RadiiBR.lg,
                    border: Border.all(
                      color: widget.color.withValues(alpha: Opacities.quarter),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            widget.icon,
                            color: widget.color,
                            size: IconSizes.xl,
                          ),
                          if (widget.badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (widget.badgeColor ?? widget.color)
                                    .withValues(alpha: Opacities.soft),
                                borderRadius: BorderRadius.circular(Spacing.xs),
                                border: Border.all(
                                  color: (widget.badgeColor ?? widget.color)
                                      .withValues(alpha: Opacities.medium),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.badgeIcon != null) ...[
                                    Icon(
                                      widget.badgeIcon,
                                      size: IconSizes.xs,
                                      color: widget.badgeColor ?? widget.color,
                                    ),
                                    const SizedBox(width: 3),
                                  ],
                                  Text(
                                    widget.badge!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: widget.badgeColor ?? widget.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        widget.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Daily Quote Card ─────────────────────────────────────────────────────────

class _QuoteCard extends StatelessWidget {
  final Map<String, String> quote;

  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = quote['text'] ?? '';
    final author = quote['author'] ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.m,
        Spacing.s,
        Spacing.m,
        Spacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.l,
          vertical: Spacing.m,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: RadiiBR.lg,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: Opacities.medium),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.format_quote_rounded,
              color: theme.colorScheme.primary.withValues(alpha: Opacities.bold),
              size: IconSizes.xl,
            ),
            HorizontalSpacing.s,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.85,
                      ),
                      height: 1.45,
                    ),
                  ),
                  if (author.isNotEmpty) ...[
                    VerticalSpacing.xs,
                    Text(
                      '— $author',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
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
}

// ─── _TournamentBannerWrapper ─────────────────────────────────────────────────

/// Wraps _TournamentBanner. The tournament is always available via local
/// fallback, so this always shows a banner (loading state shows skeleton).
class _TournamentBannerWrapper extends ConsumerWidget {
  const _TournamentBannerWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentAsync = ref.watch(currentTournamentProvider);
    return tournamentAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (tournament) {
        return _TournamentBanner(
          tournament: tournament,
        ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.06);
      },
    );
  }
}

// ─── _TournamentBanner ───────────────────────────────────────────────────────

class _TournamentBanner extends StatelessWidget {
  final TournamentInfo tournament;
  const _TournamentBanner({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final isActive = tournament.isActive;
    final chipColor = isActive ? Colors.green : theme.colorScheme.outline;
    final chipLabel = isActive ? l10n.tournamentActive : l10n.tournamentEnded;

    final remaining = isActive
        ? tournament.remainingDuration
        : tournament.durationUntilStart;

    String timeStr = '';
    if (remaining > Duration.zero) {
      final h = remaining.inHours.toString().padLeft(2, '0');
      final m = (remaining.inMinutes % 60).toString().padLeft(2, '0');
      final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
      timeStr = '$h:$m:$s';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.m, Spacing.s, Spacing.m, 0),
      child: InkWell(
        borderRadius: RadiiBR.lg,
        onTap: () => Navigator.push(
          context,
          AppPageRoute(builder: (_) => const TournamentScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.s,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: Opacities.heavy),
                theme.colorScheme.secondaryContainer.withValues(alpha: Opacities.bold),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: RadiiBR.lg,
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: Opacities.quarter),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: IconSizes.mld,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: Spacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tournamentHomeBanner,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (timeStr.isNotEmpty)
                      Text(
                        isActive
                            ? l10n.tournamentEndsIn(timeStr)
                            : l10n.tournamentNextIn(timeStr),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.s,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: Opacities.light),
                  borderRadius: RadiiBR.xs,
                  border: Border.all(color: chipColor.withValues(alpha: Opacities.semi)),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: chipColor,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: IconSizes.smd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── _StreakStatusCard ────────────────────────────────────────────────────────

/// Shown on the home screen when the daily challenge streak is active.
/// Displays an animated flame when streak ≥ 3, a milestone progress bar,
/// and a "play today!" warning when the daily challenge is not yet complete.
class _StreakStatusCard extends StatelessWidget {
  final int streak;
  final bool completedToday;
  final int freezeCount;
  final VoidCallback onTap;

  const _StreakStatusCard({
    required this.streak,
    required this.completedToday,
    required this.freezeCount,
    required this.onTap,
  });

  /// Returns the next milestone day after [current], or null if all passed.
  static int? _nextMilestone(int current) {
    for (final m in DailyChallengeService.kMilestoneCredits.keys) {
      if (m > current) return m;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;
    final l10n = AppLocalizations.of(context)!;
    final isAtRisk = streak > 0 && !completedToday;
    final nextMilestone = _nextMilestone(streak);
    final milestoneProgress = nextMilestone != null
        ? streak / nextMilestone
        : 1.0;

    final cardColor = isAtRisk
        ? gameColors.incorrect.withValues(alpha: Opacities.light)
        : gameColors.streakContainer.withValues(alpha: Opacities.half);
    final borderColor = isAtRisk
        ? gameColors.incorrect.withValues(alpha: Opacities.semi)
        : gameColors.streak.withValues(alpha: Opacities.medium);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m,
          vertical: Spacing.s + Spacing.xxs,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: RadiiBR.lg,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Flame icon — animated when streak >= 3
            _buildFlameIcon(gameColors, isAtRisk),
            HorizontalSpacing.s,
            // Streak info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$streak',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isAtRisk
                              ? gameColors.incorrect
                              : gameColors.streak,
                        ),
                      ),
                      HorizontalSpacing.xs,
                      if (isAtRisk)
                        Text(
                          l10n.streakLossWarningTitle,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: gameColors.incorrect,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (!isAtRisk && completedToday)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: gameColors.success.withValues(alpha: Opacities.soft),
                            borderRadius: RadiiBR.sm,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: IconSizes.xsm,
                            color: gameColors.success,
                          ),
                        ),
                    ],
                  ),
                  if (isAtRisk)
                    Text(
                      l10n.streakLossWarning,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: gameColors.incorrect,
                      ),
                    ),
                  // Milestone progress bar
                  if (nextMilestone != null) ...[
                    VerticalSpacing.xxs,
                    Row(
                      children: [
                        Expanded(
                          child: AppProgressBar(
                            value: milestoneProgress,
                            height: 6,
                            color: gameColors.streak,
                            backgroundColor: theme.colorScheme.onSurface
                                .withValues(alpha: Opacities.light),
                          ),
                        ),
                        HorizontalSpacing.xs,
                        Text(
                          '→ $nextMilestone',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Freeze badge
            if (freezeCount > 0) ...[
              HorizontalSpacing.s,
              _buildFreezeBadge(context, theme),
            ],
            // Chevron
            Icon(
              Icons.chevron_right,
              size: IconSizes.smd,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlameIcon(GameColors gameColors, bool isAtRisk) {
    final icon = Icon(
      Icons.local_fire_department,
      color: isAtRisk ? gameColors.incorrect : gameColors.streak,
      size: IconSizes.xxl,
    );
    if (streak >= 3) {
      // Continuous flame effect: shimmer + scale pulse + subtle shake
      return icon
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: AnimDurations.veryLong, color: const Color(0xFFFFB300))
          .scaleXY(
            begin: 1.0,
            end: 1.12,
            duration: AnimDurations.slower,
            curve: AppCurves.standard,
          )
          .then()
          .scaleXY(
            begin: 1.12,
            end: 1.0,
            duration: AnimDurations.slower,
            curve: AppCurves.standard,
          )
          .shake(hz: 2.5, offset: const Offset(0.5, 0), duration: AnimDurations.extraLong);
    }
    return icon;
  }

  Widget _buildFreezeBadge(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.lightBlue.withValues(alpha: Opacities.soft),
        borderRadius: RadiiBR.sm,
        border: Border.all(color: Colors.lightBlue.withValues(alpha: Opacities.semi)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.ac_unit,
            size: IconSizes.xs,
            color: Colors.lightBlue,
          ),
          HorizontalSpacing.xxs,
          Text(
            '$freezeCount',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.lightBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
