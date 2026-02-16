import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/share_service.dart';
import 'package:crossclimber/widgets/confetti_overlay.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/services/sound_service.dart';
import 'package:crossclimber/services/haptic_service.dart';

class LevelCompletionScreen extends ConsumerStatefulWidget {
  final int stars;
  final Duration timeElapsed;
  final int score;
  final int? levelId;
  final bool isNewBestTime;
  final int creditsEarned;
  final bool isLastLevel;
  final VoidCallback onNextLevel;
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;

  const LevelCompletionScreen({
    super.key,
    required this.stars,
    required this.timeElapsed,
    required this.score,
    this.levelId,
    this.isNewBestTime = false,
    this.creditsEarned = 0,
    this.isLastLevel = false,
    required this.onNextLevel,
    required this.onPlayAgain,
    required this.onMainMenu,
  });

  @override
  ConsumerState<LevelCompletionScreen> createState() =>
      _LevelCompletionScreenState();
}

class _LevelCompletionScreenState extends ConsumerState<LevelCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _creditController;
  late Animation<int> _creditAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _creditController = AnimationController(
      duration: AnimDurations.extraLong,
      vsync: this,
    );

    _creditAnimation = IntTween(begin: 0, end: widget.creditsEarned).animate(
      CurvedAnimation(parent: _creditController, curve: Curves.easeOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Start credit animation after stars appear
    Future.delayed(AnimDurations.slowest, () {
      if (mounted) {
        _creditController.forward();
        // Play confetti if 3 stars or new best time
        if (widget.stars >= 3 || widget.isNewBestTime) {
          _confettiController.play();
        }
      }
    });
  }

  @override
  void dispose() {
    _creditController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Congratulations Text
              Text(
                    widget.isLastLevel
                        ? l10n.allLevelsCompleted
                        : l10n.congratulations,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),

              VerticalSpacing.s,

              Text(
                widget.isLastLevel
                    ? l10n.allLevelsCompletedDesc(60)
                    : l10n.youWon,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ).animate(delay: 300.ms).fadeIn(),

              VerticalSpacing.xl,

              // Stars Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isFilled = index < widget.stars;
                  return Padding(
                        padding: SpacingInsets.horizontalS,
                        child: Icon(
                          isFilled ? Icons.star : Icons.star_border,
                          size: Spacing.largeIconSize,
                          color: isFilled
                              ? gameColors.star
                              : theme.colorScheme.outline,
                        ),
                      )
                      .animate(delay: (500 + index * 200).ms)
                      .scale(
                        begin: const Offset(0, 0),
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      )
                      .shimmer(
                        delay: (500 + index * 200).ms,
                        duration: 600.ms,
                        color: gameColors.star.withValues(alpha: 0.5),
                      );
                }),
              ),

              VerticalSpacing.xl,

              // Stats Card
              Card(
                margin: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                child: Padding(
                  padding: SpacingInsets.l,
                  child: Column(
                    children: [
                      _StatRow(
                        icon: Icons.timer_outlined,
                        label: l10n.timeElapsed,
                        value: _formatTime(widget.timeElapsed),
                        isHighlight: widget.isNewBestTime,
                      ),
                      if (widget.isNewBestTime)
                        Padding(
                          padding: const EdgeInsets.only(top: Spacing.xs),
                          child:
                              Text(
                                    l10n.newBestTime,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: gameColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                  .animate(
                                    onPlay: (controller) => controller.repeat(),
                                  )
                                  .shimmer(duration: 2.seconds),
                        ),
                      const Divider(height: 24),
                      _StatRow(
                        icon: Icons.stars,
                        label: l10n.stars(widget.stars),
                        value: '${widget.stars} / 3',
                      ),
                      const Divider(height: Spacing.l),
                      _StatRow(
                        icon: Icons.emoji_events,
                        label: l10n.yourScore,
                        value: widget.score.toString(),
                      ),
                      if (widget.creditsEarned > 0) ...[
                        const Divider(height: Spacing.l),
                        AnimatedBuilder(
                          animation: _creditAnimation,
                          builder: (context, child) {
                            return _StatRow(
                              icon: Icons.monetization_on,
                              label: 'Credits Earned',
                              value: '+${_creditAnimation.value}',
                              valueColor: gameColors.star,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3, end: 0),

              VerticalSpacing.xl,

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                child: Column(
                  children: [
                    // Next Level or Main Menu button (based on if it's the last level)
                    if (!widget.isLastLevel)
                      FilledButton.icon(
                        onPressed: () {
                          ref.read(soundServiceProvider).play(SoundEffect.tap);
                          ref
                              .read(hapticServiceProvider)
                              .trigger(HapticType.selection);
                          widget.onNextLevel();
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(l10n.nextLevel),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            Spacing.buttonHeight,
                          ),
                        ),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () {
                          ref.read(soundServiceProvider).play(SoundEffect.tap);
                          ref
                              .read(hapticServiceProvider)
                              .trigger(HapticType.selection);
                          widget.onMainMenu();
                        },
                        icon: const Icon(Icons.home),
                        label: Text(l10n.mainMenu),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            Spacing.buttonHeight,
                          ),
                        ),
                      ),
                    VerticalSpacing.s,
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(soundServiceProvider).play(SoundEffect.tap);
                        ref
                            .read(hapticServiceProvider)
                            .trigger(HapticType.selection);
                        widget.onPlayAgain();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.playAgain),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          Spacing.buttonHeight,
                        ),
                      ),
                    ),
                    VerticalSpacing.s,
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(soundServiceProvider).play(SoundEffect.tap);
                        ref
                            .read(hapticServiceProvider)
                            .trigger(HapticType.selection);
                        if (widget.levelId != null) {
                          ShareService.shareResult(
                            levelId: widget.levelId!,
                            stars: widget.stars,
                            time: widget.timeElapsed,
                            score: widget.score,
                          );
                        }
                      },
                      icon: const Icon(Icons.share),
                      label: Text(AppLocalizations.of(context)!.share),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          Spacing.buttonHeight,
                        ),
                      ),
                    ),
                    VerticalSpacing.s,
                    TextButton(
                      onPressed: () {
                        ref.read(soundServiceProvider).play(SoundEffect.tap);
                        ref
                            .read(hapticServiceProvider)
                            .trigger(HapticType.selection);
                        widget.onMainMenu();
                      },
                      child: Text(l10n.mainMenu),
                    ),
                  ],
                ),
              ).animate(delay: 1000.ms).fadeIn(),
            ],
          ),
        ),
        ConfettiOverlay(controller: _confettiController),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlight;
  final Color? valueColor;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;
    return Row(
      children: [
        Icon(
          icon,
          color: isHighlight ? gameColors.success : theme.colorScheme.primary,
          size: Spacing.iconSize + 4, // 28px
        ),
        HorizontalSpacing.s,
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isHighlight
                  ? gameColors.success
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            letterSpacing: -0.5,
            color:
                valueColor ??
                (isHighlight ? gameColors.success : theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
