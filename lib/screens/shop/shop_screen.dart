import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/widgets/modern_dialog.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/services/daily_reward_service.dart';
import 'package:crossclimber/services/ad_reward_service.dart';
import 'package:crossclimber/screens/shop/shop_screen_cards.dart';
import 'package:crossclimber/screens/shop/shop_screen_rewards.dart';
import 'package:crossclimber/widgets/discovery_banner.dart';
import 'package:crossclimber/providers/discovery_tip_provider.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with ShopScreenCards, ShopScreenRewards {
  int _currentCredits = 0;
  final _dailyRewardService = DailyRewardService();
  final _adRewardService = AdRewardService();
  bool _canClaimDaily = false;
  int _dailyStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    final credits = await ref.read(progressRepositoryProvider).getCredits();
    final canClaim = await _dailyRewardService.canClaimToday();
    final streak = await _dailyRewardService.getStreakCount();

    if (mounted) {
      setState(() {
        _currentCredits = credits;
        _canClaimDaily = canClaim;
        _dailyStreak = streak;
      });
    }
  }

  Future<void> _claimDailyReward() async {
    final reward = await _dailyRewardService.claimDailyReward();

    if (reward.alreadyClaimed) {
      if (mounted) {
        final gameColors = Theme.of(context).gameColors;
        ModernNotification.show(
          context: context,
          message: AppLocalizations.of(context)!.alreadyClaimedToday,
          icon: Icons.info_outline,
          backgroundColor: gameColors.warning,
          iconColor: gameColors.onWarning,
        );
      }
      return;
    }

    // Apply rewards
    final progressRepo = ref.read(progressRepositoryProvider);
    await progressRepo.addCredits(reward.credits);
    if (reward.revealHints > 0) {
      await progressRepo.addHintStock('revealWord', reward.revealHints);
    }
    if (reward.undoHints > 0) {
      await progressRepo.addHintStock('undo', reward.undoHints);
    }

    await _loadCredits();

    if (mounted) {
      final theme = Theme.of(context);
      final gameColors = theme.gameColors;

      await ModernDialog.show<bool>(
        context: context,
        icon: Icons.celebration,
        iconColor: gameColors.success,
        title: AppLocalizations.of(context)!.dailyRewardTitle,
        message: AppLocalizations.of(
          context,
        )!.dailyRewardStreak(reward.streakDay),
        customContent: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildRewardItem(
              theme,
              Icons.monetization_on,
              AppLocalizations.of(context)!.rewardCreditsLabel(reward.credits),
              theme.colorScheme.primary,
            ),
            if (reward.revealHints > 0)
              buildRewardItem(
                theme,
                Icons.style,
                AppLocalizations.of(context)!.rewardRevealHints(reward.revealHints),
                gameColors.success,
              ),
            if (reward.undoHints > 0)
              buildRewardItem(
                theme,
                Icons.undo,
                AppLocalizations.of(context)!.rewardUndoHints(reward.undoHints),
                gameColors.success,
              ),
          ],
        ),
        actions: [
          ModernDialogAction(
            label: AppLocalizations.of(context)!.great,
            isPrimary: true,
            result: true,
          ),
        ],
      );
    }
  }

  Future<void> _watchAdForCredits() async {
    final credits = await _adRewardService.watchAdForCredits();

    if (credits == 0) {
      if (mounted) {
        final gameColors = Theme.of(context).gameColors;
        ModernNotification.show(
          context: context,
          message: AppLocalizations.of(context)!.dailyAdLimitReached,
          icon: Icons.info_outline,
          backgroundColor: gameColors.warning,
          iconColor: gameColors.onWarning,
        );
      }
      return;
    }

    await ref.read(progressRepositoryProvider).addCredits(credits);
    await _loadCredits();

    if (mounted) {
      final gameColors = Theme.of(context).gameColors;
      ModernNotification.show(
        context: context,
        message: AppLocalizations.of(context)!.creditsEarnedNotification(credits),
        icon: Icons.check_circle_outline,
        backgroundColor: gameColors.success,
        iconColor: gameColors.onSuccess,
      );
    }
  }

  Future<void> _watchAdForHint() async {
    final hintType = await _adRewardService.watchAdForHint();

    if (hintType == null) {
      if (mounted) {
        final gameColors = Theme.of(context).gameColors;
        ModernNotification.show(
          context: context,
          message: AppLocalizations.of(context)!.dailyAdLimitReached,
          icon: Icons.info_outline,
          backgroundColor: gameColors.warning,
          iconColor: gameColors.onWarning,
        );
      }
      return;
    }

    await ref.read(progressRepositoryProvider).addHintStock(hintType, 1);
    await _loadCredits();

    if (mounted) {
      final gameColors = Theme.of(context).gameColors;
      ModernNotification.show(
        context: context,
        message: hintType == 'revealWord'
            ? AppLocalizations.of(context)!.revealHintEarned
            : AppLocalizations.of(context)!.undoHintEarned,
        icon: Icons.check_circle_outline,
        backgroundColor: gameColors.success,
        iconColor: gameColors.onSuccess,
      );
    }
  }

  Future<void> _purchaseHints(String hintType, int amount, int cost) async {
    if (_currentCredits < cost) {
      if (mounted) {
        final gameColors = Theme.of(context).gameColors;
        ModernNotification.show(
          context: context,
          message: AppLocalizations.of(context)!.notEnoughCredits,
          icon: Icons.error_outline,
          backgroundColor: gameColors.incorrect,
          iconColor: gameColors.onIncorrect,
        );
      }
      return;
    }

    final progressRepo = ref.read(progressRepositoryProvider);
    final success = await progressRepo.removeCredits(cost);

    if (success) {
      await progressRepo.addHintStock(hintType, amount);
      await _loadCredits();

      if (mounted) {
        final gameColors = Theme.of(context).gameColors;
        ModernNotification.show(
          context: context,
        message: AppLocalizations.of(context)!.hintsPurchasedNotification(amount),
          icon: Icons.check_circle_outline,
          backgroundColor: gameColors.success,
          iconColor: gameColors.onSuccess,
        );
      }
    }
  }

  Future<void> _purchaseCredits(int amount, String realPrice) async {
    // This would connect to real IAP in production
    if (mounted) {
      ModernNotification.show(
        context: context,
        message:
            AppLocalizations.of(context)!.creditPurchaseComingSoon(amount, realPrice),
        icon: Icons.info_outline,
      );
    }
  }

  Future<void> _purchaseLives(int amount, int cost) async {
    if (_currentCredits < cost) {
      if (mounted) {
        final gameColors = Theme.of(context).gameColors;
        ModernNotification.show(
          context: context,
          message: AppLocalizations.of(context)!.notEnoughCredits,
          icon: Icons.error_outline,
          backgroundColor: gameColors.incorrect,
          iconColor: gameColors.onIncorrect,
        );
      }
      return;
    }

    final progressRepo = ref.read(progressRepositoryProvider);

    if (amount == 1) {
      final success = await progressRepo.addLife(
        useCredits: true,
        creditCost: cost,
      );
      if (!success) {
        if (mounted) {
          final gameColors = Theme.of(context).gameColors;
          ModernNotification.show(
            context: context,
            message: AppLocalizations.of(context)!.livesAlreadyFull,
            icon: Icons.warning_amber,
            backgroundColor: gameColors.warning,
            iconColor: gameColors.onWarning,
          );
        }
        return;
      }
    } else {
      await progressRepo.restoreAllLives(useCredits: true, creditCost: cost);
    }

    await _loadCredits();

    if (mounted) {
      final gameColors = Theme.of(context).gameColors;
      ModernNotification.show(
        context: context,
        message: AppLocalizations.of(context)!.livesPurchasedNotification(amount),
        icon: Icons.check_circle_outline,
        backgroundColor: gameColors.success,
        iconColor: gameColors.onSuccess,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppLocalizations.of(context)!.shopTitle,
        type: AppBarType.standard,
        showCredits: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCredits,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: SpacingInsets.m,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Discovery tip (first visit only)
              DiscoveryBanner(
                feature: DiscoveryFeature.shop,
                icon: Icons.storefront_rounded,
                title: AppLocalizations.of(context)!.discoveryShopTitle,
                description: AppLocalizations.of(context)!.discoveryShopDesc,
                ctaLabel: AppLocalizations.of(context)!.discoveryGotIt,
              ),
              VerticalSpacing.s,

              // Daily Reward Section
              if (_canClaimDaily) ...[
                buildDailyRewardCard(
                  context,
                  onTap: _claimDailyReward,
                  dailyStreak: _dailyStreak,
                ),
                VerticalSpacing.m,
              ],

              // Free Credits Section
              buildSectionHeader(
                context,
                icon: Icons.card_giftcard,
                title: AppLocalizations.of(context)!.freeCreditsTitle,
                subtitle: AppLocalizations.of(context)!.freeCreditsSubtitle,
              ),
              VerticalSpacing.s,
              buildAdRewardCard(
                context,
                onWatchAdForCredits: _watchAdForCredits,
                onWatchAdForHint: _watchAdForHint,
              ),

              VerticalSpacing.xl,

              // Credits Section
              buildSectionHeader(
                context,
                icon: Icons.monetization_on,
                title: AppLocalizations.of(context)!.creditPackageTitle,
                subtitle: AppLocalizations.of(context)!.creditPackageSubtitle,
              ),
              VerticalSpacing.s,
              buildCreditPackageCard(
                context,
                amount: 100,
                price: '₺19.99',
                popular: false,
                onTap: () => _purchaseCredits(100, '₺19.99'),
              ),
              VerticalSpacing.s,
              buildCreditPackageCard(
                context,
                amount: 500,
                price: '₺79.99',
                popular: true,
                bonus: '+100 Bonus',
                onTap: () => _purchaseCredits(500, '₺79.99'),
              ),
              VerticalSpacing.s,
              buildCreditPackageCard(
                context,
                amount: 1000,
                price: '₺149.99',
                popular: false,
                bonus: '+300 Bonus',
                onTap: () => _purchaseCredits(1000, '₺149.99'),
              ),

              VerticalSpacing.xl,

              // Lives Section
              buildSectionHeader(
                context,
                icon: Icons.favorite,
                title: AppLocalizations.of(context)!.lifePackageTitle,
                subtitle: AppLocalizations.of(context)!.lifePackageSubtitle,
              ),
              VerticalSpacing.s,
              buildLifePackageCard(
                context,
                amount: 1,
                cost: 10,
                currentCredits: _currentCredits,
                onPurchase: _purchaseLives,
              ),
              VerticalSpacing.s,
              buildLifePackageCard(
                context,
                amount: 5,
                cost: 40,
                popular: true,
                currentCredits: _currentCredits,
                onPurchase: _purchaseLives,
              ),

              VerticalSpacing.xl,

              // Hints Section
              buildSectionHeader(
                context,
                icon: Icons.lightbulb,
                title: AppLocalizations.of(context)!.hintPackageTitle,
                subtitle: AppLocalizations.of(context)!.hintPackageSubtitle,
              ),
              VerticalSpacing.s,
              buildHintPackageCard(
                context,
                hintType: 'revealWord',
                icon: Icons.style,
                title: AppLocalizations.of(context)!.revealWord,
                description: AppLocalizations.of(context)!.revealWordDesc,
                amount: 3,
                cost: 45,
                popular: true,
                currentCredits: _currentCredits,
                onPurchase: _purchaseHints,
              ),
              VerticalSpacing.s,
              buildHintPackageCard(
                context,
                hintType: 'undo',
                icon: Icons.undo,
                title: AppLocalizations.of(context)!.undoMove,
                description: AppLocalizations.of(context)!.undoMoveDesc,
                amount: 10,
                cost: 30,
                currentCredits: _currentCredits,
                onPurchase: _purchaseHints,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
