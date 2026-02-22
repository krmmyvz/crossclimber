import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';

class TimeStatsCard extends StatelessWidget {
  final Statistics stats;

  const TimeStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(Spacing.m + Spacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: RadiiBR.lg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _TimeStatRow(
            label: l10n.totalTimePlayed,
            value: _formatDuration(stats.totalPlayTime.inSeconds),
            icon: Icons.hourglass_full,
          ),
          const Divider(height: 24),
          _TimeStatRow(
            label: l10n.bestTime,
            value: stats.bestTime > 0 ? _formatDuration(stats.bestTime) : 'N/A',
            icon: Icons.speed,
          ),
          const Divider(height: 24),
          _TimeStatRow(
            label: l10n.averageTime,
            value: stats.totalGamesWon > 0
                ? _formatDuration(stats.averageTime.round())
                : 'N/A',
            icon: Icons.av_timer,
          ),
        ],
      ),
    ).animate().fadeIn(delay: AnimDurations.microFast).slideX(begin: -0.2, end: 0);
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}

class _TimeStatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TimeStatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: Spacing.iconSize),
        HorizontalSpacing.m,
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
