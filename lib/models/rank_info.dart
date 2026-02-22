import 'package:flutter/material.dart';
import 'package:crossclimber/l10n/app_localizations.dart';

// ─── Rank definition ─────────────────────────────────────────────────────────

/// Internal rank data: (icon, l10n key suffix, xpThreshold).
/// The l10n key suffix maps to `rankNovice`, `rankWordStudent`, etc.
const List<RankDef> kRankDefs = [
  RankDef(icon: Icons.eco_rounded, key: 'Novice', threshold: 0),
  RankDef(icon: Icons.menu_book_rounded, key: 'WordStudent', threshold: 500),
  RankDef(icon: Icons.edit_rounded, key: 'WordMaster', threshold: 1500),
  RankDef(icon: Icons.extension_rounded, key: 'PuzzleSolver', threshold: 3000),
  RankDef(icon: Icons.terrain_rounded, key: 'MountainClimber', threshold: 6000),
  RankDef(icon: Icons.air_rounded, key: 'WordEagle', threshold: 10000),
  RankDef(icon: Icons.workspace_premium_rounded, key: 'WordKing', threshold: 18000),
  RankDef(icon: Icons.diamond_rounded, key: 'DiamondMind', threshold: 30000),
  RankDef(icon: Icons.local_fire_department_rounded, key: 'Legend', threshold: 50000),
  RankDef(icon: Icons.star_rounded, key: 'CrossClimberMaster', threshold: 80000),
];

class RankDef {
  final IconData icon;
  final String key;
  final int threshold;

  const RankDef({
    required this.icon,
    required this.key,
    required this.threshold,
  });

  /// Resolve the localized name for this rank.
  String localizedName(AppLocalizations l10n) {
    return switch (key) {
      'Novice' => l10n.rankNovice,
      'WordStudent' => l10n.rankWordStudent,
      'WordMaster' => l10n.rankWordMaster,
      'PuzzleSolver' => l10n.rankPuzzleSolver,
      'MountainClimber' => l10n.rankMountainClimber,
      'WordEagle' => l10n.rankWordEagle,
      'WordKing' => l10n.rankWordKing,
      'DiamondMind' => l10n.rankDiamondMind,
      'Legend' => l10n.rankLegend,
      'CrossClimberMaster' => l10n.rankCrossClimberMaster,
      _ => key,
    };
  }
}

// ─── RankInfo ─────────────────────────────────────────────────────────────────

class RankInfo {
  final IconData icon;
  final String name; // Localized or fallback
  final String key; // Internal key for rank-up detection
  final int rankIndex;
  final int rankThreshold;
  final int nextThreshold;
  final double progress; // 0.0–1.0 within current rank
  final int gainedXp;
  final int totalXp;

  const RankInfo({
    required this.icon,
    required this.name,
    required this.key,
    required this.rankIndex,
    required this.rankThreshold,
    required this.nextThreshold,
    required this.progress,
    required this.gainedXp,
    required this.totalXp,
  });

  bool get isMaxRank => rankIndex == kRankDefs.length - 1;

  /// XP remaining until next rank.
  int get xpToNextRank => isMaxRank ? 0 : nextThreshold - totalXp;

  /// Whether a rank-up occurred compared to [previous].
  bool didRankUp(RankInfo previous) => rankIndex > previous.rankIndex;
}
