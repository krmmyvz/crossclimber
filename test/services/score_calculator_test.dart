import 'package:flutter_test/flutter_test.dart';
import 'package:crossclimber/services/score_calculator.dart';

void main() {
  late ScoreCalculator calculator;

  setUp(() {
    calculator = ScoreCalculator();
  });

  group('ScoreCalculator', () {
    group('calculateFinalScore', () {
      test('calculates base score without penalties', () {
        final score = calculator.calculateFinalScore(
          timeElapsed: Duration.zero,
          wrongAttempts: 0,
          hintsUsed: 0,
          comboBonus: 0,
        );
        expect(score, ScoreCalculator.baseScore);
      });

      test('applies time penalty', () {
        final score = calculator.calculateFinalScore(
          timeElapsed: const Duration(seconds: 10),
          wrongAttempts: 0,
          hintsUsed: 0,
          comboBonus: 0,
        );
        const expectedPenalty = 10 * ScoreCalculator.timePenaltyPerSecond;
        expect(score, ScoreCalculator.baseScore - expectedPenalty);
      });

      test('applies wrong attempt penalty', () {
        final score = calculator.calculateFinalScore(
          timeElapsed: Duration.zero,
          wrongAttempts: 2,
          hintsUsed: 0,
          comboBonus: 0,
        );
        const expectedPenalty = 2 * ScoreCalculator.wrongAttemptPenalty;
        expect(score, ScoreCalculator.baseScore - expectedPenalty);
      });

      test('applies hint penalty', () {
        final score = calculator.calculateFinalScore(
          timeElapsed: Duration.zero,
          wrongAttempts: 0,
          hintsUsed: 1,
          comboBonus: 0,
        );
        expect(score, ScoreCalculator.baseScore - ScoreCalculator.hintPenalty);
      });

      test('adds combo bonus', () {
        final score = calculator.calculateFinalScore(
          timeElapsed: Duration.zero,
          wrongAttempts: 0,
          hintsUsed: 0,
          comboBonus: 500,
        );
        expect(score, ScoreCalculator.baseScore + 500);
      });

      test('clamps score to 0 when penalties are high', () {
        final score = calculator.calculateFinalScore(
          timeElapsed: const Duration(seconds: 1000), // Huge penalty
          wrongAttempts: 0,
          hintsUsed: 0,
          comboBonus: 0,
        );
        expect(score, 0); // Should not be negative
      });
    });

    group('calculateCredits', () {
      test('returns 0 for replayed levels', () {
        final credits = calculator.calculateCredits(
          starsEarned: 3,
          levelId: 5,
          hintsUsed: 0,
          wrongAttempts: 0,
          highestUnlockedLevel: 10, // Replaying level 5
        );
        expect(credits, 0);
      });

      test('calculates base credits for 1 star', () {
        // 1.5 * 10 = 15
        final credits = calculator.calculateCredits(
          starsEarned: 1,
          levelId: 1,
          hintsUsed: 1,
          wrongAttempts: 1,
          highestUnlockedLevel: 1,
        );
        // Base 15 + Difficulty (1~/10 * 10 = 0) = 15
        expect(credits, 15);
      });

      test('calculates base credits for 2 stars', () {
        // 2.5 * 10 = 25
        final credits = calculator.calculateCredits(
          starsEarned: 2,
          levelId: 1,
          hintsUsed: 1,
          wrongAttempts: 1,
          highestUnlockedLevel: 1,
        );
        expect(credits, 25);
      });

      test('calculates base credits for 3 stars', () {
        // 3.5 * 10 = 35
        final credits = calculator.calculateCredits(
          starsEarned: 3,
          levelId: 1,
          hintsUsed: 1, // Not perfect
          wrongAttempts: 1,
          highestUnlockedLevel: 1,
        );
        expect(credits, 35);
      });

      test('adds difficulty bonus', () {
        // Level 25 -> 25 ~/ 10 = 2 -> 2 * 10 = 20 bonus
        // 3 stars base = 35
        final credits = calculator.calculateCredits(
          starsEarned: 3,
          levelId: 25,
          hintsUsed: 1,
          wrongAttempts: 1,
          highestUnlockedLevel: 25,
        );
        expect(credits, 35 + 20);
      });

      test('adds perfect completion bonus', () {
        // 3 stars (35) + No hints + No wrongs (+50)
        final credits = calculator.calculateCredits(
          starsEarned: 3,
          levelId: 1,
          hintsUsed: 0,
          wrongAttempts: 0,
          highestUnlockedLevel: 1,
        );
        expect(credits, 35 + 50);
      });
    });
  });
}
