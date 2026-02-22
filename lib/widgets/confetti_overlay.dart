import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:crossclimber/theme/game_colors.dart';

class ConfettiOverlay extends StatelessWidget {
  final ConfettiController controller;
  final bool loop;

  const ConfettiOverlay({
    super.key,
    required this.controller,
    this.loop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;
    return ExcludeSemantics(
      child: Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirection: pi / 2, // down
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        gravity: 0.2, // slower fall
        shouldLoop: loop,
        colors: [
          gameColors.success,
          theme.colorScheme.primary,
          theme.colorScheme.tertiary,
          gameColors.warning,
          theme.colorScheme.secondary,
          gameColors.star,
        ],
      ),
      ),
    );
  }
}
