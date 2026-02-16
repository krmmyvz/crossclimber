/// Result of a combo operation.
class ComboResult {
  final int currentCombo;
  final int maxCombo;
  final int comboBonus;
  final int comboPoints;

  const ComboResult({
    required this.currentCombo,
    required this.maxCombo,
    required this.comboBonus,
    required this.comboPoints,
  });
}

/// Tracks and calculates combo multipliers for consecutive correct guesses.
///
/// Combo tiers:
/// - 0–2 correct: 1.0×
/// - 3–4 correct: 1.5×
/// - 5–7 correct: 2.0×
/// - 8+ correct: 2.5×
class ComboTracker {
  /// Returns the multiplier for the given combo count.
  double getMultiplier(int currentCombo) {
    if (currentCombo < 3) return 1.0;
    if (currentCombo < 5) return 1.5;
    if (currentCombo < 8) return 2.0;
    return 2.5;
  }

  /// Increments the combo and calculates the bonus points earned.
  ComboResult increment({
    required int currentCombo,
    required int maxCombo,
    required int currentBonus,
  }) {
    final newCombo = currentCombo + 1;
    final multiplier = getMultiplier(
      currentCombo,
    ); // multiplier from pre-increment combo
    final points = (10 * multiplier).round();
    return ComboResult(
      currentCombo: newCombo,
      maxCombo: newCombo > maxCombo ? newCombo : maxCombo,
      comboBonus: currentBonus + points,
      comboPoints: points,
    );
  }

  /// Resets the combo on a wrong guess.
  ComboResult reset({required int maxCombo, required int currentBonus}) {
    return ComboResult(
      currentCombo: 0,
      maxCombo: maxCombo,
      comboBonus: currentBonus,
      comboPoints: 0,
    );
  }
}
