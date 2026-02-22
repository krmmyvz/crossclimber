import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/shadows.dart';
import 'package:crossclimber/theme/spacing.dart';

/// Simple tooltip-style tutorial dialog
class TutorialTooltip extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDismiss;
  final IconData icon;
  final Color? color;

  const TutorialTooltip({
    super.key,
    required this.title,
    required this.message,
    required this.onDismiss,
    this.icon = Icons.info_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Container(
          margin: SpacingInsets.m,
          padding: SpacingInsets.m,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: RadiiBR.md,
            boxShadow: AppShadows.elevation2,
            border: Border.all(
              color: effectiveColor.withValues(alpha: Opacities.medium),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: effectiveColor, size: IconSizes.lg),
                  HorizontalSpacing.s,
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: effectiveColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: IconSizes.md),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              VerticalSpacing.s,
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: Spacing.s + Spacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onDismiss,
                  child: const Text('Got it!'),
                ),
              ),
            ],
          ),
        )
        .animate()
        .slideY(
          begin: -0.2,
          end: 0,
          duration: AnimDurations.normal,
          curve: AppCurves.easeOut,
        )
        .fadeIn(duration: AnimDurations.fast);
  }

  /// Show tooltip at the top of the screen
  static void showTop(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.lightbulb_outline,
    Color? color,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 0,
        right: 0,
        child: TutorialTooltip(
          title: title,
          message: message,
          icon: icon,
          color: color,
          onDismiss: () => entry.remove(),
        ),
      ),
    );

    overlay.insert(entry);

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      entry.remove();
    });
  }
}

/// Full-screen tutorial dialog
class TutorialDialog extends StatelessWidget {
  final String title;
  final String description;
  final List<TutorialPoint> points;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;
  final String completeButtonText;

  const TutorialDialog({
    super.key,
    required this.title,
    required this.description,
    this.points = const [],
    required this.onComplete,
    this.onSkip,
    this.completeButtonText = 'Got it!',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
          shape: RoundedRectangleBorder(borderRadius: RadiiBR.xl),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: SpacingInsets.l,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Spacing.s + Spacing.xs),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: Opacities.subtle),
                        borderRadius: RadiiBR.md,
                      ),
                      child: Icon(
                        Icons.school,
                        color: theme.colorScheme.primary,
                        size: IconSizes.xl,
                      ),
                    ),
                    HorizontalSpacing.m,
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xl - Spacing.s + Spacing.xs),

                // Description
                Text(
                  description,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),

                // Points
                if (points.isNotEmpty) ...[
                  const SizedBox(height: Spacing.xl - Spacing.s + Spacing.xs),
                  ...points.map((point) => _buildPoint(point, theme)),
                ],

                VerticalSpacing.l,

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onSkip != null)
                      TextButton(onPressed: onSkip, child: const Text('Skip')),
                    const SizedBox(width: Spacing.s + Spacing.xs),
                    ElevatedButton(
                      onPressed: onComplete,
                      child: Text(completeButtonText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: AnimDurations.normal,
          curve: AppCurves.easeOut,
        )
        .fadeIn(duration: AnimDurations.fast);
  }

  Widget _buildPoint(TutorialPoint point, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: Opacities.subtle),
              borderRadius: RadiiBR.sm,
            ),
            child: Icon(point.icon, size: IconSizes.sm, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: Spacing.s + Spacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                VerticalSpacing.xs,
                Text(
                  point.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: Opacities.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show tutorial dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    List<TutorialPoint> points = const [],
    required VoidCallback onComplete,
    VoidCallback? onSkip,
    String completeButtonText = 'Got it!',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TutorialDialog(
        title: title,
        description: description,
        points: points,
        onComplete: () {
          Navigator.of(context).pop();
          onComplete();
        },
        onSkip: onSkip != null
            ? () {
                Navigator.of(context).pop();
                onSkip();
              }
            : null,
        completeButtonText: completeButtonText,
      ),
    );
  }
}

/// Tutorial point with icon and description
class TutorialPoint {
  final String title;
  final String description;
  final IconData icon;

  const TutorialPoint({
    required this.title,
    required this.description,
    this.icon = Icons.check_circle_outline,
  });
}
