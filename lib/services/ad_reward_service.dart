import 'package:shared_preferences/shared_preferences.dart';

/// Mock ad reward service
/// In production, this would integrate with Google AdMob or similar
class AdRewardService {
  static const String _keyAdsWatchedToday = 'adsWatchedToday';
  static const String _keyLastAdDate = 'lastAdWatchDate';
  static const int maxAdsPerDay = 5;

  /// Check if user can watch more ads today
  Future<bool> canWatchAd() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAdDate = prefs.getString(_keyLastAdDate);
    final adsWatchedToday = prefs.getInt(_keyAdsWatchedToday) ?? 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Reset counter if it's a new day
    if (lastAdDate != null) {
      final lastDate = DateTime.parse(lastAdDate);
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);

      if (today.isAfter(lastDay)) {
        await prefs.setInt(_keyAdsWatchedToday, 0);
        return true;
      }
    }

    return adsWatchedToday < maxAdsPerDay;
  }

  /// Get remaining ads that can be watched today
  Future<int> getRemainingAdsToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAdDate = prefs.getString(_keyLastAdDate);
    final adsWatchedToday = prefs.getInt(_keyAdsWatchedToday) ?? 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Reset counter if it's a new day
    if (lastAdDate != null) {
      final lastDate = DateTime.parse(lastAdDate);
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);

      if (today.isAfter(lastDay)) {
        return maxAdsPerDay;
      }
    }

    return (maxAdsPerDay - adsWatchedToday).clamp(0, maxAdsPerDay);
  }

  /// Simulate watching an ad and get reward
  /// Returns credits earned (25) or 0 if limit reached
  Future<int> watchAdForCredits() async {
    final canWatch = await canWatchAd();
    if (!canWatch) return 0;

    final prefs = await SharedPreferences.getInstance();
    final adsWatchedToday = prefs.getInt(_keyAdsWatchedToday) ?? 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await prefs.setInt(_keyAdsWatchedToday, adsWatchedToday + 1);
    await prefs.setString(_keyLastAdDate, today.toIso8601String());

    // TODO: In production, show actual rewarded ad here
    // await _rewardedAd.show();

    return 25; // 25 credits per ad
  }

  /// Simulate watching an ad for a random hint
  /// Returns hint type ('revealWord' or 'undo') or null if limit reached
  Future<String?> watchAdForHint() async {
    final canWatch = await canWatchAd();
    if (!canWatch) return null;

    final prefs = await SharedPreferences.getInstance();
    final adsWatchedToday = prefs.getInt(_keyAdsWatchedToday) ?? 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await prefs.setInt(_keyAdsWatchedToday, adsWatchedToday + 1);
    await prefs.setString(_keyLastAdDate, today.toIso8601String());

    // TODO: In production, show actual rewarded ad here

    // Random hint type
    return DateTime.now().millisecond % 2 == 0 ? 'revealWord' : 'undo';
  }
}
