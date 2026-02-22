import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/models/tournament.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/services/level_repository.dart';
import 'package:crossclimber/services/progress_repository.dart';
import 'package:crossclimber/services/remote_config_service.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final tournamentServiceProvider = Provider<TournamentService>((ref) {
  return TournamentService(
    levelRepo: ref.read(levelRepositoryProvider),
    progressRepo: ref.read(progressRepositoryProvider),
  );
});

/// Current week's tournament info (always available — local fallback if offline).
final currentTournamentProvider = FutureProvider<TournamentInfo>((ref) async {
  return ref.read(tournamentServiceProvider).getOrCreateCurrentTournament();
});

/// Real-time leaderboard stream for a given [weekId].
final tournamentLeaderboardProvider =
    StreamProvider.family<List<TournamentEntry>, String>((ref, weekId) {
  return ref.read(tournamentServiceProvider).getLeaderboard(weekId);
});

/// Current user's own tournament entry for a given [weekId].
final myTournamentEntryProvider =
    FutureProvider.family<TournamentEntry?, String>((ref, weekId) async {
  return ref.read(tournamentServiceProvider).getUserEntry(weekId);
});

// ─── Service ──────────────────────────────────────────────────────────────────

class TournamentService {
  static const String _collection = 'tournaments';
  static const String _entriesSubcollection = 'entries';

  final LevelRepository _levelRepo;
  final ProgressRepository _progressRepo;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TournamentService({
    LevelRepository? levelRepo,
    ProgressRepository? progressRepo,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _levelRepo = levelRepo ?? LevelRepository(RemoteConfigService()),
        _progressRepo = progressRepo ?? ProgressRepository(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // ── Week helpers ──────────────────────────────────────────────────────────

  /// Returns the ISO week ID string for the current week, e.g. "2026-W08".
  static String getCurrentWeekId() {
    final monday = getMondayOfCurrentWeek();
    final week = _isoWeekNumber(monday);
    return '${monday.year}-W${week.toString().padLeft(2, '0')}';
  }

  /// Returns the UTC DateTime for the Monday that starts the current ISO week.
  static DateTime getMondayOfCurrentWeek() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day - (now.weekday - 1));
  }

  /// Computes the ISO week number for the given date.
  static int _isoWeekNumber(DateTime date) {
    final thursday =
        date.add(Duration(days: 4 - (date.weekday == 0 ? 7 : date.weekday)));
    final jan1 = DateTime.utc(thursday.year, 1, 1);
    return ((thursday.difference(jan1).inDays) / 7).floor() + 1;
  }

  // ── Level selection ───────────────────────────────────────────────────────

  /// Picks 7 level IDs from [allLevels] deterministically based on [weekId].
  ///
  /// Selection: 3 × difficulty-1, 3 × difficulty-2, 1 × difficulty-3,
  /// sorted so they appear in increasing difficulty order.
  static List<int> computeTournamentLevelIds(
    String weekId,
    List<Level> allLevels,
  ) {
    final seed = weekId.hashCode.abs();
    final rng = math.Random(seed);

    final diff1 = allLevels
        .where((l) => l.difficulty == 1)
        .map((l) => l.id)
        .toList()..sort();
    final diff2 = allLevels
        .where((l) => l.difficulty == 2)
        .map((l) => l.id)
        .toList()..sort();
    final diff3 = allLevels
        .where((l) => l.difficulty == 3)
        .map((l) => l.id)
        .toList()..sort();

    final s1 = List<int>.from(diff1)..shuffle(rng);
    final s2 = List<int>.from(diff2)..shuffle(rng);
    final s3 = List<int>.from(diff3)..shuffle(rng);

    final picked = <int>[
      ...s1.take(math.min(3, s1.length)),
      ...s2.take(math.min(3, s2.length)),
      ...s3.take(math.min(1, s3.length)),
    ]..sort();

    return picked;
  }

  // ── Auth helpers ──────────────────────────────────────────────────────────

  /// Returns the current user, signing in anonymously if needed.
  Future<User?> _getOrSignInUser() async {
    var user = _auth.currentUser;
    if (user == null) {
      try {
        final credential = await _auth.signInAnonymously();
        user = credential.user;
      } catch (e) {
        debugPrint('[Tournament] Anonymous sign-in failed: $e');
        return null;
      }
    }
    return user;
  }

  String _displayNameFor(User user) {
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    // Fallback: "Player" + last 4 chars of UID
    final suffix = user.uid.length >= 4
        ? user.uid.substring(user.uid.length - 4)
        : user.uid;
    return 'Player $suffix';
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns the current week's tournament, creating the Firestore document
  /// if it does not yet exist.  Falls back to a locally-computed tournament
  /// when Firebase is unreachable (offline mode).
  Future<TournamentInfo> getOrCreateCurrentTournament() async {
    final weekId = getCurrentWeekId();
    final docRef = _firestore.collection(_collection).doc(weekId);

    try {
      final snap = await docRef.get();
      if (snap.exists) {
        return TournamentInfo.fromFirestore(snap);
      }

      // Document doesn't exist — compute levels and create it.
      final monday = getMondayOfCurrentWeek();
      final nextMonday = monday.add(const Duration(days: 7));

      // Load levels for level selection (language 'en' as canonical)
      final allLevels = await _levelRepo.loadLevels('en');
      final levelIds = computeTournamentLevelIds(weekId, allLevels);

      final info = TournamentInfo(
        weekId: weekId,
        startDate: monday,
        endDate: nextMonday,
        levelIds: levelIds,
      );

      await docRef.set(info.toFirestore());
      return info;
    } catch (e) {
      debugPrint('[Tournament] Firestore unavailable, using local fallback: $e');
      return _buildLocalTournament(weekId);
    }
  }

  /// Computes a tournament locally without Firebase.
  /// Level selection is deterministic based on [weekId], so the result
  /// is identical across devices for the same week.
  Future<TournamentInfo> _buildLocalTournament(String weekId) async {
    final monday = getMondayOfCurrentWeek();
    final nextMonday = monday.add(const Duration(days: 7));

    try {
      final allLevels = await _levelRepo.loadLevels('en');
      final levelIds = computeTournamentLevelIds(weekId, allLevels);
      return TournamentInfo(
        weekId: weekId,
        startDate: monday,
        endDate: nextMonday,
        levelIds: levelIds,
      );
    } catch (_) {
      // Even local level loading failed — return a minimal tournament
      // with empty levels (UI will show the banner but no playable levels)
      return TournamentInfo(
        weekId: weekId,
        startDate: monday,
        endDate: nextMonday,
        levelIds: const [],
      );
    }
  }

  /// Stream of the top-100 leaderboard entries for [weekId].
  Stream<List<TournamentEntry>> getLeaderboard(String weekId) {
    return _firestore
        .collection(_collection)
        .doc(weekId)
        .collection(_entriesSubcollection)
        .orderBy('totalScore', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs
          .map((doc) => TournamentEntry.fromFirestore(doc))
          .toList();

      // Assign ranks in-memory (avoids a Firestore Cloud Function dependency)
      for (var i = 0; i < entries.length; i++) {
        final ranked = TournamentEntry(
          uid: entries[i].uid,
          displayName: entries[i].displayName,
          totalScore: entries[i].totalScore,
          levelScores: entries[i].levelScores,
          rank: i + 1,
          updatedAt: entries[i].updatedAt,
        );
        entries[i] = ranked;
      }
      return entries;
    });
  }

  /// Returns the current user's entry for [weekId], or null if not yet
  /// participating or on error.
  Future<TournamentEntry?> getUserEntry(String weekId) async {
    final user = await _getOrSignInUser();
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(weekId)
          .collection(_entriesSubcollection)
          .doc(user.uid)
          .get();
      if (!doc.exists) return null;
      return TournamentEntry.fromFirestore(doc);
    } catch (e) {
      debugPrint('[Tournament] getUserEntry error: $e');
      return null;
    }
  }

  /// Submits or updates the user's score for [levelId] in [weekId].
  ///
  /// Only updates if [score] is higher than the previously recorded score.
  Future<void> submitLevelScore({
    required String weekId,
    required int levelId,
    required int score,
  }) async {
    final user = await _getOrSignInUser();
    if (user == null) return;

    final entryRef = _firestore
        .collection(_collection)
        .doc(weekId)
        .collection(_entriesSubcollection)
        .doc(user.uid);

    try {
      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(entryRef);
        final levelKey = levelId.toString();

        if (!snap.exists) {
          // First score submission — create entry
          txn.set(entryRef, {
            'uid': user.uid,
            'displayName': _displayNameFor(user),
            'totalScore': score,
            'levelScores': {levelKey: score},
            'rank': 0,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return;
        }

        final data = snap.data()!;
        final levelScores = Map<String, int>.from(data['levelScores'] as Map? ?? {});
        final prevScore = levelScores[levelKey] ?? 0;

        // Only update if the new score is higher
        if (score <= prevScore) return;

        final scoreDelta = score - prevScore;
        final newTotal = (data['totalScore'] as int? ?? 0) + scoreDelta;

        levelScores[levelKey] = score;

        txn.update(entryRef, {
          'levelScores': levelScores,
          'totalScore': newTotal,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('[Tournament] submitLevelScore error: $e');
    }
  }

  /// Called from the game completion flow.  Checks if [levelId] is part of
  /// the current tournament and submits [score] if so.  Fire-and-forget.
  Future<void> submitLevelScoreIfTournament({
    required int levelId,
    required int score,
  }) async {
    try {
      final tournament = await getOrCreateCurrentTournament();
      if (!tournament.isActive) return;
      if (!tournament.levelIds.contains(levelId)) return;

      await submitLevelScore(
        weekId: tournament.weekId,
        levelId: levelId,
        score: score,
      );
    } catch (_) {
      // Best-effort: never propagate errors into the game flow
    }
  }

  /// Claims the end-of-tournament reward for the current user.
  ///
  /// Should be called once per tournament, after it has ended.
  Future<void> claimRewardIfEligible(String weekId) async {
    final user = await _getOrSignInUser();
    if (user == null) return;

    try {
      final entry = await getUserEntry(weekId);
      if (entry == null) return;

      // Get rank from live leaderboard (first 100 results one-shot)
      final snap = await _firestore
          .collection(_collection)
          .doc(weekId)
          .collection(_entriesSubcollection)
          .orderBy('totalScore', descending: true)
          .limit(100)
          .get();

      final rank = snap.docs.indexWhere((d) => d.id == user.uid) + 1;
      if (rank == 0) return; // not in top 100 — participation tier

      final effectiveRank = rank > 0 ? rank : 101; // 101 → participation
      final tier = TournamentRewardTier.forRank(effectiveRank);
      await _progressRepo.addCredits(tier.credits);
    } catch (e) {
      debugPrint('[Tournament] claimRewardIfEligible error: $e');
    }
  }
}
