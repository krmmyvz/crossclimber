import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/responsive.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/widgets/letter_tile.dart';

/// Reusable word row widgets for the game screen
class WordRowWidgets {
  /// Build a row of empty letter tiles
  static Widget buildEmptyWordRow(
    BuildContext context,
    int length,
    bool isActive,
    double tileSize,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xxs),
          child: Container(
            width: tileSize,
            height: tileSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primaryContainer.withValues(alpha: Opacities.medium)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: RadiiBR.xs,
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                width: isActive ? 2 : 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Build a row of letter tiles with letters.
  ///
  /// When [shouldWaveBounce] is true, each tile bounces with a staggered
  /// delay (left to right) — used when the entire word is correct.
  static Widget buildWordRow(
    BuildContext context,
    String word,
    bool isLocked,
    bool isCorrect,
    double tileSize, {
    bool shouldShake = false,
    bool shouldWaveBounce = false,
  }) {
    final letters = word.split('');
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(letters.length, (index) {
        Widget tile = Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xxs),
          child: SizedBox(
            width: tileSize,
            height: tileSize,
            child: LetterTile(
              letter: letters[index],
              isLocked: isLocked,
              isCorrect: isCorrect,
              shouldShake: false,
            ),
          ),
        );

        // Staggered wave bounce for each letter when word is correct
        if (shouldWaveBounce) {
          tile = tile
              .animate()
              .slideY(
                begin: 0.0,
                end: -0.15,
                duration: AnimDurations.fast,
                delay: StaggerDelay.extraFast(index),
                curve: AppCurves.easeOut,
              )
              .then()
              .slideY(
                begin: -0.15,
                end: 0.0,
                duration: AnimDurations.fast,
                curve: AppCurves.spring,
              );
        }

        return tile;
      }),
    );

    if (shouldShake) {
      return row
          .animate(onPlay: (controller) => controller.forward(from: 0))
          .shake(duration: AnimDurations.slow, hz: 4, rotation: 0.05);
    }

    return row;
  }
}

/// Status item widget for the game status bar
class StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isProminent;

  const StatusItem({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.isProminent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;
    final isCompact = Responsive.isCompact(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? Spacing.xxs : Spacing.xs,
        vertical: Spacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isProminent ? 22 : 18, color: effectiveColor),
          if (!isCompact) ...[
            HorizontalSpacing.xxs,
            Text(
              label,
              style:
                  (isProminent
                          ? theme.textTheme.titleLarge
                          : theme.textTheme.bodyLarge)
                      ?.copyWith(
                        fontWeight: isProminent
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: effectiveColor,
                      ),
            ),
          ] else ...[
            HorizontalSpacing.xxs,
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: effectiveColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
