import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crossclimber/services/daily_reward_service.dart';
import 'package:crossclimber/services/progress_repository.dart';

void main() {
  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Creates a service with a fresh in-memory SharedPreferences.
  DailyRewardService makeService() => DailyRewardService(ProgressRepository());

  String todayIso() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).toIso8601String();
  }

  String daysAgoIso(int days) {
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days));
    return d.toIso8601String();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ── kDayRewards ───────────────────────────────────────────────────────────

  group('kDayRewards', () {
    test('has exactly 7 entries', () {
      expect(kDayRewards.length, 7);
    });

    test('day numbers are 1–7 in order', () {
      for (var i = 0; i < 7; i++) {
        expect(kDayRewards[i].day, i + 1);
      }
    });

    test('day 1 gives 50 credits', () {
      expect(kDayRewards[0].credits, 50);
    });

    test('day 2 gives 1 revealHint', () {
      expect(kDayRewards[1].revealHints, 1);
      expect(kDayRewards[1].credits, 0);
    });

    test('day 3 gives 100 credits', () {
      expect(kDayRewards[2].credits, 100);
    });

    test('day 4 gives 1 undoHint', () {
      expect(kDayRewards[3].undoHints, 1);
      expect(kDayRewards[3].credits, 0);
    });

    test('day 5 gives 150 credits', () {
      expect(kDayRewards[4].credits, 150);
    });

    test('day 6 gives 1 reveal + 1 undo hint', () {
      expect(kDayRewards[5].revealHints, 1);
      expect(kDayRewards[5].undoHints, 1);
    });

    test('day 7 gives 300 credits + specialTheme', () {
      expect(kDayRewards[6].credits, 300);
      expect(kDayRewards[6].specialTheme, isTrue);
    });
  });

  // ── getCalendarState ──────────────────────────────────────────────────────

  group('getCalendarState', () {
    test('returns day 1 and canClaimNow when never claimed', () async {
      final svc = makeService();
      final state = await svc.getCalendarState();

      expect(state.todaysCycleDay, 1);
      expect(state.claimedToday, isFalse);
      expect(state.canClaimNow, isTrue);
      expect(state.streakWasReset, isFalse);
    });

    test('returns claimedToday=true and countdown when claimed today', () async {
      SharedPreferences.setMockInitialValues({
        'dr_last_claim_date': todayIso(),
        'dr_last_claimed_day': 3,
      });
      final svc = makeService();
      final state = await svc.getCalendarState();

      expect(state.claimedToday, isTrue);
      expect(state.canClaimNow, isFalse);
      expect(state.todaysCycleDay, 3);
      expect(state.timeUntilNext, isNotNull);
    });

    test('advances cycle day by 1 after consecutive day', () async {
      SharedPreferences.setMockInitialValues({
        'dr_last_claim_date': daysAgoIso(1),
        'dr_last_claimed_day': 4,
      });
      final svc = makeService();
      final state = await svc.getCalendarState();

      expect(state.todaysCycleDay, 5);
      expect(state.claimedToday, isFalse);
      expect(state.streakWasReset, isFalse);
    });

    test('wraps cycle day from 7 back to 1 on consecutive day', () async {
      SharedPreferences.setMockInitialValues({
        'dr_last_claim_date': daysAgoIso(1),
        'dr_last_claimed_day': 7,
      });
      final svc = makeService();
      final state = await svc.getCalendarState();

      expect(state.todaysCycleDay, 1);
      expect(state.claimedToday, isFalse);
    });

    test('resets to day 1 and sets streakWasReset when a day is missed', () async {
      SharedPreferences.setMockInitialValues({
        'dr_last_claim_date': daysAgoIso(2),
        'dr_last_claimed_day': 5,
      });
      final svc = makeService();
      final state = await svc.getCalendarState();

      expect(state.todaysCycleDay, 1);
      expect(state.claimedToday, isFalse);
      expect(state.streakWasReset, isTrue);
    });

    test('does not set streakWasReset if streak was already at day 1 when missed', () async {
      SharedPreferences.setMockInitialValues({
        'dr_last_claim_date': daysAgoIso(2),
        'dr_last_claimed_day': 1,
      });
      final svc = makeService();
      final state = await svc.getCalendarState();

      expect(state.todaysCycleDay, 1);
      expect(state.streakWasReset, isFalse);
    });
  });

  // ── claimDailyReward ──────────────────────────────────────────────────────

  group('claimDailyReward', () {
    test('claims day 1 — returns 50 credits, persists state', () async {
      final svc = makeService();
      final reward = await svc.claimDailyReward();

      expect(reward.alreadyClaimed, isFalse);
      expect(reward.streakDay, 1);
      expect(reward.credits, 50);
      expect(reward.revealHints, 0);
      expect(reward.undoHints, 0);
      expect(reward.specialTheme, isFalse);

      // Should be unable to claim again today
      expect(await svc.canClaimToday(), isFalse);
    });

    test('double claim on same day returns alreadyClaimed', () async {
      final svc = makeService();
      await svc.claimDailyReward();
      final second = await svc.claimDailyReward();

      expect(second.alreadyClaimed, isTrue);
      expect(second.credits, 0);
    });

    test('claims day 2 — returns 1 reveal hint', () async {
      SharedPreferences.setMockInitialValues({
        'dr_last_claim_date': daysAgoIso(1),
        'dr_last_claimed_day': 1,
      });
      final svc = makeService();
      final reward = await svc.claimDailyReward();

      expect(reward.streakDay, 2);
      expect(reward.revealHints, 1);
      expect(reward.credits, 0);
    });

    test('claims day 6 — returns 1 reveal + 1 undo', () async {
      SharedPreferences.setMockInitialValues({
        'dr_last_claim_date': daysAgoIso(1),
        'dr_last_claimed_day': 5,
      });
      final svc = makeService();
      final reward = await svc.claimDailyReward();

      expect(reward.streakDay, 6);
      expect(reward.revealHints, 1);
      expect(reward.undoHints, 1);
    });

    test('claims day 7 — returns 300 credits + specialTheme', () async {
      SharedPreferences.setMockInitialValues({
        'dr_last_claim_date': daysAgoIso(1),
        'dr_last_claimed_day': 6,
      });
      final svc = makeService();
      final reward = await svc.claimDailyReward();

      expect(reward.streakDay, 7);
      expect(reward.credits, 300);
      expect(reward.specialTheme, isTrue);
    });

    test('after claiming day 7, next day starts cycle at day 1', () async {
      SharedPreferences.setMockInitialValues({
        'dr_last_claim_date': daysAgoIso(1),
        'dr_last_claimed_day': 6,
      });
      final svc = makeService();
      await svc.claimDailyReward(); // claims day 7

      // Reset mock to simulate "next day"
      SharedPreferences.setMockInitialValues({
        'dr_last_claim_date': daysAgoIso(1),
        'dr_last_claimed_day': 7,
      });
      final nextDaySvc = makeService();
      final state = await nextDaySvc.getCalendarState();
      expect(state.todaysCycleDay, 1);
    });

    test('missed day resets cycle to 1 even if streak was at 5', () async {
      SharedPreferences.setMockInitialValues({
        'dr_last_claim_date': daysAgoIso(3),
        'dr_last_claimed_day': 5,
      });
      final svc = makeService();
      final reward = await svc.claimDailyReward();

      expect(reward.streakDay, 1);
      expect(reward.credits, 50);
    });
  });

  // ── Compat API ────────────────────────────────────────────────────────────

  group('compat API', () {
    test('canClaimToday returns true initially', () async {
      expect(await makeService().canClaimToday(), isTrue);
    });

    test('canClaimToday returns false after claiming today', () async {
      final svc = makeService();
      await svc.claimDailyReward();
      expect(await svc.canClaimToday(), isFalse);
    });

    test('getStreakCount returns 0 when never claimed', () async {
      expect(await makeService().getStreakCount(), 0);
    });

    test('getStreakCount returns todaysCycleDay after claim', () async {
      final svc = makeService();
      await svc.claimDailyReward();
      expect(await svc.getStreakCount(), 1);
    });

    test('getStreakCount returns previous cycle day when not yet claimed today', () async {
      SharedPreferences.setMockInitialValues({
        'dr_last_claim_date': daysAgoIso(1),
        'dr_last_claimed_day': 3,
      });
      // Today would be day 4, not yet claimed → streak count = 3
      expect(await makeService().getStreakCount(), 3);
    });
  });

  // ── DailyReward model ─────────────────────────────────────────────────────

  group('DailyReward model', () {
    test('hasRewards is true when credits > 0', () {
      const r = DailyReward(credits: 10, streakDay: 1);
      expect(r.hasRewards, isTrue);
    });

    test('hasRewards is true when specialTheme = true', () {
      const r = DailyReward(credits: 0, streakDay: 7, specialTheme: true);
      expect(r.hasRewards, isTrue);
    });

    test('hasRewards is false for alreadyClaimed factory', () {
      expect(DailyReward.alreadyClaimed().hasRewards, isFalse);
    });
  });
}

