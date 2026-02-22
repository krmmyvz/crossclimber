import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/animations.dart';

class ClueDisplay extends StatelessWidget {
  final GameState gameState;
  final Level level;
  final int? selectedRowIndex;
  final bool isTopSelected;
  final bool isBottomSelected;

  const ClueDisplay({
    super.key,
    required this.gameState,
    required this.level,
    required this.selectedRowIndex,
    required this.isTopSelected,
    required this.isBottomSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String clueText = '';

    if (selectedRowIndex != null) {
      final solutionIndex = gameState.middleWordIndices[selectedRowIndex!];
      clueText = level.clues[solutionIndex - 1];
    } else if (isTopSelected) {
      clueText = level.startClue;
    } else if (isBottomSelected) {
      clueText = level.endClue;
    }

    if (clueText.isEmpty) return const SizedBox.shrink();

    return Container(
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
            size: IconSizes.sm,
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
    ).animate().fadeIn(duration: AnimDurations.fast).slideY(begin: -0.2, end: 0);
  }
}
