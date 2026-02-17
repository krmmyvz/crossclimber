import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crossclimber/services/statistics_repository.dart';

void main() {
  late StatisticsRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = StatisticsRepository();
  });

  group('StatisticsRepository', () {
    test('getStatistics returns default statistics initially', () async {
      final stats = await repository.getStatistics();
      expect(stats.totalGamesPlayed, 0);
      expect(stats.totalGamesWon, 0);
      expect(stats.currentStreak, 0);
    });

    test('recordGameComplete updates global statistics', () async {
      await repository.recordGameComplete(
        levelId: 1,
        time: const Duration(seconds: 30),
        stars: 3,
        hintsUsed: 1,
        wrongAttempts: 2,
        score: 100,
      );

      final stats = await repository.getStatistics();
      expect(stats.totalGamesPlayed, 1);
      expect(stats.totalGamesWon, 1);
      expect(stats.totalPlayTime.inSeconds, 30);
      expect(stats.totalHintsUsed, 1);
      expect(stats.totalWrongAttempts, 2);
      expect(stats.threeStarLevels, 1);
      expect(stats.fastestSolve?.inSeconds, 30);
      expect(stats.currentStreak, 1);
    });

    test('recordGameComplete updates level-specific statistics', () async {
      await repository.recordGameComplete(
        levelId: 1,
        time: const Duration(seconds: 30),
        stars: 3,
        hintsUsed: 1,
        wrongAttempts: 0,
        score: 100,
      );

      final stats = await repository.getStatistics();
      final levelStats = stats.levelStats[1];
      expect(levelStats, isNotNull);
      expect(levelStats!.timesPlayed, 1);
      expect(levelStats.timesCompleted, 1);
      expect(levelStats.bestTime?.inSeconds, 30);
      expect(levelStats.bestStars, 3);
      expect(levelStats.bestScore, 100);
    });

    test('streak increments correctly for consecutive days', () async {
      // Simulate play yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final initialStats = Statistics(
        currentStreak: 1,
        longestStreak: 1,
        lastPlayedDate: yesterday,
      );
      await repository.saveStatistics(initialStats);

      // Play today
      await repository.recordGameComplete(
        levelId: 2,
        time: const Duration(seconds: 60),
        stars: 2,
        hintsUsed: 0,
        wrongAttempts: 0,
      );

      final stats = await repository.getStatistics();
      expect(stats.currentStreak, 2);
      expect(stats.longestStreak, 2);
    });

    test('streak resets if day skipped', () async {
      // Simulate play 2 days ago
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final initialStats = Statistics(
        currentStreak: 5,
        longestStreak: 5,
        lastPlayedDate: twoDaysAgo,
      );
      await repository.saveStatistics(initialStats);

      // Play today
      await repository.recordGameComplete(
        levelId: 1,
        time: const Duration(seconds: 60),
        stars: 1,
        hintsUsed: 0,
        wrongAttempts: 0,
      );

      final stats = await repository.getStatistics();
      expect(stats.currentStreak, 1);
      expect(stats.longestStreak, 5); // Longest streak preserved
    });

    test('updates best time if faster', () async {
      // Initial record
      await repository.recordGameComplete(
        levelId: 1,
        time: const Duration(seconds: 60),
        stars: 1,
        hintsUsed: 0,
        wrongAttempts: 0,
      );

      // Faster run
      await repository.recordGameComplete(
        levelId: 1,
        time: const Duration(seconds: 30),
        stars: 1,
        hintsUsed: 0,
        wrongAttempts: 0,
      );

      final stats = await repository.getStatistics();
      expect(stats.fastestSolve?.inSeconds, 30);
      expect(stats.levelStats[1]?.bestTime?.inSeconds, 30);
    });

    test('does not update best time if slower', () async {
      // Initial record
      await repository.recordGameComplete(
        levelId: 1,
        time: const Duration(seconds: 30),
        stars: 1,
        hintsUsed: 0,
        wrongAttempts: 0,
      );

      // Slower run
      await repository.recordGameComplete(
        levelId: 1,
        time: const Duration(seconds: 60),
        stars: 1,
        hintsUsed: 0,
        wrongAttempts: 0,
      );

      final stats = await repository.getStatistics();
      expect(stats.fastestSolve?.inSeconds, 30);
      expect(stats.levelStats[1]?.bestTime?.inSeconds, 30);
    });
  });
}
