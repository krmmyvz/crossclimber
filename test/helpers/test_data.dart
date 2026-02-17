import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/providers/game_state.dart';

/// Common test data factories
class TestData {
  static Level createLevel({
    int id = 1,
    List<String> startWord = const ['C', 'A', 'T'],
    List<String> endWord = const ['D', 'O', 'G'],
    int difficulty = 1,
  }) {
    return Level(
      id: id,
      startWord: startWord,
      endWord: endWord,
      solution: [
        startWord,
        ['C', 'O', 'T'],
        ['D', 'O', 'T'],
        endWord,
      ],
      clues: ['A small bed', 'A point or speck'],
      difficulty: difficulty,
      startClue: 'A small pet',
      endClue: 'Man\'s best friend',
    );
  }

  static GameState createGameState({
    Level? level,
    GamePhase phase = GamePhase.guessing,
    int lives = 5,
  }) {
    final currentLevel = level ?? createLevel();
    final middleCount = currentLevel.solution.length - 2;
    
    return GameState(
      currentLevel: currentLevel,
      phase: phase,
      middleWords: List.filled(middleCount, ''),
      middleWordsGuessed: List.filled(middleCount, false),
      middleWordIndices: List.generate(middleCount, (i) => i + 1),
      middleWordsValidOrder: List.filled(middleCount, false),
      lives: lives,
    );
  }
}
