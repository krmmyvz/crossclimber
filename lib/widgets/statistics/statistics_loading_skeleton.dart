import 'package:flutter/material.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/skeleton_loading.dart';

class StatisticsLoadingSkeleton extends StatelessWidget {
  const StatisticsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: SpacingInsets.m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Overview Card
          SkeletonCard(height: 160),
          VerticalSpacing.l,
          // Performance Grid
          Row(
            children: [
              Expanded(child: SkeletonCard(height: 120)),
              HorizontalSpacing.s,
              Expanded(child: SkeletonCard(height: 120)),
            ],
          ),
          VerticalSpacing.l,
          // Time Stats
          SkeletonCard(height: 200),
          VerticalSpacing.l,
          // Achievement Progress
          SkeletonCard(height: 120),
        ],
      ),
    );
  }
}
