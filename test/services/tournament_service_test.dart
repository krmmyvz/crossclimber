import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/models/tournament.dart';
import 'package:crossclimber/services/tournament_service.dart';

void main() {
  // ── TournamentRewardTier.forRank ─────────────────────────────────────────

  group('TournamentRewardTier.forRank', () {
    test('rank 1 → 500 credits with badge (🥇)', () {
      final tier = TournamentRewardTier.forRank(1);
      expect(tier.credits, 500);
      expect(tier.hasBadge, isTrue);
      expect(tier.icon, Icons.emoji_events_rounded);
    });

    test('rank 2 → 250 credits with badge (🥈)', () {
      final tier = TournamentRewardTier.forRank(2);
      expect(tier.credits, 250);
      expect(tier.hasBadge, isTrue);
    });

    test('rank 3 → 100 credits with badge (🥉)', () {
      final tier = TournamentRewardTier.forRank(3);
      expect(tier.credits, 100);
      expect(tier.hasBadge, isTrue);
    });

    test('rank 7 (in 4-10) → 50 credits, no badge', () {
      final tier = TournamentRewardTier.forRank(7);
      expect(tier.credits, 50);
      expect(tier.hasBadge, isFalse);
    });

    test('rank 50 (11+) → 10 credits, no badge', () {
      final tier = TournamentRewardTier.forRank(50);
      expect(tier.credits, 10);
      expect(tier.hasBadge, isFalse);
    });
  });

  // ── TournamentInfo.status ────────────────────────────────────────────────

  group('TournamentInfo.status', () {
    test('returns upcoming when now is before startDate', () {
      final now = DateTime.now().toUtc();
      final info = TournamentInfo(
        weekId: '2030-W01',
        startDate: now.add(const Duration(hours: 2)),
        endDate: now.add(const Duration(days: 7)),
        levelIds: const [1, 2, 3, 4, 5, 6, 7],
      );
      expect(info.status, TournamentStatus.upcoming);
      expect(info.isActive, isFalse);
    });

    test('returns active when now is inside [start, end)', () {
      final now = DateTime.now().toUtc();
      final info = TournamentInfo(
        weekId: '2030-W02',
        startDate: now.subtract(const Duration(hours: 1)),
        endDate: now.add(const Duration(days: 6)),
        levelIds: const [1, 2, 3, 4, 5, 6, 7],
      );
      expect(info.status, TournamentStatus.active);
      expect(info.isActive, isTrue);
    });

    test('returns ended when now is after endDate', () {
      final now = DateTime.now().toUtc();
      final info = TournamentInfo(
        weekId: '2026-W03',
        startDate: now.subtract(const Duration(days: 8)),
        endDate: now.subtract(const Duration(days: 1)),
        levelIds: const [1, 2, 3, 4, 5, 6, 7],
      );
      expect(info.status, TournamentStatus.ended);
      expect(info.isActive, isFalse);
    });
  });

  // ── TournamentEntry helpers ──────────────────────────────────────────────

  group('TournamentEntry', () {
    final entry = TournamentEntry(
      uid: 'user1',
      displayName: 'Alice',
      totalScore: 900,
      levelScores: {'3': 300, '7': 600},
    );

    test('hasCompletedLevel returns true for completed levels', () {
      expect(entry.hasCompletedLevel(3), isTrue);
      expect(entry.hasCompletedLevel(7), isTrue);
    });

    test('hasCompletedLevel returns false for uncompleted levels', () {
      expect(entry.hasCompletedLevel(5), isFalse);
    });

    test('scoreForLevel returns correct score', () {
      expect(entry.scoreForLevel(3), 300);
      expect(entry.scoreForLevel(7), 600);
    });

    test('scoreForLevel returns 0 for missing level', () {
      expect(entry.scoreForLevel(99), 0);
    });

    test('levelsCompleted matches levelScores.length', () {
      expect(entry.levelsCompleted, 2);
    });
  });

  // ── computeTournamentLevelIds ────────────────────────────────────────────

  group('TournamentService.computeTournamentLevelIds', () {
    /// Build a synthetic level list: 30 easy, 25 medium, 5 hard.
    List<Level> _makeLevels() {
      final levels = <Level>[];
      for (int i = 1; i <= 60; i++) {
        final difficulty = i <= 30
            ? 1
            : i <= 55
                ? 2
                : 3;
        levels.add(
          Level(
            id: i,
            startWord: const ['S', 'T', 'A', 'R', 'T'],
            endWord: const ['E', 'N', 'D'],
            solution: const ['START', 'END'],
            clues: const [],
            startClue: '',
            endClue: '',
            difficulty: difficulty,
          ),
        );
      }
      return levels;
    }

    test('returns exactly 7 level IDs', () {
      final levels = _makeLevels();
      final ids =
          TournamentService.computeTournamentLevelIds('2026-W08', levels);
      expect(ids.length, 7);
    });

    test('result contains exactly 3 easy, 3 medium, 1 hard level', () {
      final levels = _makeLevels();
      final ids =
          TournamentService.computeTournamentLevelIds('2026-W10', levels);
      final easy = ids.where((id) => id <= 30).length;
      final medium = ids.where((id) => id > 30 && id <= 55).length;
      final hard = ids.where((id) => id > 55).length;
      expect(easy, 3);
      expect(medium, 3);
      expect(hard, 1);
    });

    test('result is sorted ascending', () {
      final levels = _makeLevels();
      final ids =
          TournamentService.computeTournamentLevelIds('2026-W11', levels);
      final sorted = List<int>.from(ids)..sort();
      expect(ids, sorted);
    });

    test('same weekId always returns the same level IDs (deterministic)', () {
      final levels = _makeLevels();
      const weekId = '2026-W15';
      final ids1 =
          TournamentService.computeTournamentLevelIds(weekId, levels);
      final ids2 =
          TournamentService.computeTournamentLevelIds(weekId, levels);
      expect(ids1, ids2);
    });

    test('different weekIds produce different level selections', () {
      final levels = _makeLevels();
      final ids1 =
          TournamentService.computeTournamentLevelIds('2026-W01', levels);
      final ids2 =
          TournamentService.computeTournamentLevelIds('2026-W26', levels);
      // Very unlikely to be identical for two different seeds; use as a
      // probabilistic sanity check.
      expect(ids1, isNot(equals(ids2)));
    });
  });

  // ── getCurrentWeekId format ──────────────────────────────────────────────

  group('TournamentService.getCurrentWeekId', () {
    test('returns string matching YYYY-Www format', () {
      final weekId = TournamentService.getCurrentWeekId();
      final pattern = RegExp(r'^\d{4}-W\d{2}$');
      expect(pattern.hasMatch(weekId), isTrue,
          reason: 'Expected format YYYY-Www, got: $weekId');
    });
  });

  // ── _isoWeekNumber via getCurrentWeekId ──────────────────────────────────
  // We can't call _isoWeekNumber directly (private), but we can verify known
  // week IDs via getMondayOfCurrentWeek + getCurrentWeekId indirectly.

  group('getMondayOfCurrentWeek', () {
    test('returned date is a Monday (weekday == 1)', () {
      final monday = TournamentService.getMondayOfCurrentWeek();
      expect(monday.weekday, DateTime.monday);
    });

    test('returned date is in UTC', () {
      final monday = TournamentService.getMondayOfCurrentWeek();
      expect(monday.isUtc, isTrue);
    });
  });
}
