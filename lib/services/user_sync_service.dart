import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final userSyncServiceProvider = Provider((ref) => UserSyncService());

// ─── Firestore keys (mirrors SharedPreferences keys) ──────────────────────────

/// The service reads **all** meaningful local data, ships it to Firestore
/// under `users/{uid}`, and can restore it back.
///
/// Call [uploadUserData] after every significant change (level completion,
/// purchase, etc.) and [downloadUserData] on fresh install / sign-in.
class UserSyncService {
  static const String _collection = 'users';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Upload (local → Firestore) ──────────────────────────────────────────

  /// Merges current SharedPreferences data into `users/{uid}`.
  Future<void> uploadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      final data = <String, dynamic>{
        // Profile
        'displayName': prefs.getString('profile_display_name') ?? '',
        'avatarIndex': prefs.getInt('profile_avatar_index') ?? 0,
        'photoUrl': user.photoURL ?? '',

        // Progress
        'highestUnlockedLevel': prefs.getInt('highest_unlocked_level') ?? 1,
        'totalScore': prefs.getInt('total_score') ?? 0,
        'credits': prefs.getInt('credits') ?? 0,
        'lives': prefs.getInt('lives') ?? 5,

        // XP
        'playerXp': prefs.getInt('player_xp') ?? 0,

        // Hint stocks
        'hintRevealLetter': prefs.getInt('hint_reveal_letter') ?? 0,
        'hintRevealWord': prefs.getInt('hint_reveal_word') ?? 0,
        'hintRemoveWrong': prefs.getInt('hint_remove_wrong') ?? 0,
        'hintShowFirst': prefs.getInt('hint_show_first') ?? 0,
        'hintUndo': prefs.getInt('hint_undo') ?? 0,

        // Themes
        'unlockedThemes': prefs.getStringList('unlocked_themes') ?? [],

        // Statistics (entire JSON blob)
        'gameStatistics': prefs.getString('game_statistics') ?? '{}',

        // Streak / daily
        'streakCount': prefs.getInt('streak_count') ?? 0,
        'streakFreezeCount': prefs.getInt('streak_freeze_count') ?? 0,

        // Level stars (level_stars_XX keys)
        'levelStars': _collectLevelStars(prefs),

        // Meta
        'lastSyncedAt': FieldValue.serverTimestamp(),
        'email': user.email ?? '',
        'isAnonymous': user.isAnonymous,
      };

      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('UserSync upload error: $e');
    }
  }

  // ── Download (Firestore → local) ────────────────────────────────────────

  /// Pulls `users/{uid}` data into SharedPreferences.
  /// Only overwrites local data if the remote document exists.
  Future<bool> downloadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc =
          await _firestore.collection(_collection).doc(user.uid).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final prefs = await SharedPreferences.getInstance();

      // Profile
      if (data['displayName'] != null) {
        await prefs.setString(
            'profile_display_name', data['displayName'] as String);
      }
      if (data['avatarIndex'] != null) {
        await prefs.setInt('profile_avatar_index', data['avatarIndex'] as int);
      }

      // Progress
      _setIntIfPresent(prefs, 'highest_unlocked_level', data['highestUnlockedLevel']);
      _setIntIfPresent(prefs, 'total_score', data['totalScore']);
      _setIntIfPresent(prefs, 'credits', data['credits']);
      _setIntIfPresent(prefs, 'lives', data['lives']);

      // XP
      _setIntIfPresent(prefs, 'player_xp', data['playerXp']);

      // Hint stocks
      _setIntIfPresent(prefs, 'hint_reveal_letter', data['hintRevealLetter']);
      _setIntIfPresent(prefs, 'hint_reveal_word', data['hintRevealWord']);
      _setIntIfPresent(prefs, 'hint_remove_wrong', data['hintRemoveWrong']);
      _setIntIfPresent(prefs, 'hint_show_first', data['hintShowFirst']);
      _setIntIfPresent(prefs, 'hint_undo', data['hintUndo']);

      // Themes
      if (data['unlockedThemes'] != null) {
        await prefs.setStringList(
          'unlocked_themes',
          List<String>.from(data['unlockedThemes'] as List),
        );
      }

      // Statistics
      if (data['gameStatistics'] != null) {
        await prefs.setString(
            'game_statistics', data['gameStatistics'] as String);
      }

      // Streak
      _setIntIfPresent(prefs, 'streak_count', data['streakCount']);
      _setIntIfPresent(prefs, 'streak_freeze_count', data['streakFreezeCount']);

      // Level stars
      if (data['levelStars'] != null) {
        final stars = Map<String, dynamic>.from(data['levelStars'] as Map);
        for (final entry in stars.entries) {
          await prefs.setInt(entry.key, entry.value as int);
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('UserSync download error: $e');
      return false;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Map<String, int> _collectLevelStars(SharedPreferences prefs) {
    final result = <String, int>{};
    for (final key in prefs.getKeys()) {
      if (key.startsWith('level_stars_') || key.startsWith('level_time_')) {
        result[key] = prefs.getInt(key) ?? 0;
      }
    }
    return result;
  }

  Future<void> _setIntIfPresent(
    SharedPreferences prefs,
    String key,
    dynamic value,
  ) async {
    if (value != null && value is int) {
      await prefs.setInt(key, value);
    }
  }
}
