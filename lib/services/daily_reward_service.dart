import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dailyRewardServiceProvider = Provider<DailyRewardService>((ref) {
  return DailyRewardService();
});

class DailyReward {
  final int credits;
  final int revealHints;
  final int undoHints;
  final int streakDay;
  final bool alreadyClaimed;

  DailyReward({
    required this.credits,
    this.revealHints = 0,
    this.undoHints = 0,
    required this.streakDay,
    this.alreadyClaimed = false,
  });

  factory DailyReward.alreadyClaimed() {
    return DailyReward(credits: 0, streakDay: 0, alreadyClaimed: true);
  }

  bool get hasRewards => credits > 0 || revealHints > 0 || undoHints > 0;
}

class DailyRewardService {
  static const String _keyLastClaim = 'lastDailyReward';
  static const String _keyStreakCount = 'dailyStreakCount';

  /// Check if daily reward is available
  Future<bool> canClaimToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaim = prefs.getString(_keyLastClaim);

    if (lastClaim == null) return true;

    final lastClaimDate = DateTime.parse(lastClaim);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastClaimDay = DateTime(
      lastClaimDate.year,
      lastClaimDate.month,
      lastClaimDate.day,
    );

    return today.isAfter(lastClaimDay);
  }

  /// Get current streak count
  Future<int> getStreakCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreakCount) ?? 0;
  }

  /// Claim daily reward
  Future<DailyReward> claimDailyReward() async {
    final canClaim = await canClaimToday();
    if (!canClaim) {
      return DailyReward.alreadyClaimed();
    }

    final prefs = await SharedPreferences.getInstance();
    final lastClaim = prefs.getString(_keyLastClaim);
    final streakCount = prefs.getInt(_keyStreakCount) ?? 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = 1;

    if (lastClaim != null) {
      final lastClaimDate = DateTime.parse(lastClaim);
      final lastClaimDay = DateTime(
        lastClaimDate.year,
        lastClaimDate.month,
        lastClaimDate.day,
      );
      final daysSince = today.difference(lastClaimDay).inDays;

      // Continue streak if claimed yesterday
      if (daysSince == 1) {
        newStreak = streakCount + 1;
      }
      // Reset streak if missed days
      else if (daysSince > 1) {
        newStreak = 1;
      }
    }

    await prefs.setInt(_keyStreakCount, newStreak);
    await prefs.setString(_keyLastClaim, today.toIso8601String());

    // Calculate rewards based on streak
    const baseCredits = 20;
    final streakBonus = (newStreak - 1) * 5; // +5 credits per day
    final totalCredits = baseCredits + streakBonus;

    // Special rewards on certain days
    int revealHints = 0;
    int undoHints = 0;

    if (newStreak % 3 == 0) {
      revealHints = 1; // 1 Reveal hint every 3 days
    }

    if (newStreak == 7) {
      revealHints = 2; // 2 Reveal hints on day 7
      undoHints = 3; // 3 Undo hints on day 7
    }

    // Reset streak after 7 days
    if (newStreak >= 7) {
      await prefs.setInt(_keyStreakCount, 0);
    }

    return DailyReward(
      credits: totalCredits,
      revealHints: revealHints,
      undoHints: undoHints,
      streakDay: newStreak,
    );
  }

  /// Get time until next reward is available
  Future<Duration?> getTimeUntilNextReward() async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaim = prefs.getString(_keyLastClaim);

    if (lastClaim == null) return null;

    final lastClaimDate = DateTime.parse(lastClaim);
    final lastClaimDay = DateTime(
      lastClaimDate.year,
      lastClaimDate.month,
      lastClaimDate.day,
    );
    final nextReward = lastClaimDay.add(const Duration(days: 1));
    final now = DateTime.now();

    if (now.isAfter(nextReward)) return null;

    return nextReward.difference(now);
  }
}
