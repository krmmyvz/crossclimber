import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/services/progress_repository.dart';

// ─── Reward definitions ───────────────────────────────────────────────────────

/// Definition of the reward granted on one day of the 7-day cycle.
class DailyRewardDef {
  final int day;
  final int credits;
  final int revealHints;
  final int undoHints;

  /// Day 7 only: marks the special weekly theme bonus.
  final bool specialTheme;

  const DailyRewardDef({
    required this.day,
    this.credits = 0,
    this.revealHints = 0,
    this.undoHints = 0,
    this.specialTheme = false,
  });
}

/// The 7-day rotating reward calendar as specified in the UI/UX roadmap.
const List<DailyRewardDef> kDayRewards = [
  DailyRewardDef(day: 1, credits: 50),
  DailyRewardDef(day: 2, revealHints: 1),
  DailyRewardDef(day: 3, credits: 100),
  DailyRewardDef(day: 4, undoHints: 1),
  DailyRewardDef(day: 5, credits: 150),
  DailyRewardDef(day: 6, revealHints: 1, undoHints: 1),
  DailyRewardDef(day: 7, credits: 300, specialTheme: true),
];

// ─── State & result models ────────────────────────────────────────────────────

/// Snapshot of the calendar for the UI to render.
class DailyCalendarState {
  /// Which day in the cycle (1–7) is shown as "today" (the day to claim).
  final int todaysCycleDay;

  /// Whether the user already claimed today's reward.
  final bool claimedToday;

  /// True when the streak was auto-reset because one or more days were missed
  /// (FOMO mechanic).
  final bool streakWasReset;

  /// Countdown until the next reward becomes available; null when a reward
  /// is already available.
  final Duration? timeUntilNext;

  const DailyCalendarState({
    required this.todaysCycleDay,
    required this.claimedToday,
    this.streakWasReset = false,
    this.timeUntilNext,
  });

  /// Short-hand: reward is available when today has not been claimed yet.
  bool get canClaimNow => !claimedToday;
}

/// The result returned after claiming a daily reward.
class DailyReward {
  final int credits;
  final int revealHints;
  final int undoHints;
  final int streakDay;
  final bool alreadyClaimed;
  final bool specialTheme;

  const DailyReward({
    required this.credits,
    this.revealHints = 0,
    this.undoHints = 0,
    required this.streakDay,
    this.alreadyClaimed = false,
    this.specialTheme = false,
  });

  factory DailyReward.alreadyClaimed() =>
      const DailyReward(credits: 0, streakDay: 0, alreadyClaimed: true);

  bool get hasRewards =>
      credits > 0 || revealHints > 0 || undoHints > 0 || specialTheme;
}

// ─── Providers ────────────────────────────────────────────────────────────────

final dailyRewardServiceProvider = Provider<DailyRewardService>((ref) {
  return DailyRewardService(ref.read(progressRepositoryProvider));
});

/// Reactive snapshot of the calendar state. Invalidate after claiming.
final dailyCalendarStateProvider = FutureProvider<DailyCalendarState>((ref) {
  return ref.read(dailyRewardServiceProvider).getCalendarState();
});

// ─── Service ──────────────────────────────────────────────────────────────────

class DailyRewardService {
  // SharedPreferences keys (new schema)
  static const String _keyLastClaimDate = 'dr_last_claim_date';
  static const String _keyLastClaimedDay = 'dr_last_claimed_day';

  final ProgressRepository _progressRepo;

  /// Inject [ProgressRepository]; if omitted a default instance is created
  /// (preserves backward-compat for direct `DailyRewardService()` calls).
  DailyRewardService([ProgressRepository? progressRepo])
      : _progressRepo = progressRepo ?? ProgressRepository();

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _todayKey() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).toIso8601String();
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns the full calendar state needed by the UI.
  Future<DailyCalendarState> getCalendarState() async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaimDateStr = prefs.getString(_keyLastClaimDate);
    final lastClaimedDay = prefs.getInt(_keyLastClaimedDay) ?? 0;

    final today = _dateOnly(DateTime.now());

    // First-ever open
    if (lastClaimDateStr == null) {
      return const DailyCalendarState(
        todaysCycleDay: 1,
        claimedToday: false,
      );
    }

    final lastClaimDate = DateTime.parse(lastClaimDateStr);
    final daysSince = today.difference(_dateOnly(lastClaimDate)).inDays;

    if (daysSince == 0) {
      // Already claimed today — compute countdown to midnight
      final tomorrow = today.add(const Duration(days: 1));
      final remaining = tomorrow.difference(DateTime.now());
      return DailyCalendarState(
        todaysCycleDay: lastClaimedDay,
        claimedToday: true,
        timeUntilNext:
            remaining.isNegative ? Duration.zero : remaining,
      );
    }

    if (daysSince == 1) {
      // Consecutive day: advance cycle by one (wraps from 7 back to 1)
      final nextDay = (lastClaimedDay % 7) + 1;
      return DailyCalendarState(
        todaysCycleDay: nextDay,
        claimedToday: false,
      );
    }

    // Missed one or more days — FOMO streak reset
    return DailyCalendarState(
      todaysCycleDay: 1,
      claimedToday: false,
      streakWasReset: lastClaimedDay > 1,
    );
  }

  /// Claims today's reward, persists the new state and applies all rewards.
  ///
  /// Returns [DailyReward.alreadyClaimed] if already claimed today.
  Future<DailyReward> claimDailyReward() async {
    final state = await getCalendarState();
    if (state.claimedToday) return DailyReward.alreadyClaimed();

    final day = state.todaysCycleDay; // 1–7
    final def = kDayRewards[day - 1];

    // Apply rewards via ProgressRepository
    if (def.credits > 0) {
      await _progressRepo.addCredits(def.credits);
    }
    if (def.revealHints > 0) {
      await _progressRepo.addHintStock('revealWord', def.revealHints);
    }
    if (def.undoHints > 0) {
      await _progressRepo.addHintStock('undo', def.undoHints);
    }

    // Persist claim
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastClaimDate, _todayKey());
    await prefs.setInt(_keyLastClaimedDay, day);

    return DailyReward(
      credits: def.credits,
      revealHints: def.revealHints,
      undoHints: def.undoHints,
      streakDay: day,
      specialTheme: def.specialTheme,
    );
  }

  // ── Legacy / compat API ────────────────────────────────────────────────────

  /// Returns true when today's reward has not yet been claimed.
  Future<bool> canClaimToday() async {
    final state = await getCalendarState();
    return state.canClaimNow;
  }

  /// Returns the last claimed cycle day (0 if never claimed or after reset).
  /// Used for streak badge by [HomeScreen] and [CommonAppBar].
  Future<int> getStreakCount() async {
    final state = await getCalendarState();
    if (state.claimedToday) return state.todaysCycleDay;
    return state.todaysCycleDay > 1 ? state.todaysCycleDay - 1 : 0;
  }

  /// Time remaining until the next reward is available (null = available now).
  Future<Duration?> getTimeUntilNextReward() async {
    final state = await getCalendarState();
    return state.timeUntilNext;
  }
}
