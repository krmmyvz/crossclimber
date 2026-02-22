import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/models/tutorial_step.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';

/// Overlay that displays tutorial steps with highlighting and animations
class TutorialOverlay extends StatefulWidget {
  final TutorialStep step;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback? onDontShowAgain;
  final int currentStep;
  final int totalSteps;
  final GlobalKey? highlightKey;
  final List<GlobalKey>? additionalHighlightKeys;
  final String title;
  final String description;
  final bool showCard;

  const TutorialOverlay({
    super.key,
    required this.step,
    required this.onNext,
    required this.onSkip,
    this.onDontShowAgain,
    required this.currentStep,
    required this.totalSteps,
    this.highlightKey,
    this.additionalHighlightKeys,
    required this.title,
    required this.description,
    this.showCard = true,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final showCard = widget.showCard;
    final onSkip = widget.onSkip;
    final highlightKey = widget.highlightKey;
    final additionalHighlightKeys = widget.additionalHighlightKeys;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Calculate highlight rects
    final List<RRect> highlightRects = [];

    void addHighlight(GlobalKey key) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final highlightSize = renderBox.size;
        highlightRects.add(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              position.dx - 8,
              position.dy - 8,
              highlightSize.width + 16,
              highlightSize.height + 16,
            ),
            const Radius.circular(12),
          ),
        );
      }
    }

    if (highlightKey != null) {
      addHighlight(highlightKey);
    }

    if (additionalHighlightKeys != null) {
      for (final key in additionalHighlightKeys) {
        addHighlight(key);
      }
    }

    // Calculate combined bounding rect for all highlights
    // This ensures the tutorial card doesn't overlap ANY highlighted element
    Rect? combinedHighlightBounds;
    if (highlightRects.isNotEmpty) {
      for (final rect in highlightRects) {
        final rectBounds = rect.outerRect;
        if (combinedHighlightBounds == null) {
          combinedHighlightBounds = rectBounds;
        } else {
          combinedHighlightBounds = combinedHighlightBounds.expandToInclude(
            rectBounds,
          );
        }
      }
    }

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        // 1. Visual Overlay (Ignored for hits)
        IgnorePointer(
          child: CustomPaint(
            size: Size(size.width, size.height),
            painter: TutorialOverlayPainter(highlightRects: highlightRects),
          ),
        ),

        // 2. Hit Test Blockers (Invisible)
        // We explicitly block touches outside the highlight rects
        // UNLESS the step allows interaction everywhere (e.g. for typing)
        if (!step.allowInteractionEverywhere) ...[
          if (highlightRects.isEmpty)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {}, // Consume taps
                behavior: HitTestBehavior.opaque,
              ),
            )
          else
          // If we have highlights, we need a custom hit test blocker
          // that blocks everything EXCEPT the highlight rects.
          // Since we can have multiple rects, using simple Positioned blocks is hard.
          // that returns true for hits outside the rects.
          // OR simpler: just use a full screen gesture detector that consumes taps,
          // but we need to let taps through the holes.
          // Given the complexity, and that we mostly use single rects or "interaction everywhere",
          // we can simplify: if interaction everywhere is false, we block everything.
          // But wait, "allowInteractionEverywhere: false" means we ONLY allow interaction in the highlight.
          // Implementing multi-rect hole blocking with widgets is complex.
          // For now, let's stick to blocking everything if no interaction allowed,
          // or if we have a primary rect, block around it.
          // Since we only use multiple rects for "interaction everywhere" steps (like guessing),
          // we might not need complex blocking logic for multiple rects.
          // Let's check: "guess_interactive" has allowInteractionEverywhere: true.
          // So we don't need to worry about blocking for that step!
          // For other steps with single highlight, we can use combinedHighlightBounds.
          if (combinedHighlightBounds != null) ...[
            // Top Block
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: combinedHighlightBounds.top,
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
              ),
            ),
            // Bottom Block
            Positioned(
              top: combinedHighlightBounds.bottom,
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
              ),
            ),
            // Left Block
            Positioned(
              top: combinedHighlightBounds.top,
              left: 0,
              width: combinedHighlightBounds.left,
              height: combinedHighlightBounds.height,
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
              ),
            ),
            // Right Block
            Positioned(
              top: combinedHighlightBounds.top,
              right: 0,
              left: combinedHighlightBounds.right,
              height: combinedHighlightBounds.height,
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
              ),
            ),
          ],
        ],

        // 3. Pulsing highlight border (Visual only)
        for (final rect in highlightRects)
          Positioned(
            left: rect.left,
            top: rect.top,
            child: IgnorePointer(
              child:
                  Container(
                        width: rect.width,
                        height: rect.height,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 3,
                          ),
                          borderRadius: RadiiBR.md,
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(duration: AnimDurations.slower)
                      .then()
                      .fadeOut(duration: AnimDurations.slower),
            ),
          ),

        // 4. Tutorial card (only if showCard is true)
        if (showCard)
          Positioned(
            bottom: () {
              if (combinedHighlightBounds == null) return 100.0;

              const cardEstimatedHeight = 200.0;
              const minMargin = 20.0;
              final availableHeight = size.height - bottomInset;

              // Calculate space below highlights
              final spaceBelow =
                  availableHeight - combinedHighlightBounds.bottom;

              // Prefer below if there's enough space
              if (spaceBelow >= cardEstimatedHeight + minMargin) {
                return null; // Will be positioned by top
              }

              // Otherwise position from bottom, ensuring minimum margin from top
              final fromBottom = bottomInset + minMargin;
              final maxFromBottom =
                  size.height - cardEstimatedHeight - minMargin;
              return fromBottom.clamp(minMargin, maxFromBottom);
            }(),
            top: () {
              if (combinedHighlightBounds == null) return null;

              const cardEstimatedHeight = 200.0;
              const minMargin = 20.0;
              final availableHeight = size.height - bottomInset;

              // Calculate space below highlights
              final spaceBelow =
                  availableHeight - combinedHighlightBounds.bottom;

              // If enough space below, position below highlights
              if (spaceBelow >= cardEstimatedHeight + minMargin) {
                final preferredTop = combinedHighlightBounds.bottom + minMargin;
                // Ensure it doesn't go beyond safe area
                final maxTop =
                    availableHeight - cardEstimatedHeight - minMargin;
                return preferredTop.clamp(minMargin, maxTop);
              }

              // Let bottom handle positioning
              return null;
            }(),
            left: 20,
            right: 20,
            child: _buildTutorialCard(context, theme),
          ),

        // 6. Skip button (only if showCard is true)
        if (showCard)
          Positioned(
            top: 0,
            right: 20,
            child: SafeArea(
              child: Material(
                type: MaterialType.transparency,
                child: TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black.withValues(alpha: Opacities.half),
                  ),
                  child: Text(AppLocalizations.of(context)!.skipTutorial),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTutorialCard(BuildContext context, ThemeData theme) {
    final step = widget.step;
    final currentStep = widget.currentStep;
    final totalSteps = widget.totalSteps;
    final title = widget.title;
    final description = widget.description;
    final onNext = widget.onNext;
    final isInteractive = step.action != TutorialAction.tapContinue;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate max height: leave room for highlights and margins
    final maxCardHeight =
        (screenHeight - bottomInset) * 0.4; // Max 40% of available height

    return Semantics(
      liveRegion: true,
      label: '$title. $description',
      child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxCardHeight.clamp(150.0, 300.0), // Between 150-300px
          ),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: RadiiBR.lg),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(totalSteps, (i) {
                            final isActive = i == currentStep;
                            return AnimatedContainer(
                              duration: AnimDurations.fastNormal,
                              margin: const EdgeInsets.only(right: 5),
                              width: isActive ? 16 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant,
                                borderRadius: RadiiBR.xs,
                              ),
                            );
                          }),
                        ),
                        _getPhaseIcon(step.phase, theme),
                      ],
                    ),
                    const SizedBox(height: Spacing.s + Spacing.xs),

                    // Title
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    VerticalSpacing.s,

                    // Description
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: Opacities.heavy,
                        ),
                        height: 1.4,
                      ),
                    ),
                    VerticalSpacing.m,

                    // Action button (Only if NOT interactive)
                    if (!isInteractive)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onNext,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: RadiiBR.md,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_getActionText(step.action)),
                              HorizontalSpacing.s,
                              const Icon(Icons.arrow_forward, size: IconSizes.smd),
                            ],
                          ),
                        ),
                      )
                    else
                      // Interactive Prompt
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer
                              .withValues(alpha: Opacities.half),
                          borderRadius: RadiiBR.md,
                          border: Border.all(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: Opacities.gentle,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                  Icons.touch_app,
                                  size: IconSizes.smd,
                                  color: theme.colorScheme.secondary,
                                )
                                .animate(onPlay: (c) => c.repeat())
                                .moveY(
                                  begin: 0,
                                  end: -4,
                                  duration: AnimDurations.mediumSlow,
                                  curve: AppCurves.standard,
                                )
                                .then()
                                .moveY(
                                  begin: -4,
                                  end: 0,
                                  duration: AnimDurations.mediumSlow,
                                  curve: AppCurves.standard,
                                ),
                            HorizontalSpacing.s,
                            Text(
                              _getActionText(step.action),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Don't show again
                    if (widget.onDontShowAgain != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: widget.onDontShowAgain,
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.tutorialDontShowAgain,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: Opacities.semi),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .slideY(
          begin: 0.2,
          end: 0,
          duration: AnimDurations.medium,
          curve: AppCurves.easeOut,
        )
        .fadeIn(duration: AnimDurations.normal),
    );
  }

  Widget _getPhaseIcon(TutorialPhase phase, ThemeData theme) {
    IconData icon;
    switch (phase) {
      case TutorialPhase.introduction:
        icon = Icons.info_outline;
        break;
      case TutorialPhase.guessing:
        icon = Icons.edit;
        break;
      case TutorialPhase.sorting:
        icon = Icons.swap_vert;
        break;
      case TutorialPhase.finalSolve:
        icon = Icons.check_circle_outline;
        break;
      case TutorialPhase.completion:
        icon = Icons.celebration;
        break;
    }

    return Icon(icon, color: theme.colorScheme.primary, size: IconSizes.xl);
  }

  String _getActionText(TutorialAction? action) {
    switch (action) {
      case TutorialAction.tapContinue:
        return 'Continue';
      case TutorialAction.guessWord:
        return 'Try Guessing';
      case TutorialAction.reorderWords:
        return 'Try Sorting';
      case TutorialAction.guessStartWord:
        return 'Guess Start Word';
      case TutorialAction.guessEndWord:
        return 'Guess End Word';
      case TutorialAction.useHint:
        return 'Use Hint';
      case TutorialAction.pause:
        return 'Try Pausing';
      case null:
        return 'Continue';
    }
  }
}

/// Custom painter for the overlay with a highlighted area
class TutorialOverlayPainter extends CustomPainter {
  final List<RRect>? highlightRects;

  TutorialOverlayPainter({this.highlightRects});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: Opacities.bold)
      ..style = PaintingStyle.fill;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (highlightRects != null) {
      for (final rect in highlightRects!) {
        path.addRRect(rect);
      }
      path.fillType = PathFillType.evenOdd;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TutorialOverlayPainter oldDelegate) {
    // Simple equality check for list content might be expensive or tricky,
    // but for now we can just check reference or length.
    // Ideally we should check if rects are different.
    if (highlightRects == null && oldDelegate.highlightRects == null) {
      return false;
    }
    if (highlightRects == null || oldDelegate.highlightRects == null) {
      return true;
    }
    if (highlightRects!.length != oldDelegate.highlightRects!.length) {
      return true;
    }
    // Deep check
    for (int i = 0; i < highlightRects!.length; i++) {
      if (highlightRects![i] != oldDelegate.highlightRects![i]) return true;
    }
    return false;
  }
}
