import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/services/xp_service.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/shadows.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/utils/achievement_utils.dart';
import 'package:crossclimber/widgets/achievements/achievement_card.dart';
import 'package:crossclimber/widgets/app_progress_bar.dart';

/// Compact profile card showing avatar, rank badge, and XP progress bar.
/// Designed for use on the HomeScreen or as a header in Settings/Profile.
class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final gameColors = theme.gameColors;
    final rankAsync = ref.watch(playerRankInfoProvider);

    final selectedBadgeAsync = ref.watch(selectedBadgeTypeIndexProvider);
    final selectedBadgeIndex = selectedBadgeAsync.asData?.value;

    return rankAsync.when(
      loading: () => _buildSkeleton(theme),
      error: (_, __) => const SizedBox.shrink(),
      data: (rankInfo) {
        final rankDef = kRankDefs[rankInfo.rankIndex];
        final localizedName = rankDef.localizedName(l10n);

        return Container(
          padding: const EdgeInsets.all(Spacing.m),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gameColors.star.withValues(alpha: Opacities.faint),
                theme.colorScheme.surfaceContainerLow,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: RadiiBR.lg,
            border: Border.all(
              color: gameColors.star.withValues(alpha: Opacities.quarter),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Rank emoji avatar with optional achievement badge overlay
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: gameColors.star.withValues(alpha: Opacities.light),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: gameColors.star.withValues(alpha: Opacities.semi),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        rankInfo.icon,
                        size: IconSizes.lg,
                        color: gameColors.star,
                      ),
                    ),
                  ),
                  if (selectedBadgeIndex != null)
                    _buildBadgeOverlay(context, selectedBadgeIndex),
                ],
              ),
              const SizedBox(width: Spacing.m),
              // Rank info + XP bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            localizedName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: gameColors.star,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          l10n.totalXpLabel(rankInfo.totalXp),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    // XP progress bar
                    AppProgressBar(
                      value: rankInfo.progress,
                      height: 6,
                      color: gameColors.star,
                      backgroundColor: gameColors.star.withValues(alpha: Opacities.light),
                    ),
                    const SizedBox(height: 2),
                    // Threshold labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${rankInfo.rankThreshold}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: Opacities.semi),
                          ),
                        ),
                        if (!rankInfo.isMaxRank)
                          Text(
                            '${rankInfo.nextThreshold}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: Opacities.semi),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeOverlay(BuildContext context, int typeIndex) {
    if (typeIndex < 0 || typeIndex >= AchievementType.values.length) {
      return const SizedBox.shrink();
    }
    final type = AchievementType.values[typeIndex];
    final rarity = AchievementUtils.getRarity(type);
    final color = AchievementUtils.rarityColor(rarity, context);
    final icon = AchievementUtils.getIcon(type);
    return Positioned(
      bottom: -2,
      right: -2,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.surface,
            width: 2,
          ),
          boxShadow: [
            AppShadows.colorSubtle(color),
          ],
        ),
        child: Icon(icon, size: IconSizes.xs, color: Colors.white),
      ),
    );
  }

  Widget _buildSkeleton(ThemeData theme) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: Opacities.half),
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
