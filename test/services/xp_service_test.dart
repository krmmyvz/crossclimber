import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crossclimber/services/xp_service.dart';

void main() {
  group('XpService.xpForCompletion', () {
    test('3 stars on easy level (id=5) gives 150 base + 0 difficulty', () {
      expect(
        XpService.xpForCompletion(stars: 3, levelId: 5),
        150,
      );
    });

    test('2 stars on mid level (id=25) gives 100 base + 25 difficulty', () {
      expect(
        XpService.xpForCompletion(stars: 2, levelId: 25),
        125,
      );
    });

    test('1 star on hard level (id=50) gives 50 base + 50 difficulty', () {
      expect(
        XpService.xpForCompletion(stars: 1, levelId: 50),
        100,
      );
    });

    test('0 stars on expert level (id=61) gives 10 base + 75 difficulty', () {
      expect(
        XpService.xpForCompletion(stars: 0, levelId: 61),
        85,
      );
    });

    test('combo bonus adds maxCombo * 10', () {
      final withCombo = XpService.xpForCompletion(
        stars: 3,
        levelId: 5,
        maxCombo: 5,
      );
      final withoutCombo = XpService.xpForCompletion(
        stars: 3,
        levelId: 5,
        maxCombo: 0,
      );
      expect(withCombo - withoutCombo, 50);
    });

    test('maxCombo=0 gives same result as omitting it', () {
      final explicit = XpService.xpForCompletion(
        stars: 2,
        levelId: 10,
        maxCombo: 0,
      );
      final omitted = XpService.xpForCompletion(stars: 2, levelId: 10);
      expect(explicit, omitted);
    });
  });

  group('XpService.xpForDailyChallenge', () {
    test('base daily XP is 200', () {
      expect(XpService.xpForDailyChallenge(), 200);
    });

    test('streak bonus is streak * 20', () {
      expect(XpService.xpForDailyChallenge(streak: 3), 200 + 60);
    });

    test('streak bonus caps at 100', () {
      expect(XpService.xpForDailyChallenge(streak: 10), 200 + 100);
      expect(XpService.xpForDailyChallenge(streak: 50), 200 + 100);
    });

    test('combo bonus adds maxCombo * 10', () {
      expect(
        XpService.xpForDailyChallenge(streak: 0, maxCombo: 4),
        200 + 40,
      );
    });

    test('both streak and combo', () {
      expect(
        XpService.xpForDailyChallenge(streak: 2, maxCombo: 3),
        200 + 40 + 30,
      );
    });
  });

  group('XpService.computeRankInfo', () {
    test('0 XP is Novice rank at index 0', () {
      final info = XpService.computeRankInfo(totalXp: 0, gainedXp: 0);
      expect(info.rankIndex, 0);
      expect(info.icon, Icons.eco_rounded);
      expect(info.key, 'Novice');
      expect(info.progress, 0.0);
      expect(info.isMaxRank, false);
    });

    test('500 XP is WordStudent rank at index 1', () {
      final info = XpService.computeRankInfo(totalXp: 500, gainedXp: 0);
      expect(info.rankIndex, 1);
      expect(info.key, 'WordStudent');
      expect(info.rankThreshold, 500);
      expect(info.nextThreshold, 1500);
      expect(info.progress, 0.0); // exactly at threshold
    });

    test('1000 XP is WordStudent with 50% progress', () {
      final info = XpService.computeRankInfo(totalXp: 1000, gainedXp: 0);
      expect(info.rankIndex, 1);
      expect(info.progress, closeTo(0.5, 0.01));
    });

    test('80000+ XP is max rank (CrossClimber Master)', () {
      final info = XpService.computeRankInfo(totalXp: 100000, gainedXp: 0);
      expect(info.rankIndex, 9);
      expect(info.key, 'CrossClimberMaster');
      expect(info.isMaxRank, true);
      expect(info.progress, 1.0);
    });

    test('gainedXp is passed through correctly', () {
      final info = XpService.computeRankInfo(totalXp: 300, gainedXp: 150);
      expect(info.gainedXp, 150);
      expect(info.totalXp, 300);
    });

    test('progress is clamped between 0.0 and 1.0', () {
      final info = XpService.computeRankInfo(totalXp: 499, gainedXp: 0);
      expect(info.progress, greaterThanOrEqualTo(0.0));
      expect(info.progress, lessThanOrEqualTo(1.0));
    });
  });

  group('RankInfo.didRankUp', () {
    test('returns true when rank index increased', () {
      final prev = XpService.computeRankInfo(totalXp: 400, gainedXp: 0);
      final next = XpService.computeRankInfo(totalXp: 600, gainedXp: 200);
      expect(next.didRankUp(prev), true);
    });

    test('returns false when rank stays same', () {
      final prev = XpService.computeRankInfo(totalXp: 100, gainedXp: 0);
      final next = XpService.computeRankInfo(totalXp: 200, gainedXp: 100);
      expect(next.didRankUp(prev), false);
    });

    test('returns false when XP decreases (edge case)', () {
      final higher = XpService.computeRankInfo(totalXp: 600, gainedXp: 0);
      final lower = XpService.computeRankInfo(totalXp: 400, gainedXp: 0);
      expect(lower.didRankUp(higher), false);
    });
  });

  group('RankInfo.xpToNextRank', () {
    test('returns correct remaining XP', () {
      final info = XpService.computeRankInfo(totalXp: 300, gainedXp: 0);
      expect(info.xpToNextRank, 200); // 500 - 300
    });

    test('max rank returns 0', () {
      final info = XpService.computeRankInfo(totalXp: 80000, gainedXp: 0);
      expect(info.xpToNextRank, 0);
    });
  });

  group('kRankDefs', () {
    test('has exactly 10 rank definitions', () {
      expect(kRankDefs.length, 10);
    });

    test('thresholds are strictly increasing', () {
      for (int i = 1; i < kRankDefs.length; i++) {
        expect(
          kRankDefs[i].threshold,
          greaterThan(kRankDefs[i - 1].threshold),
          reason: 'Rank ${kRankDefs[i].key} threshold should be > ${kRankDefs[i - 1].key}',
        );
      }
    });

    test('first rank starts at 0 XP', () {
      expect(kRankDefs.first.threshold, 0);
    });

    test('last rank is at 80000 XP', () {
      expect(kRankDefs.last.threshold, 80000);
    });

    test('all ranks have unique keys', () {
      final keys = kRankDefs.map((d) => d.key).toSet();
      expect(keys.length, kRankDefs.length);
    });

    test('all ranks have valid icon', () {
      for (final def in kRankDefs) {
        expect(def.icon, isNotNull,
            reason: '${def.key} should have an icon');
      }
    });
  });
}
