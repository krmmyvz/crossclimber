import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ─── Status ──────────────────────────────────────────────────────────────────

enum TournamentStatus { upcoming, active, ended }

// ─── TournamentInfo ───────────────────────────────────────────────────────────

/// Metadata for a single weekly tournament round.
class TournamentInfo {
  final String weekId;      // e.g. "2026-W08"
  final DateTime startDate; // Monday 00:00 UTC
  final DateTime endDate;   // Following Monday 00:00 UTC (exclusive)
  final List<int> levelIds; // 7 level IDs, sorted by difficulty

  const TournamentInfo({
    required this.weekId,
    required this.startDate,
    required this.endDate,
    required this.levelIds,
  });

  TournamentStatus get status {
    final now = DateTime.now().toUtc();
    if (now.isBefore(startDate)) return TournamentStatus.upcoming;
    if (now.isBefore(endDate)) return TournamentStatus.active;
    return TournamentStatus.ended;
  }

  bool get isActive => status == TournamentStatus.active;

  Duration get remainingDuration {
    final now = DateTime.now().toUtc();
    if (now.isAfter(endDate)) return Duration.zero;
    return endDate.difference(now);
  }

  Duration get durationUntilStart {
    final now = DateTime.now().toUtc();
    if (now.isAfter(startDate)) return Duration.zero;
    return startDate.difference(now);
  }

  factory TournamentInfo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return TournamentInfo(
      weekId: data['weekId'] as String,
      startDate: (data['startDate'] as Timestamp).toDate().toUtc(),
      endDate: (data['endDate'] as Timestamp).toDate().toUtc(),
      levelIds: List<int>.from(data['levelIds'] as List),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'weekId': weekId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'levelIds': levelIds,
      };
}

// ─── TournamentEntry ──────────────────────────────────────────────────────────

/// A user's participation record in a tournament.
class TournamentEntry {
  final String uid;
  final String displayName;
  final int totalScore;
  final Map<String, int> levelScores; // "levelId" → score
  final int rank;                     // 1-based; 0 = not yet ranked
  final DateTime? updatedAt;

  const TournamentEntry({
    required this.uid,
    required this.displayName,
    required this.totalScore,
    required this.levelScores,
    this.rank = 0,
    this.updatedAt,
  });

  int get levelsCompleted => levelScores.length;

  bool hasCompletedLevel(int levelId) =>
      levelScores.containsKey(levelId.toString());

  int scoreForLevel(int levelId) =>
      levelScores[levelId.toString()] ?? 0;

  factory TournamentEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return TournamentEntry(
      uid: data['uid'] as String,
      displayName: data['displayName'] as String? ?? 'Player',
      totalScore: data['totalScore'] as int? ?? 0,
      levelScores: Map<String, int>.from(data['levelScores'] as Map? ?? {}),
      rank: data['rank'] as int? ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate().toUtc(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'displayName': displayName,
        'totalScore': totalScore,
        'levelScores': levelScores,
        'rank': rank,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

// ─── TournamentRewardTier ─────────────────────────────────────────────────────

/// Reward configuration for a rank bracket.
class TournamentRewardTier {
  final int minRank;
  final int maxRank;
  final int credits;
  final bool hasBadge;
  final IconData icon;
  final Color iconColor;

  const TournamentRewardTier({
    required this.minRank,
    required this.maxRank,
    required this.credits,
    required this.hasBadge,
    required this.icon,
    required this.iconColor,
  });

  bool contains(int rank) => rank >= minRank && rank <= maxRank;

  static const List<TournamentRewardTier> tiers = [
    TournamentRewardTier(
      minRank: 1,
      maxRank: 1,
      credits: 500,
      hasBadge: true,
      icon: Icons.emoji_events_rounded,
      iconColor: Color(0xFFFFD700),
    ),
    TournamentRewardTier(
      minRank: 2,
      maxRank: 2,
      credits: 250,
      hasBadge: true,
      icon: Icons.emoji_events_rounded,
      iconColor: Color(0xFFC0C0C0),
    ),
    TournamentRewardTier(
      minRank: 3,
      maxRank: 3,
      credits: 100,
      hasBadge: true,
      icon: Icons.emoji_events_rounded,
      iconColor: Color(0xFFCD7F32),
    ),
    TournamentRewardTier(
      minRank: 4,
      maxRank: 10,
      credits: 50,
      hasBadge: false,
      icon: Icons.military_tech_rounded,
      iconColor: Color(0xFF78909C),
    ),
    TournamentRewardTier(
      minRank: 11,
      maxRank: 999999,
      credits: 10,
      hasBadge: false,
      icon: Icons.military_tech_outlined,
      iconColor: Color(0xFF90A4AE),
    ),
  ];

  static TournamentRewardTier forRank(int rank) {
    for (final tier in tiers) {
      if (tier.contains(rank)) return tier;
    }
    return tiers.last;
  }
}
