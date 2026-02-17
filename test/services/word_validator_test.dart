import 'package:flutter_test/flutter_test.dart';
import 'package:crossclimber/services/word_validator.dart';

void main() {
  late WordValidator validator;

  setUp(() {
    validator = WordValidator();
  });

  group('WordValidator', () {
    group('isOneLetterDiff', () {
      test('returns true for single letter difference', () {
        expect(validator.isOneLetterDiff('CAT', 'COT'), isTrue);
        expect(validator.isOneLetterDiff('LIME', 'LIKE'), isTrue);
      });

      test('returns false for identical words', () {
        expect(validator.isOneLetterDiff('CAT', 'CAT'), isFalse);
      });

      test('returns false for two or more letter differences', () {
        expect(validator.isOneLetterDiff('CAT', 'DOG'), isFalse);
        expect(validator.isOneLetterDiff('LIME', 'LATE'), isFalse);
      });

      test('returns false for different lengths', () {
        expect(validator.isOneLetterDiff('CAT', 'CATS'), isFalse);
        expect(validator.isOneLetterDiff('HELLO', 'HI'), isFalse);
      });
    });

    group('isCorrectMiddleGuess', () {
      test('returns true for exact match', () {
        expect(validator.isCorrectMiddleGuess('TEST', 'TEST'), isTrue);
      });

      test('returns true for case-insensitive match', () {
        expect(validator.isCorrectMiddleGuess('test', 'TEST'), isTrue);
        expect(validator.isCorrectMiddleGuess('Test', 'TEST'), isTrue);
      });

      test('returns false for incorrect guess', () {
        expect(validator.isCorrectMiddleGuess('WRONG', 'TEST'), isFalse);
      });
    });

    group('isCorrectFinalGuess', () {
      test('returns true when guess matches joined target list', () {
        expect(
          validator.isCorrectFinalGuess('COLD', ['C', 'O', 'L', 'D']),
          isTrue,
        );
      });

      test('returns true for case-insensitive match', () {
        expect(
          validator.isCorrectFinalGuess('cold', ['C', 'O', 'L', 'D']),
          isTrue,
        );
      });

      test('returns false for incorrect guess', () {
        expect(
          validator.isCorrectFinalGuess('WARM', ['C', 'O', 'L', 'D']),
          isFalse,
        );
      });
    });
  });
}
