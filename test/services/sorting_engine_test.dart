import 'package:flutter_test/flutter_test.dart';
import 'package:crossclimber/services/sorting_engine.dart';
import 'package:crossclimber/services/word_validator.dart';
import 'package:crossclimber/models/level.dart';

void main() {
  late SortingEngine engine;

  setUp(() {
    engine = SortingEngine(WordValidator());
  });

  // Helper: COLD → CORD → WORD → WARD → WARM chain
  Level makeLevel() => Level(
    id: 1,
    startWord: ['C', 'O', 'L', 'D'],
    endWord: ['W', 'A', 'R', 'M'],
    solution: ['COLD', 'CORD', 'WORD', 'WARD', 'WARM'],
    clues: ['Thin rope', 'Unit of language', 'Protective custody'],
    startClue: 'Not hot',
    endClue: 'Not cold',
    difficulty: 1,
  );

  group('reorderWords', () {
    test('moves item forward', () {
      final result = engine.reorderWords(
        middleWords: ['CORD', 'WORD', 'WARD'],
        middleWordsGuessed: [true, true, true],
        middleWordIndices: [1, 2, 3],
        oldIndex: 0,
        newIndex: 2,
      );
      expect(result.middleWords, ['WORD', 'CORD', 'WARD']);
      expect(result.middleWordIndices, [2, 1, 3]);
    });

    test('moves item backward', () {
      final result = engine.reorderWords(
        middleWords: ['CORD', 'WORD', 'WARD'],
        middleWordsGuessed: [true, true, true],
        middleWordIndices: [1, 2, 3],
        oldIndex: 2,
        newIndex: 0,
      );
      expect(result.middleWords, ['WARD', 'CORD', 'WORD']);
    });

    test('does not mutate original lists', () {
      final words = ['CORD', 'WORD', 'WARD'];
      final indices = [1, 2, 3];
      engine.reorderWords(
        middleWords: words,
        middleWordsGuessed: [true, true, true],
        middleWordIndices: indices,
        oldIndex: 0,
        newIndex: 2,
      );
      expect(words, ['CORD', 'WORD', 'WARD']);
      expect(indices, [1, 2, 3]);
    });
  });

  group('validateOrder', () {
    test('all valid for correct order', () {
      final level = makeLevel();
      // Correct middle order: indices [1,2,3] → CORD, WORD, WARD
      final validity = engine.validateOrder(
        level: level,
        middleWordIndices: [1, 2, 3],
      );
      expect(validity, [true, true, true]);
    });

    test('detects invalid positions', () {
      final level = makeLevel();
      // Swapped order: indices [3,2,1] → WARD, WORD, CORD
      // COLD→WARD: diff=3 ✗, WARD→WORD: diff=1 ✓ but COLD→WARD fails for pos 0
      final validity = engine.validateOrder(
        level: level,
        middleWordIndices: [3, 2, 1],
      );
      // At least the first position should be invalid
      expect(validity[0], isFalse);
    });
  });

  group('isFullChainValid', () {
    test('returns true for correct chain', () {
      final level = makeLevel();
      expect(
        engine.isFullChainValid(level: level, middleWordIndices: [1, 2, 3]),
        isTrue,
      );
    });

    test('returns false for incorrect chain', () {
      final level = makeLevel();
      expect(
        engine.isFullChainValid(
          level: level,
          middleWordIndices: [3, 1, 2], // wrong order
        ),
        isFalse,
      );
    });
  });
}
