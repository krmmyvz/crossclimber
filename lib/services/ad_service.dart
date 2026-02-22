import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of attempting to show a rewarded ad.
enum AdResult {
  /// Ad was shown and user earned the reward.
  rewarded,
  /// Daily ad limit reached.
  dailyLimitReached,
  /// No ad is loaded / available right now.
  adNotAvailable,
}

/// Centralized ad management service.
///
/// Handles interstitial, rewarded, and banner ads through the Google Mobile Ads
/// SDK.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // ── Ad Unit IDs ─────────────────────────────────────────────────────────────
  // Android: production IDs  |  iOS: test IDs (create iOS app in AdMob later)
  static String get _interstitialAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-6114181024525578/1191740549';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910'; // TODO: iOS production
    throw UnsupportedError('Unsupported platform');
  }

  static String get _rewardedAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-6114181024525578/1686059981';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/1712485313'; // TODO: iOS production
    throw UnsupportedError('Unsupported platform');
  }

  static String get _bannerAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-6114181024525578/7046702457';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2435281174'; // TODO: iOS production
    throw UnsupportedError('Unsupported platform');
  }

  // ── Daily limit tracking (SharedPreferences) ───────────────────────────────
  static const String _keyAdsWatchedToday = 'adsWatchedToday';
  static const String _keyLastAdDate = 'lastAdWatchDate';
  static const int maxAdsPerDay = 5;

  // ── Internal state ─────────────────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInitialized = false;

  /// Counter tracking how many levels have been completed since last
  /// interstitial.  Resets each time an interstitial is shown.
  int _levelsSinceLastAd = 0;

  /// Minimum levels before the *first* interstitial appears.
  static const int _firstAdAfterLevel = 5;

  /// Interstitial frequency: one every N levels after the first.
  static const int _interstitialInterval = 5;

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Call once at app startup (e.g. from `main()`).
  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();

    // Register test devices to avoid invalid traffic on real ad units
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: ['16BA752FB62F47AAEBEA1D53542F7781'],
      ),
    );

    _isInitialized = true;
    _loadInterstitial();
    _loadRewarded();
  }

  // ── Interstitial ───────────────────────────────────────────────────────────

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial(); // pre-load next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Call after every level completion.  Shows an interstitial if the interval
  /// condition is met (every [_interstitialInterval] levels, skipping the
  /// first [_firstAdAfterLevel]).
  ///
  /// Returns `true` if an ad was shown.
  Future<bool> showInterstitialIfReady() async {
    _levelsSinceLastAd++;

    // Don't show ads before the first threshold
    if (_levelsSinceLastAd < _firstAdAfterLevel) return false;

    // Only show on interval boundaries
    if ((_levelsSinceLastAd - _firstAdAfterLevel) % _interstitialInterval !=
        0) {
      return false;
    }

    if (_interstitialAd == null) return false;

    await _interstitialAd!.show();
    _levelsSinceLastAd = 0;
    return true;
  }

  // ── Rewarded ───────────────────────────────────────────────────────────────

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _loadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Rewarded ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              _loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  /// Whether a rewarded ad is loaded and ready to show.
  bool get isRewardedAdReady => _rewardedAd != null;

  /// Show a rewarded ad.  [onRewarded] fires only after the user watches the
  /// full ad.  Returns an [AdResult] indicating what happened.
  Future<AdResult> showRewardedAd({
    required void Function() onRewarded,
  }) async {
    // Enforce daily limit
    final canWatch = await _canWatchAd();
    if (!canWatch) return AdResult.dailyLimitReached;

    if (_rewardedAd == null) return AdResult.adNotAvailable;

    bool rewarded = false;

    await _rewardedAd!.show(
      onUserEarnedReward: (_, __) {
        rewarded = true;
      },
    );

    if (rewarded) {
      await _incrementDailyCount();
      onRewarded();
      return AdResult.rewarded;
    }

    return AdResult.adNotAvailable;
  }

  // ── Banner ─────────────────────────────────────────────────────────────────

  /// Create a banner ad (caller is responsible for disposing it).
  BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    void Function(Ad)? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded ?? (_) {},
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed to load: $error');
          ad.dispose();
          onAdFailedToLoad?.call(ad, error);
        },
      ),
    );
  }

  // ── Daily limit helpers ────────────────────────────────────────────────────

  Future<bool> _canWatchAd() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAdDate = prefs.getString(_keyLastAdDate);
    final adsWatchedToday = prefs.getInt(_keyAdsWatchedToday) ?? 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

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

  Future<void> _incrementDailyCount() async {
    final prefs = await SharedPreferences.getInstance();
    final adsWatchedToday = prefs.getInt(_keyAdsWatchedToday) ?? 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await prefs.setInt(_keyAdsWatchedToday, adsWatchedToday + 1);
    await prefs.setString(_keyLastAdDate, today.toIso8601String());
  }

  /// How many rewarded ads the user can still watch today.
  Future<int> getRemainingAdsToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAdDate = prefs.getString(_keyLastAdDate);
    final adsWatchedToday = prefs.getInt(_keyAdsWatchedToday) ?? 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastAdDate != null) {
      final lastDate = DateTime.parse(lastAdDate);
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      if (today.isAfter(lastDay)) return maxAdsPerDay;
    }

    return (maxAdsPerDay - adsWatchedToday).clamp(0, maxAdsPerDay);
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
