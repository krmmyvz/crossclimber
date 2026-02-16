import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository();
});

class Statistics {
  final int totalGamesPlayed;
  final int totalGamesWon;
  final Duration totalPlayTime;
  final int totalHintsUsed;
  final int totalWrongAttempts;
  final int threeStarLevels;
  final int twoStarLevels;
  final int oneStarLevels;
  final Duration? fastestSolve;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPlayedDate;
  final Map<int, LevelStats> levelStats; // level ID -> stats

  Statistics({
    this.totalGamesPlayed = 0,
    this.totalGamesWon = 0,
    this.totalPlayTime = Duration.zero,
    this.totalHintsUsed = 0,
    this.totalWrongAttempts = 0,
    this.threeStarLevels = 0,
    this.twoStarLevels = 0,
    this.oneStarLevels = 0,
    this.fastestSolve,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPlayedDate,
    this.levelStats = const {},
  });

  // Computed properties for UI compatibility
  int get totalStars =>
      (threeStarLevels * 3) + (twoStarLevels * 2) + oneStarLevels;
  int get perfectGames => threeStarLevels;
  int get bestTime => fastestSolve?.inSeconds ?? 0;

  double get winRate =>
      totalGamesPlayed > 0 ? (totalGamesWon / totalGamesPlayed * 100) : 0.0;

  double get averageTime =>
      totalGamesWon > 0 ? totalPlayTime.inSeconds / totalGamesWon : 0.0;

  Map<String, dynamic> toJson() => {
    'totalGamesPlayed': totalGamesPlayed,
    'totalGamesWon': totalGamesWon,
    'totalPlayTime': totalPlayTime.inSeconds,
    'totalHintsUsed': totalHintsUsed,
    'totalWrongAttempts': totalWrongAttempts,
    'threeStarLevels': threeStarLevels,
    'twoStarLevels': twoStarLevels,
    'oneStarLevels': oneStarLevels,
    'fastestSolve': fastestSolve?.inSeconds,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastPlayedDate': lastPlayedDate?.toIso8601String(),
    'levelStats': levelStats.map((k, v) => MapEntry(k.toString(), v.toJson())),
  };

  factory Statistics.fromJson(Map<String, dynamic> json) {
    final levelStats =
        (json['levelStats'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(int.parse(k), LevelStats.fromJson(v)),
        ) ??
        {};

    int threeStars = 0;
    int twoStars = 0;
    int oneStars = 0;

    for (final stat in levelStats.values) {
      if (stat.bestStars == 3) {
        threeStars++;
      } else if (stat.bestStars == 2) {
        twoStars++;
      } else if (stat.bestStars == 1) {
        oneStars++;
      }
    }

    return Statistics(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalGamesWon: json['totalGamesWon'] ?? 0,
      totalPlayTime: Duration(seconds: json['totalPlayTime'] ?? 0),
      totalHintsUsed: json['totalHintsUsed'] ?? 0,
      totalWrongAttempts: json['totalWrongAttempts'] ?? 0,
      threeStarLevels: threeStars,
      twoStarLevels: twoStars,
      oneStarLevels: oneStars,
      fastestSolve: json['fastestSolve'] != null
          ? Duration(seconds: json['fastestSolve'])
          : null,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'])
          : null,
      levelStats: levelStats,
    );
  }
}

class LevelStats {
  final int timesPlayed;
  final int timesCompleted;
  final Duration? bestTime;
  final int bestStars;
  final int bestScore;
  final int fewestHints;
  final DateTime? lastPlayed;

  LevelStats({
    this.timesPlayed = 0,
    this.timesCompleted = 0,
    this.bestTime,
    this.bestStars = 0,
    this.bestScore = 0,
    this.fewestHints = 999,
    this.lastPlayed,
  });

  Map<String, dynamic> toJson() => {
    'timesPlayed': timesPlayed,
    'timesCompleted': timesCompleted,
    'bestTime': bestTime?.inSeconds,
    'bestStars': bestStars,
    'bestScore': bestScore,
    'fewestHints': fewestHints,
    'lastPlayed': lastPlayed?.toIso8601String(),
  };

  factory LevelStats.fromJson(Map<String, dynamic> json) {
    return LevelStats(
      timesPlayed: json['timesPlayed'] ?? 0,
      timesCompleted: json['timesCompleted'] ?? 0,
      bestTime: json['bestTime'] != null
          ? Duration(seconds: json['bestTime'])
          : null,
      bestStars: json['bestStars'] ?? 0,
      bestScore: json['bestScore'] ?? 0,
      fewestHints: json['fewestHints'] ?? 999,
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'])
          : null,
    );
  }
}

class StatisticsRepository {
  static const String _key = 'game_statistics';

  Future<Statistics> getStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return Statistics();
    }

    try {
      final json = jsonDecode(jsonString);
      return Statistics.fromJson(json);
    } catch (e) {
      return Statistics();
    }
  }

  Future<void> saveStatistics(Statistics stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(stats.toJson()));
  }

  Future<void> recordGameComplete({
    required int levelId,
    required Duration time,
    required int stars,
    required int hintsUsed,
    required int wrongAttempts,
    int? score,
  }) async {
    final stats = await getStatistics();
    final now = DateTime.now();

    // Update streak
    int newStreak = stats.currentStreak;
    if (stats.lastPlayedDate != null) {
      final daysSinceLastPlay = now.difference(stats.lastPlayedDate!).inDays;
      if (daysSinceLastPlay == 0) {
        // Same day, keep streak
        newStreak = stats.currentStreak;
      } else if (daysSinceLastPlay == 1) {
        // Next day, increment streak
        newStreak = stats.currentStreak + 1;
      } else {
        // Streak broken, reset
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    // Update level-specific stats
    final currentLevelStats = stats.levelStats[levelId] ?? LevelStats();
    final updatedLevelStats = LevelStats(
      timesPlayed: currentLevelStats.timesPlayed + 1,
      timesCompleted: currentLevelStats.timesCompleted + 1,
      bestTime:
          currentLevelStats.bestTime == null ||
              time < currentLevelStats.bestTime!
          ? time
          : currentLevelStats.bestTime,
      bestStars: stars > currentLevelStats.bestStars
          ? stars
          : currentLevelStats.bestStars,
      bestScore: score != null && score > currentLevelStats.bestScore
          ? score
          : currentLevelStats.bestScore,
      fewestHints: hintsUsed < currentLevelStats.fewestHints
          ? hintsUsed
          : currentLevelStats.fewestHints,
      lastPlayed: now,
    );

    // Calculate new star counts
    int newThreeStarLevels = stats.threeStarLevels;
    int newTwoStarLevels = stats.twoStarLevels;
    int newOneStarLevels = stats.oneStarLevels;

    if (currentLevelStats.timesCompleted == 0) {
      // First time completion
      if (stars == 3) {
        newThreeStarLevels++;
      } else if (stars == 2) {
        newTwoStarLevels++;
      } else if (stars == 1) {
        newOneStarLevels++;
      }
    } else if (stars > currentLevelStats.bestStars) {
      // Improved score on replayed level
      // Increment new tier
      if (stars == 3) {
        newThreeStarLevels++;
      } else if (stars == 2) {
        newTwoStarLevels++;
      } else if (stars == 1) {
        newOneStarLevels++;
      }

      // Decrement old tier
      if (currentLevelStats.bestStars == 3) {
        newThreeStarLevels--;
      } else if (currentLevelStats.bestStars == 2) {
        newTwoStarLevels--;
      } else if (currentLevelStats.bestStars == 1) {
        newOneStarLevels--;
      }
    }

    // Update global stats
    final updatedStats = Statistics(
      totalGamesPlayed: stats.totalGamesPlayed + 1,
      totalGamesWon: stats.totalGamesWon + 1,
      totalPlayTime: stats.totalPlayTime + time,
      totalHintsUsed: stats.totalHintsUsed + hintsUsed,
      totalWrongAttempts: stats.totalWrongAttempts + wrongAttempts,
      threeStarLevels: newThreeStarLevels,
      twoStarLevels: newTwoStarLevels,
      oneStarLevels: newOneStarLevels,
      fastestSolve: stats.fastestSolve == null || time < stats.fastestSolve!
          ? time
          : stats.fastestSolve,
      currentStreak: newStreak,
      longestStreak: newStreak > stats.longestStreak
          ? newStreak
          : stats.longestStreak,
      lastPlayedDate: now,
      levelStats: {...stats.levelStats, levelId: updatedLevelStats},
    );

    await saveStatistics(updatedStats);
  }

  Future<void> recordLevelAttempt(int levelId) async {
    final stats = await getStatistics();
    final currentLevelStats = stats.levelStats[levelId] ?? LevelStats();

    final updatedLevelStats = LevelStats(
      timesPlayed: currentLevelStats.timesPlayed + 1,
      timesCompleted: currentLevelStats.timesCompleted,
      bestTime: currentLevelStats.bestTime,
      bestStars: currentLevelStats.bestStars,
      fewestHints: currentLevelStats.fewestHints,
      lastPlayed: DateTime.now(),
    );

    final updatedStats = Statistics(
      totalGamesPlayed: stats.totalGamesPlayed + 1,
      totalGamesWon: stats.totalGamesWon,
      totalPlayTime: stats.totalPlayTime,
      totalHintsUsed: stats.totalHintsUsed,
      totalWrongAttempts: stats.totalWrongAttempts,
      threeStarLevels: stats.threeStarLevels,
      twoStarLevels: stats.twoStarLevels,
      oneStarLevels: stats.oneStarLevels,
      fastestSolve: stats.fastestSolve,
      currentStreak: stats.currentStreak,
      longestStreak: stats.longestStreak,
      lastPlayedDate: stats.lastPlayedDate,
      levelStats: {...stats.levelStats, levelId: updatedLevelStats},
    );

    await saveStatistics(updatedStats);
  }
}
