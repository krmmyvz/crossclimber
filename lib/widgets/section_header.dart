import 'package:flutter/material.dart';

import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/spacing.dart';

/// Standardized section header widget used across screens.
///
/// Displays an optional leading icon, title text, and optional trailing widget.
///
/// ```dart
/// SectionHeader(
///   icon: Icons.trending_up,
///   title: 'Statistics',
///   trailing: Badge(label: '3'),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  /// Icon displayed before the title. If null, no icon is shown.
  final IconData? icon;

  /// Section title text.
  final String title;

  /// Optional widget displayed at the end (badge, chip, button, etc.).
  final Widget? trailing;

  /// Icon/title color override. Defaults to `theme.colorScheme.primary`.
  final Color? color;

  /// Icon size override. Defaults to [IconSizes.smd].
  final double? iconSize;

  /// Text style override. Defaults to `theme.textTheme.titleMedium` with bold.
  final TextStyle? titleStyle;

  /// Horizontal gap between icon and title. Defaults to [Spacing.xs].
  final double spacing;

  const SectionHeader({
    super.key,
    this.icon,
    required this.title,
    this.trailing,
    this.color,
    this.iconSize,
    this.titleStyle,
    this.spacing = Spacing.xs,
  });

  /// Large variant — uses titleLarge + bold. Common for main section headers.
  const factory SectionHeader.large({
    Key? key,
    IconData? icon,
    required String title,
    Widget? trailing,
    Color? color,
  }) = _LargeSectionHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveStyle = titleStyle ??
        theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: effectiveColor,
        );

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize ?? IconSizes.smd, color: effectiveColor),
          SizedBox(width: spacing),
        ],
        Expanded(
          child: Text(
            title,
            style: effectiveStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _LargeSectionHeader extends SectionHeader {
  const _LargeSectionHeader({
    super.key,
    super.icon,
    required super.title,
    super.trailing,
    super.color,
  }) : super(spacing: Spacing.s);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionHeader(
      icon: icon,
      title: title,
      trailing: trailing,
      color: color,
      iconSize: iconSize,
      spacing: Spacing.s,
      titleStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ).build(context);
  }
}
