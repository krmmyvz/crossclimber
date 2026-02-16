/// Score and credit calculation logic extracted from GameNotifier._completeLevel.
class ScoreCalculator {
  /// Base score before penalties.
  static const int baseScore = 1000;

  /// Points deducted per second elapsed.
  static const int timePenaltyPerSecond = 2;

  /// Points deducted per wrong attempt.
  static const int wrongAttemptPenalty = 50;

  /// Points deducted per hint used.
  static const int hintPenalty = 100;

  /// Base points awarded for guessing a middle word.
  static const int middleWordPoints = 50;

  /// Base points awarded for guessing a start/end word.
  static const int finalWordPoints = 100;

  /// Calculates the final score for a completed level.
  int calculateFinalScore({
    required Duration timeElapsed,
    required int wrongAttempts,
    required int hintsUsed,
    required int comboBonus,
  }) {
    final timePenalty = timeElapsed.inSeconds * timePenaltyPerSecond;
    final wrongPenalty = wrongAttempts * wrongAttemptPenalty;
    final hintPen = hintsUsed * hintPenalty;
    final scoreBeforeBonus = (baseScore - timePenalty - wrongPenalty - hintPen)
        .clamp(0, baseScore);
    return scoreBeforeBonus + comboBonus;
  }

  /// Calculates credit reward for a completed level.
  ///
  /// Returns 0 if this is a replay (levelId < highestUnlockedLevel).
  int calculateCredits({
    required int starsEarned,
    required int levelId,
    required int hintsUsed,
    required int wrongAttempts,
    required int highestUnlockedLevel,
  }) {
    // Replayed levels award no credits to prevent farming
    if (levelId < highestUnlockedLevel) return 0;

    // Rebalanced reward system — generous for F2P experience
    final baseCredits =
        ((starsEarned == 1
                    ? 1.5
                    : starsEarned == 2
                    ? 2.5
                    : 3.5) *
                10)
            .toInt();
    final difficultyBonus = (levelId ~/ 10) * 10;
    var creditReward = baseCredits + difficultyBonus;

    // Perfect completion bonus
    if (hintsUsed == 0 && wrongAttempts == 0 && starsEarned == 3) {
      creditReward += 50;
    }

    return creditReward;
  }
}
