import 'package:flutter/material.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';

/// Widget builders for rewards section in shop
mixin ShopScreenRewards {
  Widget buildDailyRewardCard(
    BuildContext context, {
    required VoidCallback onTap,
    required int dailyStreak,
  }) {
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiiBR.md,
        child: Container(
          padding: SpacingInsets.m,
          decoration: BoxDecoration(
            borderRadius: RadiiBR.md,
            gradient: LinearGradient(
              colors: [
                gameColors.success.withValues(alpha: 0.2),
                gameColors.success.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: gameColors.success, width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.m),
                decoration: BoxDecoration(
                  color: gameColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: 32,
                  color: gameColors.onSuccess,
                ),
              ),
              HorizontalSpacing.m,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.dailyRewardClaim,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    VerticalSpacing.xxs,
                    Text(
                      AppLocalizations.of(context)!.dailyRewardAmount,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: gameColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (dailyStreak > 0) ...[
                      VerticalSpacing.xxs,
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.dailyRewardStreak(dailyStreak),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: gameColors.success),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAdRewardCard(
    BuildContext context, {
    required VoidCallback onWatchAdForCredits,
    required VoidCallback onWatchAdForHint,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: SpacingInsets.m,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_filled,
                  color: theme.colorScheme.tertiary,
                  size: 32,
                ),
                HorizontalSpacing.s,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.watchAdsTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.watchAdsSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            VerticalSpacing.m,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onWatchAdForCredits,
                    icon: const Icon(Icons.monetization_on),
                    label: Text(AppLocalizations.of(context)!.watchAdCredits),
                  ),
                ),
                HorizontalSpacing.s,
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onWatchAdForHint,
                    icon: const Icon(Icons.lightbulb),
                    label: Text(AppLocalizations.of(context)!.watchAdHint),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRewardItem(
    ThemeData theme,
    IconData icon,
    String text,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          HorizontalSpacing.s,
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
