import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/onboarding_provider.dart';
import 'package:crossclimber/screens/home_screen.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/opacities.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: AnimDurations.medium,
        curve: AppCurves.standard,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            FadeTransition(opacity: animation, child: const HomeScreen()),
        transitionDuration: AnimDurations.slow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;

    final pages = [
      _OnboardingPageData(
        icon: Icons.terrain_rounded,
        iconColor: gameColors.correct,
        title: l10n.onboardingPage1Title,
        description: l10n.onboardingPage1Desc,
      ),
      _OnboardingPageData(
        icon: Icons.checklist_rounded,
        iconColor: theme.colorScheme.primary,
        title: l10n.onboardingPage2Title,
        description: l10n.onboardingPage2Desc,
      ),
      _OnboardingPageData(
        icon: Icons.calendar_today_rounded,
        iconColor: theme.colorScheme.secondary,
        title: l10n.onboardingPage3Title,
        description: l10n.onboardingPage3Desc,
      ),
      _OnboardingPageData(
        icon: Icons.local_fire_department_rounded,
        iconColor: gameColors.star,
        title: l10n.onboardingPage4Title,
        description: l10n.onboardingPage4Desc,
      ),
    ];

    final clampedTextScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ── Skip button row ───────────────────────────────────
              Padding(
                padding: SpacingInsets.m,
                child: Align(
                  alignment: Alignment.topRight,
                  child: AnimatedOpacity(
                    opacity: _currentPage < 3 ? 1.0 : 0.0,
                    duration: AnimDurations.fast,
                    child: TextButton(
                      onPressed: _currentPage < 3 ? _completeOnboarding : null,
                      child: Text(l10n.onboardingSkip),
                    ),
                  ),
                ),
              ),

              // ── Page content ──────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    return _OnboardingPage(data: pages[index])
                        .animate(key: ValueKey('page_$index'))
                        .fadeIn(duration: AnimDurations.medium, delay: 40.ms)
                        .slideX(
                          begin: 0.08,
                          end: 0,
                          duration: AnimDurations.medium,
                          delay: 40.ms,
                          curve: Curves.easeOut,
                        );
                  },
                ),
              ),

              // ── Bottom: dots + action button ─────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.l,
                  vertical: Spacing.xl,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ExpandingDotsIndicator(
                      currentPage: _currentPage,
                      count: pages.length,
                      activeDotColor: theme.colorScheme.primary,
                      dotColor: theme.colorScheme.outlineVariant,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                    AnimatedSwitcher(
                      duration: AnimDurations.normal,
                      child: _currentPage < 3
                          ? FilledButton.icon(
                              key: const ValueKey('next'),
                              onPressed: _nextPage,
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text(l10n.onboardingNext),
                            )
                          : FilledButton.icon(
                              key: const ValueKey('start'),
                              onPressed: _completeOnboarding,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(l10n.onboardingStart),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: SpacingInsets.horizontalL,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Icon circle ──────────────────────────────────────────
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.iconColor.withValues(alpha: Opacities.light),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: IconSizes.display,
              color: data.iconColor,
            ),
          ),
          VerticalSpacing.xl,

          // ── Title ────────────────────────────────────────────────
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          VerticalSpacing.m,

          // ── Description ──────────────────────────────────────────
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Custom expanding dots indicator (replaces smooth_page_indicator)
// ══════════════════════════════════════════════════════════════════════════════

class _ExpandingDotsIndicator extends StatelessWidget {
  final int currentPage;
  final int count;
  final Color activeDotColor;
  final Color dotColor;
  final double dotHeight;
  final double dotWidth;
  final double expansionFactor;

  const _ExpandingDotsIndicator({
    required this.currentPage,
    required this.count,
    required this.activeDotColor,
    required this.dotColor,
    this.dotHeight = 8,
    this.dotWidth = 8,
    this.expansionFactor = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: AnimDurations.normal,
          curve: AppCurves.standard,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? dotWidth * expansionFactor : dotWidth,
          height: dotHeight,
          decoration: BoxDecoration(
            color: isActive ? activeDotColor : dotColor,
            borderRadius: BorderRadius.circular(dotHeight / 2),
          ),
        );
      }),
    );
  }
}
