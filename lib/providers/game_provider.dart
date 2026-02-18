import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/services/level_repository.dart';
import 'package:crossclimber/services/progress_repository.dart';
import 'package:crossclimber/services/sound_service.dart';
import 'package:crossclimber/services/haptic_service.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/services/daily_challenge_service.dart';
import 'package:crossclimber/services/word_validator.dart';
import 'package:crossclimber/services/sorting_engine.dart';
import 'package:crossclimber/services/combo_tracker.dart';
import 'package:crossclimber/services/score_calculator.dart';
import 'package:crossclimber/services/undo_manager.dart';
import 'package:crossclimber/services/life_manager.dart';
import 'package:crossclimber/services/game_timer_service.dart';
import 'package:crossclimber/services/hint_manager.dart';
import 'package:crossclimber/providers/settings_provider.dart';

import 'package:crossclimber/services/analytics_service.dart';
import 'package:crossclimber/services/remote_config_service.dart';

// ... existing code ...

export 'game_state.dart';
import 'package:crossclimber/providers/game_state.dart';

final remoteConfigServiceProvider = Provider((ref) => RemoteConfigService());

final levelRepositoryProvider = Provider((ref) {
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  return LevelRepository(remoteConfig);
});
final progressRepositoryProvider = Provider((ref) => ProgressRepository());

final unlockedLevelProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(progressRepositoryProvider);
  return repository.getHighestUnlockedLevel();
});

/// Provider for hint stocks - can be watched and invalidated when stocks change
final hintStocksProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(progressRepositoryProvider);
  final stocks = await Future.wait([
    repository.getHintStock('revealWord'),
    repository.getHintStock('undo'),
  ]);
  return {'revealWord': stocks[0], 'undo': stocks[1]};
});

final levelsProvider = FutureProvider.family<List<Level>, String>((
  ref,
  languageCode,
) async {
  final repository = ref.watch(levelRepositoryProvider);
  return repository.loadLevels(languageCode);
});

class GameNotifier extends Notifier<GameState> {
  // External services (injected via providers)
  late final SoundService _soundService;
  late final HapticService _hapticService;
  late final StatisticsRepository _statisticsRepo;
  late final AchievementService _achievementService;
  late final DailyChallengeService _dailyChallengeService;
  late final AnalyticsService _analyticsService;

  // Extracted domain services
  final _wordValidator = WordValidator();
  late final SortingEngine _sortingEngine;
  final _comboTracker = ComboTracker();
  final _scoreCalculator = ScoreCalculator();
  final _undoManager = UndoManager();
  late final LifeManager _lifeManager;
  final _timerService = GameTimerService();
  late final HintManager _hintManager;

  // Life regeneration timer
  Timer? _lifeRegenTimer;

  @override
  GameState build() {
    // Inject services
    _soundService = ref.read(soundServiceProvider);
    _hapticService = ref.read(hapticServiceProvider);
    _statisticsRepo = ref.read(statisticsRepositoryProvider);
    _achievementService = ref.read(achievementServiceProvider);
    _dailyChallengeService = ref.read(dailyChallengeServiceProvider);
    _analyticsService = ref.read(analyticsServiceProvider);

    _sortingEngine = SortingEngine(_wordValidator);
    final progressRepo = ref.read(progressRepositoryProvider);
    _lifeManager = LifeManager(progressRepo);
    _hintManager = HintManager(progressRepo);

    ref.onDispose(() {
      _timerService.dispose();
      _lifeRegenTimer?.cancel();
    });

    // Initialize sound service logic (moved from singleton)
    // SoundService initialization is now handled by the provider if needed,
    // but here we just ensure settings are applied.

    // Watch settings and update services
    ref.listen(settingsProvider, (previous, next) {
      _soundService.setSoundEnabled(next.soundEnabled);
      _hapticService.setHapticEnabled(next.hapticEnabled);
    });

    // Initialize services with current settings
    final settings = ref.read(settingsProvider);
    _soundService.setSoundEnabled(settings.soundEnabled);
    _hapticService.setHapticEnabled(settings.hapticEnabled);

    return GameState();
  }

  void startLevel(Level level) async {
    _timerService.stop();
    final middleCount = level.solution.length - 2;

    final middleIndices = List.generate(middleCount, (i) => i + 1);
    middleIndices.shuffle();

    final shuffledMiddleWords = List.filled(middleCount, '');

    final progressRepo = ref.read(progressRepositoryProvider);
    final currentLives = await progressRepo.getLives();
    final lastRegenTime = await progressRepo.getLastLifeRegenTime();

    state = GameState(
      currentLevel: level,
      phase: GamePhase.guessing,
      middleWords: shuffledMiddleWords,
      middleWordsGuessed: List.filled(middleCount, false),
      middleWordIndices: middleIndices,
      middleWordsValidOrder: List.filled(middleCount, false),
      isTimerRunning: true,
      hintsRemaining: 3,
      undoHistory: [],
      undosUsed: 0,
      maxUndos: 5,
      currentCombo: 0,
      maxCombo: 0,
      comboBonus: 0,
      lives: currentLives,
      lastLifeRegenTime: lastRegenTime,
    );

    _timerService.start(() {
      if (!state.isTimerRunning || state.isPaused) return;
      state = state.copyWith(
        timeElapsed: state.timeElapsed + const Duration(seconds: 1),
      );
    });
    
    _analyticsService.logLevelStart(level.id, level.difficulty.toString());
    _startLifeRegenTimer();
  }

  void _startLifeRegenTimer() {
    _lifeRegenTimer?.cancel();
    _lifeRegenTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final result = await _lifeManager.checkRegeneration(
        currentLives: state.lives,
        lastRegenTime: state.lastLifeRegenTime,
      );
      if (result != null) {
        state = state.copyWith(
          lives: result.lives,
          lastLifeRegenTime: result.lastRegenTime,
        );
        _soundService.play(SoundEffect.complete);
        _hapticService.trigger(HapticType.light);
      }
    });
  }

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void _decreaseLife() async {
    if (state.lives <= 0) return;
    final result = await _lifeManager.decreaseLife();
    state = state.copyWith(
      lives: result.lives,
      lastLifeRegenTime: result.lastRegenTime,
    );
    if (result.lives == 0) {
      state = state.copyWith(isPaused: true);
      _analyticsService.logLevelFail(state.currentLevel?.id ?? 0, 'out_of_lives');
    }
  }

  Future<void> restoreLife({
    bool useCredits = false,
    int creditCost = 50,
  }) async {
    final result = await _lifeManager.restoreLife(
      useCredits: useCredits,
      creditCost: creditCost,
    );
    if (result.success) {
      state = state.copyWith(
        lives: result.lives,
        lastLifeRegenTime: result.lastRegenTime,
        isPaused: false,
      );
      _soundService.play(SoundEffect.complete);
      _hapticService.trigger(HapticType.success);
    }
  }

  Future<void> restoreAllLives({
    bool useCredits = false,
    int creditCost = 100,
  }) async {
    final result = await _lifeManager.restoreAllLives(
      useCredits: useCredits,
      creditCost: creditCost,
    );
    state = state.copyWith(
      lives: result.lives,
      lastLifeRegenTime: null,
      isPaused: false,
    );
    _soundService.play(SoundEffect.complete);
    _hapticService.trigger(HapticType.success);
  }

  void restartLevel() {
    final level = state.currentLevel;
    if (level != null) {
      startLevel(level);
    }
  }

  // Legacy hint method - reveals full word
  Future<void> useHint(int uiIndex) async {
    if (state.hintsRemaining <= 0) return;
    final level = state.currentLevel;
    if (level == null) return;

    final result = _hintManager.revealWord(
      level: level,
      middleWords: state.middleWords,
      middleWordsGuessed: state.middleWordsGuessed,
      middleWordIndices: state.middleWordIndices,
      hintsRemaining: state.hintsRemaining,
      hintsUsed: state.hintsUsed,
      uiIndex: uiIndex,
    );

    if (!result.success) return;

    state = state.copyWith(
      middleWordsGuessed: result.middleWordsGuessed,
      middleWords: result.middleWords,
      hintsRemaining: result.hintsRemaining,
      hintsUsed: result.hintsUsed,
    );

    _analyticsService.logHintUsed('basic_reveal');
    _soundService.play(SoundEffect.hint);
    _hapticService.trigger(HapticType.light);

    if (result.allGuessed) {
      _transitionToSortingOrFinalSolve();
    }
  }

  void submitMiddleGuess(int uiIndex, String guess) {
    final level = state.currentLevel;
    if (level == null) return;

    if (guess.isEmpty) {
      state = state.copyWith(lastError: 'invalidWord');
      return;
    }

    final solutionIndex = state.middleWordIndices[uiIndex];
    final targetWord = level.solution[solutionIndex];

    if (_wordValidator.isCorrectMiddleGuess(guess, targetWord)) {
      _saveUndoSnapshot('Guessed word: ${guess.toUpperCase()}');

      final newGuessed = List<bool>.from(state.middleWordsGuessed);
      newGuessed[uiIndex] = true;
      final newWords = List<String>.from(state.middleWords);
      newWords[uiIndex] = guess.toUpperCase();

      final combo = _comboTracker.increment(
        currentCombo: state.currentCombo,
        maxCombo: state.maxCombo,
        currentBonus: state.comboBonus,
      );

      final currentScore =
          state.score + ScoreCalculator.middleWordPoints + combo.comboPoints;

      state = state.copyWith(
        middleWordsGuessed: newGuessed,
        middleWords: newWords,
        lastError: null,
        currentCombo: combo.currentCombo,
        maxCombo: combo.maxCombo,
        comboBonus: combo.comboBonus,
        score: currentScore,
      );

      _soundService.play(SoundEffect.correct);
      _hapticService.trigger(HapticType.success);

      if (newGuessed.every((g) => g)) {
        _transitionToSortingOrFinalSolve();
      }
    } else {
      final combo = _comboTracker.reset(
        maxCombo: state.maxCombo,
        currentBonus: state.comboBonus,
      );
      state = state.copyWith(
        wrongAttempts: state.wrongAttempts + 1,
        lastError: 'wrong',
        currentCombo: combo.currentCombo,
      );
      _decreaseLife();
      _soundService.play(SoundEffect.wrong);
      _hapticService.trigger(HapticType.error);
    }
  }

  void reorderMiddleWords(int oldIndex, int newIndex) {
    final result = _sortingEngine.reorderWords(
      middleWords: state.middleWords,
      middleWordsGuessed: state.middleWordsGuessed,
      middleWordIndices: state.middleWordIndices,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );

    state = state.copyWith(
      middleWords: result.middleWords,
      middleWordsGuessed: result.middleWordsGuessed,
      middleWordIndices: result.middleWordIndices,
      lastError: null,
    );

    _soundService.play(SoundEffect.move);
    _hapticService.trigger(HapticType.selection);

    _validateSortingRealtime();
  }

  void _validateSortingRealtime() {
    final level = state.currentLevel;
    if (level == null || state.phase != GamePhase.sorting) return;

    final validityMap = _sortingEngine.validateOrder(
      level: level,
      middleWordIndices: state.middleWordIndices,
    );

    final allValid = validityMap.every((valid) => valid);

    state = state.copyWith(middleWordsValidOrder: validityMap, lastError: null);

    if (allValid) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (state.phase == GamePhase.sorting) {
          state = state.copyWith(phase: GamePhase.finalSolve, lastError: null);
          _soundService.play(SoundEffect.correct);
          _hapticService.trigger(HapticType.success);
        }
      });
    }
  }

  void checkSorting() {
    final level = state.currentLevel;
    if (level == null) return;

    final isValid = _sortingEngine.isFullChainValid(
      level: level,
      middleWordIndices: state.middleWordIndices,
    );

    if (isValid) {
      state = state.copyWith(phase: GamePhase.finalSolve, lastError: null);
      _soundService.play(SoundEffect.correct);
      _hapticService.trigger(HapticType.success);
    } else {
      state = state.copyWith(
        wrongAttempts: state.wrongAttempts + 1,
        lastError: 'orderIncorrect',
      );
      _soundService.play(SoundEffect.wrong);
      _hapticService.trigger(HapticType.warning);
    }
  }

  void submitFinalGuess(bool isTop, String guess) {
    final level = state.currentLevel;
    if (level == null) return;

    final targetWord = isTop ? level.startWord : level.endWord;

    if (_wordValidator.isCorrectFinalGuess(guess, targetWord)) {
      _saveUndoSnapshot(
        isTop
            ? 'Guessed start word: ${guess.toUpperCase()}'
            : 'Guessed end word: ${guess.toUpperCase()}',
      );

      final combo = _comboTracker.increment(
        currentCombo: state.currentCombo,
        maxCombo: state.maxCombo,
        currentBonus: state.comboBonus,
      );

      final currentScore =
          state.score + ScoreCalculator.finalWordPoints + combo.comboPoints;

      state = state.copyWith(
        topGuess: isTop ? guess.toUpperCase() : state.topGuess,
        bottomGuess: isTop ? state.bottomGuess : guess.toUpperCase(),
        lastError: null,
        currentCombo: combo.currentCombo,
        maxCombo: combo.maxCombo,
        comboBonus: combo.comboBonus,
        score: currentScore,
      );
      _soundService.play(SoundEffect.correct);
      _hapticService.trigger(HapticType.success);
    } else {
      final combo = _comboTracker.reset(
        maxCombo: state.maxCombo,
        currentBonus: state.comboBonus,
      );
      state = state.copyWith(
        wrongAttempts: state.wrongAttempts + 1,
        lastError: 'wrong',
        currentCombo: combo.currentCombo,
      );
      _decreaseLife();
      _soundService.play(SoundEffect.wrong);
      _hapticService.trigger(HapticType.error);
      return;
    }

    if (state.topGuess != null && state.bottomGuess != null) {
      _completeLevel();
    }
  }

  void _completeLevel() async {
    final finalScore = _scoreCalculator.calculateFinalScore(
      timeElapsed: state.timeElapsed,
      wrongAttempts: state.wrongAttempts,
      hintsUsed: state.hintsUsed,
      comboBonus: state.comboBonus,
    );

    final progressRepo = ref.read(progressRepositoryProvider);
    final currentLevelId = state.currentLevel?.id ?? 0;
    final highestUnlocked = await progressRepo.getHighestUnlockedLevel();

    final creditReward = _scoreCalculator.calculateCredits(
      starsEarned: state.starsEarned,
      levelId: currentLevelId,
      hintsUsed: state.hintsUsed,
      wrongAttempts: state.wrongAttempts,
      highestUnlockedLevel: highestUnlocked,
    );

    state = state.copyWith(
      phase: GamePhase.completed,
      isTimerRunning: false,
      score: finalScore,
      creditsEarned: creditReward,
    );

    _analyticsService.logLevelComplete(
      currentLevelId,
      state.starsEarned,
      state.timeElapsed,
      finalScore,
    );

    _soundService.play(SoundEffect.complete);
    _hapticService.trigger(HapticType.success);

    // Star sounds
    Future.delayed(const Duration(milliseconds: 500), () {
      for (int i = 0; i < state.starsEarned; i++) {
        Future.delayed(Duration(milliseconds: i * 200), () {
          _soundService.play(SoundEffect.star);
          _hapticService.trigger(HapticType.light);
        });
      }
    });

    // Save progress
    progressRepo.setHighestUnlockedLevel(currentLevelId + 1);
    progressRepo.addScore(finalScore);
    progressRepo.addCredits(creditReward);

    // Record statistics
    _statisticsRepo.recordGameComplete(
      levelId: currentLevelId,
      time: state.timeElapsed,
      stars: state.starsEarned,
      hintsUsed: state.hintsUsed,
      wrongAttempts: state.wrongAttempts,
      score: finalScore,
    );

    // Check achievements
    final stats = await _statisticsRepo.getStatistics();
    _achievementService.checkAndUnlockAchievements(
      levelsCompleted: stats.totalGamesWon,
      threeStarCount: stats.threeStarLevels,
      completionTime: state.timeElapsed,
      hintsUsed: state.hintsUsed,
      wrongAttempts: state.wrongAttempts,
      totalPlayTime: stats.totalPlayTime,
    );

    // Check daily challenge
    final dailyChallenge = await _dailyChallengeService.getTodayChallenge();
    if (!dailyChallenge.completed && dailyChallenge.levelId == currentLevelId) {
      await _dailyChallengeService.completeChallenge();
      await _dailyChallengeService.updateStreak(true);
    }

    ref.invalidate(unlockedLevelProvider);
  }

  // Advanced hint system
  Future<String?> useAdvancedHint(String hintType, int wordIndex) async {
    final level = state.currentLevel;
    if (level == null) return null;

    final result = await _hintManager.useAdvancedHint(
      level: level,
      middleWords: state.middleWords,
      middleWordsGuessed: state.middleWordsGuessed,
      middleWordIndices: state.middleWordIndices,
      hintsRemaining: state.hintsRemaining,
      hintsUsed: state.hintsUsed,
      hintType: hintType,
      wordIndex: wordIndex,
    );

    if (!result.success) return result.message;

    state = state.copyWith(
      middleWordsGuessed: result.middleWordsGuessed,
      middleWords: result.middleWords,
      hintsRemaining: result.hintsRemaining,
      hintsUsed: result.hintsUsed,
      temporaryHighlightedKeys: result.highlightedKeys,
    );

    _analyticsService.logHintUsed(hintType);
    _soundService.play(SoundEffect.hint);
    _hapticService.trigger(HapticType.light);

    // Clear highlight after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (state.temporaryHighlightedKeys.isNotEmpty) {
        state = state.copyWith(temporaryHighlightedKeys: {});
      }
    });

    if (result.allGuessed) {
      _transitionToSortingOrFinalSolve();
    }

    return result.message;
  }

  // Undo system
  void _saveUndoSnapshot(String action) {
    final newHistory = _undoManager.saveSnapshot(
      history: state.undoHistory,
      snapshot: UndoSnapshot(
        middleWords: List.from(state.middleWords),
        middleWordsGuessed: List.from(state.middleWordsGuessed),
        topGuess: state.topGuess,
        bottomGuess: state.bottomGuess,
        wrongAttempts: state.wrongAttempts,
        action: action,
      ),
      undosUsed: state.undosUsed,
      maxUndos: state.maxUndos,
    );

    if (newHistory != null) {
      state = state.copyWith(undoHistory: newHistory);
    }
  }

  void performUndo() {
    final result = _undoManager.performUndo(
      history: state.undoHistory,
      undosUsed: state.undosUsed,
      maxUndos: state.maxUndos,
    );

    if (result == null) return;

    state = state.copyWith(
      middleWords: result.middleWords,
      middleWordsGuessed: result.middleWordsGuessed,
      topGuess: result.topGuess,
      bottomGuess: result.bottomGuess,
      wrongAttempts: result.wrongAttempts,
      undoHistory: result.updatedHistory,
      undosUsed: result.updatedUndosUsed,
      lastError: null,
    );

    _soundService.play(SoundEffect.tap);
    _hapticService.trigger(HapticType.medium);
  }

  String? getLastUndoAction() {
    return _undoManager.getLastAction(state.undoHistory);
  }

  void clearError() {
    if (state.lastError != null) {
      state = state.copyWith(lastError: null);
    }
  }

  // --- Private helpers ---

  /// Transitions from guessing phase to either sorting or final solve,
  /// depending on the autoSort setting.
  void _transitionToSortingOrFinalSolve() {
    final settings = ref.read(settingsProvider);
    if (settings.autoSort) {
      state = state.copyWith(phase: GamePhase.finalSolve, lastError: null);
      _soundService.play(SoundEffect.correct);
      _hapticService.trigger(HapticType.success);
    } else {
      state = state.copyWith(phase: GamePhase.sorting);
      _validateSortingRealtime();
    }
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);
