import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

enum AchievementType {
  firstWin,
  tenLevels,
  thirtyLevels,
  fiftyLevels,
  hundredLevels,
  perfectStreak5,
  perfectStreak10,
  speedDemon,
  noHintsMaster,
  threeStarPerfectionist,
  earlyBird,
  nightOwl,
  marathonRunner,
  hintlessHero,
  errorFree,
}

class Achievement {
  final AchievementType type;
  final String name;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int target;

  Achievement({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    this.unlocked = false,
    this.unlockedAt,
    this.progress = 0,
    required this.target,
  });

  // Getter for UI compatibility
  bool get isUnlocked => unlocked;

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'name': name,
    'description': description,
    'icon': icon,
    'unlocked': unlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'progress': progress,
    'target': target,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      type: AchievementType.values[json['type']],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      unlocked: json['unlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      progress: json['progress'] ?? 0,
      target: json['target'],
    );
  }

  Achievement copyWith({bool? unlocked, DateTime? unlockedAt, int? progress}) {
    return Achievement(
      type: type,
      name: name,
      description: description,
      icon: icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target,
    );
  }

  double get progressPercentage => (progress / target * 100).clamp(0, 100);
}

class AchievementService {
  static const String _key = 'achievements';

  final List<Achievement> _defaultAchievements = [
    Achievement(
      type: AchievementType.firstWin,
      name: 'First Victory',
      description: 'Complete your first level',
      icon: '🎉',
      target: 1,
    ),
    Achievement(
      type: AchievementType.tenLevels,
      name: 'Climbing Up',
      description: 'Complete 10 levels',
      icon: '🏆',
      target: 10,
    ),
    Achievement(
      type: AchievementType.thirtyLevels,
      name: 'Word Master',
      description: 'Complete 30 levels',
      icon: '⭐',
      target: 30,
    ),
    Achievement(
      type: AchievementType.fiftyLevels,
      name: 'Halfway There',
      description: 'Complete 50 levels',
      icon: '💪',
      target: 50,
    ),
    Achievement(
      type: AchievementType.hundredLevels,
      name: 'Century Club',
      description: 'Complete 100 levels',
      icon: '👑',
      target: 100,
    ),
    Achievement(
      type: AchievementType.perfectStreak5,
      name: 'Perfect Five',
      description: 'Win 5 levels in a row with 3 stars',
      icon: '🌟',
      target: 5,
    ),
    Achievement(
      type: AchievementType.perfectStreak10,
      name: 'Perfect Ten',
      description: 'Win 10 levels in a row with 3 stars',
      icon: '✨',
      target: 10,
    ),
    Achievement(
      type: AchievementType.speedDemon,
      name: 'Speed Demon',
      description: 'Complete a level in under 30 seconds',
      icon: '⚡',
      target: 1,
    ),
    Achievement(
      type: AchievementType.noHintsMaster,
      name: 'No Hints Master',
      description: 'Complete 20 levels without using hints',
      icon: '🧠',
      target: 20,
    ),
    Achievement(
      type: AchievementType.threeStarPerfectionist,
      name: 'Three Star Perfectionist',
      description: 'Earn 3 stars on 50 levels',
      icon: '⭐⭐⭐',
      target: 50,
    ),
    Achievement(
      type: AchievementType.earlyBird,
      name: 'Early Bird',
      description: 'Complete a level before 6 AM',
      icon: '🌅',
      target: 1,
    ),
    Achievement(
      type: AchievementType.nightOwl,
      name: 'Night Owl',
      description: 'Complete a level after midnight',
      icon: '🦉',
      target: 1,
    ),
    Achievement(
      type: AchievementType.marathonRunner,
      name: 'Marathon Runner',
      description: 'Play for 10 hours total',
      icon: '🏃',
      target: 600, // 600 minutes
    ),
    Achievement(
      type: AchievementType.hintlessHero,
      name: 'Hintless Hero',
      description: 'Complete 5 levels without any hints',
      icon: '🦸',
      target: 5,
    ),
    Achievement(
      type: AchievementType.errorFree,
      name: 'Error Free',
      description: 'Complete 10 levels without any wrong attempts',
      icon: '✅',
      target: 10,
    ),
  ];

  Future<List<Achievement>> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      // Return default achievements
      await _saveAchievements(_defaultAchievements);
      return _defaultAchievements;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Achievement.fromJson(json)).toList();
    } catch (e) {
      return _defaultAchievements;
    }
  }

  Future<void> _saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = achievements.map((a) => a.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<void> checkAndUnlockAchievements({
    int? levelsCompleted,
    int? threeStarCount,
    int? perfectStreak,
    Duration? completionTime,
    int? hintsUsed,
    int? wrongAttempts,
    Duration? totalPlayTime,
  }) async {
    final achievements = await getAchievements();
    bool updated = false;

    for (int i = 0; i < achievements.length; i++) {
      final achievement = achievements[i];
      if (achievement.unlocked) continue;

      Achievement? updatedAchievement;

      switch (achievement.type) {
        case AchievementType.firstWin:
          if (levelsCompleted != null && levelsCompleted >= 1) {
            updatedAchievement = achievement.copyWith(
              progress: 1,
              unlocked: true,
              unlockedAt: DateTime.now(),
            );
          }
          break;

        case AchievementType.tenLevels:
        case AchievementType.thirtyLevels:
        case AchievementType.fiftyLevels:
        case AchievementType.hundredLevels:
          if (levelsCompleted != null) {
            updatedAchievement = achievement.copyWith(
              progress: levelsCompleted,
              unlocked: levelsCompleted >= achievement.target,
              unlockedAt: levelsCompleted >= achievement.target
                  ? DateTime.now()
                  : null,
            );
          }
          break;

        case AchievementType.perfectStreak5:
        case AchievementType.perfectStreak10:
          if (perfectStreak != null) {
            updatedAchievement = achievement.copyWith(
              progress: perfectStreak,
              unlocked: perfectStreak >= achievement.target,
              unlockedAt: perfectStreak >= achievement.target
                  ? DateTime.now()
                  : null,
            );
          }
          break;

        case AchievementType.speedDemon:
          if (completionTime != null && completionTime.inSeconds < 30) {
            updatedAchievement = achievement.copyWith(
              progress: 1,
              unlocked: true,
              unlockedAt: DateTime.now(),
            );
          }
          break;

        case AchievementType.noHintsMaster:
        case AchievementType.hintlessHero:
          if (hintsUsed == 0 && levelsCompleted != null) {
            final currentProgress = achievement.progress;
            final newProgress = currentProgress + 1;
            updatedAchievement = achievement.copyWith(
              progress: newProgress,
              unlocked: newProgress >= achievement.target,
              unlockedAt: newProgress >= achievement.target
                  ? DateTime.now()
                  : null,
            );
          }
          break;

        case AchievementType.threeStarPerfectionist:
          if (threeStarCount != null) {
            updatedAchievement = achievement.copyWith(
              progress: threeStarCount,
              unlocked: threeStarCount >= achievement.target,
              unlockedAt: threeStarCount >= achievement.target
                  ? DateTime.now()
                  : null,
            );
          }
          break;

        case AchievementType.earlyBird:
          final hour = DateTime.now().hour;
          if (hour < 6 && levelsCompleted != null) {
            updatedAchievement = achievement.copyWith(
              progress: 1,
              unlocked: true,
              unlockedAt: DateTime.now(),
            );
          }
          break;

        case AchievementType.nightOwl:
          final hour = DateTime.now().hour;
          if (hour >= 0 && hour < 6 && levelsCompleted != null) {
            updatedAchievement = achievement.copyWith(
              progress: 1,
              unlocked: true,
              unlockedAt: DateTime.now(),
            );
          }
          break;

        case AchievementType.marathonRunner:
          if (totalPlayTime != null) {
            final minutes = totalPlayTime.inMinutes;
            updatedAchievement = achievement.copyWith(
              progress: minutes,
              unlocked: minutes >= achievement.target,
              unlockedAt: minutes >= achievement.target ? DateTime.now() : null,
            );
          }
          break;

        case AchievementType.errorFree:
          if (wrongAttempts == 0 && levelsCompleted != null) {
            final currentProgress = achievement.progress;
            final newProgress = currentProgress + 1;
            updatedAchievement = achievement.copyWith(
              progress: newProgress,
              unlocked: newProgress >= achievement.target,
              unlockedAt: newProgress >= achievement.target
                  ? DateTime.now()
                  : null,
            );
          }
          break;
      }

      if (updatedAchievement != null) {
        achievements[i] = updatedAchievement;
        updated = true;
      }
    }

    if (updated) {
      await _saveAchievements(achievements);
    }
  }

  Future<List<Achievement>> getUnlockedAchievements() async {
    final achievements = await getAchievements();
    return achievements.where((a) => a.unlocked).toList();
  }

  Future<List<Achievement>> getAllAchievements() async {
    return await getAchievements();
  }

  Future<int> getUnlockedCount() async {
    final unlocked = await getUnlockedAchievements();
    return unlocked.length;
  }
}
