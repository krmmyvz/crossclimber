import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/daily_reward_service.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';

// ──────────────────────────────────────────────────────────────────────────────
/// 7-day rotating reward calendar widget.
///
/// Shows a compact card with day tiles, today's claim button and a countdown
/// until the next reward. Handles the claim animation and particle shower
/// internally.
// ──────────────────────────────────────────────────────────────────────────────
class DailyRewardCalendar extends ConsumerStatefulWidget {
  const DailyRewardCalendar({super.key});

  @override
  ConsumerState<DailyRewardCalendar> createState() =>
      _DailyRewardCalendarState();
}

class _DailyRewardCalendarState extends ConsumerState<DailyRewardCalendar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _claimCtrl;
  bool _isClaiming = false;
  bool _showParticles = false;
  DailyReward? _lastReward;

  @override
  void initState() {
    super.initState();
    _claimCtrl = AnimationController(
      vsync: this,
      duration: AnimDurations.slow,
    );
  }

  @override
  void dispose() {
    _claimCtrl.dispose();
    super.dispose();
  }

  // ── Claim logic ─────────────────────────────────────────────────────────────

  Future<void> _onClaim() async {
    if (_isClaiming) return;
    setState(() => _isClaiming = true);

    // Run the bounce / shimmer animation immediately
    _claimCtrl.forward(from: 0);

    final reward =
        await ref.read(dailyRewardServiceProvider).claimDailyReward();

    if (!mounted) return;

    if (reward.alreadyClaimed) {
      setState(() => _isClaiming = false);
      _claimCtrl.reset();
      return;
    }

    _lastReward = reward;
    setState(() => _showParticles = true);

    // Refresh calendar UI and anything watching credits / streak
    ref.invalidate(dailyCalendarStateProvider);

    _showRewardSnackBar(reward);

    await Future.delayed(AnimDurations.ultraLong);
    if (mounted) {
      setState(() {
        _isClaiming = false;
        _showParticles = false;
      });
      _claimCtrl.reset();
    }
  }

  void _showRewardSnackBar(DailyReward reward) {
    final l10n = AppLocalizations.of(context)!;
    final parts = <String>[];
    if (reward.credits > 0) {
      parts.add(l10n.dailyCalendarRewardCredits(reward.credits));
    }
    if (reward.revealHints > 0) parts.add(l10n.dailyCalendarRewardReveal);
    if (reward.undoHints > 0) parts.add(l10n.dailyCalendarRewardUndo);
    if (reward.specialTheme) parts.add(l10n.dailyCalendarRewardSpecial);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: IconSizes.smd),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${l10n.dailyCalendarRewardSummary}${parts.isNotEmpty ? ': ${parts.join(', ')}' : ''}',
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: RadiiBR.lg),
        margin: const EdgeInsets.all(Spacing.m),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(dailyCalendarStateProvider);
    final theme = Theme.of(context);

    return calendarAsync.when(
      loading: () => _Skeleton(theme: theme),
      error: (_, __) => const SizedBox.shrink(),
      data: (state) => _buildCalendar(context, theme, state),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    ThemeData theme,
    DailyCalendarState state,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final gold = theme.gameColors.star;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Main card ──────────────────────────────────────────────────────
        AnimatedContainer(
          duration: AnimDurations.normal,
          padding: const EdgeInsets.fromLTRB(
            Spacing.m,
            Spacing.m,
            Spacing.m,
            Spacing.s,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: RadiiBR.lg,
            border: Border.all(
              color: state.canClaimNow
                  ? gold.withValues(alpha: Opacities.half)
                  : theme.colorScheme.outlineVariant.withValues(alpha: Opacities.semi),
              width: state.canClaimNow ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(l10n, theme, state),
              if (state.streakWasReset) ...[
                const SizedBox(height: Spacing.xs),
                _buildResetChip(l10n, theme),
              ],
              const SizedBox(height: Spacing.s),
              _buildDayRow(l10n, theme, state),
              if (state.claimedToday && state.timeUntilNext != null) ...[
                const SizedBox(height: Spacing.xs),
                _buildCountdown(l10n, theme, state),
              ],
            ],
          ),
        ),

        // ── Particle shower overlay ────────────────────────────────────────
        if (_showParticles) _ParticleShower(reward: _lastReward),
      ],
    );
  }

  // ── Sub-builders ────────────────────────────────────────────────────────────

  Widget _buildHeader(
    AppLocalizations l10n,
    ThemeData theme,
    DailyCalendarState state,
  ) {
    final gold = theme.gameColors.star;
    final accent = state.canClaimNow ? gold : theme.colorScheme.primary;

    return Row(
      children: [
        Icon(Icons.card_giftcard_rounded, color: accent, size: IconSizes.smd),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: Text(
            l10n.dailyCalendarTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: state.canClaimNow ? gold : null,
            ),
          ),
        ),
        // Day-in-cycle badge
        _Badge(
          label: '${state.todaysCycleDay}/7',
          color: accent,
        ),
      ],
    );
  }

  Widget _buildResetChip(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: Opacities.medium),
        borderRadius: BorderRadius.circular(Spacing.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: IconSizes.xs,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.dailyCalendarStreakReset,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(
    AppLocalizations l10n,
    ThemeData theme,
    DailyCalendarState state,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (i) {
          final day = i + 1;
          final def = kDayRewards[i];
          final isPast =
              day < state.todaysCycleDay ||
              (day == state.todaysCycleDay && state.claimedToday);
          final isToday = day == state.todaysCycleDay;
          final isFuture = day > state.todaysCycleDay;

          return Padding(
            padding: EdgeInsets.only(right: i < 6 ? Spacing.xs : 0),
            child: _DayCard(
              def: def,
              isToday: isToday,
              isPast: isPast,
              isFuture: isFuture,
              claimedToday: state.claimedToday,
              isClaiming: isToday && _isClaiming,
              claimAnim: _claimCtrl,
              onClaim: isToday && !state.claimedToday ? _onClaim : null,
              l10n: l10n,
              theme: theme,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCountdown(
    AppLocalizations l10n,
    ThemeData theme,
    DailyCalendarState state,
  ) {
    final dur = state.timeUntilNext!;
    final gold = theme.gameColors.star;
    final h = dur.inHours.toString().padLeft(2, '0');
    final m = (dur.inMinutes % 60).toString().padLeft(2, '0');
    final s = (dur.inSeconds % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.schedule_rounded,
          size: IconSizes.xs,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          l10n.dailyCalendarNextIn('$h:$m:$s'),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: Spacing.s),
        Text(
          l10n.dailyCalendarFomoWarning,
          style: theme.textTheme.labelSmall?.copyWith(
            color: gold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _DayCard — one slot in the 7-day grid
// ──────────────────────────────────────────────────────────────────────────────

class _DayCard extends StatelessWidget {
  final DailyRewardDef def;
  final bool isToday;
  final bool isPast;
  final bool isFuture;
  final bool claimedToday;
  final bool isClaiming;
  final AnimationController claimAnim;
  final VoidCallback? onClaim;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _DayCard({
    required this.def,
    required this.isToday,
    required this.isPast,
    required this.isFuture,
    required this.claimedToday,
    required this.isClaiming,
    required this.claimAnim,
    required this.onClaim,
    required this.l10n,
    required this.theme,
  });

  Widget _buildRewardIcons() {
    final gold = theme.gameColors.star;
    final icons = <Widget>[];
    if (def.credits > 0) {
      icons.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_rounded, size: IconSizes.xs, color: gold),
          const SizedBox(width: 1),
          Text('${def.credits}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ));
    }
    if (def.revealHints > 0) {
      icons.add(const Icon(Icons.search_rounded, size: IconSizes.xs, color: Colors.blueAccent));
    }
    if (def.undoHints > 0) {
      icons.add(const Icon(Icons.undo_rounded, size: IconSizes.xs, color: Colors.deepPurple));
    }
    if (def.specialTheme) {
      icons.add(const Icon(Icons.palette_rounded, size: IconSizes.xs, color: Colors.pinkAccent));
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 2,
      runSpacing: 0,
      children: icons,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = theme.gameColors.star;
    final isAvailable = isToday && !claimedToday;
    final isClaimed = isPast || (isToday && claimedToday);

    final Color borderColor;
    final Color bgColor;
    final double opacity;

    if (isClaimed) {
      borderColor = Colors.green.withValues(alpha: Opacities.semi);
      bgColor = Colors.green.withValues(alpha: Opacities.faint);
      opacity = 1.0;
    } else if (isAvailable) {
      borderColor = gold;
      bgColor = gold.withValues(alpha: Opacities.faint);
      opacity = 1.0;
    } else {
      borderColor = theme.colorScheme.outlineVariant.withValues(alpha: Opacities.medium);
      bgColor =
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: Opacities.medium);
      opacity = Opacities.semi;
    }

    final card = AnimatedContainer(
      duration: AnimDurations.normal,
      width: 58,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: Spacing.s),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: RadiiBR.md,
        border: Border.all(
          color: borderColor,
          width: isAvailable ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day number circle
          _DayCircle(
            day: def.day,
            isClaimed: isClaimed,
            isAvailable: isAvailable,
            theme: theme,
          ),
          const SizedBox(height: 4),
          // Reward shorthand
          _buildRewardIcons(),
          const SizedBox(height: 4),
          // Bottom: claim button or icon
          if (isAvailable)
            _ClaimButton(label: l10n.dailyCalendarClaim, onTap: onClaim)
          else if (isFuture)
            Icon(
              Icons.lock_outline_rounded,
              size: IconSizes.xs,
              color: theme.colorScheme.outline,
            )
          else
            const SizedBox(height: 13),
        ],
      ),
    );

    Widget result = Opacity(opacity: opacity, child: card);

    // Add pulsing glow when available-but-not-yet-claiming
    if (isAvailable && !isClaiming) {
      result = result
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.035, 1.035),
            duration: AnimDurations.long,
            curve: AppCurves.standard,
          );
    }

    // Bounce + shimmer flash on the claiming frame
    if (isAvailable && isClaiming) {
      result = AnimatedBuilder(
        animation: claimAnim,
        builder: (_, child) {
          final t = claimAnim.value;
          // 0→0.5: scale up, 0.5→1: scale back down
          final scale =
              t < 0.5 ? 1.0 + t * 0.16 : 1.08 - (t - 0.5) * 0.16;
          return Transform.scale(scale: scale, child: child);
        },
        child: result,
      );
    }

    return result;
  }
}

// ── Small helper widgets ─────────────────────────────────────────────────────

class _DayCircle extends StatelessWidget {
  final int day;
  final bool isClaimed;
  final bool isAvailable;
  final ThemeData theme;

  const _DayCircle({
    required this.day,
    required this.isClaimed,
    required this.isAvailable,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final gold = theme.gameColors.star;
    final bg = isClaimed
        ? Colors.green
        : isAvailable
            ? gold
            : theme.colorScheme.surfaceContainerHighest;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: isClaimed
            ? const Icon(Icons.check_rounded, color: Colors.white, size: IconSizes.sm)
            : Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isAvailable
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                ),
              ),
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _ClaimButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.gameColors.star;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: gold,
          borderRadius: RadiiBR.sm,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: Opacities.light),
        borderRadius: BorderRadius.circular(Spacing.xs),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  final ThemeData theme;

  const _Skeleton({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 138,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: Opacities.semi),
        borderRadius: RadiiBR.lg,
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: AnimDurations.slowest,
          color: theme.colorScheme.onSurface.withValues(alpha: Opacities.faintest),
        );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _ParticleShower — overlay reward icons that fly up and fade out
// ──────────────────────────────────────────────────────────────────────────────

class _ParticleShower extends StatelessWidget {
  final DailyReward? reward;

  const _ParticleShower({this.reward});

  static const _particleIconData = <IconData>[
    Icons.diamond_rounded,
    Icons.auto_awesome_rounded,
    Icons.star_rounded,
    Icons.diamond_rounded,
    Icons.auto_awesome_rounded,
    Icons.search_rounded,
    Icons.undo_rounded,
    Icons.palette_rounded,
  ];

  /// Build theme-aware particle icon list
  static List<({IconData icon, Color color})> _buildParticleIcons(
    GameColors gameColors,
    ColorScheme colorScheme,
  ) {
    return [
      (icon: _particleIconData[0], color: gameColors.star),
      (icon: _particleIconData[1], color: gameColors.star),
      (icon: _particleIconData[2], color: gameColors.star),
      (icon: _particleIconData[3], color: colorScheme.primary),
      (icon: _particleIconData[4], color: gameColors.star),
      (icon: _particleIconData[5], color: colorScheme.primary),
      (icon: _particleIconData[6], color: colorScheme.secondary),
      (icon: _particleIconData[7], color: colorScheme.tertiary),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (reward == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final particleIcons = _buildParticleIcons(theme.gameColors, theme.colorScheme);

    final icons = <({IconData icon, Color color})>[];
    if (reward!.credits > 0) {
      icons.addAll([particleIcons[0], particleIcons[1], particleIcons[2], particleIcons[3], particleIcons[4]]);
    }
    if (reward!.revealHints > 0) icons.add(particleIcons[5]);
    if (reward!.undoHints > 0) icons.add(particleIcons[6]);
    if (reward!.specialTheme) icons.add(particleIcons[7]);
    while (icons.length < 6) {
      icons.add(particleIcons[1]); // sparkle
    }

    final rng = math.Random(42); // fixed seed → deterministic positions
    const count = 8;

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: List.generate(count, (i) {
            final dx = (rng.nextDouble() - 0.5) * 180;
            final p = icons[i % icons.length];
            return Animate(
              delay: Duration(milliseconds: i * 90),
              effects: [
                SlideEffect(
                  begin: const Offset(0, 0),
                  end: Offset(dx / 100, -1.4),
                  duration: AnimDurations.slowest,
                  curve: Curves.easeOut,
                ),
                const FadeEffect(
                  begin: 1.0,
                  end: 0.0,
                  delay: AnimDurations.slow,
                  duration: AnimDurations.slower,
                ),
                const ScaleEffect(
                  begin: Offset(0.4, 0.4),
                  end: Offset(1.3, 1.3),
                  duration: AnimDurations.normal,
                ),
              ],
              child: Icon(p.icon, size: IconSizes.mld, color: p.color),
            );
          }),
        ),
      ),
    );
  }
}
