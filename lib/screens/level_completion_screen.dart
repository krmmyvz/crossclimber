import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/services/daily_challenge_service.dart';
import 'package:crossclimber/services/share_service.dart';
import 'package:crossclimber/services/xp_service.dart';
import 'package:crossclimber/utils/achievement_utils.dart';
import 'package:crossclimber/widgets/confetti_overlay.dart';
import 'package:crossclimber/widgets/app_progress_bar.dart';
import 'package:crossclimber/widgets/modern_dialog.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/shadows.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/services/sound_service.dart';
import 'package:crossclimber/services/haptic_service.dart';
import 'package:crossclimber/services/ad_service.dart';

class LevelCompletionScreen extends ConsumerStatefulWidget {
  final int stars;
  final Duration timeElapsed;
  final int score;
  final int? levelId;
  final bool isNewBestTime;
  final int creditsEarned;
  final bool isLastLevel;
  final int maxCombo;
  final Level? nextLevelPreloaded;
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
    this.maxCombo = 0,
    this.nextLevelPreloaded,
    required this.onNextLevel,
    required this.onPlayAgain,
    required this.onMainMenu,
  });

  @override
  ConsumerState<LevelCompletionScreen> createState() =>
      _LevelCompletionScreenState();
}

class _LevelCompletionScreenState extends ConsumerState<LevelCompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _creditController;
  late Animation<int> _creditAnimation;
  late ConfettiController _confettiController;

  // XP / Rank state
  late AnimationController _xpBarController;
  late Animation<double> _xpBarAnimation;
  int _xpGained = 0;
  RankInfo? _rankInfo;
  RankInfo? _prevRankInfo;
  bool _rewardsDoubled = false;

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

    _xpBarController = AnimationController(
      duration: AnimDurations.slowest,
      vsync: this,
    );
    _xpBarAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _xpBarController, curve: AppCurves.easeOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Award XP and load rank info
    if (widget.levelId != null && widget.stars > 0) {
      _awardXp();
    }

    // Start credit animation after stars appear
    Future.delayed(AnimDurations.slowest, () {
      if (mounted) {
        _creditController.forward();
        // Always play confetti; intensity is naturally higher for 3 stars
        _confettiController.play();
      }
    });
  }

  Future<void> _awardXp() async {
    final xpService = ref.read(xpServiceProvider);
    final gained = XpService.xpForCompletion(
      stars: widget.stars,
      levelId: widget.levelId!,
      maxCombo: widget.maxCombo,
    );
    final prevXp = await xpService.getXp();
    final newXp = await xpService.addXp(gained);
    if (!mounted) return;

    final prevRankInfo = XpService.computeRankInfo(
      totalXp: prevXp,
      gainedXp: 0,
    );
    final newRankInfo = XpService.computeRankInfo(
      totalXp: newXp,
      gainedXp: gained,
    );

    setState(() {
      _xpGained = gained;
      _rankInfo = newRankInfo;
      _prevRankInfo = prevRankInfo;
    });

    // Invalidate cached XP provider so HomeScreen etc. see new value
    ref.invalidate(playerXpProvider);
    ref.invalidate(playerRankInfoProvider);

    // Animate XP bar after a short delay (after stars animate)
    await Future.delayed(AnimDurations.extraLong);
    if (mounted) {
      _xpBarController.forward();
    }

    // Show rank-up celebration if rank changed
    if (mounted && newRankInfo.didRankUp(prevRankInfo)) {
      await Future.delayed(AnimDurations.extraLong);
      if (mounted) _showRankUpDialog(newRankInfo);
    }
  }

  void _showRankUpDialog(RankInfo newRank) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final rankDef = kRankDefs[newRank.rankIndex];
    final localizedName = rankDef.localizedName(l10n);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.rankUpTitle,
      barrierColor: Colors.black54,
      transitionDuration: AnimDurations.slow,
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: AppCurves.elastic),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (ctx, anim, secondaryAnim) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(Spacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: RadiiBR.xl,
                border: Border.all(
                  color: theme.gameColors.star.withValues(alpha: Opacities.half),
                  width: 2,
                ),
                boxShadow: [
                  AppShadows.glow(theme.gameColors.star),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.rankUpTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.gameColors.star,
                    ),
                  ),
                  const SizedBox(height: Spacing.l),
                  Icon(
                        newRank.icon,
                        size: IconSizes.display,
                        color: theme.gameColors.star,
                      )
                      .animate()
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1.0, 1.0),
                        duration: AnimDurations.mediumSlow,
                        curve: AppCurves.elastic,
                      )
                      .shimmer(
                        duration: AnimDurations.extraLong,
                        color: theme.gameColors.star.withValues(alpha: Opacities.half),
                      ),
                  const SizedBox(height: Spacing.m),
                  Text(
                    localizedName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: Spacing.s),
                  Text(
                    l10n.rankUpMessage(localizedName),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Spacing.xl),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.gameColors.star,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      l10n.great,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _creditController.dispose();
    _confettiController.dispose();
    _xpBarController.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSharePreview(BuildContext context, AppLocalizations l10n) {
    if (widget.levelId == null) return;
    final emojiText = ShareService.buildEmojiGrid(
      levelId: widget.levelId!,
      stars: widget.stars,
      time: widget.timeElapsed,
      score: widget.score,
    );

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return _SharePreviewDialog(
          l10n: l10n,
          emojiText: emojiText,
          onShare: () {
            Navigator.of(ctx).pop();
            ShareService.shareWithEmojiGrid(
              levelId: widget.levelId!,
              stars: widget.stars,
              time: widget.timeElapsed,
              score: widget.score,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;

    // Show toast notifications for newly unlocked achievements
    ref.listen<List<Achievement>>(recentlyUnlockedAchievementsProvider, (
      _,
      List<Achievement> next,
    ) {
      if (next.isNotEmpty && context.mounted) {
        for (final ach in next) {
          final rarity = AchievementUtils.getRarity(ach.type);
          ModernNotification.show(
            context: context,
            message:
                '${l10n.achievementUnlocked}: ${AchievementUtils.getTitle(l10n, ach.type)}',
            icon: AchievementUtils.getIcon(ach.type),
            backgroundColor: AchievementUtils.rarityColor(rarity, context),
            iconColor: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(recentlyUnlockedAchievementsProvider.notifier).clear();
        });
      }
    });

    // Show toast notification for streak milestones
    ref.listen<int?>(streakMilestoneProvider, (_, int? days) {
      if (days != null && context.mounted) {
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
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: Opacities.medium),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: SingleChildScrollView(
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
                      .fadeIn(duration: AnimDurations.slow)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: AnimDurations.slow,
                        curve: AppCurves.elastic,
                      ),

                  VerticalSpacing.s,

                  Text(
                    widget.isLastLevel
                        ? l10n.allLevelsCompletedDesc(60)
                        : l10n.youWon,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ).animate(delay: AnimDurations.normal).fadeIn(),

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
                          .animate(
                            delay:
                                AnimDurations.slow +
                                StaggerDelay.slow(index),
                          )
                          .scaleXY(
                            begin: 0,
                            end: 1,
                            duration: AnimDurations.slow,
                            curve: AppCurves.elastic,
                          )
                          .shimmer(
                            delay: StaggerDelay.slow(index),
                            duration: AnimDurations.slower,
                            color: gameColors.star.withValues(alpha: Opacities.half),
                          );
                    }),
                  ),

                  VerticalSpacing.xl,

                  // Star-count feedback message
                  _StarFeedbackMessage(stars: widget.stars)
                      .animate(delay: AnimDurations.long)
                      .fadeIn(duration: AnimDurations.medium)
                      .slideY(begin: 0.3, end: 0, duration: AnimDurations.medium),

                  VerticalSpacing.m,

                  // XP / Rank progress bar
                  if (_rankInfo != null && _xpGained > 0)
                    _XpRankBar(
                          rankInfo: _rankInfo!,
                          prevRankInfo: _prevRankInfo!,
                          xpGained: _xpGained,
                          animation: _xpBarAnimation,
                        )
                        .animate(delay: AnimDurations.slowest)
                        .fadeIn()
                        .slideY(begin: 0.3, end: 0),

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
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: gameColors.success,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      )
                                      .animate(
                                        onPlay: (controller) =>
                                            controller.repeat(),
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
                                  icon: Icons.diamond_rounded,
                                  label: l10n.creditsEarnedLabel,
                                  value: '+${_creditAnimation.value}',
                                  valueColor: gameColors.star,
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ).animate(delay: AnimDurations.slower).fadeIn().slideY(begin: 0.3, end: 0),

                  VerticalSpacing.xl,

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                    child: Column(
                      children: [
                        // Double Rewards button (rewarded ad)
                        if (widget.creditsEarned > 0 && !_rewardsDoubled)
                          Padding(
                            padding: const EdgeInsets.only(bottom: Spacing.s),
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result = await AdService.instance.showRewardedAd(
                                  onRewarded: () async {
                                    // Grant extra credits equal to original reward
                                    await ref
                                        .read(progressRepositoryProvider)
                                        .addCredits(widget.creditsEarned);
                                    ref.invalidate(creditsProvider);
                                  },
                                );
                                if (result == AdResult.rewarded && mounted) {
                                  setState(() {
                                    _rewardsDoubled = true;
                                    // Update animation to show doubled value
                                    _creditAnimation = IntTween(
                                      begin: widget.creditsEarned,
                                      end: widget.creditsEarned * 2,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: _creditController,
                                        curve: Curves.easeOut,
                                      ),
                                    );
                                    _creditController
                                      ..reset()
                                      ..forward();
                                  });
                                  ref.read(soundServiceProvider).play(SoundEffect.complete);
                                  ref.read(hapticServiceProvider).trigger(HapticType.success);
                                }
                              },
                              icon: const Icon(Icons.play_circle_outline),
                              label: Text(AppLocalizations.of(context)!.doubleRewards),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(
                                  double.infinity,
                                  Spacing.buttonHeight,
                                ),
                                foregroundColor: Theme.of(context).gameColors.star,
                                side: BorderSide(
                                  color: Theme.of(context).gameColors.star,
                                ),
                              ),
                            ),
                          ),
                        // Next Level or Main Menu button (based on if it's the last level)
                        if (!widget.isLastLevel)
                          FilledButton.icon(
                            onPressed: () {
                              ref
                                  .read(soundServiceProvider)
                                  .play(SoundEffect.tap);
                              ref
                                  .read(hapticServiceProvider)
                                  .trigger(HapticType.selection);
                              widget.onNextLevel();
                            },
                            icon: widget.nextLevelPreloaded != null
                                ? const Icon(Icons.arrow_forward)
                                : const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
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
                              ref
                                  .read(soundServiceProvider)
                                  .play(SoundEffect.tap);
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
                            ref
                                .read(soundServiceProvider)
                                .play(SoundEffect.tap);
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
                            ref
                                .read(soundServiceProvider)
                                .play(SoundEffect.tap);
                            ref
                                .read(hapticServiceProvider)
                                .trigger(HapticType.selection);
                            if (widget.levelId != null) {
                              _showSharePreview(context, l10n);
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
                            ref
                                .read(soundServiceProvider)
                                .play(SoundEffect.tap);
                            ref
                                .read(hapticServiceProvider)
                                .trigger(HapticType.selection);
                            widget.onMainMenu();
                          },
                          child: Text(l10n.mainMenu),
                        ),
                      ],
                    ),
                  ).animate(delay: AnimDurations.long).fadeIn(),
                ],
              ),
            ), // SingleChildScrollView
          ),
          ConfettiOverlay(controller: _confettiController),
        ],
      ),
    );
  }
}

// ── XP / Rank Progress Bar ────────────────────────────────────────────────────

class _XpRankBar extends StatelessWidget {
  final RankInfo rankInfo;
  final RankInfo prevRankInfo;
  final int xpGained;
  final Animation<double> animation;

  const _XpRankBar({
    required this.rankInfo,
    required this.prevRankInfo,
    required this.xpGained,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final gameColors = theme.gameColors;
    final startProgress = prevRankInfo.progress;
    final endProgress = rankInfo.progress;
    final barFill = Tween<double>(begin: startProgress, end: endProgress);
    final rankDef = kRankDefs[rankInfo.rankIndex];
    final localizedName = rankDef.localizedName(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          Spacing.m,
          Spacing.s,
          Spacing.m,
          Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: RadiiBR.lg,
          border: Border.all(color: gameColors.star.withValues(alpha: Opacities.medium)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      rankInfo.icon,
                      size: IconSizes.md,
                      color: gameColors.star,
                    ),
                    HorizontalSpacing.xs,
                    Text(
                      localizedName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: gameColors.star,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.s,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: gameColors.star.withValues(alpha: Opacities.soft),
                    borderRadius: RadiiBR.sm,
                  ),
                  child: Text(
                    '+$xpGained XP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: gameColors.star,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            VerticalSpacing.xs,
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final progress = barFill.evaluate(animation);
                return AppProgressBar(
                  value: progress,
                  color: gameColors.star,
                  backgroundColor: gameColors.star.withValues(alpha: Opacities.soft),
                );
              },
            ),
            VerticalSpacing.xxs,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${rankInfo.rankThreshold} XP',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: Opacities.half),
                    fontSize: 11,
                  ),
                ),
                if (!rankInfo.isMaxRank)
                  Text(
                    '${rankInfo.nextThreshold} XP',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: Opacities.half),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Row ──────────────────────────────────────────────────────────────────

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
                  : theme.colorScheme.onSurface.withValues(alpha: Opacities.bold),
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

// ── Star count feedback message ───────────────────────────────────────────────

class _StarFeedbackMessage extends StatelessWidget {
  final int stars;
  const _StarFeedbackMessage({required this.stars});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;

    String message;
    Color color;
    switch (stars) {
      case 3:
        message = l10n.completion3Stars;
        color = gameColors.star;
      case 2:
        message = l10n.completion2Stars;
        color = theme.colorScheme.primary;
      case 1:
        message = l10n.completion1Star;
        color = theme.colorScheme.secondary;
      default:
        message = '${l10n.completion0Stars}\n${l10n.completionHintSuggestion}';
        color = theme.colorScheme.onSurface.withValues(alpha: Opacities.bold);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Share Preview Dialog ──────────────────────────────────────────────────────

class _SharePreviewDialog extends StatefulWidget {
  final AppLocalizations l10n;
  final String emojiText;
  final VoidCallback onShare;

  const _SharePreviewDialog({
    required this.l10n,
    required this.emojiText,
    required this.onShare,
  });

  @override
  State<_SharePreviewDialog> createState() => _SharePreviewDialogState();
}

class _SharePreviewDialogState extends State<_SharePreviewDialog> {
  bool _copied = false;

  void _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.emojiText));
    if (mounted) {
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _copied = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l10n.sharePreviewTitle),
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: RadiiBR.md,
        ),
        child: Text(
          widget.emojiText,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
            height: 1.8,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.sharePreviewClose),
        ),
        OutlinedButton.icon(
          onPressed: _copied ? null : _handleCopy,
          icon: Icon(_copied ? Icons.check : Icons.copy, size: IconSizes.smd),
          label: Text(
            _copied ? l10n.sharePreviewCopied : l10n.sharePreviewCopy,
          ),
        ),
        FilledButton.icon(
          onPressed: widget.onShare,
          icon: const Icon(Icons.share, size: IconSizes.smd),
          label: Text(l10n.share),
        ),
      ],
    );
  }
}
