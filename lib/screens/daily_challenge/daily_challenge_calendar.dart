import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/services/daily_challenge_service.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';

/// Mixin for daily challenge calendar widgets
mixin DailyChallengeCalendar {
  Widget buildCalendarView(
    ThemeData theme,
    DailyChallengeService service,
    DailyChallenge currentChallenge,
  ) {
    return Container(
      padding: const EdgeInsets.all(Spacing.l - Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: theme.colorScheme.primary),
              HorizontalSpacing.s,
              Text(
                'Last 7 Days',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          VerticalSpacing.l,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = DateTime.now().subtract(Duration(days: 6 - index));
              final isToday = index == 6;

              // Check if challenge was completed on this date
              bool isCompleted = false;
              if (isToday) {
                isCompleted = currentChallenge.isCompleted;
              }
              // For past days, use streak as heuristic
              if (!isToday && currentChallenge.streak > 0) {
                final daysAgo = 6 - index;
                if (daysAgo < currentChallenge.streak) {
                  isCompleted = true;
                }
              }

              return buildCalendarDay(theme, date, isCompleted, isToday);
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget buildCalendarDay(
    ThemeData theme,
    DateTime date,
    bool completed,
    bool isToday,
  ) {
    final dayName = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];

    return Column(
      children: [
        Text(
          dayName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        VerticalSpacing.s,
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: completed
                ? theme.gameColors.success
                : (isToday
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest),
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Center(
            child: completed
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${date.day}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
