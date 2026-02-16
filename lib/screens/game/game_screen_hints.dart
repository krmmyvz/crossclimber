import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/border_radius.dart';

/// Mixin providing hint system functionality for GameScreen
mixin GameScreenHints<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Build hint quick access bar
  Widget buildHintQuickAccessBar(
    BuildContext context,
    AppLocalizations l10n,
    GameState gameState,
    Level level, {
    required int? selectedRowIndex,
    required void Function(BuildContext, AppLocalizations) onShowMarket,
    required void Function() onHintUsed,
  }) {
    final theme = Theme.of(context);

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
              _buildCircularHintButton(
                context: context,
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
                        .useAdvancedHint('revealWord', selectedRowIndex);
                    ref.invalidate(hintStocksProvider);
                    onHintUsed();
                  } else {
                    onShowMarket(context, l10n);
                  }
                },
              ),
              _buildCircularHintButton(
                context: context,
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

  Widget _buildCircularHintButton({
    required BuildContext context,
    required IconData icon,
    required String hintType,
    required int stockCount,
    bool isEnabled = true,
    required VoidCallback onTap,
  }) {
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

  /// Build clue display widget
  Widget buildClueDisplay(
    BuildContext context,
    AppLocalizations l10n,
    GameState gameState,
    Level level, {
    Key? key,
    required int? selectedRowIndex,
    required bool isTopSelected,
    required bool isBottomSelected,
  }) {
    final theme = Theme.of(context);
    String clueText = '';

    if (selectedRowIndex != null) {
      final solutionIndex = gameState.middleWordIndices[selectedRowIndex];
      clueText = level.clues[solutionIndex - 1];
    } else if (isTopSelected) {
      clueText = level.startClue;
    } else if (isBottomSelected) {
      clueText = level.endClue;
    }

    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.s,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: RadiiBR.sm,
        border: Border.all(color: theme.colorScheme.primary, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: theme.colorScheme.primary,
            size: 16,
          ),
          HorizontalSpacing.xs,
          Expanded(
            child: Text(
              clueText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.2, end: 0);
  }
}
