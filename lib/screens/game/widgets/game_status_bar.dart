import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/models/tutorial_step.dart';
import 'package:crossclimber/providers/tutorial_provider.dart';
import 'package:crossclimber/screens/game/game_screen_widgets.dart';
import 'package:crossclimber/services/tutorial_data.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/combo_indicator.dart';

class GameStatusBar extends ConsumerWidget {
  final GameState gameState;
  final GlobalKey? timerKey;
  final GlobalKey? comboBadgeKey;

  const GameStatusBar({
    super.key,
    required this.gameState,
    this.timerKey,
    this.comboBadgeKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusItem(
                key: timerKey,
                icon: Icons.timer_outlined,
                label: _formatTime(gameState.timeElapsed),
              ),
              StatusItem(
                icon: Icons.star,
                label: '${gameState.score}',
                color: theme.colorScheme.tertiary,
                isProminent: true,
              ),
            ],
          ),
          if (gameState.currentCombo >= 2 ||
              (ref.watch(tutorialProgressProvider).currentStepIndex <
                      TutorialData.getTotalSteps() &&
                  TutorialData.getStepAt(
                        ref.read(tutorialProgressProvider).currentStepIndex,
                      )?.phase ==
                      TutorialPhase.guessing))
            KeyedSubtree(
              key: comboBadgeKey,
              child: ComboCounter(
                comboCount: gameState.currentCombo,
                multiplier: gameState.comboMultiplier,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
