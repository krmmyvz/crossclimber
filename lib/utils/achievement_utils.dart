import 'package:flutter/material.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/l10n/app_localizations.dart';

class AchievementUtils {
  // ── Rarity ─────────────────────────────────────────────────────────────

  static AchievementRarity getRarity(AchievementType type) => switch (type) {
        // Legendary
        AchievementType.hundredLevels ||
        AchievementType.perfectStreak10 ||
        AchievementType.threeStarPerfectionist ||
        AchievementType.marathonRunner ||
        AchievementType.streak60Days ||
        AchievementType.streak100Days ||
        AchievementType.combo10x ||
        AchievementType.allLevels ||
        AchievementType.legendaryRank =>
          AchievementRarity.legendary,

        // Rare
        AchievementType.thirtyLevels ||
        AchievementType.fiftyLevels ||
        AchievementType.perfectStreak5 ||
        AchievementType.speedDemon ||
        AchievementType.noHintsMaster ||
        AchievementType.errorFree ||
        AchievementType.streak30Days ||
        AchievementType.combo8x ||
        AchievementType.speed45s ||
        AchievementType.dailyChallenge30 ||
        AchievementType.shareResults =>
          AchievementRarity.rare,

        // Common (everything else)
        _ => AchievementRarity.common,
      };

  static Color rarityColor(AchievementRarity rarity, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (rarity) {
      AchievementRarity.legendary => const Color(0xFFFFB300), // gold
      AchievementRarity.rare      => const Color(0xFF7C4DFF), // purple
      AchievementRarity.common    => cs.primary,
    };
  }

  static String rarityLabel(AchievementRarity rarity, AppLocalizations l10n) =>
      switch (rarity) {
        AchievementRarity.legendary => l10n.achievementRarityLegendary,
        AchievementRarity.rare      => l10n.achievementRarityRare,
        AchievementRarity.common    => l10n.achievementRarityCommon,
      };

  // ── Icon ────────────────────────────────────────────────────────────────

  static IconData getIcon(AchievementType type) => switch (type) {
        AchievementType.firstWin              => Icons.emoji_events,
        AchievementType.tenLevels             => Icons.star,
        AchievementType.thirtyLevels          => Icons.stars,
        AchievementType.fiftyLevels           => Icons.workspace_premium,
        AchievementType.hundredLevels         => Icons.military_tech,
        AchievementType.perfectStreak5        => Icons.calendar_today,
        AchievementType.perfectStreak10       => Icons.event_available,
        AchievementType.speedDemon            => Icons.flash_on,
        AchievementType.noHintsMaster         => Icons.auto_awesome,
        AchievementType.threeStarPerfectionist => Icons.diamond,
        AchievementType.earlyBird             => Icons.wb_sunny,
        AchievementType.nightOwl              => Icons.nightlight,
        AchievementType.marathonRunner        => Icons.directions_run,
        AchievementType.hintlessHero          => Icons.lightbulb,
        AchievementType.errorFree             => Icons.done_all,
        AchievementType.streak7Days           => Icons.local_fire_department,
        AchievementType.streak14Days          => Icons.local_fire_department,
        AchievementType.streak30Days          => Icons.whatshot_rounded,
        AchievementType.streak60Days          => Icons.bolt_rounded,
        AchievementType.streak100Days         => Icons.military_tech_rounded,
        AchievementType.combo5x               => Icons.track_changes_rounded,
        AchievementType.combo8x               => Icons.palette_rounded,
        AchievementType.combo10x              => Icons.auto_awesome_rounded,
        AchievementType.speed60s              => Icons.rocket_launch_rounded,
        AchievementType.speed45s              => Icons.electric_bolt_rounded,
        AchievementType.allLevels             => Icons.landscape_rounded,
        AchievementType.legendaryRank         => Icons.workspace_premium_rounded,
        AchievementType.shareResults          => Icons.share_rounded,
        AchievementType.dailyChallengeFirst   => Icons.calendar_month_rounded,
        AchievementType.dailyChallenge30      => Icons.date_range_rounded,
      };

  // ── Title ────────────────────────────────────────────────────────────────

  static String getTitle(AppLocalizations l10n, AchievementType type) =>
      switch (type) {
        AchievementType.firstWin              => l10n.achievementFirstWin,
        AchievementType.tenLevels             => l10n.achievementTenLevels,
        AchievementType.thirtyLevels          => l10n.achievementThirtyLevels,
        AchievementType.fiftyLevels           => l10n.achievementFiftyLevels,
        AchievementType.hundredLevels         => l10n.achievementCenturyClub,
        AchievementType.perfectStreak5        => l10n.achievementPerfectStreak5,
        AchievementType.perfectStreak10       => l10n.achievementPerfectStreak10,
        AchievementType.speedDemon            => l10n.achievementSpeedDemon,
        AchievementType.noHintsMaster         => l10n.achievementNoHintsMaster,
        AchievementType.threeStarPerfectionist => l10n.achievementThreeStarPerfectionist,
        AchievementType.earlyBird             => l10n.achievementEarlyBird,
        AchievementType.nightOwl              => l10n.achievementNightOwl,
        AchievementType.marathonRunner        => l10n.achievementMarathonRunner,
        AchievementType.hintlessHero          => l10n.achievementHintlessHero,
        AchievementType.errorFree             => l10n.achievementErrorFree,
        AchievementType.streak7Days           => l10n.achievementStreak7Days,
        AchievementType.streak14Days          => l10n.achievementStreak14Days,
        AchievementType.streak30Days          => l10n.achievementStreak30Days,
        AchievementType.streak60Days          => l10n.achievementStreak60Days,
        AchievementType.streak100Days         => l10n.achievementStreak100Days,
        AchievementType.combo5x               => l10n.achievementCombo5x,
        AchievementType.combo8x               => l10n.achievementCombo8x,
        AchievementType.combo10x              => l10n.achievementCombo10x,
        AchievementType.speed60s              => l10n.achievementSpeed60s,
        AchievementType.speed45s              => l10n.achievementSpeed45s,
        AchievementType.allLevels             => l10n.achievementAllLevels,
        AchievementType.legendaryRank         => l10n.achievementLegendaryRank,
        AchievementType.shareResults          => l10n.achievementShareResults,
        AchievementType.dailyChallengeFirst   => l10n.achievementDailyChallengeFirst,
        AchievementType.dailyChallenge30      => l10n.achievementDailyChallenge30,
      };

  // ── Description ─────────────────────────────────────────────────────────

  static String getDescription(AppLocalizations l10n, AchievementType type) =>
      switch (type) {
        AchievementType.firstWin              => l10n.achievementDescFirstWin,
        AchievementType.tenLevels             => l10n.achievementDescTenLevels,
        AchievementType.thirtyLevels          => l10n.achievementDescThirtyLevels,
        AchievementType.fiftyLevels           => l10n.achievementDescFiftyLevels,
        AchievementType.hundredLevels         => l10n.achievementDescCenturyClub,
        AchievementType.perfectStreak5        => l10n.achievementDescPerfectStreak5,
        AchievementType.perfectStreak10       => l10n.achievementDescPerfectStreak10,
        AchievementType.speedDemon            => l10n.achievementDescSpeedDemon,
        AchievementType.noHintsMaster         => l10n.achievementDescNoHintsMaster,
        AchievementType.threeStarPerfectionist => l10n.achievementDescThreeStarPerfectionist,
        AchievementType.earlyBird             => l10n.achievementDescEarlyBird,
        AchievementType.nightOwl              => l10n.achievementDescNightOwl,
        AchievementType.marathonRunner        => l10n.achievementDescMarathonRunner,
        AchievementType.hintlessHero          => l10n.achievementDescHintlessHero,
        AchievementType.errorFree             => l10n.achievementDescErrorFree,
        AchievementType.streak7Days           => l10n.achievementDescStreak7Days,
        AchievementType.streak14Days          => l10n.achievementDescStreak14Days,
        AchievementType.streak30Days          => l10n.achievementDescStreak30Days,
        AchievementType.streak60Days          => l10n.achievementDescStreak60Days,
        AchievementType.streak100Days         => l10n.achievementDescStreak100Days,
        AchievementType.combo5x               => l10n.achievementDescCombo5x,
        AchievementType.combo8x               => l10n.achievementDescCombo8x,
        AchievementType.combo10x              => l10n.achievementDescCombo10x,
        AchievementType.speed60s              => l10n.achievementDescSpeed60s,
        AchievementType.speed45s              => l10n.achievementDescSpeed45s,
        AchievementType.allLevels             => l10n.achievementDescAllLevels,
        AchievementType.legendaryRank         => l10n.achievementDescLegendaryRank,
        AchievementType.shareResults          => l10n.achievementDescShareResults,
        AchievementType.dailyChallengeFirst   => l10n.achievementDescDailyChallengeFirst,
        AchievementType.dailyChallenge30      => l10n.achievementDescDailyChallenge30,
      };
}
