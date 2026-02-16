import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/widgets/modern_dialog.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/screens/shop_screen.dart';

/// Mixin providing dialog functionality for GameScreen
mixin GameScreenDialogs<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Format duration as MM:SS
  String formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get time until next life regeneration
  String getTimeUntilNextLife(DateTime lastRegenTime) {
    final now = DateTime.now();
    final nextRegenTime = lastRegenTime.add(const Duration(minutes: 30));
    final remaining = nextRegenTime.difference(now);

    if (remaining.isNegative) return '0:00';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Show out of lives dialog with purchase options
  Future<void> showOutOfLivesDialog() async {
    final gameState = ref.read(gameProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Timer widget
    Widget? timerWidget;
    if (gameState.lastLifeRegenTime != null) {
      timerWidget = Container(
        padding: const EdgeInsets.all(Spacing.s + Spacing.xs),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: RadiiBR.lg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            HorizontalSpacing.s,
            Text(
              l10n.nextLifeIn(
                getTimeUntilNextLife(gameState.lastLifeRegenTime!),
              ),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Credits check
    final credits = await ref.read(progressRepositoryProvider).getCredits();
    final canBuyLife = credits >= 50;
    final canBuyAllLives = credits >= 100;

    if (!mounted) return;

    await ModernDialog.show(
      context: context,
      title: l10n.outOfLivesTitle,
      message: l10n.outOfLivesMessage,
      icon: Icons.favorite_border,
      iconColor: theme.colorScheme.error,
      customContent: timerWidget != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [VerticalSpacing.m, timerWidget],
            )
          : null,
      actions: [
        ModernDialogAction(
          label: l10n.buyOneLife,
          icon: Icons.favorite,
          isPrimary: true,
          isEnabled: canBuyLife,
          result: 'buy_one',
        ),
        ModernDialogAction(
          label: l10n.buyAllLives,
          icon: Icons.favorite,
          isEnabled: canBuyAllLives,
          result: 'buy_all',
        ),
        ModernDialogAction(
          label: l10n.exitGame,
          isDestructive: true,
          result: 'exit',
        ),
      ],
    ).then((result) async {
      if (result == 'buy_one') {
        await ref
            .read(gameProvider.notifier)
            .restoreLife(useCredits: true, creditCost: 50);
      } else if (result == 'buy_all') {
        await ref
            .read(gameProvider.notifier)
            .restoreAllLives(useCredits: true, creditCost: 100);
      } else if (result == 'exit') {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  /// Show unlock animation when correct sorting is achieved
  void showUnlockAnimation(
    OverlayEntry? Function() getEntry,
    void Function(OverlayEntry?) setEntry,
  ) {
    if (!mounted) return;

    final overlay = Overlay.of(context);
    final l10n = AppLocalizations.of(context)!;
    final entry = OverlayEntry(
      builder: (context) {
        final gameColors = Theme.of(context).gameColors;
        final theme = Theme.of(context);

        return Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: 0,
          right: 0,
          child: Center(
            child:
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.l,
                        vertical: Spacing.m,
                      ),
                      decoration: BoxDecoration(
                        color: gameColors.success,
                        borderRadius: RadiiBR.lg,
                        boxShadow: [
                          BoxShadow(
                            color: gameColors.success.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                    Icons.lock_open_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  )
                                  .animate(
                                    onPlay: (controller) =>
                                        controller.repeat(reverse: true),
                                  )
                                  .scale(
                                    duration: 500.ms,
                                    curve: Curves.elasticOut,
                                  ),
                              HorizontalSpacing.s,
                              Text(
                                l10n.startEndUnlocked,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.easeOutBack)
                    .fadeIn(),
          ),
        );
      },
    );

    setEntry(entry);
    overlay.insert(entry);

    // Auto-remove after animation
    Future.delayed(AnimDurations.extraLong, () {
      if (mounted && getEntry() == entry) {
        entry.remove();
        if (getEntry() == entry) {
          setEntry(null);
        }
      }
    });
  }

  /// Show market/shop dialog for buying hints
  void showMarketDialog(BuildContext context, AppLocalizations l10n) {
    Navigator.push(
      context,
      BottomSlidePageRoute(builder: (context) => const ShopScreen()),
    ).then((_) {
      ref.invalidate(hintStocksProvider);
    });
  }

  /// Build pause menu widget
  Widget buildPauseMenu(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;

    return Center(
      child: ModernDialogContent(
        title: l10n.paused,
        message: '',
        icon: Icons.pause_circle_outline,
        iconColor: theme.colorScheme.primary,
        actions: [
          ModernDialogAction(
            label: l10n.resume,
            icon: Icons.play_arrow,
            isPrimary: true,
            onPressed: () {
              ref.read(gameProvider.notifier).togglePause();
            },
          ),
          ModernDialogAction(
            label: l10n.restart,
            icon: Icons.refresh,
            onPressed: () {
              ref.read(gameProvider.notifier).restartLevel();
            },
          ),
          ModernDialogAction(
            label: l10n.mainMenu,
            icon: Icons.exit_to_app,
            isDestructive: true,
            onPressed: () async {
              final shouldExit = await ModernDialog.show<bool>(
                context: context,
                title: l10n.returnToMainMenu,
                message: l10n.progressLostWarning,
                icon: Icons.exit_to_app,
                iconColor: gameColors.warning,
                actions: [
                  ModernDialogAction(label: l10n.cancel, result: false),
                  ModernDialogAction(
                    label: l10n.exit,
                    isPrimary: true,
                    result: true,
                  ),
                ],
              );

              if (shouldExit == true && context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
    );
  }
}
