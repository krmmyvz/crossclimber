import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/utils/achievement_utils.dart';
import 'package:crossclimber/widgets/achievements/achievement_card.dart';
import 'package:crossclimber/widgets/achievements/achievement_progress_header.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/widgets/discovery_banner.dart';
import 'package:crossclimber/widgets/empty_state_widget.dart';
import 'package:crossclimber/widgets/modern_dialog.dart';
import 'package:crossclimber/widgets/skeleton_loading.dart';
import 'package:crossclimber/providers/discovery_tip_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final achievementService = AchievementService();

    // Show toast for newly unlocked achievements
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
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(recentlyUnlockedAchievementsProvider.notifier).clear();
        });
      }
    });

    final clampedTextScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
      child: Scaffold(
        appBar: CommonAppBar(
          title: l10n.achievements,
          type: AppBarType.standard,
          showCredits: false,
        ),
        body: FutureBuilder<List<Achievement>>(
          future: achievementService.getAllAchievements(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildLoadingSkeleton(theme);
            }

            final achievements = snapshot.data!;
            final unlockedCount = achievements
                .where((a) => a.isUnlocked)
                .length;
            final totalCount = achievements.length;

            return Column(
              children: [
                DiscoveryBanner(
                  feature: DiscoveryFeature.achievements,
                  icon: Icons.emoji_events_rounded,
                  title: l10n.discoveryAchievementsTitle,
                  description: l10n.discoveryAchievementsDesc,
                  ctaLabel: l10n.discoveryGotIt,
                ),

                // Progress Header
                AchievementProgressHeader(
                  unlocked: unlockedCount,
                  total: totalCount,
                ),

                // Empty state if nothing unlocked yet
                if (unlockedCount == 0)
                  Padding(
                    padding: SpacingInsets.m,
                    child: EmptyStateWidget(
                      icon: Icons.emoji_events_outlined,
                      title: l10n.emptyAchievementsTitle,
                      description: l10n.emptyAchievementsDesc,
                    ),
                  )
                else
                  // Achievements grouped by rarity
                  Expanded(
                    child: _RarityGroupedList(achievements: achievements),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return const Column(
      children: [
        // Progress Header Skeleton
        Padding(padding: SpacingInsets.m, child: SkeletonCard(height: 120)),
        // Achievements List Skeleton
        Expanded(child: SkeletonList(itemCount: 6, itemHeight: 100)),
      ],
    );
  }
}

// ─── Rarity-grouped achievements list ────────────────────────────────────────

class _RarityGroupedList extends StatelessWidget {
  final List<Achievement> achievements;
  const _RarityGroupedList({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    List<Widget> items = [];
    var globalIndex = 0;

    for (final rarity in [
      AchievementRarity.legendary,
      AchievementRarity.rare,
      AchievementRarity.common,
    ]) {
      final group =
          achievements
              .where((a) => AchievementUtils.getRarity(a.type) == rarity)
              .toList()
            ..sort((a, b) {
              if (a.isUnlocked == b.isUnlocked) return 0;
              return a.isUnlocked ? -1 : 1;
            });

      if (group.isEmpty) continue;

      // Section header
      items.add(_RarityHeader(rarity: rarity, l10n: l10n));

      for (final ach in group) {
        items.add(AchievementCard(achievement: ach, index: globalIndex++));
      }
    }

    return ListView(
      padding: SpacingInsets.m,
      children: items
          .asMap()
          .entries
          .map(
            (e) => e.value
                .animate()
                .fadeIn(delay: StaggerDelay.extraFast(e.key))
                .slideY(begin: 0.05),
          )
          .toList(),
    );
  }
}

class _RarityHeader extends StatelessWidget {
  final AchievementRarity rarity;
  final AppLocalizations l10n;
  const _RarityHeader({required this.rarity, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color = AchievementUtils.rarityColor(rarity, context);
    final label = AchievementUtils.rarityLabel(rarity, l10n);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.s, top: Spacing.m),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 22,
            decoration: BoxDecoration(color: color, borderRadius: RadiiBR.xxs),
          ),
          const SizedBox(width: Spacing.s),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
