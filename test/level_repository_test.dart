import 'package:flutter_test/flutter_test.dart';
import 'package:crossclimber/models/level.dart';

void main() {
  test('Level.fromJson parses correctly', () {
    final json = {
      'id': 1,
      'startWord': ['C', 'O', 'L', 'D'],
      'endWord': ['W', 'A', 'R', 'M'],
      'solution': ['C', 'O', 'R', 'D', 'W', 'O', 'R', 'D', 'W', 'A', 'R', 'D'],
      'clues': ['Thin rope', 'Unit of language', 'Protective custody']
    };

    final level = Level.fromJson(json);

    expect(level.id, 1);
    expect(level.startWord, ['C', 'O', 'L', 'D']);
    expect(level.endWord, ['W', 'A', 'R', 'M']);
    expect(level.solution.length, 12);
    expect(level.clues.length, 3);
  });
}
