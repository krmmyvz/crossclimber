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
import 'package:crossclimber/screens/statistics_screen.dart';
import 'package:crossclimber/screens/shop/shop_screen.dart';
import 'package:crossclimber/screens/game_screen.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/services/daily_reward_service.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/services/sound_service.dart';
import 'package:crossclimber/services/haptic_service.dart';

// ─── Local providers for home screen data ────────────────────────────────────

final _homeStatsProvider = FutureProvider.autoDispose<Statistics>((ref) {
  return ref.read(statisticsRepositoryProvider).getStatistics();
});

final _homeStreakProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.read(dailyRewardServiceProvider).getStreakCount();
});

final _homeCreditsProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.read(progressRepositoryProvider).getCredits();
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

  Future<void> _quickPlay() async {
    ref.read(soundServiceProvider).play(SoundEffect.tap);
    ref.read(hapticServiceProvider).trigger(HapticType.selection);

    final highestLevel = ref.read(unlockedLevelProvider).value ?? 1;
    final locale = Localizations.localeOf(context).languageCode;

    try {
      final levels = await ref.read(levelsProvider(locale).future);
      final available = levels.where((l) => l.id <= highestLevel).toList();
      if (available.isEmpty || !context.mounted) {
        _goToLevelMap();
        return;
      }
      final random = available[math.Random().nextInt(available.length)];
      if (!context.mounted) return;
      Navigator.push(
        context,
        AppPageRoute(builder: (_) => GameScreen(level: random)),
      );
    } catch (_) {
      if (context.mounted) _goToLevelMap();
    }
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
    final creditsAsync = ref.watch(_homeCreditsProvider);
    final achievementsAsync = ref.watch(_homeAchievementsProvider);
    final unlockedLevelAsync = ref.watch(unlockedLevelProvider);

    return Scaffold(
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
              onPlay: _goToLevelMap,
            ),

            // ── Quick Access 2×2 Grid ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.m,
                Spacing.l,
                Spacing.m,
                Spacing.s,
              ),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: Spacing.s,
                mainAxisSpacing: Spacing.s,
                childAspectRatio: 1.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _GridCard(
                    icon: Icons.event_rounded,
                    label: l10n.dailyChallenge,
                    color: theme.colorScheme.secondary,
                    badge: streakAsync.whenOrNull(
                      data: (v) => v > 0 ? l10n.homeStreakDays(v) : null,
                    ),
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
                    badge: achievementsAsync.whenOrNull(
                      data: (v) =>
                          l10n.homeAchievementsProgress(v.unlocked, v.total),
                    ),
                    isLoading: achievementsAsync.isLoading,
                    onTap: () => Navigator.push(
                      context,
                      FadeThroughPageRoute(
                        builder: (_) => const AchievementsScreen(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.06),
                  _GridCard(
                    icon: Icons.bar_chart_rounded,
                    label: l10n.statistics,
                    color: theme.colorScheme.tertiary,
                    badge: statsAsync.whenOrNull(
                      data: (v) => v.totalStars > 0
                          ? l10n.homeTotalStars(v.totalStars)
                          : null,
                    ),
                    isLoading: statsAsync.isLoading,
                    onTap: () => Navigator.push(
                      context,
                      FadeThroughPageRoute(
                        builder: (_) => const StatisticsScreen(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.06),
                  _GridCard(
                    icon: Icons.store_rounded,
                    label: l10n.shopTitle,
                    color: theme.colorScheme.primary,
                    badge: creditsAsync.whenOrNull(data: (v) => '💎 $v'),
                    isLoading: creditsAsync.isLoading,
                    onTap: () => Navigator.push(
                      context,
                      FadeThroughPageRoute(
                        builder: (_) => const ShopScreen(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.06),
                ],
              ),
            ),

            // ── Continue / Quick Play ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FilledButton.tonalIcon(
                      onPressed: _goToLevelMap,
                      icon:
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(
                        unlockedLevelAsync.whenOrNull(
                              data: (v) => l10n.homeContinueLevel(v),
                            ) ??
                            l10n.continueButton,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: Spacing.m),
                        shape: RoundedRectangleBorder(
                          borderRadius: RadiiBR.lg,
                        ),
                      ),
                    ),
                  ),
                  HorizontalSpacing.s,
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: _quickPlay,
                      icon: const Icon(Icons.shuffle_rounded, size: 18),
                      label: Text(l10n.homeQuickPlay),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: Spacing.m),
                        shape: RoundedRectangleBorder(
                          borderRadius: RadiiBR.lg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 250.ms),

            // ── Settings ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.m,
                Spacing.s,
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
                icon: const Icon(Icons.settings_rounded, size: 18),
                label: Text(l10n.settings),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: Spacing.s),
                  foregroundColor: theme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: RadiiBR.lg,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),
          ],
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
    final heroHeight = (screenHeight * 0.42).clamp(260.0, 400.0);

    return AnimatedBuilder(
      animation: gradientCtrl,
      builder: (context, child) {
        final t = gradientCtrl.value;
        final topColor = Color.lerp(
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
          t,
        )!;
        final midColor = Color.lerp(
          theme.colorScheme.primaryContainer,
          theme.colorScheme.secondaryContainer,
          t,
        )!;

        return Container(
          height: heroHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [
                topColor,
                midColor,
                theme.colorScheme.surface,
              ],
              stops: const [0.0, 0.55, 1.0],
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
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1),

            VerticalSpacing.xs,

            // Subtitle
            Text(
              l10n.homeSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.88),
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

            const SizedBox(height: Spacing.xl),

            // Large pulsing play button
            _PulsingPlayButton(
              theme: theme,
              l10n: l10n,
              onPressed: onPlay,
            ),
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
      icon: const Icon(Icons.play_arrow_rounded, size: 28),
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
        shadowColor: Colors.black.withValues(alpha: 0.35),
      ),
    )
        .animate(
          onPlay: (c) => c.repeat(reverse: true),
        )
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 1200.ms,
          curve: Curves.easeInOut,
        )
        .shimmer(
          duration: 2400.ms,
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        );
  }
}

// ─── Grid Card ────────────────────────────────────────────────────────────────

class _GridCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final bool isLoading;
  final VoidCallback onTap;

  const _GridCard({
    required this.icon,
    required this.label,
    required this.color,
    this.badge,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Skeleton loading state
    if (isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.5),
          borderRadius: RadiiBR.lg,
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            duration: 1200.ms,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
          );
    }

    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: RadiiBR.lg,
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiiBR.lg,
        child: Container(
          padding: const EdgeInsets.all(Spacing.m),
          decoration: BoxDecoration(
            borderRadius: RadiiBR.lg,
            border: Border.all(
              color: color.withValues(alpha: 0.25),
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
                  Icon(icon, color: color, size: 28),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(Spacing.xs),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                label,
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
    );
  }
}
