import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crossclimber/services/daily_reward_service.dart';

void main() {
  late DailyRewardService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = DailyRewardService();
  });

  group('DailyRewardService', () {
    test('canClaimToday returns true initially', () async {
      expect(await service.canClaimToday(), isTrue);
    });

    test('getStreakCount returns 0 initially', () async {
      expect(await service.getStreakCount(), 0);
    });

    test('claimDailyReward claims reward and updates streak', () async {
      final reward = await service.claimDailyReward();
      
      expect(reward.alreadyClaimed, isFalse);
      expect(reward.streakDay, 1);
      expect(reward.credits, 20); // Base credits
      expect(await service.getStreakCount(), 1);
      expect(await service.canClaimToday(), isFalse);
    });

    test('claimDailyReward increases streak if claimed next day', () async {
      // Simulate claim yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      SharedPreferences.setMockInitialValues({
        'lastDailyReward': yesterday.toIso8601String(),
        'dailyStreakCount': 1,
      });

      final reward = await service.claimDailyReward();
      
      expect(reward.streakDay, 2);
      expect(reward.credits, 25); // 20 + 5
      expect(await service.getStreakCount(), 2);
    });

    test('claimDailyReward resets streak if day missed', () async {
      // Simulate claim 2 days ago
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      SharedPreferences.setMockInitialValues({
        'lastDailyReward': twoDaysAgo.toIso8601String(),
        'dailyStreakCount': 5,
      });

      final reward = await service.claimDailyReward();
      
      expect(reward.streakDay, 1);
      expect(reward.credits, 20); // Reset to base
      expect(await service.getStreakCount(), 1);
    });

    test('gives special rewards on 3rd day', () async {
      // Simulate streak at 2
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      SharedPreferences.setMockInitialValues({
        'lastDailyReward': yesterday.toIso8601String(),
        'dailyStreakCount': 2,
      });

      final reward = await service.claimDailyReward();
      
      expect(reward.streakDay, 3);
      expect(reward.revealHints, 1);
    });

    test('gives special rewards on 7th day and resets streak', () async {
      // Simulate streak at 6
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      SharedPreferences.setMockInitialValues({
        'lastDailyReward': yesterday.toIso8601String(),
        'dailyStreakCount': 6,
      });

      final reward = await service.claimDailyReward();
      
      expect(reward.streakDay, 7);
      expect(reward.revealHints, 2);
      expect(reward.undoHints, 3);
      
      // Verify streak resets after 7
      expect(await service.getStreakCount(), 0);
    });

    test('claimDailyReward returns already claimed if claimed today', () async {
      await service.claimDailyReward();
      final reward = await service.claimDailyReward();
      
      expect(reward.alreadyClaimed, isTrue);
      expect(reward.credits, 0);
    });
  });
}
