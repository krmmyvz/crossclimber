import 'package:flutter_test/flutter_test.dart';
import 'package:crossclimber/services/score_calculator.dart';

void main() {
  late ScoreCalculator calculator;

  setUp(() {
    calculator = ScoreCalculator();
  });

  group('calculateFinalScore', () {
    test('perfect run: no penalties, no combo bonus', () {
      final score = calculator.calculateFinalScore(
        timeElapsed: Duration.zero,
        wrongAttempts: 0,
        hintsUsed: 0,
        comboBonus: 0,
      );
      expect(score, 1000);
    });

    test('applies time penalty (2 pts/sec)', () {
      final score = calculator.calculateFinalScore(
        timeElapsed: const Duration(seconds: 60),
        wrongAttempts: 0,
        hintsUsed: 0,
        comboBonus: 0,
      );
      expect(score, 1000 - 120); // 60s * 2
    });

    test('applies wrong attempt penalty (50 pts each)', () {
      final score = calculator.calculateFinalScore(
        timeElapsed: Duration.zero,
        wrongAttempts: 3,
        hintsUsed: 0,
        comboBonus: 0,
      );
      expect(score, 1000 - 150);
    });

    test('applies hint penalty (100 pts each)', () {
      final score = calculator.calculateFinalScore(
        timeElapsed: Duration.zero,
        wrongAttempts: 0,
        hintsUsed: 2,
        comboBonus: 0,
      );
      expect(score, 1000 - 200);
    });

    test('adds combo bonus after penalties', () {
      final score = calculator.calculateFinalScore(
        timeElapsed: const Duration(seconds: 30),
        wrongAttempts: 1,
        hintsUsed: 0,
        comboBonus: 100,
      );
      // 1000 - 60 - 50 = 890 + 100 = 990
      expect(score, 990);
    });

    test('score never goes below zero before combo', () {
      final score = calculator.calculateFinalScore(
        timeElapsed: const Duration(seconds: 600), // 1200 penalty
        wrongAttempts: 10, // 500 penalty
        hintsUsed: 5, // 500 penalty
        comboBonus: 50,
      );
      // clamped to 0, then +50
      expect(score, 50);
    });

    test('combined penalties', () {
      final score = calculator.calculateFinalScore(
        timeElapsed: const Duration(minutes: 2),
        wrongAttempts: 2,
        hintsUsed: 1,
        comboBonus: 30,
      );
      // 1000 - 240 - 100 - 100 = 560 + 30 = 590
      expect(score, 590);
    });
  });

  group('calculateCredits', () {
    test('1 star: base 15 credits', () {
      final credits = calculator.calculateCredits(
        starsEarned: 1,
        levelId: 0,
        hintsUsed: 1,
        wrongAttempts: 3,
        highestUnlockedLevel: 0,
      );
      expect(credits, 15); // (1.5 * 10) = 15 + 0 difficulty
    });

    test('2 stars: base 25 credits', () {
      final credits = calculator.calculateCredits(
        starsEarned: 2,
        levelId: 0,
        hintsUsed: 0,
        wrongAttempts: 1,
        highestUnlockedLevel: 0,
      );
      expect(credits, 25);
    });

    test('3 stars: base 35 credits', () {
      final credits = calculator.calculateCredits(
        starsEarned: 3,
        levelId: 0,
        hintsUsed: 1,
        wrongAttempts: 1,
        highestUnlockedLevel: 0,
      );
      expect(credits, 35);
    });

    test('adds difficulty bonus based on level tier', () {
      final credits = calculator.calculateCredits(
        starsEarned: 1,
        levelId: 25,
        hintsUsed: 0,
        wrongAttempts: 1,
        highestUnlockedLevel: 25,
      );
      // base 15 + (25 ~/ 10) * 10 = 15 + 20 = 35
      expect(credits, 35);
    });

    test('perfect play bonus: 3 stars, no hints, no wrong', () {
      final credits = calculator.calculateCredits(
        starsEarned: 3,
        levelId: 10,
        hintsUsed: 0,
        wrongAttempts: 0,
        highestUnlockedLevel: 10,
      );
      // base 35 + difficulty 10 + perfect 50 = 95
      expect(credits, 95);
    });

    test('replayed level awards 0 credits', () {
      final credits = calculator.calculateCredits(
        starsEarned: 3,
        levelId: 5,
        hintsUsed: 0,
        wrongAttempts: 0,
        highestUnlockedLevel: 10,
      );
      expect(credits, 0);
    });
  });
}
