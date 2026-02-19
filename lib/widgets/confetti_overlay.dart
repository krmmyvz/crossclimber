import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple,
          Colors.yellow,
        ],
      ),
      ),
    );
  }
}
