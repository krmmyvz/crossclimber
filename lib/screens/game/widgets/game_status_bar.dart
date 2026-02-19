import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    // Clamp text scaling so the status bar doesn't overflow at large sizes
    final clampedTextScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
      child: Container(
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
              Semantics(
                label: 'Timer: ${_TimerStatusItem._fmt(gameState.timeElapsed)}',
                child: _TimerStatusItem(
                  timerKey: timerKey,
                  timeElapsed: gameState.timeElapsed,
                ),
              ),
              Semantics(
                label: 'Score: ${gameState.score}',
                child: StatusItem(
                  icon: Icons.star,
                  label: '${gameState.score}',
                  color: theme.colorScheme.tertiary,
                  isProminent: true,
                ),
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
    ),    // closes Container
    );    // closes MediaQuery
  }

}

// ── Timer with colour-coded urgency + pulse animation ────────────────────────

class _TimerStatusItem extends StatelessWidget {
  final GlobalKey? timerKey;
  final Duration timeElapsed;

  const _TimerStatusItem({this.timerKey, required this.timeElapsed});

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSec = timeElapsed.inSeconds;

    Color timerColor;
    if (totalSec >= 240) {
      // >= 4 min → red
      timerColor = theme.colorScheme.error;
    } else if (totalSec >= 120) {
      // >= 2 min → orange warning
      timerColor = const Color(0xFFFF8C00);
    } else {
      timerColor = theme.colorScheme.onSurface;
    }

    Widget item = StatusItem(
      key: timerKey,
      icon: Icons.timer_outlined,
      label: _fmt(timeElapsed),
      color: timerColor,
    );

    // Pulse when in danger zone (>= 4 min)
    if (totalSec >= 240) {
      item = item
          .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
          .scaleXY(end: 1.08, duration: 700.ms, curve: Curves.easeInOut);
    }

    return item;
  }
}
