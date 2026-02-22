import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

// ─── Rarity ──────────────────────────────────────────────────────────────────

enum AchievementRarity { common, rare, legendary }

// ─── Types ───────────────────────────────────────────────────────────────────

enum AchievementType {
  // ── Original 15 ──────────────────────────────────────────────────────────
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
  // ── New 15 ────────────────────────────────────────────────────────────────
  streak7Days,
  streak14Days,
  streak30Days,
  streak60Days,
  streak100Days,
  combo5x,
  combo8x,
  combo10x,
  speed60s,
  speed45s,
  allLevels,
  legendaryRank,
  shareResults,
  dailyChallengeFirst,
  dailyChallenge30,
}

// ─── Achievement model ───────────────────────────────────────────────────────

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
    final typeIndex = json['type'] as int;
    // Guard against old save data having fewer enum values
    final type = typeIndex < AchievementType.values.length
        ? AchievementType.values[typeIndex]
        : AchievementType.firstWin;
    return Achievement(
      type: type,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      progress: json['progress'] as int? ?? 0,
      target: json['target'] as int,
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

// ─── Service ─────────────────────────────────────────────────────────────────

class AchievementService {
  static const String _key = 'achievements';
  static const String _selectedBadgeKey = 'selected_badge_type';
  static const String _dailyChallengesCompletedKey = 'daily_challenges_completed_total';
  static const String _shareCountKey = 'achievement_share_count';

  // ── Default definitions ──────────────────────────────────────────────────

  final List<Achievement> _defaultAchievements = [
    // ── Original 15 ────────────────────────────────────────────────────────
    Achievement(type: AchievementType.firstWin,         name: 'First Victory',              description: 'Complete your first level',                icon: '🎉', target: 1),
    Achievement(type: AchievementType.tenLevels,        name: 'Climbing Up',                description: 'Complete 10 levels',                       icon: '🏆', target: 10),
    Achievement(type: AchievementType.thirtyLevels,     name: 'Word Master',                description: 'Complete 30 levels',                       icon: '⭐', target: 30),
    Achievement(type: AchievementType.fiftyLevels,      name: 'Halfway There',              description: 'Complete 50 levels',                       icon: '💪', target: 50),
    Achievement(type: AchievementType.hundredLevels,    name: 'Century Club',               description: 'Complete 100 levels',                      icon: '👑', target: 100),
    Achievement(type: AchievementType.perfectStreak5,   name: 'Perfect Five',               description: 'Get 3 stars on 5 consecutive levels',      icon: '🌟', target: 5),
    Achievement(type: AchievementType.perfectStreak10,  name: 'Perfect Ten',                description: 'Get 3 stars on 10 consecutive levels',     icon: '✨', target: 10),
    Achievement(type: AchievementType.speedDemon,       name: 'Speed Demon',                description: 'Complete a level in under 30 seconds',     icon: '⚡', target: 1),
    Achievement(type: AchievementType.noHintsMaster,    name: 'No Hints Master',            description: 'Complete 50 levels without using hints',   icon: '🧠', target: 50),
    Achievement(type: AchievementType.threeStarPerfectionist, name: 'Three Star Perfectionist', description: 'Get 3 stars on 20 levels',            icon: '⭐⭐⭐', target: 20),
    Achievement(type: AchievementType.earlyBird,        name: 'Early Bird',                 description: 'Complete a level before 9 AM',             icon: '🌅', target: 1),
    Achievement(type: AchievementType.nightOwl,         name: 'Night Owl',                  description: 'Complete a level after 11 PM',             icon: '🦉', target: 1),
    Achievement(type: AchievementType.marathonRunner,   name: 'Marathon Runner',            description: 'Play 10 levels in a single session',       icon: '🏃', target: 600),
    Achievement(type: AchievementType.hintlessHero,     name: 'Hintless Hero',              description: 'Complete 10 levels without using hints',   icon: '🦸', target: 10),
    Achievement(type: AchievementType.errorFree,        name: 'Error Free',                 description: 'Complete a level without any wrong attempts', icon: '✅', target: 1),
    // ── New: Streak ─────────────────────────────────────────────────────────
    Achievement(type: AchievementType.streak7Days,      name: 'Week Warrior',               description: 'Maintain a 7-day daily streak',            icon: '🔥', target: 7),
    Achievement(type: AchievementType.streak14Days,     name: 'Fortnight Fighter',          description: 'Maintain a 14-day daily streak',           icon: '🔥🔥', target: 14),
    Achievement(type: AchievementType.streak30Days,     name: 'Monthly Master',             description: 'Maintain a 30-day daily streak',           icon: '🌙', target: 30),
    Achievement(type: AchievementType.streak60Days,     name: 'Blazing Trail',              description: 'Maintain a 60-day daily streak',           icon: '💫', target: 60),
    Achievement(type: AchievementType.streak100Days,    name: 'Century Streak',             description: 'Maintain a 100-day daily streak',          icon: '🏅', target: 100),
    // ── New: Combo ──────────────────────────────────────────────────────────
    Achievement(type: AchievementType.combo5x,          name: 'Combo Starter',              description: 'Build a 5x combo in one game',             icon: '🎯', target: 5),
    Achievement(type: AchievementType.combo8x,          name: 'Combo Artist',               description: 'Build an 8x combo in one game',            icon: '🎨', target: 8),
    Achievement(type: AchievementType.combo10x,         name: 'Combo Legend',               description: 'Build a 10x combo in one game',            icon: '💥', target: 10),
    // ── New: Speed ──────────────────────────────────────────────────────────
    Achievement(type: AchievementType.speed60s,         name: 'Quick Thinker',              description: 'Complete a level in under 60 seconds',     icon: '🚀', target: 1),
    Achievement(type: AchievementType.speed45s,         name: 'Lightning Fast',             description: 'Complete a level in under 45 seconds',     icon: '⚡⚡', target: 1),
    // ── New: Collector ──────────────────────────────────────────────────────
    Achievement(type: AchievementType.allLevels,        name: 'Level Conqueror',            description: 'Complete all 60 levels',                   icon: '🏔️', target: 60),
    Achievement(type: AchievementType.legendaryRank,    name: 'The Legend',                 description: 'Reach the Legendary rank',                  icon: '⭐🔥', target: 50000),
    // ── New: Social ─────────────────────────────────────────────────────────
    Achievement(type: AchievementType.shareResults,     name: 'Sharing is Caring',          description: 'Share 10 results',                         icon: '📤', target: 10),
    Achievement(type: AchievementType.dailyChallengeFirst, name: 'Challenge Accepted',      description: 'Complete your first daily challenge',       icon: '📅', target: 1),
    Achievement(type: AchievementType.dailyChallenge30, name: 'Daily Devotee',              description: 'Complete 30 daily challenges',              icon: '🗓️', target: 30),
  ];

  // ── Load / save ──────────────────────────────────────────────────────────

  Future<List<Achievement>> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      await _saveAchievements(_defaultAchievements);
      return List.from(_defaultAchievements);
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      final saved = jsonList.map((j) => Achievement.fromJson(j as Map<String, dynamic>)).toList();

      // Merge: ensure new achievement types are always present
      final savedTypes = saved.map((a) => a.type).toSet();
      final merged = List<Achievement>.from(saved);
      for (final def in _defaultAchievements) {
        if (!savedTypes.contains(def.type)) {
          merged.add(def);
        }
      }
      return merged;
    } catch (_) {
      return List.from(_defaultAchievements);
    }
  }

  Future<void> _saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(achievements.map((a) => a.toJson()).toList()),
    );
  }

  // ── Badge ────────────────────────────────────────────────────────────────

  Future<int?> getSelectedBadgeTypeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_selectedBadgeKey);
    return v;
  }

  Future<void> setSelectedBadgeTypeIndex(int? index) async {
    final prefs = await SharedPreferences.getInstance();
    if (index == null) {
      await prefs.remove(_selectedBadgeKey);
    } else {
      await prefs.setInt(_selectedBadgeKey, index);
    }
  }

  // ── Share counter ────────────────────────────────────────────────────────

  Future<int> getShareCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_shareCountKey) ?? 0;
  }

  Future<int> incrementShareCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_shareCountKey) ?? 0) + 1;
    await prefs.setInt(_shareCountKey, count);
    return count;
  }

  // ── Daily challenge counter ──────────────────────────────────────────────

  Future<int> getDailyChallengesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyChallengesCompletedKey) ?? 0;
  }

  Future<int> incrementDailyChallengesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_dailyChallengesCompletedKey) ?? 0) + 1;
    await prefs.setInt(_dailyChallengesCompletedKey, count);
    return count;
  }

  // ── Check & unlock ───────────────────────────────────────────────────────

  /// Returns the list of achievements newly unlocked during this call.
  Future<List<Achievement>> checkAndUnlockAchievements({
    int? levelsCompleted,
    int? threeStarCount,
    int? perfectStreak,
    Duration? completionTime,
    int? hintsUsed,
    int? wrongAttempts,
    Duration? totalPlayTime,
    int? maxComboThisGame,
    int? longestStreak,
    int? dailyChallengesCompleted,
    int? totalXp,
  }) async {
    final achievements = await getAchievements();
    final List<Achievement> newlyUnlocked = [];
    bool updated = false;

    for (int i = 0; i < achievements.length; i++) {
      final achievement = achievements[i];
      if (achievement.unlocked) continue;

      Achievement? upd;

      switch (achievement.type) {
        // ── Original 15 ──────────────────────────────────────────────────
        case AchievementType.firstWin:
          if (levelsCompleted != null && levelsCompleted >= 1) {
            upd = achievement.copyWith(progress: 1, unlocked: true, unlockedAt: DateTime.now());
          }

        case AchievementType.tenLevels:
        case AchievementType.thirtyLevels:
        case AchievementType.fiftyLevels:
        case AchievementType.hundredLevels:
          if (levelsCompleted != null) {
            upd = achievement.copyWith(
              progress: levelsCompleted,
              unlocked: levelsCompleted >= achievement.target,
              unlockedAt: levelsCompleted >= achievement.target ? DateTime.now() : null,
            );
          }

        case AchievementType.perfectStreak5:
        case AchievementType.perfectStreak10:
          if (perfectStreak != null) {
            upd = achievement.copyWith(
              progress: perfectStreak,
              unlocked: perfectStreak >= achievement.target,
              unlockedAt: perfectStreak >= achievement.target ? DateTime.now() : null,
            );
          }

        case AchievementType.speedDemon:
          if (completionTime != null && completionTime.inSeconds < 30) {
            upd = achievement.copyWith(progress: 1, unlocked: true, unlockedAt: DateTime.now());
          }

        case AchievementType.noHintsMaster:
        case AchievementType.hintlessHero:
          if (hintsUsed == 0 && levelsCompleted != null) {
            final np = achievement.progress + 1;
            upd = achievement.copyWith(
              progress: np,
              unlocked: np >= achievement.target,
              unlockedAt: np >= achievement.target ? DateTime.now() : null,
            );
          }

        case AchievementType.threeStarPerfectionist:
          if (threeStarCount != null) {
            upd = achievement.copyWith(
              progress: threeStarCount,
              unlocked: threeStarCount >= achievement.target,
              unlockedAt: threeStarCount >= achievement.target ? DateTime.now() : null,
            );
          }

        case AchievementType.earlyBird:
          if (DateTime.now().hour < 9 && levelsCompleted != null) {
            upd = achievement.copyWith(progress: 1, unlocked: true, unlockedAt: DateTime.now());
          }

        case AchievementType.nightOwl:
          if (DateTime.now().hour >= 23 && levelsCompleted != null) {
            upd = achievement.copyWith(progress: 1, unlocked: true, unlockedAt: DateTime.now());
          }

        case AchievementType.marathonRunner:
          if (totalPlayTime != null) {
            final min = totalPlayTime.inMinutes;
            upd = achievement.copyWith(
              progress: min,
              unlocked: min >= achievement.target,
              unlockedAt: min >= achievement.target ? DateTime.now() : null,
            );
          }

        case AchievementType.errorFree:
          if (wrongAttempts == 0 && levelsCompleted != null) {
            upd = achievement.copyWith(progress: 1, unlocked: true, unlockedAt: DateTime.now());
          }

        // ── New: Streak ──────────────────────────────────────────────────
        case AchievementType.streak7Days:
        case AchievementType.streak14Days:
        case AchievementType.streak30Days:
        case AchievementType.streak60Days:
        case AchievementType.streak100Days:
          if (longestStreak != null) {
            upd = achievement.copyWith(
              progress: longestStreak,
              unlocked: longestStreak >= achievement.target,
              unlockedAt: longestStreak >= achievement.target ? DateTime.now() : null,
            );
          }

        // ── New: Combo ───────────────────────────────────────────────────
        case AchievementType.combo5x:
        case AchievementType.combo8x:
        case AchievementType.combo10x:
          if (maxComboThisGame != null) {
            final best = achievement.progress < maxComboThisGame
                ? maxComboThisGame
                : achievement.progress;
            upd = achievement.copyWith(
              progress: best,
              unlocked: best >= achievement.target,
              unlockedAt: best >= achievement.target ? DateTime.now() : null,
            );
          }

        // ── New: Speed ───────────────────────────────────────────────────
        case AchievementType.speed60s:
          if (completionTime != null && completionTime.inSeconds < 60) {
            upd = achievement.copyWith(progress: 1, unlocked: true, unlockedAt: DateTime.now());
          }

        case AchievementType.speed45s:
          if (completionTime != null && completionTime.inSeconds < 45) {
            upd = achievement.copyWith(progress: 1, unlocked: true, unlockedAt: DateTime.now());
          }

        // ── New: Collector ───────────────────────────────────────────────
        case AchievementType.allLevels:
          if (levelsCompleted != null) {
            upd = achievement.copyWith(
              progress: levelsCompleted,
              unlocked: levelsCompleted >= achievement.target,
              unlockedAt: levelsCompleted >= achievement.target ? DateTime.now() : null,
            );
          }

        case AchievementType.legendaryRank:
          if (totalXp != null) {
            upd = achievement.copyWith(
              progress: totalXp,
              unlocked: totalXp >= achievement.target,
              unlockedAt: totalXp >= achievement.target ? DateTime.now() : null,
            );
          }

        // ── New: Social ──────────────────────────────────────────────────
        case AchievementType.shareResults:
          final shareCount = await getShareCount();
          if (shareCount >= achievement.target) {
            upd = achievement.copyWith(
              progress: shareCount,
              unlocked: true,
              unlockedAt: DateTime.now(),
            );
          } else if (shareCount > achievement.progress) {
            upd = achievement.copyWith(progress: shareCount);
          }

        case AchievementType.dailyChallengeFirst:
        case AchievementType.dailyChallenge30:
          if (dailyChallengesCompleted != null) {
            upd = achievement.copyWith(
              progress: dailyChallengesCompleted,
              unlocked: dailyChallengesCompleted >= achievement.target,
              unlockedAt: dailyChallengesCompleted >= achievement.target
                  ? DateTime.now()
                  : null,
            );
          }
      }

      if (upd != null) {
        achievements[i] = upd;
        updated = true;
        if (upd.unlocked && !achievement.unlocked) {
          newlyUnlocked.add(upd);
        }
      }
    }

    if (updated) {
      await _saveAchievements(achievements);
    }

    return newlyUnlocked;
  }

  // ── Utilities ────────────────────────────────────────────────────────────

  Future<List<Achievement>> getUnlockedAchievements() async {
    final achievements = await getAchievements();
    return achievements.where((a) => a.unlocked).toList();
  }

  Future<List<Achievement>> getAllAchievements() async {
    return getAchievements();
  }

  Future<int> getUnlockedCount() async {
    final unlocked = await getUnlockedAchievements();
    return unlocked.length;
  }
}


