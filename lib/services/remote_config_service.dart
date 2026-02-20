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

  /// Returns today's quote for the given locale.
  /// Rotates through the list using day-of-year so every day is different.
  /// Falls back to local hardcoded list when Remote Config is empty.
  Map<String, String> getDailyQuote(String languageCode) {
    final key = 'daily_quotes_$languageCode';
    final jsonString = _remoteConfig.getString(key);

    List<dynamic> quotes;
    try {
      quotes = jsonString.isNotEmpty
          ? json.decode(jsonString) as List<dynamic>
          : _localQuotes[languageCode] ?? _localQuotes['en']!;
    } catch (_) {
      quotes = _localQuotes[languageCode] ?? _localQuotes['en']!;
    }

    if (quotes.isEmpty) quotes = _localQuotes['en']!;

    final epoch = DateTime(2026, 1, 1);
    final dayIndex = DateTime.now().difference(epoch).inDays.abs();
    final q = quotes[dayIndex % quotes.length] as Map<String, dynamic>;

    return {
      'text': q['text'] as String? ?? '',
      'author': q['author'] as String? ?? '',
    };
  }

  static const _localQuotes = <String, List<Map<String, String?>>>{
    'en': [
      {'text': 'Every word is a step up the mountain.', 'author': 'CrossClimber'},
      {'text': 'Climb with words, reach the summit.', 'author': null},
      {'text': 'The best vocabulary is built one puzzle at a time.', 'author': null},
      {'text': 'Words are the rungs of the ladder to mastery.', 'author': null},
      {'text': 'Start with one word. The summit will follow.', 'author': 'CrossClimber'},
      {'text': 'Language is the map; words are the path.', 'author': null},
      {'text': 'Every solved puzzle is a new peak conquered.', 'author': 'CrossClimber'},
      {'text': 'Challenge your mind, one word ladder at a time.', 'author': null},
      {'text': 'The journey of a thousand words begins with one.', 'author': null},
      {'text': 'Sharp minds climb the sharpest word mountains.', 'author': 'CrossClimber'},
      {'text': 'Play every day, grow every day.', 'author': null},
      {'text': 'Words connect us — so does CrossClimber.', 'author': 'CrossClimber'},
      {'text': 'Think. Guess. Climb. Repeat.', 'author': 'CrossClimber'},
      {'text': 'Each puzzle is a new adventure in language.', 'author': null},
    ],
    'tr': [
      {'text': 'Her kelime dağın bir basamağıdır.', 'author': 'CrossClimber'},
      {'text': 'Kelimelerle tırman, zirveye ulaş.', 'author': null},
      {'text': 'En iyi kelime dağarcığı her bulmacada gelişir.', 'author': null},
      {'text': 'Kelimeler, ustalığa giden merdivenin basamaklarıdır.', 'author': null},
      {'text': 'Bir kelimeyle başla, zirve peşinden gelir.', 'author': 'CrossClimber'},
      {'text': 'Dil bir harita, kelimeler ise yoldur.', 'author': null},
      {'text': 'Çözülen her bulmaca, fethedilen yeni bir zirve demektir.', 'author': 'CrossClimber'},
      {'text': 'Zihnini zorluyorsun, her kelime merdiveninde.', 'author': null},
      {'text': 'Bin kelimelik yolculuk tek bir kelimeyle başlar.', 'author': null},
      {'text': 'Keskin zihinler, en dik kelime dağlarını tırmanır.', 'author': 'CrossClimber'},
      {'text': 'Her gün oyna, her gün büyü.', 'author': null},
      {'text': 'Kelimeler bizi birbirine bağlar — CrossClimber de öyle.', 'author': 'CrossClimber'},
      {'text': 'Düşün. Tahmin Et. Tırman. Tekrarla.', 'author': 'CrossClimber'},
      {'text': 'Her bulmaca, dilde yeni bir macera.', 'author': null},
    ],
  };

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
