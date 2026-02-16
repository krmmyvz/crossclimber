import 'package:flutter/material.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/l10n/app_localizations.dart';

class AchievementUtils {
  static IconData getIcon(AchievementType type) {
    switch (type) {
      case AchievementType.firstWin:
        return Icons.emoji_events;
      case AchievementType.tenLevels:
        return Icons.star;
      case AchievementType.speedDemon:
        return Icons.flash_on;
      case AchievementType.marathonRunner:
        return Icons.directions_run;
      case AchievementType.thirtyLevels:
        return Icons.stars;
      case AchievementType.perfectStreak5:
        return Icons.calendar_today;
      case AchievementType.hundredLevels:
        return Icons.military_tech;
      case AchievementType.hintlessHero:
        return Icons.lightbulb;
      case AchievementType.errorFree:
        return Icons.done_all;
      case AchievementType.earlyBird:
        return Icons.wb_sunny;
      case AchievementType.nightOwl:
        return Icons.nightlight;
      case AchievementType.perfectStreak10:
        return Icons.event_available;
      case AchievementType.fiftyLevels:
        return Icons.workspace_premium;
      case AchievementType.threeStarPerfectionist:
        return Icons.diamond;
      case AchievementType.noHintsMaster:
        return Icons.auto_awesome;
    }
  }

  static String getTitle(AppLocalizations l10n, AchievementType type) {
    switch (type) {
      case AchievementType.firstWin:
        return l10n.achievementFirstWin;
      case AchievementType.tenLevels:
        return l10n.achievementTenLevels;
      case AchievementType.speedDemon:
        return l10n.achievementSpeedDemon;
      case AchievementType.marathonRunner:
        return l10n.achievementMarathonRunner;
      case AchievementType.thirtyLevels:
        return l10n.achievementThirtyLevels;
      case AchievementType.perfectStreak5:
        return l10n.achievementPerfectStreak5;
      case AchievementType.hundredLevels:
        return l10n.achievementCenturyClub;
      case AchievementType.hintlessHero:
        return l10n.achievementHintlessHero;
      case AchievementType.errorFree:
        return l10n.achievementErrorFree;
      case AchievementType.earlyBird:
        return l10n.achievementEarlyBird;
      case AchievementType.nightOwl:
        return l10n.achievementNightOwl;
      case AchievementType.perfectStreak10:
        return l10n.achievementPerfectStreak10;
      case AchievementType.fiftyLevels:
        return l10n.achievementFiftyLevels;
      case AchievementType.threeStarPerfectionist:
        return l10n.achievementThreeStarPerfectionist;
      case AchievementType.noHintsMaster:
        return l10n.achievementNoHintsMaster;
    }
  }

  static String getDescription(AppLocalizations l10n, AchievementType type) {
    switch (type) {
      case AchievementType.firstWin:
        return l10n.achievementDescFirstWin;
      case AchievementType.tenLevels:
        return l10n.achievementDescTenLevels;
      case AchievementType.speedDemon:
        return l10n.achievementDescSpeedDemon;
      case AchievementType.marathonRunner:
        return l10n.achievementDescMarathonRunner;
      case AchievementType.thirtyLevels:
        return l10n.achievementDescThirtyLevels;
      case AchievementType.perfectStreak5:
        return l10n.achievementDescPerfectStreak5;
      case AchievementType.hundredLevels:
        return l10n.achievementDescCenturyClub;
      case AchievementType.hintlessHero:
        return l10n.achievementDescHintlessHero;
      case AchievementType.errorFree:
        return l10n.achievementDescErrorFree;
      case AchievementType.earlyBird:
        return l10n.achievementDescEarlyBird;
      case AchievementType.nightOwl:
        return l10n.achievementDescNightOwl;
      case AchievementType.perfectStreak10:
        return l10n.achievementDescPerfectStreak10;
      case AchievementType.fiftyLevels:
        return l10n.achievementDescFiftyLevels;
      case AchievementType.threeStarPerfectionist:
        return l10n.achievementDescThreeStarPerfectionist;
      case AchievementType.noHintsMaster:
        return l10n.achievementDescNoHintsMaster;
    }
  }
}
