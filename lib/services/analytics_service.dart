import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider((ref) => AnalyticsService());

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logLevelStart(int levelId, String difficulty) async {
    await _analytics.logLevelStart(
      levelName: 'level_$levelId',
    );
    await logEvent('level_start_detail', {
      'level_id': levelId,
      'difficulty': difficulty,
    });
  }

  Future<void> logLevelComplete(int levelId, int stars, Duration time, int score) async {
    await _analytics.logLevelEnd(
      levelName: 'level_$levelId',
      success: 1,
    );
    await logEvent('level_completed_detail', {
      'level_id': levelId,
      'stars': stars,
      'seconds_taken': time.inSeconds,
      'score': score,
    });
  }

  Future<void> logLevelFail(int levelId, String reason) async {
    await _analytics.logLevelEnd(
      levelName: 'level_$levelId',
      success: 0,
    );
    await logEvent('level_failed_detail', {
      'level_id': levelId,
      'reason': reason,
    });
  }

  Future<void> logHintUsed(String hintType) async {
    await logEvent('use_hint', {
      'hint_type': hintType,
    });
  }

  Future<void> logPurchase(String itemType, int amount) async {
    await logEvent('in_app_purchase_simulation', {
      'item': itemType,
      'amount': amount,
    });
  }

  Future<void> logDailyChallengeComplete(int streak) async {
    await logEvent('daily_challenge_complete', {
      'streak': streak,
    });
  }
}
