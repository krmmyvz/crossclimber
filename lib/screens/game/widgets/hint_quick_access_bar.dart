import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/responsive.dart';
import 'package:crossclimber/theme/spacing.dart';

class HintQuickAccessBar extends ConsumerWidget {
  final int? selectedRowIndex;
  final VoidCallback onHintUsed;
  final Function(BuildContext, AppLocalizations) onShowMarket;

  const HintQuickAccessBar({
    super.key,
    required this.selectedRowIndex,
    required this.onHintUsed,
    required this.onShowMarket,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final phase = ref.watch(gameProvider.select((s) => s.phase));
    final hasUndoHistory = ref.watch(gameProvider.select((s) => s.undoHistory.isNotEmpty));
    final l10n = AppLocalizations.of(context)!;

    if (phase != GamePhase.guessing) {
      return const SizedBox.shrink();
    }

    final isEnabled = selectedRowIndex != null;
    final hintStocksAsync = ref.watch(hintStocksProvider);

    return hintStocksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (hintStocks) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.s,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CircularHintButton(
                icon: Icons.style,
                hintType: 'revealWord',
                stockCount: hintStocks['revealWord'] ?? 0,
                isEnabled: isEnabled,
                semanticsLabel:
                    'Reveal word hint, ${hintStocks['revealWord'] ?? 0} remaining',
                onTap: () async {
                  if (!isEnabled) return;
                  final stock = hintStocks['revealWord'] ?? 0;
                  if (stock > 0) {
                    await ref
                        .read(gameProvider.notifier)
                        .useAdvancedHint('revealWord', selectedRowIndex!);
                    ref.invalidate(hintStocksProvider);
                    onHintUsed();
                  } else {
                    onShowMarket(context, l10n);
                  }
                },
              ),
              _CircularHintButton(
                icon: Icons.undo,
                hintType: 'undo',
                stockCount: hintStocks['undo'] ?? 0,
                isEnabled: isEnabled && hasUndoHistory,
                semanticsLabel:
                    'Undo hint, ${hintStocks['undo'] ?? 0} remaining',
                onTap: () async {
                  if (!isEnabled || !hasUndoHistory) return;
                  final stock = hintStocks['undo'] ?? 0;
                  if (stock > 0) {
                    final progressRepo = ref.read(progressRepositoryProvider);
                    final success = await progressRepo.useHintStock('undo');
                    if (success) {
                      ref.read(gameProvider.notifier).performUndo();
                      ref.invalidate(hintStocksProvider);
                    }
                  } else {
                    onShowMarket(context, l10n);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularHintButton extends StatelessWidget {
  final IconData icon;
  final String hintType;
  final int stockCount;
  final bool isEnabled;
  final VoidCallback onTap;
  final String? semanticsLabel;

  const _CircularHintButton({
    required this.icon,
    required this.hintType,
    required this.stockCount,
    this.isEnabled = true,
    required this.onTap,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasStock = stockCount > 0;
    final canUse = hasStock && isEnabled;
    final isCompact = Responsive.isCompact(context);
    final buttonSize = isCompact ? 36.0 : Spacing.buttonHeight;
    final iconSize = isCompact ? 18.0 : Spacing.iconSize;

    return Semantics(
      label: semanticsLabel ?? '$hintType hint, $stockCount remaining',
      button: true,
      enabled: isEnabled,
      child: Opacity(
      opacity: isEnabled ? 1.0 : 0.65,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: canUse
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHigh,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: isEnabled ? onTap : null,
              customBorder: const CircleBorder(),
              child: Container(
                width: buttonSize,
                height: buttonSize,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: iconSize,
                  color: canUse
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ),
            ),
          ),
          if (hasStock)
            Positioned(
              top: -(Spacing.xs),
              right: -(Spacing.xs),
              child: Container(
                width: Spacing.m + Spacing.xs + Spacing.xxs,
                height: Spacing.m + Spacing.xs + Spacing.xxs,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: Spacing.xxs,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$stockCount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned(
              top: -(Spacing.xs),
              right: -(Spacing.xs),
              child: Container(
                width: Spacing.m + Spacing.xs + Spacing.xxs,
                height: Spacing.m + Spacing.xs + Spacing.xxs,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: Spacing.xxs,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: IconSizes.xs,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    ),    // closes Opacity
    );    // closes Semantics
  }
}
