import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:crossclimber/models/level.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crossclimber/services/remote_config_service.dart';

class LevelRepository {
  final RemoteConfigService? _remoteConfigService;

  LevelRepository([this._remoteConfigService]);

  Future<List<Level>> loadLevels(String languageCode) async {
    if (_remoteConfigService != null) {
      return _remoteConfigService.getLevels(languageCode);
    }

    final String fileName = languageCode == 'tr'
        ? 'levels_tr.json'
        : 'levels_en.json';
    final String response = await rootBundle.loadString(
      'assets/levels/$fileName',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Level.fromJson(json)).toList();
  }

  Future<List<Level>> loadDailyLevels(String languageCode) async {
    if (_remoteConfigService != null) {
      return _remoteConfigService.getDailyLevels(languageCode);
    }

    final String fileName = languageCode == 'tr'
        ? 'daily_levels_tr.json'
        : 'daily_levels_en.json';
    final String response = await rootBundle.loadString(
      'assets/levels/$fileName',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Level.fromJson(json)).toList();
  }

  Future<Level> getLevelById(int levelId) async {
    // Get current language
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';

    final levels = await loadLevels(languageCode);
    return levels.firstWhere(
      (level) => level.id == levelId,
      orElse: () => levels.first, // Fallback to first level
    );
  }

  Future<Level> getDailyLevelById(int levelId) async {
    try {
      // Get current language
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';

      final levels = await loadDailyLevels(languageCode);
      if (levels.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            'ERROR: No daily levels found for language: $languageCode',
          );
        }
        throw Exception('No daily levels found');
      }

      // Use modulo to ensure we always get a valid level regardless of the ID
      // IDs in JSON are 1-based, so we adjust for 0-based index
      final index = (levelId - 1) % levels.length;
      if (kDebugMode) {
        debugPrint('Loaded ${levels.length} daily levels for $languageCode');
        debugPrint('Getting daily level at index $index for levelId $levelId');
      }
      return levels[index];
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('ERROR loading daily level: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }
}
