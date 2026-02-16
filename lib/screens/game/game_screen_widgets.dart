import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/border_radius.dart';
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
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: RadiiBR.xs,
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                width: isActive ? 2 : 1,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Build a row of letter tiles with letters
  static Widget buildWordRow(
    BuildContext context,
    String word,
    bool isLocked,
    bool isCorrect,
    double tileSize, {
    bool shouldShake = false,
  }) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: word.split('').map((char) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xxs),
          child: SizedBox(
            width: tileSize,
            height: tileSize,
            child: LetterTile(
              letter: char,
              isLocked: isLocked,
              isCorrect: isCorrect,
              shouldShake: false,
            ),
          ),
        );
      }).toList(),
    );

    if (shouldShake) {
      return row
          .animate(onPlay: (controller) => controller.forward(from: 0))
          .shake(duration: 500.ms, hz: 4, rotation: 0.05);
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isProminent ? 22 : 18, color: effectiveColor),
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
        ],
      ),
    );
  }
}
