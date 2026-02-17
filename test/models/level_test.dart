import 'package:flutter_test/flutter_test.dart';
import 'package:crossclimber/models/level.dart';

void main() {
  group('Level Model', () {
    final validJson = {
      'id': 1,
      'startWord': ['C', 'A', 'T'],
      'endWord': ['D', 'O', 'G'],
      'solution': [
        ['C', 'A', 'T'],
        ['C', 'O', 'T'],
        ['D', 'O', 'T'],
        ['D', 'O', 'G']
      ],
      'clues': ['Clue 1', 'Clue 2'],
      'difficulty': 1,
      'startClue': 'Start Clue',
      'endClue': 'End Clue',
    };

    test('fromJson creates valid Level object', () {
      final level = Level.fromJson(validJson);

      expect(level.id, 1);
      expect(level.startWord, ['C', 'A', 'T']);
      expect(level.endWord, ['D', 'O', 'G']);
      expect(level.solution.length, 4);
      expect(level.clues.length, 2);
      expect(level.difficulty, 1);
      expect(level.startClue, 'Start Clue');
      expect(level.endClue, 'End Clue');
    });

    test('fromJson handles string lists correctly', () {
      final level = Level.fromJson(validJson);
      expect(level.startWord, isA<List<String>>());
      expect(level.solution, isA<List<List<String>>>());
    });

    test('toJson converts Level object back to JSON', () {
      final level = Level.fromJson(validJson);
      final json = level.toJson();

      expect(json['id'], 1);
      expect(json['startWord'], ['C', 'A', 'T']);
      expect(json['difficulty'], 1);
    });

    test('fromJson handles missing optional fields if any', () {
      // Assuming all fields are currently required in the constructor,
      // but if we had optionals, we'd test defaults here.
      // Current model seems strict.
    });
  });
}
