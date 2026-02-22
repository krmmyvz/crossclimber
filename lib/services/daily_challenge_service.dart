import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final dailyChallengeServiceProvider = Provider<DailyChallengeService>((ref) {
  return DailyChallengeService();
});

// ─── Streak update result ─────────────────────────────────────────────────────

class StreakUpdateResult {
  /// The streak value after the update.
  final int newStreak;

  /// If a milestone (7/14/30/60/100) was just reached for the first time.
  final int? milestoneReached;

  /// Credits granted for the milestone (0 if none).
  final int creditsGranted;

  /// True when a streak freeze was consumed to prevent a reset.
  final bool freezeUsed;

  const StreakUpdateResult({
    required this.newStreak,
    this.milestoneReached,
    this.creditsGranted = 0,
    this.freezeUsed = false,
  });
}

class DailyChallenge {
  final int levelId;
  final DateTime date;
  final int bonusStars;
  final bool completed;
  final DateTime? completedAt;
  final int streak;
  final Map<String, int> stats;
  // Completion data for viewing/sharing
  final int? completionScore;
  final Duration? completionTime;
  final int? completionStars;

  DailyChallenge({
    required this.levelId,
    required this.date,
    this.bonusStars = 2,
    this.completed = false,
    this.completedAt,
    this.streak = 0,
    this.stats = const {},
    this.completionScore,
    this.completionTime,
    this.completionStars,
  });

  bool get isCompleted => completed;

  Map<String, dynamic> toJson() => {
    'levelId': levelId,
    'date': date.toIso8601String(),
    'bonusStars': bonusStars,
    'completed': completed,
    'completedAt': completedAt?.toIso8601String(),
    'streak': streak,
    'stats': stats,
    'completionScore': completionScore,
    'completionTime': completionTime?.inSeconds,
    'completionStars': completionStars,
  };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      levelId: json['levelId'],
      date: DateTime.parse(json['date']),
      bonusStars: json['bonusStars'] ?? 2,
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      streak: json['streak'] ?? 0,
      stats: Map<String, int>.from(json['stats'] ?? {}),
      completionScore: json['completionScore'],
      completionTime: json['completionTime'] != null
          ? Duration(seconds: json['completionTime'])
          : null,
      completionStars: json['completionStars'],
    );
  }
}

class DailyChallengeService {
  static const String _key = 'daily_challenge';

  // ── SharedPreferences keys ────────────────────────────────────────────────
  static const String _keyStreakFreezeCount = 'streak_freeze_count';
  static const String _keyMilestonesGranted = 'streak_milestones_granted';
  static const String _keyLastCompletedDate = 'challenge_last_completed_date';
  static const String _keyMissedDayProcessedPrefix = 'streak_missed_processed_';

  // ── Milestone definitions: days → bonus credits ───────────────────────────
  static const Map<int, int> kMilestoneCredits = {
    7: 100,
    14: 200,
    30: 500,
    60: 1000,
    100: 2000,
  };

  Future<DailyChallenge> getDailyChallenge() async {
    // Auto-handle streak for missed days (freeze or reset)
    await _checkAndHandleMissedDay();

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Try to load existing challenge
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      try {
        final challenge = DailyChallenge.fromJson(jsonDecode(jsonString));

        // Check if it's still today's challenge
        final challengeDate = DateTime(
          challenge.date.year,
          challenge.date.month,
          challenge.date.day,
        );

        if (challengeDate.isAtSameMomentAs(today)) {
          // Update with current stats and streak
          final stats = await getChallengeStats();
          final streak = await getCurrentStreak();
          return DailyChallenge(
            levelId: challenge.levelId,
            date: challenge.date,
            bonusStars: challenge.bonusStars,
            completed: challenge.completed,
            completedAt: challenge.completedAt,
            streak: streak,
            stats: stats,
            // Preserve completion data when loading saved challenge
            completionScore: challenge.completionScore,
            completionTime: challenge.completionTime,
            completionStars: challenge.completionStars,
          );
        }
      } catch (e) {
        // Invalid data, create new challenge
      }
    }

    // Generate new challenge for today
    final levelId = _generateDailyLevelId(today);
    final stats = await getChallengeStats();
    final streak = await getCurrentStreak();
    final newChallenge = DailyChallenge(
      levelId: levelId,
      date: today,
      bonusStars: 2,
      streak: streak,
      stats: stats,
    );

    await _saveChallenge(newChallenge);
    return newChallenge;
  }

  Future<DailyChallenge> getTodayChallenge() async {
    return getDailyChallenge();
  }

  int _generateDailyLevelId(DateTime date) {
    // Generate a consistent level ID based on date
    // We have 30 daily challenge levels (1-30)
    // Use day of year to cycle through them
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;

    // Cycle through levels 1-30 based on the day of year
    // This ensures each day gets a unique level but it repeats predictably
    return (dayOfYear % 30) + 1;
  }

  Future<void> completeChallenge({
    int? score,
    Duration? time,
    int? stars,
  }) async {
    final challenge = await getTodayChallenge();
    final completed = DailyChallenge(
      levelId: challenge.levelId,
      date: challenge.date,
      bonusStars: challenge.bonusStars,
      completed: true,
      completedAt: DateTime.now(),
      completionScore: score,
      completionTime: time,
      completionStars: stars,
    );
    await _saveChallenge(completed);

    // Award credits for completion (50 credits - balanced reward)
    final prefs = await SharedPreferences.getInstance();
    final currentCredits = prefs.getInt('credits') ?? 10;
    await prefs.setInt('credits', currentCredits + 50);
  }

  Future<void> _saveChallenge(DailyChallenge challenge) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(challenge.toJson()));
  }

  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('challenge_streak') ?? 0;
  }

  Future<StreakUpdateResult> updateStreak(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    final currentStreak = await getCurrentStreak();

    if (completed) {
      final newStreak = currentStreak + 1;
      await prefs.setInt('challenge_streak', newStreak);

      // Track last completed date for missed-day detection
      final now = DateTime.now();
      await prefs.setString(
        _keyLastCompletedDate,
        DateTime(now.year, now.month, now.day).toIso8601String(),
      );

      // Update best streak
      final bestStreak = prefs.getInt('challenges_best_streak') ?? 0;
      if (newStreak > bestStreak) {
        await prefs.setInt('challenges_best_streak', newStreak);
      }

      // Check milestone
      int? milestoneReached;
      int creditsGranted = 0;
      if (kMilestoneCredits.containsKey(newStreak)) {
        final grantedStr = prefs.getString(_keyMilestonesGranted) ?? '[]';
        final granted =
            (jsonDecode(grantedStr) as List).map((e) => e as int).toList();
        if (!granted.contains(newStreak)) {
          milestoneReached = newStreak;
          creditsGranted = kMilestoneCredits[newStreak]!;
          final currentCredits = prefs.getInt('credits') ?? 10;
          await prefs.setInt('credits', currentCredits + creditsGranted);
          granted.add(newStreak);
          await prefs.setString(_keyMilestonesGranted, jsonEncode(granted));
        }
      }

      return StreakUpdateResult(
        newStreak: newStreak,
        milestoneReached: milestoneReached,
        creditsGranted: creditsGranted,
      );
    } else {
      // Missed a day — try to consume a freeze first
      final freezeCount = await getStreakFreezeCount();
      if (currentStreak > 0 && freezeCount > 0) {
        await prefs.setInt(_keyStreakFreezeCount, freezeCount - 1);
        return StreakUpdateResult(newStreak: currentStreak, freezeUsed: true);
      }
      await prefs.setInt('challenge_streak', 0);
      return const StreakUpdateResult(newStreak: 0);
    }
  }

  Future<Map<String, int>> getChallengeStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'completed': prefs.getInt('challenges_completed') ?? 0,
      'streak': await getCurrentStreak(),
      'bestStreak': prefs.getInt('challenges_best_streak') ?? 0,
      'totalStars': prefs.getInt('challenges_total_stars') ?? 0,
    };
  }

  // ── Streak freeze API ─────────────────────────────────────────────────────

  Future<int> getStreakFreezeCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreakFreezeCount) ?? 0;
  }

  Future<void> addStreakFreezes(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyStreakFreezeCount) ?? 0;
    await prefs.setInt(_keyStreakFreezeCount, current + count);
  }

  // ── Convenience helper ────────────────────────────────────────────────────

  /// Returns true if today's daily challenge has already been completed.
  Future<bool> isTodayChallengeCompleted() async {
    final challenge = await getTodayChallenge();
    return challenge.isCompleted;
  }

  // ── Private: missed-day detection ─────────────────────────────────────────

  /// Called once per day when loading the challenge.
  /// If the user missed ≥ 1 day and has a freeze, consumes the freeze
  /// to preserve the streak; otherwise resets streak to 0.
  Future<void> _checkAndHandleMissedDay() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr =
        DateTime(now.year, now.month, now.day).toIso8601String();
    final processedKey = '$_keyMissedDayProcessedPrefix$todayStr';
    if (prefs.getBool(processedKey) == true) return;
    await prefs.setBool(processedKey, true);

    final lastCompletedStr = prefs.getString(_keyLastCompletedDate);
    if (lastCompletedStr == null) return; // Never completed a challenge

    final lastCompleted = DateTime.parse(lastCompletedStr);
    final daysSince =
        DateTime(now.year, now.month, now.day).difference(lastCompleted).inDays;
    if (daysSince <= 1) return; // Consecutive or same day — no miss

    final currentStreak = await getCurrentStreak();
    if (currentStreak == 0) return;

    final freezeCount = prefs.getInt(_keyStreakFreezeCount) ?? 0;
    if (freezeCount > 0) {
      await prefs.setInt(_keyStreakFreezeCount, freezeCount - 1);
      // Streak preserved — freeze consumed silently
    } else {
      await prefs.setInt('challenge_streak', 0);
    }
  }

  Future<void> checkDailyLoginReward() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginStr = prefs.getString('last_login_date');
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';

    if (lastLoginStr != todayStr) {
      // New day login
      final currentCredits = prefs.getInt('credits') ?? 10;
      await prefs.setInt(
        'credits',
        currentCredits + 20,
      ); // 20 credits for daily login
      await prefs.setString('last_login_date', todayStr);
    }
  }
}
