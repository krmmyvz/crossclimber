import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:crossclimber/models/level.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 12),
      ));
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Error initializing Remote Config: $e');
    }
  }

  Future<List<Level>> getLevels(String languageCode) async {
    final key = 'levels_${languageCode}_v1';
    final jsonString = _remoteConfig.getString(key);

    if (jsonString.isEmpty) {
      return _loadLocalLevels(languageCode);
    }

    try {
      final List<dynamic> data = json.decode(jsonString);
      return data.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error parsing levels from Remote Config: $e');
      return _loadLocalLevels(languageCode);
    }
  }

  Future<List<Level>> getDailyLevels(String languageCode) async {
    final key = 'daily_levels_${languageCode}_v1';
    final jsonString = _remoteConfig.getString(key);

    if (jsonString.isEmpty) {
      return _loadLocalDailyLevels(languageCode);
    }

    try {
      final List<dynamic> data = json.decode(jsonString);
      return data.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error parsing daily levels from Remote Config: $e');
      return _loadLocalDailyLevels(languageCode);
    }
  }

  Map<String, dynamic> getEconomyConfig() {
    final jsonString = _remoteConfig.getString('economy_config');
    if (jsonString.isEmpty) {
      return {
        'dailyLoginReward': 20,
        'dailyChallengeReward': 50,
        'adRewardCredits': 25,
        'lifeCost': 50,
        'allLivesCost': 100,
        'maxAdsPerDay': 5,
      };
    }
    return json.decode(jsonString);
  }

  String getContentVersion() {
    return _remoteConfig.getString('content_version');
  }

  // Fallback methods
  Future<List<Level>> _loadLocalLevels(String languageCode) async {
    final String fileName = languageCode == 'tr' ? 'levels_tr.json' : 'levels_en.json';
    final String response = await rootBundle.loadString('assets/levels/$fileName');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Level.fromJson(json)).toList();
  }

  Future<List<Level>> _loadLocalDailyLevels(String languageCode) async {
    final String fileName = languageCode == 'tr' ? 'daily_levels_tr.json' : 'daily_levels_en.json';
    final String response = await rootBundle.loadString('assets/levels/$fileName');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Level.fromJson(json)).toList();
  }
}
