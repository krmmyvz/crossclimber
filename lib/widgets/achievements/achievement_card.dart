import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/utils/achievement_utils.dart';
import 'package:crossclimber/widgets/app_progress_bar.dart';
import 'package:crossclimber/widgets/modern_dialog.dart';

// ─── selectedBadgeProvider ───────────────────────────────────────────────────

final selectedBadgeTypeIndexProvider = FutureProvider<int?>((ref) {
  return AchievementService().getSelectedBadgeTypeIndex();
});

// ─── AchievementCard ─────────────────────────────────────────────────────────

class AchievementCard extends ConsumerWidget {
  final Achievement achievement;
  final int index;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLocked = !achievement.isUnlocked;

    final recentlyUnlocked = ref.watch(recentlyUnlockedAchievementsProvider);
    final isNew = recentlyUnlocked.any((a) => a.type == achievement.type);

    final rarity = AchievementUtils.getRarity(achievement.type);
    final rarityColor = AchievementUtils.rarityColor(rarity, context);
    final rarityLabel = AchievementUtils.rarityLabel(rarity, l10n);

    final selectedBadgeAsync = ref.watch(selectedBadgeTypeIndexProvider);
    final isSelectedBadge =
        selectedBadgeAsync.asData?.value == achievement.type.index;

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: Spacing.s + Spacing.xs),
      decoration: BoxDecoration(
        color: isLocked
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: Opacities.half)
            : theme.colorScheme.surface,
        borderRadius: RadiiBR.md,
        border: Border.all(
          color: isNew
              ? rarityColor.withValues(alpha: Opacities.heavy)
              : isLocked
                  ? theme.colorScheme.outline.withValues(alpha: Opacities.medium)
                  : rarityColor.withValues(alpha: Opacities.semi),
          width: isNew ? 2 : 1,
        ),
        boxShadow: isLocked
            ? null
            : [
                BoxShadow(
                  color: (isNew ? rarityColor : theme.colorScheme.primary)
                      .withValues(alpha: isNew ? Opacities.quarter : Opacities.subtle),
                  blurRadius: isNew ? 12 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: SpacingInsets.m,
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isLocked
                    ? theme.colorScheme.surfaceContainerHighest
                    : rarityColor.withValues(alpha: Opacities.light),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLocked
                      ? theme.colorScheme.outline
                      : rarityColor.withValues(alpha: Opacities.strong),
                  width: 2,
                ),
              ),
              child: Icon(
                AchievementUtils.getIcon(achievement.type),
                color: isLocked ? theme.colorScheme.outline : rarityColor,
                size: IconSizes.xl,
              ),
            ),
            HorizontalSpacing.m,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + rarity + lock
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AchievementUtils.getTitle(l10n, achievement.type),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLocked
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: Opacities.half)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: rarityColor
                              .withValues(alpha: isLocked ? Opacities.faint : Opacities.light),
                          borderRadius: RadiiBR.xs,
                          border: Border.all(
                            color: rarityColor
                                .withValues(alpha: isLocked ? Opacities.gentle : Opacities.semi),
                          ),
                        ),
                        child: Text(
                          rarityLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isLocked
                                ? rarityColor.withValues(alpha: Opacities.half)
                                : rarityColor,
                          ),
                        ),
                      ),
                      if (isLocked) ...[
                        HorizontalSpacing.xs,
                        Icon(
                          Icons.lock,
                          size: IconSizes.mld,
                          color: theme.colorScheme.outline,
                        ),
                      ],
                    ],
                  ),
                  VerticalSpacing.xs,
                  Text(
                    AchievementUtils.getDescription(l10n, achievement.type),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isLocked
                          ? theme.colorScheme.onSurface.withValues(alpha: Opacities.semi)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  // Unlocked date + badge button
                  if (!isLocked && achievement.unlockedAt != null) ...[
                    VerticalSpacing.s,
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: IconSizes.sm,
                          color: theme.colorScheme.primary,
                        ),
                        HorizontalSpacing.xs,
                        Expanded(
                          child: Text(
                            _formatDate(l10n, achievement.unlockedAt!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _BadgeButton(
                          achievement: achievement,
                          isSelected: isSelectedBadge,
                          onToggle: () async {
                            final svc = AchievementService();
                            if (isSelectedBadge) {
                              await svc.setSelectedBadgeTypeIndex(null);
                            } else {
                              await svc.setSelectedBadgeTypeIndex(
                                achievement.type.index,
                              );
                            }
                            ref.invalidate(selectedBadgeTypeIndexProvider);
                            if (context.mounted) {
                              ModernNotification.show(
                                context: context,
                                message: isSelectedBadge
                                    ? l10n.achievementBadgeRemoved
                                    : l10n.achievementBadgeSelected,
                                icon: Icons.workspace_premium_rounded,
                                backgroundColor: rarityColor,
                                iconColor: Colors.white,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                  // Progress bar
                  if (achievement.progress < achievement.target) ...[
                    VerticalSpacing.s,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.progress,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${achievement.progress}/${achievement.target}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        VerticalSpacing.xs,
                        AppProgressBar(
                          value: achievement.progress / achievement.target,
                          minValue: 0.02,
                          color: isLocked
                              ? theme.colorScheme.outline
                              : rarityColor,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          borderRadius: RadiiBR.xs,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    card = card
        .animate()
        .fadeIn(delay: (index * 50).ms)
        .slideX(begin: 0.2);

    if (isNew) {
      card = card
          .animate(onPlay: (c) => c.repeat(reverse: true, count: 3))
          .shimmer(
            duration: AnimDurations.mediumSlow,
            color: rarityColor.withValues(alpha: Opacities.medium),
          );
    }

    return card;
  }

  String _formatDate(AppLocalizations l10n, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return l10n.today;
    if (diff.inDays == 1) return l10n.yesterday;
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ─── _BadgeButton ─────────────────────────────────────────────────────────────

class _BadgeButton extends StatelessWidget {
  final Achievement achievement;
  final bool isSelected;
  final VoidCallback onToggle;

  const _BadgeButton({
    required this.achievement,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rarity = AchievementUtils.getRarity(achievement.type);
    final rarityColor = AchievementUtils.rarityColor(rarity, context);
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: isSelected
          ? l10n.achievementBadgeRemove
          : l10n.achievementBadgeSelect,
      child: InkWell(
        borderRadius: RadiiBR.sm,
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? rarityColor.withValues(alpha: Opacities.soft)
                : Colors.transparent,
            borderRadius: RadiiBR.sm,
            border: Border.all(
              color: isSelected
                  ? rarityColor.withValues(alpha: Opacities.strong)
                  : cs.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected
                    ? Icons.workspace_premium_rounded
                    : Icons.workspace_premium_outlined,
                size: IconSizes.xsm,
                color: isSelected ? rarityColor : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 3),
              Text(
                isSelected
                    ? l10n.achievementBadgeActive
                    : l10n.achievementBadgeSelect,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? rarityColor : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
