import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/providers/game_state.dart';
import 'package:crossclimber/services/progress_repository.dart';

/// Result of a hint operation.
class HintResult {
  final List<String> middleWords;
  final List<bool> middleWordsGuessed;
  final int hintsRemaining;
  final int hintsUsed;
  final Set<String> highlightedKeys;
  final bool allGuessed;
  final String? message;
  final bool success;

  const HintResult({
    required this.middleWords,
    required this.middleWordsGuessed,
    required this.hintsRemaining,
    required this.hintsUsed,
    this.highlightedKeys = const {},
    this.allGuessed = false,
    this.message,
    this.success = true,
  });
}

/// Manages hint usage for the game.
///
/// Supports legacy hints (using hintsRemaining counter) and
/// advanced hints (using stock from ProgressRepository).
class HintManager {
  final ProgressRepository _progressRepo;

  HintManager(this._progressRepo);

  /// Uses a legacy hint to reveal the full word at [uiIndex].
  /// Deducts from [GameState.hintsRemaining].
  HintResult revealWord({
    required Level level,
    required List<String> middleWords,
    required List<bool> middleWordsGuessed,
    required List<int> middleWordIndices,
    required int hintsRemaining,
    required int hintsUsed,
    required int uiIndex,
  }) {
    if (hintsRemaining <= 0) {
      return HintResult(
        middleWords: middleWords,
        middleWordsGuessed: middleWordsGuessed,
        hintsRemaining: hintsRemaining,
        hintsUsed: hintsUsed,
        success: false,
        message: 'No hints remaining',
      );
    }

    final solutionIndex = middleWordIndices[uiIndex];
    final targetWord = level.solution[solutionIndex];

    final newGuessed = List<bool>.from(middleWordsGuessed);
    newGuessed[uiIndex] = true;

    final newWords = List<String>.from(middleWords);
    newWords[uiIndex] = targetWord.toUpperCase();

    final allGuessed = newGuessed.every((g) => g);

    return HintResult(
      middleWords: newWords,
      middleWordsGuessed: newGuessed,
      hintsRemaining: hintsRemaining - 1,
      hintsUsed: hintsUsed + 1,
      allGuessed: allGuessed,
    );
  }

  /// Uses an advanced hint (from stock) to reveal a word.
  /// Only supports 'revealWord' hint type.
  Future<HintResult> useAdvancedHint({
    required Level level,
    required List<String> middleWords,
    required List<bool> middleWordsGuessed,
    required List<int> middleWordIndices,
    required int hintsRemaining,
    required int hintsUsed,
    required String hintType,
    required int wordIndex,
  }) async {
    if (hintType != 'revealWord') {
      return HintResult(
        middleWords: middleWords,
        middleWordsGuessed: middleWordsGuessed,
        hintsRemaining: hintsRemaining,
        hintsUsed: hintsUsed,
        success: false,
        message: 'Unsupported hint type: $hintType',
      );
    }

    final hasHint = await _progressRepo.useHintStock(hintType);

    if (!hasHint) {
      return HintResult(
        middleWords: middleWords,
        middleWordsGuessed: middleWordsGuessed,
        hintsRemaining: hintsRemaining,
        hintsUsed: hintsUsed,
        success: false,
        message: 'No hints available! Buy more from the shop.',
      );
    }

    final solutionIndex = middleWordIndices[wordIndex];
    final targetWord = level.solution[solutionIndex];

    final wordLetters = targetWord.toUpperCase().split('').toSet();

    final newGuessed = List<bool>.from(middleWordsGuessed);
    newGuessed[wordIndex] = true;

    final newWords = List<String>.from(middleWords);
    newWords[wordIndex] = targetWord.toUpperCase();

    final allGuessed = newGuessed.every((g) => g);

    return HintResult(
      middleWords: newWords,
      middleWordsGuessed: newGuessed,
      hintsRemaining: hintsRemaining,
      hintsUsed: hintsUsed + 1,
      highlightedKeys: wordLetters,
      allGuessed: allGuessed,
      message: 'Word revealed: ${targetWord.toUpperCase()}',
    );
  }
}
