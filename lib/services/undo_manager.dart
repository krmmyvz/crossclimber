import 'package:crossclimber/providers/game_state.dart';

/// Result of an undo operation.
class UndoResult {
  final List<String> middleWords;
  final List<bool> middleWordsGuessed;
  final String? topGuess;
  final String? bottomGuess;
  final int wrongAttempts;
  final List<UndoSnapshot> updatedHistory;
  final int updatedUndosUsed;

  const UndoResult({
    required this.middleWords,
    required this.middleWordsGuessed,
    required this.topGuess,
    required this.bottomGuess,
    required this.wrongAttempts,
    required this.updatedHistory,
    required this.updatedUndosUsed,
  });
}

/// Manages the undo history stack for game actions.
///
/// Snapshots are stored newest-last. Max 10 snapshots kept in memory.
class UndoManager {
  static const int maxSnapshots = 10;

  /// Saves a snapshot to the history stack.
  /// Returns null if max undos have been used.
  List<UndoSnapshot>? saveSnapshot({
    required List<UndoSnapshot> history,
    required UndoSnapshot snapshot,
    required int undosUsed,
    required int maxUndos,
  }) {
    if (undosUsed >= maxUndos) return null;

    final newHistory = List<UndoSnapshot>.from(history)..add(snapshot);

    // Keep only last N snapshots to save memory
    if (newHistory.length > maxSnapshots) {
      newHistory.removeAt(0);
    }

    return newHistory;
  }

  /// Performs an undo by restoring the last snapshot.
  /// Returns null if no undo is available.
  UndoResult? performUndo({
    required List<UndoSnapshot> history,
    required int undosUsed,
    required int maxUndos,
  }) {
    if (history.isEmpty || undosUsed >= maxUndos) return null;

    final snapshot = history.last;

    return UndoResult(
      middleWords: snapshot.middleWords,
      middleWordsGuessed: snapshot.middleWordsGuessed,
      topGuess: snapshot.topGuess,
      bottomGuess: snapshot.bottomGuess,
      wrongAttempts: snapshot.wrongAttempts,
      updatedHistory: history.sublist(0, history.length - 1),
      updatedUndosUsed: undosUsed + 1,
    );
  }

  /// Returns the description of the last action that can be undone.
  String? getLastAction(List<UndoSnapshot> history) {
    if (history.isEmpty) return null;
    return history.last.action;
  }
}
