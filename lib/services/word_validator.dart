/// Pure word validation logic extracted from GameNotifier.
///
/// Handles single-letter-difference checks and guess correctness
/// for the word chain game mechanics.
class WordValidator {
  /// Returns true if [a] and [b] differ by exactly one character.
  /// Both strings must be the same length.
  bool isOneLetterDiff(String a, String b) {
    if (a.length != b.length) return false;
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) diff++;
    }
    return diff == 1;
  }

  /// Checks if a middle-word guess matches the target (case-insensitive).
  bool isCorrectMiddleGuess(String guess, String target) {
    return guess.toUpperCase() == target.toUpperCase();
  }

  /// Checks if a final guess (start/end word) matches the target word.
  /// Target is stored as a list of characters (e.g. ['C','O','L','D']).
  bool isCorrectFinalGuess(String guess, List<String> targetWord) {
    return guess.toUpperCase() == targetWord.join();
  }
}
