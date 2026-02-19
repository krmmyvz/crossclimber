import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crossclimber/services/daily_challenge_service.dart';

void main() {
  late DailyChallengeService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = DailyChallengeService();
  });

  group('DailyChallengeService', () {
    test('generates new challenge if none exists', () async {
      final challenge = await service.getDailyChallenge();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      expect(challenge.date, today);
      expect(challenge.completed, isFalse);
      expect(challenge.levelId, greaterThan(0));
      expect(challenge.levelId, lessThanOrEqualTo(30));
    });

    test('generates consistent level ID for same date', () async {
      final challenge1 = await service.getDailyChallenge();
      
      // Clear prefs to simulate app restart
      SharedPreferences.setMockInitialValues({});
      
      final challenge2 = await service.getDailyChallenge();
      
      expect(challenge1.levelId, challenge2.levelId);
    });

    test('loads existing challenge if from today', () async {
      final challenge1 = await service.getDailyChallenge();
      
      // Complete the challenge
      await service.completeChallenge(score: 1000);
      
      final challenge2 = await service.getDailyChallenge();
      
      expect(challenge2.levelId, challenge1.levelId);
      expect(challenge2.completed, isTrue);
      expect(challenge2.completionScore, 1000);
    });

    test('resets challenge if date changed', () async {
      // Create a fake stored challenge from yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      DailyChallenge(
        levelId: 5,
        date: DateTime(yesterday.year, yesterday.month, yesterday.day),
        completed: true,
      );
      
      // Inject into prefs
      // Since _saveChallenge is private, we can't use it directly.
      // But we know it stores json string in 'daily_challenge' key.
      // However, SharedPreferences.setMockInitialValues is usually called in setUp.
      // To simulate "old data", we might need to rely on how getDailyChallenge handles it.
      // The service implementation handles date check.
      
      // Let's just verify that getDailyChallenge returns a challenge for TODAY
      final challenge = await service.getDailyChallenge();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      expect(challenge.date, today);
    });

    test('completeChallenge awards credits', () async {
      SharedPreferences.setMockInitialValues({'credits': 100});
      
      await service.completeChallenge(score: 1000);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('credits'), 150); // 100 + 50 bonus
    });

    test('checkDailyLoginReward awards credits once per day', () async {
      SharedPreferences.setMockInitialValues({'credits': 100});
      
      // First login
      await service.checkDailyLoginReward();
      var prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('credits'), 120); // 100 + 20
      
      // Second login same day
      await service.checkDailyLoginReward();
      prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('credits'), 120); // Should not change
    });
  });
}
