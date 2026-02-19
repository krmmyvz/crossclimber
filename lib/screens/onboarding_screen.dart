import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/onboarding_provider.dart';
import 'package:crossclimber/screens/home_screen.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';

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
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
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
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const HomeScreen(),
        ),
        transitionDuration: const Duration(milliseconds: 500),
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

    return Scaffold(
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
                  duration: const Duration(milliseconds: 200),
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
                      .fadeIn(duration: 380.ms, delay: 40.ms)
                      .slideX(
                        begin: 0.08,
                        end: 0,
                        duration: 380.ms,
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
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: theme.colorScheme.primary,
                      dotColor: theme.colorScheme.outlineVariant,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
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
              color: data.iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 64, color: data.iconColor),
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
