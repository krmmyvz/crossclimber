import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/models/tournament.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/providers/locale_provider.dart';
import 'package:crossclimber/screens/game_screen.dart';
import 'package:crossclimber/services/tournament_service.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/widgets/offline_banner.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/theme/animations.dart';

// ──────────────────────────────────────────────────────────────────────────────
/// Weekly Tournament Screen.
///
/// Shows the countdown timer, the 7 tournament levels, the Live leaderboard
/// (top-10 + user's own position) and the reward tier table.
// ──────────────────────────────────────────────────────────────────────────────

class TournamentScreen extends ConsumerStatefulWidget {
  const TournamentScreen({super.key});

  @override
  ConsumerState<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends ConsumerState<TournamentScreen> {
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final tournamentAsync = ref.read(currentTournamentProvider);
      final tournament = tournamentAsync.value;
      if (tournament == null) return; // still loading

      final remaining = tournament.status == TournamentStatus.active
          ? tournament.remainingDuration
          : tournament.durationUntilStart;

      setState(() => _remaining = remaining);
    });
  }

  String _formatDuration(Duration d) {
    if (d <= Duration.zero) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (d.inHours > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  void _openLevel(Level level, TournamentInfo tournament) {
    if (!OfflineGuard.check(ref, context)) return;
    Navigator.push(
      context,
      AppPageRoute(builder: (_) => GameScreen(level: level)),
    ).then((_) {
      // Refresh user entry after returning from game
      ref.invalidate(myTournamentEntryProvider(tournament.weekId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final tournamentAsync = ref.watch(currentTournamentProvider);

    final clampedTextScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
      child: Scaffold(
        appBar: CommonAppBar(
          title: l10n.tournamentTitle,
          type: AppBarType.standard,
          showCredits: false,
          showStreak: false,
        ),
        body: tournamentAsync.when(
          loading: () => const _LoadingBody(),
          error: (_, __) => _ErrorBody(message: l10n.tournamentLoadError),
          data: (tournament) {
            return _TournamentBody(
              tournament: tournament,
              remaining: _remaining,
              formatDuration: _formatDuration,
              onPlayLevel: (level) => _openLevel(level, tournament),
            );
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _TournamentBody — main content
// ──────────────────────────────────────────────────────────────────────────────

class _TournamentBody extends ConsumerWidget {
  final TournamentInfo tournament;
  final Duration remaining;
  final String Function(Duration) formatDuration;
  final void Function(Level) onPlayLevel;

  const _TournamentBody({
    required this.tournament,
    required this.remaining,
    required this.formatDuration,
    required this.onPlayLevel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;

    final levelsAsync = ref.watch(levelsProvider(locale));
    final leaderboardAsync = ref.watch(
      tournamentLeaderboardProvider(tournament.weekId),
    );
    final myEntryAsync = ref.watch(
      myTournamentEntryProvider(tournament.weekId),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header card with status + countdown ───────────────────────
          _HeaderCard(
            tournament: tournament,
            remaining: remaining,
            formatDuration: formatDuration,
            l10n: l10n,
          ).animate().fadeIn().slideY(begin: 0.08),

          const SizedBox(height: Spacing.m),

          // ── My rank summary ───────────────────────────────────────────
          myEntryAsync
              .when(
                loading: () => const _SectionSkeleton(height: 64),
                error: (_, __) => const SizedBox.shrink(),
                data: (entry) => _MyRankSummary(entry: entry, l10n: l10n),
              )
              .animate()
              .fadeIn(delay: 60.ms),

          const SizedBox(height: Spacing.m),

          // ── Tournament levels ─────────────────────────────────────────
          _SectionLabel(label: l10n.tournamentLevels),
          const SizedBox(height: Spacing.s),
          levelsAsync
              .when(
                loading: () => const _SectionSkeleton(height: 220),
                error: (_, __) => const SizedBox.shrink(),
                data: (allLevels) {
                  final levels =
                      allLevels
                          .where((l) => tournament.levelIds.contains(l.id))
                          .toList()
                        ..sort((a, b) => a.id.compareTo(b.id));

                  return myEntryAsync.when(
                    loading: () => const _SectionSkeleton(height: 220),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (entry) => _LevelGrid(
                      levels: levels,
                      myEntry: entry,
                      isActive: tournament.isActive,
                      onPlay: onPlayLevel,
                      l10n: l10n,
                    ),
                  );
                },
              )
              .animate()
              .fadeIn(delay: AnimDurations.micro),

          const SizedBox(height: Spacing.m),

          // ── Live leaderboard ──────────────────────────────────────────
          _SectionLabel(label: l10n.tournamentLeaderboard),
          const SizedBox(height: Spacing.s),
          leaderboardAsync
              .when(
                loading: () => const _SectionSkeleton(height: 300),
                error: (_, __) => const SizedBox.shrink(),
                data: (entries) => _Leaderboard(
                  entries: entries,
                  myEntry: myEntryAsync.value,
                  l10n: l10n,
                ),
              )
              .animate()
              .fadeIn(delay: 140.ms),

          const SizedBox(height: Spacing.m),

          // ── Reward tiers ──────────────────────────────────────────────
          _SectionLabel(label: l10n.tournamentRewards),
          const SizedBox(height: Spacing.s),
          _RewardTiers(l10n: l10n).animate().fadeIn(delay: 180.ms),

          const SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _HeaderCard
// ──────────────────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final TournamentInfo tournament;
  final Duration remaining;
  final String Function(Duration) formatDuration;
  final AppLocalizations l10n;

  const _HeaderCard({
    required this.tournament,
    required this.remaining,
    required this.formatDuration,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = tournament.isActive;
    final statusColor = isActive ? Colors.green : theme.colorScheme.outline;
    final countdownLabel = isActive
        ? l10n.tournamentEndsIn(formatDuration(remaining))
        : tournament.status == TournamentStatus.upcoming
        ? l10n.tournamentNextIn(formatDuration(remaining))
        : l10n.tournamentEnded;

    return Container(
      padding: const EdgeInsets.all(Spacing.m),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: RadiiBR.lg,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: Opacities.quarter),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: IconSizes.mld,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: Spacing.s),
              Expanded(
                child: Text(
                  l10n.tournamentTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.s,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: Opacities.soft),
                  borderRadius: BorderRadius.circular(Spacing.xs),
                  border: Border.all(color: statusColor.withValues(alpha: Opacities.half)),
                ),
                child: Text(
                  isActive ? l10n.tournamentActive : l10n.tournamentEnded,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.s),
          // Countdown
          if (remaining > Duration.zero) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: IconSizes.xsm,
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.7,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  countdownLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
          ],
          // Week pill
          Center(
            child: Text(
              l10n.tournamentWeek(tournament.weekId.replaceAll('-', ' ')),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.65,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _MyRankSummary
// ──────────────────────────────────────────────────────────────────────────────

class _MyRankSummary extends StatelessWidget {
  final TournamentEntry? entry;
  final AppLocalizations l10n;

  const _MyRankSummary({required this.entry, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;

    if (entry == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m,
          vertical: Spacing.s,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: RadiiBR.lg,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: Opacities.semi),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              color: theme.colorScheme.outline,
              size: IconSizes.md,
            ),
            const SizedBox(width: Spacing.s),
            Text(
              l10n.tournamentNotParticipating,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final tier = TournamentRewardTier.forRank(
      entry!.rank > 0 ? entry!.rank : 101,
    );

    return Container(
      padding: const EdgeInsets.all(Spacing.m),
      decoration: BoxDecoration(
        color: gameColors.success.withValues(alpha: Opacities.faint),
        borderRadius: RadiiBR.lg,
        border: Border.all(color: gameColors.success.withValues(alpha: Opacities.medium)),
      ),
      child: Row(
        children: [
          Icon(tier.icon, size: IconSizes.lg, color: tier.iconColor),
          const SizedBox(width: Spacing.s),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tournamentMyRank,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                entry!.rank > 0 ? l10n.tournamentRank(entry!.rank) : '—',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.tournamentScore(entry!.totalScore),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                l10n.tournamentLevelsProgress(entry!.levelsCompleted),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _LevelGrid
// ──────────────────────────────────────────────────────────────────────────────

class _LevelGrid extends StatelessWidget {
  final List<Level> levels;
  final TournamentEntry? myEntry;
  final bool isActive;
  final void Function(Level) onPlay;
  final AppLocalizations l10n;

  const _LevelGrid({
    required this.levels,
    required this.myEntry,
    required this.isActive,
    required this.onPlay,
    required this.l10n,
  });

  String _difficultyLabel(int d, AppLocalizations l10n) => switch (d) {
    1 => l10n.tournamentDifficultyEasy,
    2 => l10n.tournamentDifficultyMedium,
    _ => l10n.tournamentDifficultyHard,
  };

  Color _difficultyColor(int d, GameColors gc) => switch (d) {
    1 => gc.correct,
    2 => const Color(0xFF2196F3),
    _ => gc.incorrect,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Spacing.s,
        mainAxisSpacing: Spacing.s,
        childAspectRatio: 1.5,
      ),
      itemCount: levels.length,
      itemBuilder: (context, i) {
        final level = levels[i];
        final completed = myEntry?.hasCompletedLevel(level.id) ?? false;
        final score = myEntry?.scoreForLevel(level.id) ?? 0;
        final diffColor = _difficultyColor(level.difficulty, gameColors);

        return AnimatedContainer(
              duration: AnimDurations.normal,
              decoration: BoxDecoration(
                color: completed
                    ? gameColors.correct.withValues(alpha: Opacities.faint)
                    : theme.colorScheme.surfaceContainerLow,
                borderRadius: RadiiBR.lg,
                border: Border.all(
                  color: completed
                      ? gameColors.correct.withValues(alpha: Opacities.medium)
                      : diffColor.withValues(alpha: Opacities.medium),
                ),
              ),
              child: InkWell(
                borderRadius: RadiiBR.lg,
                onTap: (isActive && !completed) ? () => onPlay(level) : null,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Difficulty pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: diffColor.withValues(alpha: Opacities.light),
                              borderRadius: RadiiBR.xs,
                            ),
                            child: Text(
                              _difficultyLabel(level.difficulty, l10n),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: diffColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (completed)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: IconSizes.xsm,
                              color: Colors.green,
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'Lvl ${level.id}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (completed) ...[
                        Text(
                          l10n.tournamentScore(score),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Text(
                          isActive ? l10n.tournamentPlay : l10n.tournamentEnded,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(delay: Duration(milliseconds: i * 50))
            .slideY(begin: 0.06);
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _Leaderboard
// ──────────────────────────────────────────────────────────────────────────────

class _Leaderboard extends StatelessWidget {
  final List<TournamentEntry> entries;
  final TournamentEntry? myEntry;
  final AppLocalizations l10n;

  const _Leaderboard({
    required this.entries,
    required this.myEntry,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topEntries = entries.take(10).toList();

    // Insert user's own entry at end if not already in top 10
    final myUid = myEntry?.uid;
    final isInTop10 = myUid != null && topEntries.any((e) => e.uid == myUid);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: Opacities.semi),
        ),
      ),
      child: Column(
        children: [
          if (topEntries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(Spacing.m),
              child: Text(
                l10n.tournamentNotParticipating,
                style: theme.textTheme.bodySmall,
              ),
            )
          else
            ...topEntries.asMap().entries.map((e) {
              final index = e.key;
              final entry = e.value;
              final isMe = entry.uid == myUid;
              return _LeaderboardRow(
                    entry: entry,
                    rank: index + 1,
                    isMe: isMe,
                    isLast: index == topEntries.length - 1 && isInTop10,
                    l10n: l10n,
                  )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: index * 40))
                  .slideX(begin: 0.04);
            }),

          // User's own entry if outside top 10
          if (!isInTop10 && myEntry != null) ...[
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: Opacities.medium),
            ),
            _LeaderboardRow(
              entry: myEntry!,
              rank: myEntry!.rank,
              isMe: true,
              isLast: true,
              l10n: l10n,
            ),
          ],
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final TournamentEntry entry;
  final int rank;
  final bool isMe;
  final bool isLast;
  final AppLocalizations l10n;

  const _LeaderboardRow({
    required this.entry,
    required this.rank,
    required this.isMe,
    required this.isLast,
    required this.l10n,
  });

  Widget _rankIcon(int r) {
    final tier = TournamentRewardTier.forRank(r);
    return switch (r) {
      1 ||
      2 ||
      3 => Icon(tier.icon, size: IconSizes.smd, color: tier.iconColor),
      _ => Text(
        '$r.',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: tier.iconColor,
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const medalRanks = {1, 2, 3};

    return Container(
      decoration: BoxDecoration(
        color: isMe
            ? theme.colorScheme.primaryContainer.withValues(alpha: Opacities.quarter)
            : null,
        borderRadius: isLast ? RadiiBR.lg : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.m,
              vertical: Spacing.s,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: medalRanks.contains(rank)
                      ? _rankIcon(rank)
                      : Text(
                          '$rank.',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
                const SizedBox(width: Spacing.s),
                Expanded(
                  child: Text(
                    '${entry.displayName}${isMe ? ' (You)' : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                      color: isMe ? theme.colorScheme.primary : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  l10n.tournamentScore(entry.totalScore),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(
              height: 1,
              indent: Spacing.m,
              endIndent: Spacing.m,
              color: theme.colorScheme.outlineVariant.withValues(alpha: Opacities.quarter),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _RewardTiers
// ──────────────────────────────────────────────────────────────────────────────

class _RewardTiers extends StatelessWidget {
  final AppLocalizations l10n;

  const _RewardTiers({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const tiers = TournamentRewardTier.tiers;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: Opacities.semi),
        ),
      ),
      child: Column(
        children: tiers.asMap().entries.map((e) {
          final index = e.key;
          final tier = e.value;
          final isTop3 = tier.maxRank <= 3;

          final rankLabel = tier.minRank == tier.maxRank
              ? '#${tier.minRank}'
              : tier.maxRank >= 99999
              ? '#${tier.minRank}+'
              : '#${tier.minRank}–#${tier.maxRank}';

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.m,
                  vertical: Spacing.s,
                ),
                child: Row(
                  children: [
                    Icon(
                      tier.icon,
                      size: isTop3 ? 20 : 16,
                      color: tier.iconColor,
                    ),
                    const SizedBox(width: Spacing.s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rankLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (tier.hasBadge)
                            Text(
                              '+ Special Badge',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      l10n.tournamentCreditsReward(tier.credits),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFB300),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < tiers.length - 1)
                Divider(
                  height: 1,
                  indent: Spacing.m,
                  endIndent: Spacing.m,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.2,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  final double height;
  const _SectionSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
          height: height,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.4,
            ),
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

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
