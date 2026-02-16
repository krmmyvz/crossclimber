import 'package:flutter/material.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/screens/game/game_screen_widgets.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/border_radius.dart';

class EndWordRow extends StatelessWidget {
  final bool isTop;
  final GameState gameState;
  final Level level;
  final double tileSize;
  final bool isSelected;
  final String currentInput;
  final String? tempInput;
  final VoidCallback onSelect;

  const EndWordRow({
    super.key,
    required this.isTop,
    required this.gameState,
    required this.level,
    required this.tileSize,
    required this.isSelected,
    required this.currentInput,
    required this.tempInput,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final word = isTop ? gameState.topGuess : gameState.bottomGuess;
    final isLocked =
        gameState.phase != GamePhase.finalSolve &&
        gameState.phase != GamePhase.completed;
    final isSolved = word != null;
    final theme = Theme.of(context);
    final wordLength = level.startWord.length;

    return GestureDetector(
      onTap: !isLocked && !isSolved ? onSelect : null,
      child: Container(
        padding: const EdgeInsets.all(Spacing.xs),
        decoration: BoxDecoration(
          color: isLocked
              ? theme.colorScheme.surfaceDim
              : (isSolved
                    ? theme.colorScheme.surfaceContainerHighest
                    : (isSelected
                          ? theme.colorScheme.primaryContainer.withValues(
                              alpha: 0.3,
                            )
                          : null)),
          borderRadius: RadiiBR.sm,
          border: Border.all(
            color: isSelected
                ? (gameState.lastError == 'wrong'
                      ? theme.gameColors.incorrect
                      : theme.colorScheme.primary)
                : (isSolved
                      ? theme.colorScheme.outlineVariant
                      : theme.colorScheme.outline),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: isLocked
                    ? Text(
                        '?',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : (isSolved
                          ? WordRowWidgets.buildWordRow(
                              context,
                              word,
                              false,
                              true,
                              tileSize,
                            )
                          : (isSelected && currentInput.isNotEmpty
                                ? WordRowWidgets.buildWordRow(
                                    context,
                                    currentInput.toUpperCase().padRight(
                                      wordLength,
                                    ),
                                    false,
                                    false,
                                    tileSize,
                                    shouldShake: gameState.lastError == 'wrong',
                                  )
                                : (tempInput != null
                                      ? WordRowWidgets.buildWordRow(
                                          context,
                                          tempInput!.toUpperCase().padRight(
                                            wordLength,
                                          ),
                                          false,
                                          false,
                                          tileSize,
                                        )
                                      : WordRowWidgets.buildEmptyWordRow(
                                          context,
                                          wordLength,
                                          isSelected,
                                          tileSize,
                                        )))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
