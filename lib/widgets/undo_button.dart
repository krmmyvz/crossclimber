import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/modern_dialog.dart';

class UndoButton extends ConsumerWidget {
  const UndoButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final theme = Theme.of(context);

    final canUndo = gameState.canUndo;
    final undosRemaining = gameState.maxUndos - gameState.undosUsed;
    final lastAction = ref.read(gameProvider.notifier).getLastUndoAction();

    return Tooltip(
      message: canUndo
          ? 'Undo: $lastAction\n$undosRemaining undos remaining'
          : 'No more undos available',
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
                            ? theme.colorScheme.secondary.withValues(alpha: 0.5)
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
                          size: 20,
                        ),
                        HorizontalSpacing.s,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Undo',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: canUndo
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$undosRemaining/${gameState.maxUndos}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: canUndo
                                    ? theme.colorScheme.secondary.withValues(
                                        alpha: 0.8,
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
                duration: 200.ms,
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
    final gameState = ref.read(gameProvider);
    final undosRemaining = gameState.maxUndos - gameState.undosUsed - 1;

    ModernDialog.show(
      context: context,
      title: 'Geri Al?',
      message: action != null
          ? 'Bu işlemi geri alacaksınız:\n\n"$action"\n\nKalan geri alma hakkı: $undosRemaining'
          : 'Son işleminizi geri almak istiyor musunuz?\n\nKalan geri alma hakkı: $undosRemaining',
      icon: Icons.undo,
      iconColor: theme.colorScheme.secondary,
      actions: [
        const ModernDialogAction(label: 'İptal', result: false),
        ModernDialogAction(
          label: 'Geri Al',
          isPrimary: true,
          result: true,
          onPressed: () {
            ref.read(gameProvider.notifier).performUndo();

            // Show modern notification
            ModernNotification.show(
              context: context,
              message: action ?? 'İşlem geri alındı',
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
    final gameState = ref.watch(gameProvider);
    final theme = Theme.of(context);

    final canUndo = gameState.canUndo;
    final undosRemaining = gameState.maxUndos - gameState.undosUsed;

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
          ? '$undosRemaining undos remaining'
          : 'No undos available',
    ).animate(target: canUndo ? 1 : 0).shake(duration: 300.ms);
  }
}
