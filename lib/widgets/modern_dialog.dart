import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';

/// Modern, stilize edilmiş diyalog widget'ı
/// LevelCompletionScreen ile tutarlı tasarım
class ModernDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final Widget? customContent; // Custom content between message and actions
  final List<ModernDialogAction> actions;

  const ModernDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.customContent,
    required this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    Widget? customContent,
    required List<ModernDialogAction> actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ModernDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        customContent: customContent,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ModernDialogContent(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        customContent: customContent,
        actions: actions,
      ),
    );
  }
}

class ModernDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final Widget? customContent;
  final List<ModernDialogAction> actions;

  const ModernDialogContent({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.customContent,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: RadiiBR.xxl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: SpacingInsets.l,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon (optional)
            if (icon != null) ...[
              Container(
                padding: SpacingInsets.m,
                decoration: BoxDecoration(
                  color: (iconColor ?? theme.colorScheme.primary).withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: iconColor ?? theme.colorScheme.primary,
                ),
              ),
              VerticalSpacing.m,
            ],

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            VerticalSpacing.s,

            // Message
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            VerticalSpacing.l,

            // Custom Content
            if (customContent != null) ...[customContent!, VerticalSpacing.l],

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: actions.map((action) {
                final buttonStyle = action.isDestructive
                    ? (action.isPrimary
                          ? FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: theme.colorScheme.onError,
                              padding: const EdgeInsets.symmetric(
                                vertical: Spacing.s + Spacing.xs,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: RadiiBR.md,
                              ),
                            )
                          : OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              side: BorderSide(color: theme.colorScheme.error),
                              padding: const EdgeInsets.symmetric(
                                vertical: Spacing.s + Spacing.xs,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: RadiiBR.md,
                              ),
                            ))
                    : (action.isPrimary
                          ? FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: Spacing.s + Spacing.xs,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: RadiiBR.md,
                              ),
                            )
                          : OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: Spacing.s + Spacing.xs,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: RadiiBR.md,
                              ),
                            ));

                Widget button;
                if (action.isPrimary) {
                  if (action.icon != null) {
                    button = FilledButton.icon(
                      onPressed: action.isEnabled
                          ? () {
                              if (action.result != null) {
                                Navigator.of(context).pop(action.result);
                              }
                              action.onPressed?.call();
                            }
                          : null,
                      style: buttonStyle,
                      icon: Icon(action.icon, size: 18),
                      label: Text(action.label),
                    );
                  } else {
                    button = FilledButton(
                      onPressed: action.isEnabled
                          ? () {
                              if (action.result != null) {
                                Navigator.of(context).pop(action.result);
                              }
                              action.onPressed?.call();
                            }
                          : null,
                      style: buttonStyle,
                      child: Text(action.label),
                    );
                  }
                } else {
                  if (action.icon != null) {
                    button = OutlinedButton.icon(
                      onPressed: action.isEnabled
                          ? () {
                              if (action.result != null) {
                                Navigator.of(context).pop(action.result);
                              }
                              action.onPressed?.call();
                            }
                          : null,
                      style: buttonStyle,
                      icon: Icon(action.icon, size: 18),
                      label: Text(action.label),
                    );
                  } else {
                    button = OutlinedButton(
                      onPressed: action.isEnabled
                          ? () {
                              if (action.result != null) {
                                Navigator.of(context).pop(action.result);
                              }
                              action.onPressed?.call();
                            }
                          : null,
                      style: buttonStyle,
                      child: Text(action.label),
                    );
                  }
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                    child: button,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: AnimDurations.normal, curve: AppCurves.elastic);
  }
}

class ModernDialogAction {
  final String label;
  final bool isPrimary;
  final bool isDestructive;
  final bool isEnabled;
  final IconData? icon;
  final VoidCallback? onPressed;
  final dynamic result;

  const ModernDialogAction({
    required this.label,
    this.isPrimary = false,
    this.isDestructive = false,
    this.isEnabled = true,
    this.icon,
    this.onPressed,
    this.result,
  });
}

/// Modern snackbar alternatifi - kısa bildirimler için
class ModernNotification extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;

  const ModernNotification({
    super.key,
    required this.message,
    this.icon,
    this.backgroundColor,
    this.iconColor,
  });

  static void show({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? iconColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _ModernNotificationOverlay(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration + const Duration(milliseconds: 500), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: SpacingInsets.m,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.s + Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: RadiiBR.md,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? theme.colorScheme.onSurface,
              size: 24,
            ),
            HorizontalSpacing.s,
          ],
          Flexible(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: iconColor ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernNotificationOverlay extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Duration duration;

  const _ModernNotificationOverlay({
    required this.message,
    this.icon,
    this.backgroundColor,
    this.iconColor,
    required this.duration,
  });

  @override
  State<_ModernNotificationOverlay> createState() =>
      _ModernNotificationOverlayState();
}

class _ModernNotificationOverlayState
    extends State<_ModernNotificationOverlay> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Show animation
    Future.delayed(AnimDurations.micro, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });

    // Hide animation
    Future.delayed(widget.duration, () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: AnimDurations.normal,
        curve: AppCurves.standard,
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, -1),
          duration: AnimDurations.normal,
          curve: AppCurves.easeOut,
          child: Center(
            child: ModernNotification(
              message: widget.message,
              icon: widget.icon,
              backgroundColor: widget.backgroundColor,
              iconColor: widget.iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
