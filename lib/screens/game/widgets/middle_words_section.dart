import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/screens/game/game_screen_widgets.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/shadows.dart';

class MiddleWordsSection extends StatelessWidget {
  final GameState gameState;
  final Level level;
  final double tileSize;
  final int? selectedRowIndex;
  final String currentInput;
  final Function(int, int) onReorder;
  final Function(int) onSelect;
  final VoidCallback onPointerDown; // For hiding tutorial card

  const MiddleWordsSection({
    super.key,
    required this.gameState,
    required this.level,
    required this.tileSize,
    required this.selectedRowIndex,
    required this.currentInput,
    required this.onReorder,
    required this.onSelect,
    required this.onPointerDown,
  });

  /// Proxy decorator for dragged items — elevated shadow + slight rotation.
  static Widget _buildDragProxy(
    Widget child,
    int index,
    Animation<double> animation,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = AppCurves.standard.transform(animation.value);
        final elevation = 1 + t * 12; // 1 → 13
        final rotation = t * (index.isEven ? 0.02 : -0.02); // ±~1.15°
        final scale = 1.0 + t * 0.04; // subtle 4% grow

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(rotation * pi)
            ..scale(scale),
          child: Material(
            elevation: elevation,
            borderRadius: RadiiBR.sm,
            shadowColor: Colors.black26,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          proxyDecorator: _buildDragProxy,
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
              currentInput: selectedRowIndex == index ? currentInput : '',
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
  final String currentInput;
  final VoidCallback onSelect;
  final VoidCallback onPointerDown;

  const MiddleWordTile({
    super.key,
    required this.index,
    required this.gameState,
    required this.level,
    required this.tileSize,
    required this.isSelected,
    required this.currentInput,
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
              size: IconSizes.sm,
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
          // Sorting-phase validity icon — conveys state beyond color alone
          if (gameState.phase == GamePhase.sorting &&
              isGuessed &&
              index < gameState.middleWordsValidOrder.length) ...[
            HorizontalSpacing.xxs,
            ExcludeSemantics(
              child: Icon(
                gameState.middleWordsValidOrder[index]
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                size: IconSizes.sm,
                color: gameState.middleWordsValidOrder[index]
                    ? Theme.of(context).gameColors.correct
                    : Theme.of(context).gameColors.incorrect,
              ),
            ),
          ],
        ],
      ),
    );

    // Wrap with drag listener only in sorting phase
    if (gameState.phase == GamePhase.sorting) {
      content = ReorderableDragStartListener(index: index, child: content);
    }

    // Satisfaction pulse when ALL words are in correct order
    final allCorrect = gameState.phase == GamePhase.sorting &&
        gameState.middleWordsValidOrder.isNotEmpty &&
        gameState.middleWordsValidOrder.every((v) => v);
    if (allCorrect) {
      content = content
          .animate()
          .scaleXY(
            begin: 1.0,
            end: 1.03,
            duration: AnimDurations.fast,
            delay: StaggerDelay.extraFast(index),
            curve: AppCurves.spring,
          )
          .then()
          .scaleXY(begin: 1.03, end: 1.0, duration: AnimDurations.fast)
          .shimmer(
            duration: AnimDurations.slower,
            delay: StaggerDelay.extraFast(index),
            color: Theme.of(context).gameColors.correct.withValues(alpha: Opacities.medium),
          );
    }

    final l10n = AppLocalizations.of(context)!;
    String semanticsLabel;
    if (gameState.phase == GamePhase.sorting) {
      semanticsLabel = 'Word $word. ${l10n.semanticsDragInstruction}';
    } else if (isGuessed) {
      semanticsLabel = 'Word $word, ${l10n.semanticsCompleted}';
    } else {
      semanticsLabel = '${l10n.semanticsUnlocked}: ${l10n.semanticsLevelCard(index + 1, l10n.semanticsUnlocked, 0)}';
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
            ? gameColors.correct.withValues(alpha: Opacities.heavy)
            : gameColors.incorrect.withValues(alpha: Opacities.heavy);
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
          ? AppShadows.elevation1
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
        shouldWaveBounce: true,
      );
    }

    // Show live typing feedback when selected and user is typing
    if (isSelected && currentInput.isNotEmpty) {
      final displayWord = currentInput.toUpperCase().padRight(wordLength);
      final shouldShake =
          gameState.lastError == 'wrong' &&
          gameState.wrongAttempts > 0;
      return WordRowWidgets.buildWordRow(
        context,
        displayWord,
        false,
        false,
        tileSize,
        shouldShake: shouldShake,
      );
    }

    final shouldShake =
        gameState.lastError == 'wrong' &&
        gameState.wrongAttempts > 0 &&
        isSelected;

    if (shouldShake) {
      return WordRowWidgets.buildEmptyWordRow(
            context,
            wordLength,
            isSelected,
            tileSize,
          )
          .animate(onPlay: (controller) => controller.forward(from: 0))
          .shake(duration: AnimDurations.slow, hz: 4, rotation: 0.05);
    }

    return WordRowWidgets.buildEmptyWordRow(
      context,
      wordLength,
      isSelected,
      tileSize,
    );
  }
}
