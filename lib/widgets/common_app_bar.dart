import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/screens/shop_screen.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/services/daily_reward_service.dart';
import 'package:crossclimber/services/sound_service.dart';
import 'package:crossclimber/services/haptic_service.dart';

enum AppBarType {
  game, // Game screen with pause button and level title
  standard, // Other screens with back button and custom title
  home, // Home screen - transparent, only shows lives and credits
}

class CommonAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final AppBarType type;
  final VoidCallback? onPausePressed;
  final List<Widget>? additionalActions;
  final bool showCredits;
  final bool showLives;
  final bool showStreak;
  final String? heroTag;

  const CommonAppBar({
    super.key,
    required this.title,
    this.type = AppBarType.standard,
    this.onPausePressed,
    this.additionalActions,
    this.showCredits = true,
    this.showLives = false,
    this.showStreak = false,
    this.heroTag,
  });

  @override
  ConsumerState<CommonAppBar> createState() => _CommonAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CommonAppBarState extends ConsumerState<CommonAppBar> {
  Widget? _buildLeading(BuildContext context, ThemeData theme) {
    if (widget.type == AppBarType.game) {
      return Row(
        children: [
          HorizontalSpacing.xxs,
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () {
              ref.read(soundServiceProvider).play(SoundEffect.tap);
              ref.read(hapticServiceProvider).trigger(HapticType.selection);
              widget.onPausePressed?.call();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          HorizontalSpacing.xxs,
          _buildLivesButton(theme),
        ],
      );
    }

    if (widget.type == AppBarType.standard && widget.showLives) {
      return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(soundServiceProvider).play(SoundEffect.tap);
              ref.read(hapticServiceProvider).trigger(HapticType.selection);
              Navigator.maybePop(context);
            },
          ),
          HorizontalSpacing.xxs,
          _buildLivesButton(theme),
        ],
      );
    }

    // Default back button behavior if not game and not showing lives
    if (widget.type == AppBarType.standard) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          ref.read(soundServiceProvider).play(SoundEffect.tap);
          ref.read(hapticServiceProvider).trigger(HapticType.selection);
          Navigator.maybePop(context);
        },
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Home type - completely transparent, no title, no leading
    if (widget.type == AppBarType.home) {
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: kToolbarHeight,
        actions: widget.showCredits ? [_buildCreditsButton(theme)] : null,
      );
    }

    return AppBar(
      // Disable automatic back button if we provide a custom leading
      automaticallyImplyLeading: false,

      // Leading (Left side)
      leading: _buildLeading(context, theme),

      // Responsive leadingWidth to prevent overflow with lives badge
      leadingWidth: (widget.type == AppBarType.game || widget.showLives) ? 140.0 : null,

      // Title (Center)
      title: widget.heroTag != null
          ? Hero(
              tag: widget.heroTag!,
              flightShuttleBuilder: (flightContext, animation, direction,
                  fromHeroContext, toHeroContext) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: toHeroContext.widget,
                    );
                  },
                );
              },
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  widget.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            )
          : Text(widget.title, overflow: TextOverflow.ellipsis, maxLines: 1),
      centerTitle: true,
      titleSpacing: 0, // Remove default spacing for better centering
      // Actions (Right side)
      actions: [
        // Streak Display
        if (widget.showStreak) _buildStreakButton(theme),

        // Credits Display
        if (widget.showCredits) _buildCreditsButton(theme),

        // Additional actions if provided
        if (widget.additionalActions != null) ...widget.additionalActions!,

        // Right padding to prevent "stuck to edge" look
        const SizedBox(width: Spacing.s),
      ],
    );
  }

  // Unified status chip builder for consistent look and feel
  Widget _buildStatusChip({
    required BuildContext context,
    required IconData icon,
    required String value,
    required Color color,
    required Color containerColor,
    required VoidCallback onTap,
    required String semanticsLabel,
    bool showAddIcon =
        false, // Kept for API compatibility but unused in compact mode
  }) {
    final theme = Theme.of(context);

    Widget chipContent = Semantics(
      label: semanticsLabel,
      button: true,
      child: InkWell(
        onTap: () {
          ref.read(soundServiceProvider).play(SoundEffect.tap);
          ref.read(hapticServiceProvider).trigger(HapticType.selection);
          onTap();
        },
        borderRadius: RadiiBR.md,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.s, // Slightly more padding for readability
            vertical: Spacing.xxs + 1,
          ),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: RadiiBR.md,
            border: Border.all(color: color.withValues(alpha: Opacities.medium), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: IconSizes.sm, color: color),
              HorizontalSpacing.xxs,
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Removed add icon to save space
            ],
          ),
        ),
      ),
    );

    return chipContent;
  }

  Widget _buildLivesButton(ThemeData theme) {
    return FutureBuilder<int>(
      future: ref.read(progressRepositoryProvider).getLives(),
      builder: (context, livesSnapshot) {
        final currentLives = livesSnapshot.data ?? 5;
        return _buildStatusChip(
          context: context,
          icon: Icons.favorite,
          value: '$currentLives',
          color: theme.colorScheme.error,
          containerColor: theme.colorScheme.errorContainer,
          showAddIcon: currentLives < 5,
          semanticsLabel: '$currentLives can, mağazaya git',
          onTap: () async {
            await Navigator.push(
              context,
              BottomSlidePageRoute(builder: (context) => const ShopScreen()),
            );
            if (mounted) setState(() {});
          },
        );
      },
    );
  }

  Widget _buildCreditsButton(ThemeData theme) {
    final creditsAsync = ref.watch(creditsProvider);
    final credits = creditsAsync.whenOrNull(data: (v) => v) ?? 0;
    return _buildStatusChip(
      context: context,
      icon: Icons.diamond_rounded,
      value: '$credits',
      color: theme.colorScheme.primary,
      containerColor: theme.colorScheme.primaryContainer,
      showAddIcon: true,
      semanticsLabel: '$credits kredi, mağazaya git',
      onTap: () async {
        await Navigator.push(
          context,
          BottomSlidePageRoute(builder: (context) => const ShopScreen()),
        );
        ref.invalidate(creditsProvider);
      },
    );
  }

  Widget _buildStreakButton(ThemeData theme) {
    return FutureBuilder<int>(
      future: ref.read(dailyRewardServiceProvider).getStreakCount(),
      builder: (context, snapshot) {
        final streak = snapshot.data ?? 0;
        final gameColors = theme.gameColors;

        // Don't show if 0 streak? Or show 0 to motivate? Showing 0 is better for discovery.
        return Padding(
          padding: const EdgeInsets.only(right: Spacing.s),
          child: _buildStatusChip(
            context: context,
            icon: Icons.local_fire_department,
            value: '$streak',
            color: gameColors.streak,
            containerColor: gameColors.streakContainer,
            semanticsLabel: '$streak günlük seri',
            onTap: () {
              // Optional: Navigate to Daily Challenge
            },
          ),
        );
      },
    );
  }
}
