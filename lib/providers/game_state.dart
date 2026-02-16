import 'package:crossclimber/models/level.dart';

/// Represents a snapshot for undo functionality
class UndoSnapshot {
  final List<String> middleWords;
  final List<bool> middleWordsGuessed;
  final String? topGuess;
  final String? bottomGuess;
  final int wrongAttempts;
  final String action;

  UndoSnapshot({
    required this.middleWords,
    required this.middleWordsGuessed,
    required this.topGuess,
    required this.bottomGuess,
    required this.wrongAttempts,
    required this.action,
  });
}

/// Game phases
enum GamePhase { guessing, sorting, finalSolve, completed }

/// Immutable game state
class GameState {
  final Level? currentLevel;
  final GamePhase phase;
  final List<String> middleWords;
  final List<bool> middleWordsGuessed;
  final List<int> middleWordIndices;
  final List<bool> middleWordsValidOrder;
  final String? topGuess;
  final String? bottomGuess;
  final Duration timeElapsed;
  final bool isTimerRunning;
  final bool isPaused;
  final int hintsRemaining;
  final int hintsUsed;
  final int wrongAttempts;
  final String? lastError;
  final int score;
  final List<UndoSnapshot> undoHistory;
  final int maxUndos;
  final int undosUsed;
  final int currentCombo;
  final int maxCombo;
  final int comboBonus;
  final int creditsEarned;
  final int lives;
  final DateTime? lastLifeRegenTime;
  final Set<String> temporaryHighlightedKeys;

  GameState({
    this.currentLevel,
    this.phase = GamePhase.guessing,
    this.middleWords = const [],
    this.middleWordsGuessed = const [],
    this.middleWordIndices = const [],
    this.middleWordsValidOrder = const [],
    this.topGuess,
    this.bottomGuess,
    this.timeElapsed = Duration.zero,
    this.isTimerRunning = false,
    this.isPaused = false,
    this.hintsRemaining = 3,
    this.hintsUsed = 0,
    this.wrongAttempts = 0,
    this.lastError,
    this.score = 0,
    this.undoHistory = const [],
    this.maxUndos = 5,
    this.undosUsed = 0,
    this.currentCombo = 0,
    this.maxCombo = 0,
    this.comboBonus = 0,
    this.creditsEarned = 0,
    this.lives = 5,
    this.lastLifeRegenTime,
    this.temporaryHighlightedKeys = const {},
  });

  GameState copyWith({
    Level? currentLevel,
    GamePhase? phase,
    List<String>? middleWords,
    List<bool>? middleWordsGuessed,
    List<int>? middleWordIndices,
    List<bool>? middleWordsValidOrder,
    String? topGuess,
    String? bottomGuess,
    Duration? timeElapsed,
    bool? isTimerRunning,
    bool? isPaused,
    int? hintsRemaining,
    int? hintsUsed,
    int? wrongAttempts,
    String? lastError,
    int? score,
    List<UndoSnapshot>? undoHistory,
    int? maxUndos,
    int? undosUsed,
    int? currentCombo,
    int? maxCombo,
    int? comboBonus,
    int? creditsEarned,
    int? lives,
    DateTime? lastLifeRegenTime,
    Set<String>? temporaryHighlightedKeys,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      phase: phase ?? this.phase,
      middleWords: middleWords ?? this.middleWords,
      middleWordsGuessed: middleWordsGuessed ?? this.middleWordsGuessed,
      middleWordIndices: middleWordIndices ?? this.middleWordIndices,
      middleWordsValidOrder:
          middleWordsValidOrder ?? this.middleWordsValidOrder,
      topGuess: topGuess ?? this.topGuess,
      bottomGuess: bottomGuess ?? this.bottomGuess,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      isPaused: isPaused ?? this.isPaused,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      wrongAttempts: wrongAttempts ?? this.wrongAttempts,
      lastError: lastError,
      score: score ?? this.score,
      undoHistory: undoHistory ?? this.undoHistory,
      maxUndos: maxUndos ?? this.maxUndos,
      undosUsed: undosUsed ?? this.undosUsed,
      currentCombo: currentCombo ?? this.currentCombo,
      maxCombo: maxCombo ?? this.maxCombo,
      comboBonus: comboBonus ?? this.comboBonus,
      creditsEarned: creditsEarned ?? this.creditsEarned,
      lives: lives ?? this.lives,
      lastLifeRegenTime: lastLifeRegenTime ?? this.lastLifeRegenTime,
      temporaryHighlightedKeys:
          temporaryHighlightedKeys ?? this.temporaryHighlightedKeys,
    );
  }

  bool get canUndo => undoHistory.isNotEmpty && undosUsed < maxUndos;

  double get comboMultiplier {
    if (currentCombo < 3) return 1.0;
    if (currentCombo < 5) return 1.5;
    if (currentCombo < 8) return 2.0;
    return 2.5;
  }

  int get starsEarned {
    if (phase != GamePhase.completed) return 0;
    final minutes = timeElapsed.inMinutes;
    if (wrongAttempts == 0 && minutes < 2) return 3;
    if (wrongAttempts <= 2 && minutes < 5) return 2;
    return 1;
  }
}
