import 'package:flutter_test/flutter_test.dart';
import 'package:crossclimber/services/word_validator.dart';

void main() {
  late WordValidator validator;

  setUp(() {
    validator = WordValidator();
  });

  group('isOneLetterDiff', () {
    test('returns true for single character difference', () {
      expect(validator.isOneLetterDiff('COLD', 'CORD'), isTrue);
      expect(validator.isOneLetterDiff('CORD', 'WORD'), isTrue);
      expect(validator.isOneLetterDiff('WORD', 'WARD'), isTrue);
    });

    test('returns false for identical strings', () {
      expect(validator.isOneLetterDiff('COLD', 'COLD'), isFalse);
    });

    test('returns false for two or more differences', () {
      expect(validator.isOneLetterDiff('COLD', 'WARM'), isFalse);
      expect(validator.isOneLetterDiff('COLD', 'CORE'), isFalse);
    });

    test('returns false for different lengths', () {
      expect(validator.isOneLetterDiff('COLD', 'COLDS'), isFalse);
      expect(validator.isOneLetterDiff('A', 'AB'), isFalse);
    });

    test('handles empty strings', () {
      expect(validator.isOneLetterDiff('', ''), isFalse);
    });

    test('handles single character strings', () {
      expect(validator.isOneLetterDiff('A', 'B'), isTrue);
      expect(validator.isOneLetterDiff('A', 'A'), isFalse);
    });
  });

  group('isCorrectMiddleGuess', () {
    test('matches case-insensitively', () {
      expect(validator.isCorrectMiddleGuess('cord', 'CORD'), isTrue);
      expect(validator.isCorrectMiddleGuess('CORD', 'cord'), isTrue);
      expect(validator.isCorrectMiddleGuess('Cord', 'CORD'), isTrue);
    });

    test('returns false for wrong guess', () {
      expect(validator.isCorrectMiddleGuess('COLD', 'CORD'), isFalse);
    });

    test('returns false for empty guess', () {
      expect(validator.isCorrectMiddleGuess('', 'CORD'), isFalse);
    });
  });

  group('isCorrectFinalGuess', () {
    test('matches against joined target word list', () {
      expect(
        validator.isCorrectFinalGuess('COLD', ['C', 'O', 'L', 'D']),
        isTrue,
      );
    });

    test('matches case-insensitively', () {
      expect(
        validator.isCorrectFinalGuess('cold', ['C', 'O', 'L', 'D']),
        isTrue,
      );
    });

    test('returns false for wrong guess', () {
      expect(
        validator.isCorrectFinalGuess('WARM', ['C', 'O', 'L', 'D']),
        isFalse,
      );
    });
  });
}
