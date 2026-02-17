import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crossclimber/services/achievement_service.dart';

void main() {
  late AchievementService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = AchievementService();
  });

  group('AchievementService', () {
    test('getAllAchievements returns default list initially', () async {
      final achievements = await service.getAllAchievements();
      expect(achievements, isNotEmpty);
      expect(achievements.any((a) => a.type == AchievementType.firstWin), isTrue);
      expect(achievements.every((a) => !a.isUnlocked), isTrue);
    });

    test('getUnlockedAchievements returns empty list initially', () async {
      final unlocked = await service.getUnlockedAchievements();
      expect(unlocked, isEmpty);
    });

    test('checkAndUnlockAchievements unlocks First Win', () async {
      await service.checkAndUnlockAchievements(levelsCompleted: 1);
      
      final unlocked = await service.getUnlockedAchievements();
      expect(unlocked.length, 1);
      expect(unlocked.first.type, AchievementType.firstWin);
      expect(unlocked.first.unlockedAt, isNotNull);
    });

    test('checkAndUnlockAchievements updates progress for cumulative achievements', () async {
      // First call with 5 levels
      await service.checkAndUnlockAchievements(levelsCompleted: 5);
      var achievements = await service.getAllAchievements();
      var tenLevels = achievements.firstWhere((a) => a.type == AchievementType.tenLevels);
      expect(tenLevels.progress, 5);
      expect(tenLevels.isUnlocked, isFalse);

      // Second call with 10 levels
      await service.checkAndUnlockAchievements(levelsCompleted: 10);
      achievements = await service.getAllAchievements();
      tenLevels = achievements.firstWhere((a) => a.type == AchievementType.tenLevels);
      expect(tenLevels.progress, 10);
      expect(tenLevels.isUnlocked, isTrue);
    });

    test('checkAndUnlockAchievements unlocks Speed Demon', () async {
      await service.checkAndUnlockAchievements(
        completionTime: const Duration(seconds: 25),
      );
      
      final unlocked = await service.getUnlockedAchievements();
      expect(unlocked.any((a) => a.type == AchievementType.speedDemon), isTrue);
    });

    test('checkAndUnlockAchievements increments Hintless Hero', () async {
      // Assuming hintlessHero requires 5 levels.
      // We need to call it 5 times (simulating 5 separate level completions)
      // Note: The current implementation of checkAndUnlockAchievements for hintlessHero increments progress by 1 
      // each time it's called with hintsUsed == 0 and levelsCompleted != null.
      
      for (int i = 0; i < 5; i++) {
        await service.checkAndUnlockAchievements(
          hintsUsed: 0,
          levelsCompleted: 100 + i, // Just needs to be non-null
        );
      }

      final achievements = await service.getAllAchievements();
      final hero = achievements.firstWhere((a) => a.type == AchievementType.hintlessHero);
      expect(hero.isUnlocked, isTrue);
    });

    test('getUnlockedCount returns correct count', () async {
      expect(await service.getUnlockedCount(), 0);
      
      await service.checkAndUnlockAchievements(levelsCompleted: 1);
      expect(await service.getUnlockedCount(), 1);
    });
  });
}
