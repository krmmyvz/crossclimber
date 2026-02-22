import 'package:flutter/material.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/opacities.dart';

/// A reusable wrapper that adds press-feedback animation to any child.
///
/// Provides:
/// - Scale-down to [pressedScale] on tap-down (default 0.95)
/// - InkWell ripple effect
/// - Configurable border radius, padding, haptic feedback
///
/// Usage:
/// ```dart
/// PressableButton(
///   onTap: () => doSomething(),
///   child: MyButtonContent(),
/// )
/// ```
class PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? splashColor;
  final Color? highlightColor;

  const PressableButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.95,
    this.borderRadius,
    this.padding,
    this.splashColor,
    this.highlightColor,
  });

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius =
        widget.borderRadius ?? RadiiBR.md;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: AnimDurations.micro,
        curve: AppCurves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: effectiveBorderRadius,
            splashColor: widget.splashColor ??
                theme.colorScheme.primary.withValues(alpha: Opacities.light),
            highlightColor: widget.highlightColor ??
                theme.colorScheme.primary.withValues(alpha: Opacities.faint),
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
