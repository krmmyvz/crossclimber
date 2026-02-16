import 'package:flutter_test/flutter_test.dart';
import 'package:crossclimber/services/undo_manager.dart';
import 'package:crossclimber/providers/game_state.dart';

UndoSnapshot _makeSnapshot(String action) => UndoSnapshot(
  middleWords: ['CORD'],
  middleWordsGuessed: [true],
  topGuess: null,
  bottomGuess: null,
  wrongAttempts: 0,
  action: action,
);

void main() {
  late UndoManager manager;

  setUp(() {
    manager = UndoManager();
  });

  group('saveSnapshot', () {
    test('adds a snapshot to empty history', () {
      final result = manager.saveSnapshot(
        history: [],
        snapshot: _makeSnapshot('action1'),
        undosUsed: 0,
        maxUndos: 5,
      );
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0].action, 'action1');
    });

    test('returns null when max undos reached', () {
      final result = manager.saveSnapshot(
        history: [],
        snapshot: _makeSnapshot('action'),
        undosUsed: 5,
        maxUndos: 5,
      );
      expect(result, isNull);
    });

    test('trims history to max 10 snapshots', () {
      final history = List.generate(10, (i) => _makeSnapshot('action$i'));
      final result = manager.saveSnapshot(
        history: history,
        snapshot: _makeSnapshot('action10'),
        undosUsed: 0,
        maxUndos: 20,
      );
      expect(result, isNotNull);
      expect(result!.length, 10);
      expect(result.first.action, 'action1'); // oldest trimmed
      expect(result.last.action, 'action10');
    });

    test('does not mutate original history list', () {
      final history = [_makeSnapshot('original')];
      manager.saveSnapshot(
        history: history,
        snapshot: _makeSnapshot('new'),
        undosUsed: 0,
        maxUndos: 5,
      );
      expect(history.length, 1); // original unchanged
    });
  });

  group('performUndo', () {
    test('restores last snapshot and increments undos used', () {
      final snapshot = UndoSnapshot(
        middleWords: ['TEST'],
        middleWordsGuessed: [true],
        topGuess: 'TOP',
        bottomGuess: null,
        wrongAttempts: 2,
        action: 'Guessed word',
      );
      final result = manager.performUndo(
        history: [snapshot],
        undosUsed: 0,
        maxUndos: 5,
      );
      expect(result, isNotNull);
      expect(result!.middleWords, ['TEST']);
      expect(result.topGuess, 'TOP');
      expect(result.wrongAttempts, 2);
      expect(result.updatedHistory, isEmpty);
      expect(result.updatedUndosUsed, 1);
    });

    test('returns null for empty history', () {
      final result = manager.performUndo(
        history: [],
        undosUsed: 0,
        maxUndos: 5,
      );
      expect(result, isNull);
    });

    test('returns null when max undos reached', () {
      final result = manager.performUndo(
        history: [_makeSnapshot('action')],
        undosUsed: 5,
        maxUndos: 5,
      );
      expect(result, isNull);
    });
  });

  group('getLastAction', () {
    test('returns last action description', () {
      final history = [_makeSnapshot('first'), _makeSnapshot('second')];
      expect(manager.getLastAction(history), 'second');
    });

    test('returns null for empty history', () {
      expect(manager.getLastAction([]), isNull);
    });
  });
}
