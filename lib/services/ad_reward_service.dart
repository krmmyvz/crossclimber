import 'package:crossclimber/services/ad_service.dart';

/// Result wrapper for ad reward attempts.
class AdRewardResult<T> {
  final AdResult adResult;
  final T? value;

  const AdRewardResult(this.adResult, [this.value]);

  bool get success => adResult == AdResult.rewarded;
  bool get isLimitReached => adResult == AdResult.dailyLimitReached;
  bool get isAdUnavailable => adResult == AdResult.adNotAvailable;
}

/// Provides reward logic on top of [AdService].
///
/// Keeps backward-compatible API (`watchAdForCredits`, `watchAdForHint`) while
/// delegating the actual ad display to the real Google Mobile Ads SDK.
class AdRewardService {
  static const int creditsPerAd = 25;

  /// How many rewarded ads the user can still watch today.
  Future<int> getRemainingAdsToday() =>
      AdService.instance.getRemainingAdsToday();

  /// Check if user can watch more ads today.
  Future<bool> canWatchAd() async {
    final remaining = await getRemainingAdsToday();
    return remaining > 0;
  }

  /// Show a rewarded video and grant credits.
  Future<AdRewardResult<int>> watchAdForCredits() async {
    int earned = 0;

    final result = await AdService.instance.showRewardedAd(
      onRewarded: () => earned = creditsPerAd,
    );

    return AdRewardResult(result, result == AdResult.rewarded ? earned : 0);
  }

  /// Show a rewarded video and grant a random hint type.
  Future<AdRewardResult<String>> watchAdForHint() async {
    String? hintType;

    final result = await AdService.instance.showRewardedAd(
      onRewarded: () {
        hintType =
            DateTime.now().millisecond % 2 == 0 ? 'revealWord' : 'undo';
      },
    );

    return AdRewardResult(result, hintType);
  }
}
