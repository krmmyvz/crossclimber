import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/game_provider.dart';
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
    final gameState = ref.watch(gameProvider);
    final l10n = AppLocalizations.of(context)!;

    if (gameState.phase != GamePhase.guessing) {
      return const SizedBox.shrink();
    }

    final isEnabled = selectedRowIndex != null;
    final hintStocksAsync = ref.watch(hintStocksProvider);

    return hintStocksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (hintStocks) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final isKeyboardOpen = bottomInset > 0;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.s,
          ),
          margin: EdgeInsets.only(bottom: isKeyboardOpen ? 0 : Spacing.m),
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
                isEnabled: isEnabled && gameState.undoHistory.isNotEmpty,
                onTap: () async {
                  if (!isEnabled || gameState.undoHistory.isEmpty) return;
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

  const _CircularHintButton({
    required this.icon,
    required this.hintType,
    required this.stockCount,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasStock = stockCount > 0;
    final canUse = hasStock && isEnabled;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
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
                width: Spacing.buttonHeight,
                height: Spacing.buttonHeight,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: Spacing.iconSize,
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
                  size: 12,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
