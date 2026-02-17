import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/screens/game/game_screen_widgets.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/border_radius.dart';

class MiddleWordsSection extends StatelessWidget {
  final GameState gameState;
  final Level level;
  final double tileSize;
  final int? selectedRowIndex;
  final Function(int, int) onReorder;
  final Function(int) onSelect;
  final VoidCallback onPointerDown; // For hiding tutorial card

  const MiddleWordsSection({
    super.key,
    required this.gameState,
    required this.level,
    required this.tileSize,
    required this.selectedRowIndex,
    required this.onReorder,
    required this.onSelect,
    required this.onPointerDown,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: gameState.middleWords.length,
          onReorder: onReorder,
          itemBuilder: (context, index) {
            return MiddleWordTile(
              key: ValueKey('word_$index'),
              index: index,
              gameState: gameState,
              level: level,
              tileSize: tileSize,
              isSelected: selectedRowIndex == index,
              onSelect: () => onSelect(index),
              onPointerDown: onPointerDown,
            );
          },
        ),
      ],
    );
  }
}

class MiddleWordTile extends StatelessWidget {
  final int index;
  final GameState gameState;
  final Level level;
  final double tileSize;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onPointerDown;

  const MiddleWordTile({
    super.key,
    required this.index,
    required this.gameState,
    required this.level,
    required this.tileSize,
    required this.isSelected,
    required this.onSelect,
    required this.onPointerDown,
  });

  @override
  Widget build(BuildContext context) {
    final isGuessed = gameState.middleWordsGuessed[index];
    final word = gameState.middleWords[index];
    final solutionIndex = gameState.middleWordIndices[index];
    final wordLength = level.solution[solutionIndex].length;

    Widget content = AnimatedContainer(
      duration: AnimDurations.normal,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs + Spacing.xxs,
        vertical: Spacing.xs + Spacing.xxs,
      ),
      decoration: _getMiddleWordDecoration(
        context,
        gameState,
        index,
        isSelected,
        isGuessed,
      ),
      child: Row(
        children: [
          // Show drag handle only in sorting phase
          if (gameState.phase == GamePhase.sorting) ...[
            Icon(
              Icons.drag_indicator,
              color: Theme.of(context).colorScheme.outline,
              size: 16,
            ),
            HorizontalSpacing.xxs,
          ],
          Expanded(
            child: Center(
              child: _buildMiddleWordContent(
                context,
                gameState,
                isGuessed,
                word,
                wordLength,
                isSelected,
                index,
                tileSize,
              ),
            ),
          ),
        ],
      ),
    );

    // Wrap with drag listener only in sorting phase
    if (gameState.phase == GamePhase.sorting) {
      content = ReorderableDragStartListener(index: index, child: content);
    }

    String semanticsLabel;
    if (gameState.phase == GamePhase.sorting) {
      semanticsLabel = 'Word $word. Double tap and hold to reorder.';
    } else if (isGuessed) {
      semanticsLabel = 'Word $word, correct.';
    } else {
      semanticsLabel = 'Empty word slot ${index + 1}, length $wordLength. Double tap to select.';
    }

    return Listener(
      onPointerDown: (_) => onPointerDown(),
      child:
          Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
                child: Semantics(
                  label: semanticsLabel,
                  button: !isGuessed,
                  selected: isSelected,
                  child: GestureDetector(
                    onTap: !isGuessed ? onSelect : null,
                    child: content,
                  ),
                ),
              )
              .animate(delay: StaggerDelay.fast(index))
              .fadeIn()
              .slideY(begin: 0.1, end: 0),
    );
  }

  BoxDecoration _getMiddleWordDecoration(
    BuildContext context,
    GameState gameState,
    int index,
    bool isSelected,
    bool isGuessed,
  ) {
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;

    Color borderColor = theme.colorScheme.outlineVariant;
    if (gameState.phase == GamePhase.sorting && isGuessed) {
      if (index < gameState.middleWordsValidOrder.length) {
        borderColor = gameState.middleWordsValidOrder[index]
            ? gameColors.correct.withValues(alpha: 0.8)
            : gameColors.incorrect.withValues(alpha: 0.8);
      }
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
    } else if (isGuessed) {
      borderColor = Colors.transparent;
    }

    return BoxDecoration(
      color: isGuessed
          ? theme.colorScheme.surfaceContainer
          : theme.colorScheme.surface,
      borderRadius: RadiiBR.sm,
      border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
      boxShadow:
          isSelected || (gameState.phase == GamePhase.sorting && !isGuessed)
          ? [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  Widget _buildMiddleWordContent(
    BuildContext context,
    GameState gameState,
    bool isGuessed,
    String word,
    int wordLength,
    bool isSelected,
    int index,
    double tileSize,
  ) {
    if (isGuessed) {
      return WordRowWidgets.buildWordRow(
        context,
        word,
        false, // isLocked
        true, // isCorrect
        tileSize,
        shouldShake: false,
      );
    }

    final shouldShake =
        gameState.lastError == 'wrong' &&
        gameState.wrongAttempts > 0 && // Ensure we only shake on active error
        isSelected;

    if (shouldShake) {
      return WordRowWidgets.buildEmptyWordRow(
            context,
            wordLength,
            isSelected,
            tileSize,
          )
          .animate(onPlay: (controller) => controller.forward(from: 0))
          .shake(duration: 500.ms, hz: 4, rotation: 0.05);
    }

    return WordRowWidgets.buildEmptyWordRow(
      context,
      wordLength,
      isSelected,
      tileSize,
    );
  }
}
