import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/services/word_validator.dart';

/// Result of a reorder operation.
class ReorderResult {
  final List<String> middleWords;
  final List<bool> middleWordsGuessed;
  final List<int> middleWordIndices;

  const ReorderResult({
    required this.middleWords,
    required this.middleWordsGuessed,
    required this.middleWordIndices,
  });
}

/// Handles word sorting/reordering logic for the sorting phase.
///
/// Uses [WordValidator] to check one-letter-difference adjacency
/// in the word chain.
class SortingEngine {
  final WordValidator _validator;

  SortingEngine(this._validator);

  /// Reorders the middle words by moving an item from [oldIndex] to [newIndex].
  /// Returns the updated lists.
  ReorderResult reorderWords({
    required List<String> middleWords,
    required List<bool> middleWordsGuessed,
    required List<int> middleWordIndices,
    required int oldIndex,
    required int newIndex,
  }) {
    var adjustedNewIndex = newIndex;
    if (oldIndex < adjustedNewIndex) {
      adjustedNewIndex -= 1;
    }

    final newWords = List<String>.from(middleWords);
    final item = newWords.removeAt(oldIndex);
    newWords.insert(adjustedNewIndex, item);

    final newGuessed = List<bool>.from(middleWordsGuessed);
    final guessedItem = newGuessed.removeAt(oldIndex);
    newGuessed.insert(adjustedNewIndex, guessedItem);

    final newIndices = List<int>.from(middleWordIndices);
    final indexItem = newIndices.removeAt(oldIndex);
    newIndices.insert(adjustedNewIndex, indexItem);

    return ReorderResult(
      middleWords: newWords,
      middleWordsGuessed: newGuessed,
      middleWordIndices: newIndices,
    );
  }

  /// Validates each middle word's position in the chain, returning
  /// a list of booleans indicating if each position is valid
  /// (connects correctly with both neighbors).
  List<bool> validateOrder({
    required Level level,
    required List<int> middleWordIndices,
  }) {
    final currentSolutionOrder = middleWordIndices.map((solutionIndex) {
      return level.solution[solutionIndex];
    }).toList();

    final fullChain = [
      level.startWord.join(),
      ...currentSolutionOrder,
      level.endWord.join(),
    ];

    final validityMap = List.filled(currentSolutionOrder.length, false);

    for (int i = 0; i < currentSolutionOrder.length; i++) {
      final prev = i == 0 ? fullChain[0] : fullChain[i];
      final current = fullChain[i + 1];
      final next = i == currentSolutionOrder.length - 1
          ? fullChain[fullChain.length - 1]
          : fullChain[i + 2];

      final connectsWithPrev = _validator.isOneLetterDiff(prev, current);
      final connectsWithNext = _validator.isOneLetterDiff(current, next);

      validityMap[i] = connectsWithPrev && connectsWithNext;
    }

    return validityMap;
  }

  /// Checks if the entire chain is valid (each adjacent pair differs
  /// by exactly one letter). Used for auto-sort and checking final order.
  bool isFullChainValid({
    required Level level,
    required List<int> middleWordIndices,
  }) {
    final currentSolutionOrder = middleWordIndices.map((solutionIndex) {
      return level.solution[solutionIndex];
    }).toList();

    final fullChain = [
      level.startWord.join(),
      ...currentSolutionOrder,
      level.endWord.join(),
    ];

    for (int i = 0; i < fullChain.length - 1; i++) {
      if (!_validator.isOneLetterDiff(fullChain[i], fullChain[i + 1])) {
        return false;
      }
    }

    return true;
  }
}
