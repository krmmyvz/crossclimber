import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/theme/border_radius.dart';

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
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
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
          .shake(duration: 400.ms, hz: 5, rotation: 0.05);
    }

    if (shouldGlow) {
      tile = tile
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 1.5.seconds,
            color: Colors.white.withValues(alpha: 0.5),
          );
    }

    if (isCorrect && !shouldGlow) {
      tile = tile
          .animate()
          .scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.elasticOut,
          )
          .then()
          .shimmer(
            duration: 600.ms,
            color: Colors.white.withValues(alpha: 0.6),
          );
    }

    if (letter.isNotEmpty && !isLocked) {
      tile = tile
          .animate()
          .fadeIn(duration: 200.ms)
          .scale(begin: const Offset(0.8, 0.8), duration: 200.ms);
    }

    return tile;
  }
}
