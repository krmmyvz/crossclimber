import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/shadows.dart';

class LetterTile extends StatelessWidget {
  final String letter;
  final bool isLocked;
  final bool isCorrect;
  final bool isChanged;
  final bool shouldShake;
  final bool shouldGlow;
  final VoidCallback? onTap;

  const LetterTile({
    super.key,
    required this.letter,
    this.isLocked = false,
    this.isCorrect = false,
    this.isChanged = false,
    this.shouldShake = false,
    this.shouldGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor = colorScheme.surfaceContainerHighest;
    Color textColor = colorScheme.onSurfaceVariant;
    Border? border;

    if (isCorrect) {
      backgroundColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
    } else if (isChanged) {
      backgroundColor = colorScheme.secondaryContainer;
      textColor = colorScheme.onSecondaryContainer;
    } else if (isLocked) {
      backgroundColor = colorScheme.surfaceDim;
      textColor = colorScheme.outline;
    } else if (letter.isNotEmpty) {
      backgroundColor = colorScheme.surface;
      textColor = colorScheme.onSurface;
      border = Border.all(color: colorScheme.outline, width: 2);
    }

    Widget tile = Semantics(
      label: letter.isEmpty ? 'Empty tile' : 'Letter $letter',
      hint: isLocked ? 'Locked' : (isCorrect ? 'Correct' : null),
      onTapHint: (onTap != null && !isLocked && !isCorrect)
          ? AppLocalizations.of(context)!.tapToGuess
          : null,
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: RadiiBR.xs,
              border: border,
              boxShadow: isCorrect || shouldGlow
                  ? [
                      AppShadows.colorMedium(colorScheme.primary),
                    ]
                  : null,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (isLocked) {
                  return Icon(
                    Icons.lock,
                    size: constraints.maxHeight * 0.5,
                    color: textColor,
                  );
                }
                return Text(
                  letter.toUpperCase(),
                  textScaler: TextScaler.noScaling,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: constraints.maxHeight * 0.6,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Apply animations
    if (shouldShake) {
      tile = tile
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shake(duration: AnimDurations.medium, hz: 5, rotation: 0.05);
    }

    if (shouldGlow) {
      tile = tile
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 1.5.seconds,
            color: Colors.white.withValues(alpha: Opacities.half),
          );
    }

    if (isCorrect && !shouldGlow) {
      // Wordle-style 3D Y-axis flip reveal + shimmer
      tile = tile
          .animate()
          .custom(
            duration: AnimDurations.medium,
            curve: AppCurves.fastOutSlowIn,
            builder: (context, value, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateY(value * 2 * pi), // full 360° flip
                child: child,
              );
            },
          )
          .then()
          .shimmer(
            duration: AnimDurations.slower,
            color: Colors.white.withValues(alpha: Opacities.strong),
          );
    }

    if (letter.isNotEmpty && !isLocked) {
      tile = tile
          .animate()
          .fadeIn(duration: AnimDurations.fast)
          .scale(begin: const Offset(0.8, 0.8), duration: AnimDurations.fast);
    }

    return tile;
  }
}
