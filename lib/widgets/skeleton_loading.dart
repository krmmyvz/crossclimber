import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';

class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: Opacities.half,
            ),
            borderRadius: borderRadius ?? RadiiBR.lg,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: AnimDurations.slowest,
          color: theme.colorScheme.surfaceContainerHighest,
        );
  }
}

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? SpacingInsets.m,
      itemCount: itemCount,
      separatorBuilder: (context, index) => VerticalSpacing.s,
      itemBuilder: (context, index) {
        return SkeletonCard(height: itemHeight, width: double.infinity);
      },
    );
  }
}

class SkeletonRow extends StatelessWidget {
  final int itemCount;
  final double height;
  final double spacing;

  const SkeletonRow({
    super.key,
    this.itemCount = 3,
    this.height = 100,
    this.spacing = Spacing.m,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(itemCount, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < itemCount - 1 ? spacing : 0,
            ),
            child: SkeletonCard(height: height),
          ),
        );
      }),
    );
  }
}
