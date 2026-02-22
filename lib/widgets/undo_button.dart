import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/modern_dialog.dart';

class UndoButton extends ConsumerWidget {
  const UndoButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (:canUndo, :maxUndos, :undosUsed) = ref.watch(
      gameProvider.select((s) => (canUndo: s.canUndo, maxUndos: s.maxUndos, undosUsed: s.undosUsed)),
    );
    final theme = Theme.of(context);

    final undosRemaining = maxUndos - undosUsed;
    final lastAction = ref.read(gameProvider.notifier).getLastUndoAction();
    final l10n = AppLocalizations.of(context)!;

    return Tooltip(
      message: canUndo
          ? (lastAction != null
              ? l10n.undoTooltipMessage(lastAction, undosRemaining)
              : l10n.undosRemainingCount(undosRemaining))
          : l10n.noUndosAvailable,
      child:
          Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canUndo
                      ? () {
                          _showUndoConfirmation(context, ref, lastAction);
                        }
                      : null,
                  borderRadius: RadiiBR.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.m,
                      vertical: Spacing.s + Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: canUndo
                          ? theme.colorScheme.secondaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: RadiiBR.md,
                      border: Border.all(
                        color: canUndo
                            ? theme.colorScheme.secondary.withValues(alpha: Opacities.half)
                            : theme.colorScheme.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.undo,
                          color: canUndo
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.onSurfaceVariant,
                          size: IconSizes.md,
                        ),
                        HorizontalSpacing.s,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.undoMove,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: canUndo
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$undosRemaining/$maxUndos',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: canUndo
                                    ? theme.colorScheme.secondary.withValues(
                                        alpha: Opacities.heavy,
                                      )
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate(target: canUndo ? 1 : 0)
              .scale(
                duration: AnimDurations.fast,
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.0, 1.0),
              ),
    );
  }

  void _showUndoConfirmation(
    BuildContext context,
    WidgetRef ref,
    String? action,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final gameState = ref.read(gameProvider);
    final undosRemaining = gameState.maxUndos - gameState.undosUsed - 1;

    ModernDialog.show(
      context: context,
      title: l10n.undoConfirmTitle,
      message: action != null
          ? l10n.undoConfirmMessageWithAction(action, undosRemaining)
          : l10n.undoConfirmMessage(undosRemaining),
      icon: Icons.undo,
      iconColor: theme.colorScheme.secondary,
      actions: [
        ModernDialogAction(label: l10n.cancel, result: false),
        ModernDialogAction(
          label: l10n.undoMove,
          isPrimary: true,
          result: true,
          onPressed: () {
            ref.read(gameProvider.notifier).performUndo();

            // Show modern notification
            ModernNotification.show(
              context: context,
              message: action ?? l10n.undoReverted,
              icon: Icons.undo,
              backgroundColor: theme.colorScheme.secondary,
              iconColor: Colors.white,
            );
          },
        ),
      ],
    );
  }
}

// Compact undo button for tight spaces
class CompactUndoButton extends ConsumerWidget {
  const CompactUndoButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (:canUndo, :maxUndos, :undosUsed) = ref.watch(
      gameProvider.select((s) => (canUndo: s.canUndo, maxUndos: s.maxUndos, undosUsed: s.undosUsed)),
    );
    final theme = Theme.of(context);

    final undosRemaining = maxUndos - undosUsed;
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      onPressed: canUndo
          ? () => ref.read(gameProvider.notifier).performUndo()
          : null,
      icon: Badge(
        label: Text('$undosRemaining'),
        isLabelVisible: canUndo,
        child: Icon(
          Icons.undo,
          color: canUndo
              ? theme.colorScheme.secondary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      tooltip: canUndo
          ? l10n.undosRemainingCount(undosRemaining)
          : l10n.noUndosAvailable,
    ).animate(target: canUndo ? 1 : 0).shake(duration: AnimDurations.normal);
  }
}
