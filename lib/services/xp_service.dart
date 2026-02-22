import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/models/rank_info.dart';

// Re-export so existing imports keep working.
export 'package:crossclimber/models/rank_info.dart';

// ─── XpService ────────────────────────────────────────────────────────────────

class XpService {
  static const String _kXpKey = 'player_xp';

  Future<int> getXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kXpKey) ?? 0;
  }

  Future<int> addXp(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_kXpKey) ?? 0;
    final newXp = current + amount;
    await prefs.setInt(_kXpKey, newXp);
    return newXp;
  }

  // ─── XP calculation ─────────────────────────────────────────────────────

  /// XP earned for completing a regular level.
  /// Formula: base (by stars) + difficulty bonus (by levelId bracket) + combo bonus.
  static int xpForCompletion({
    required int stars,
    required int levelId,
    int maxCombo = 0,
  }) {
    // Base XP by star count
    final base = switch (stars) {
      3 => 150,
      2 => 100,
      1 => 50,
      _ => 10,
    };
    // Difficulty bonus by level bracket
    final difficultyBonus = levelId <= 10
        ? 0
        : levelId <= 30
            ? 25
            : levelId <= 60
                ? 50
                : 75;
    // Combo bonus: maxCombo × 10
    final comboBonus = maxCombo * 10;
    return base + difficultyBonus + comboBonus;
  }

  /// XP earned for completing a daily challenge.
  /// Formula: 200 + streak × 20 (capped at 100 bonus) + combo bonus.
  static int xpForDailyChallenge({
    int streak = 0,
    int maxCombo = 0,
  }) {
    const base = 200;
    final streakBonus = (streak * 20).clamp(0, 100);
    final comboBonus = maxCombo * 10;
    return base + streakBonus + comboBonus;
  }

  // ─── Rank helpers ────────────────────────────────────────────────────────

  static RankInfo computeRankInfo({
    required int totalXp,
    required int gainedXp,
  }) {
    int rankIndex = 0;
    for (int i = kRankDefs.length - 1; i >= 0; i--) {
      if (totalXp >= kRankDefs[i].threshold) {
        rankIndex = i;
        break;
      }
    }

    final def = kRankDefs[rankIndex];
    final isMax = rankIndex == kRankDefs.length - 1;
    final nextThreshold =
        isMax ? totalXp : kRankDefs[rankIndex + 1].threshold;

    final progress = isMax
        ? 1.0
        : (totalXp - def.threshold) / (nextThreshold - def.threshold);

    return RankInfo(
      icon: def.icon,
      name: def.key, // Will be localized at display time via RankDef.localizedName
      key: def.key,
      rankIndex: rankIndex,
      rankThreshold: def.threshold,
      nextThreshold: nextThreshold,
      progress: progress.clamp(0.0, 1.0),
      gainedXp: gainedXp,
      totalXp: totalXp,
    );
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final xpServiceProvider = Provider<XpService>((ref) => XpService());

final playerXpProvider = FutureProvider<int>((ref) {
  return ref.read(xpServiceProvider).getXp();
});

/// Provides the current player RankInfo reactively.
final playerRankInfoProvider = FutureProvider<RankInfo>((ref) async {
  final xp = await ref.watch(playerXpProvider.future);
  return XpService.computeRankInfo(totalXp: xp, gainedXp: 0);
});
