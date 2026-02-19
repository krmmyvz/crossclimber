import 'package:flutter/material.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/game_colors.dart';

/// Widget builders for shop package cards
mixin ShopScreenCards {
  Widget buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: SpacingInsets.s,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: RadiiBR.sm,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        HorizontalSpacing.s,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCreditPackageCard(
    BuildContext context, {
    required int amount,
    required String price,
    required VoidCallback onTap,
    bool popular = false,
    String? bonus,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: popular ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiiBR.md,
        child: Container(
          padding: SpacingInsets.m,
          decoration: BoxDecoration(
            borderRadius: RadiiBR.md,
            border: popular
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.s + Spacing.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: RadiiBR.md,
                ),
                child: Icon(
                  Icons.monetization_on,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
              HorizontalSpacing.m,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$amount Kredi',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (popular) ...[
                          HorizontalSpacing.s,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: RadiiBR.md,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.mostPopular,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (bonus != null)
                      Text(
                        bonus,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: RadiiBR.xl,
                ),
                child: Text(
                  price,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLifePackageCard(
    BuildContext context, {
    required int amount,
    required int cost,
    required int currentCredits,
    required Function(int, int) onPurchase,
    bool popular = false,
  }) {
    final theme = Theme.of(context);
    final canAfford = currentCredits >= cost;

    return Card(
      elevation: popular ? 4 : 1,
      child: InkWell(
        onTap: canAfford ? () => onPurchase(amount, cost) : null,
        borderRadius: RadiiBR.md,
        child: Container(
          padding: SpacingInsets.m,
          decoration: BoxDecoration(
            borderRadius: RadiiBR.md,
            border: popular
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.s + Spacing.xs),
                decoration: BoxDecoration(
                  color: canAfford
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: RadiiBR.md,
                ),
                child: Icon(
                  Icons.favorite,
                  size: 32,
                  color: canAfford
                      ? theme.gameColors.lives
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              HorizontalSpacing.m,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$amount Can',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: canAfford
                                ? null
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (popular) ...[
                          HorizontalSpacing.s,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: RadiiBR.md,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.popularLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    VerticalSpacing.xs,
                    Text(
                      amount == 1
                          ? AppLocalizations.of(context)!.buyOneLifeDesc
                          : AppLocalizations.of(context)!.buyFiveLives,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              HorizontalSpacing.m,
              Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    size: 20,
                    color: canAfford
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  HorizontalSpacing.xs,
                  Text(
                    '$cost',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: canAfford
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHintPackageCard(
    BuildContext context, {
    required String hintType,
    required IconData icon,
    required String title,
    required String description,
    required int amount,
    required int cost,
    required int currentCredits,
    required Function(String, int, int) onPurchase,
    bool popular = false,
  }) {
    final theme = Theme.of(context);
    final canAfford = currentCredits >= cost;

    return Card(
      elevation: popular ? 4 : 1,
      child: InkWell(
        onTap: canAfford ? () => onPurchase(hintType, amount, cost) : null,
        borderRadius: RadiiBR.md,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: RadiiBR.md,
            border: popular
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: canAfford
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: RadiiBR.md,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: canAfford
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: Spacing.s + Spacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '$amount x $title',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: canAfford
                                  ? null
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (popular) ...[
                          HorizontalSpacing.s,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: RadiiBR.md,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.popularLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    VerticalSpacing.xs,
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.s + Spacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    size: 20,
                    color: canAfford
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  HorizontalSpacing.xs,
                  Text(
                    '$cost',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: canAfford
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
