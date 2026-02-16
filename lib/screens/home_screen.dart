import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/screens/level_map_screen.dart';
import 'package:crossclimber/screens/settings_screen.dart';
import 'package:crossclimber/screens/achievements_screen.dart';
import 'package:crossclimber/screens/daily_challenge_screen.dart';
import 'package:crossclimber/screens/statistics_screen.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/services/sound_service.dart';
import 'package:crossclimber/services/haptic_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;

    return Scaffold(
      // Use CommonAppBar with home type - transparent, only shows credits (right)
      extendBodyBehindAppBar: true,
      appBar: const CommonAppBar(
        title: '', // No title for home screen
        type: AppBarType.home,
        showCredits: true,
        showStreak: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.appTitle,
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            VerticalSpacing.xl,

            // Play Button with Onboarding Pulse
            FutureBuilder(
              future: StatisticsRepository().getStatistics(),
              builder: (context, snapshot) {
                final hasPlayed =
                    snapshot.hasData && snapshot.data!.totalGamesPlayed > 0;

                Widget playButton = FilledButton.icon(
                  onPressed: () {
                    ref.read(soundServiceProvider).play(SoundEffect.tap);
                    ref
                        .read(hapticServiceProvider)
                        .trigger(HapticType.selection);
                    Navigator.push(
                      context,
                      AppPageRoute(
                        builder: (context) => const LevelMapScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.play),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xl,
                      vertical: Spacing.m,
                    ),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                );

                if (!hasPlayed && snapshot.hasData) {
                  return playButton
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.1, 1.1),
                        duration: 1.seconds,
                        curve: Curves.easeInOut,
                      )
                      .shimmer(
                        duration: 2.seconds,
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.3,
                        ),
                      );
                }

                return playButton;
              },
            ),

            VerticalSpacing.l,

            // Quick Access Buttons Row
            Padding(
              padding: SpacingInsets.horizontalM,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Daily Challenge Button
                  Expanded(
                    child: _QuickAccessButton(
                      icon: Icons.event,
                      label: l10n.dailyChallenge,
                      color: theme.colorScheme.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          FadeThroughPageRoute(
                            builder: (context) => const DailyChallengeScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  HorizontalSpacing.s,
                  // Achievements Button
                  Expanded(
                    child: _QuickAccessButton(
                      icon: Icons.emoji_events,
                      label: l10n.achievements,
                      color: gameColors.star,
                      onTap: () {
                        Navigator.push(
                          context,
                          FadeThroughPageRoute(
                            builder: (context) => const AchievementsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  HorizontalSpacing.s,
                  // Statistics Button
                  Expanded(
                    child: _QuickAccessButton(
                      icon: Icons.bar_chart,
                      label: l10n.statistics,
                      color: theme.colorScheme.tertiary,
                      onTap: () {
                        Navigator.push(
                          context,
                          FadeThroughPageRoute(
                            builder: (context) => const StatisticsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            VerticalSpacing.l,

            // Settings Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  FadeThroughPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              label: Text(l10n.settings),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: RadiiBR.lg,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.m,
          horizontal: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: RadiiBR.lg,
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            VerticalSpacing.xs,
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
