import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/widgets/skeleton_loading.dart';
import 'package:crossclimber/widgets/achievements/achievement_progress_header.dart';
import 'package:crossclimber/widgets/achievements/achievement_card.dart';
import 'package:crossclimber/widgets/empty_state_widget.dart';
import 'package:crossclimber/widgets/discovery_banner.dart';
import 'package:crossclimber/providers/discovery_tip_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final achievementService = AchievementService();

    return Scaffold(
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
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;
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
                // Achievements List
                Expanded(
                  child: ListView.builder(
                    padding: SpacingInsets.m,
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      return AchievementCard(
                        achievement: achievements[index],
                        index: index,
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return const Column(
      children: [
        // Progress Header Skeleton
        Padding(
          padding: SpacingInsets.m,
          child: SkeletonCard(height: 120),
        ),
        // Achievements List Skeleton
        Expanded(child: SkeletonList(itemCount: 6, itemHeight: 100)),
      ],
    );
  }
}
