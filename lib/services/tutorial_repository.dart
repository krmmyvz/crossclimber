import 'package:shared_preferences/shared_preferences.dart';
import 'package:crossclimber/models/tutorial_step.dart';

class TutorialRepository {
  static const String _keyHasSeenIntroduction = 'tutorial_intro';
  static const String _keyHasSeenGuessing = 'tutorial_guessing';
  static const String _keyHasSeenSorting = 'tutorial_sorting';
  static const String _keyHasSeenFinalSolve = 'tutorial_final';
  static const String _keyIsCompleted = 'tutorial_completed';
  static const String _keyShowTips = 'tutorial_show_tips';
  static const String _keyCurrentStep = 'tutorial_current_step';

  /// Load tutorial progress from SharedPreferences
  Future<TutorialProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    return TutorialProgress(
      hasSeenIntroduction: prefs.getBool(_keyHasSeenIntroduction) ?? false,
      hasSeenGuessingPhase: prefs.getBool(_keyHasSeenGuessing) ?? false,
      hasSeenSortingPhase: prefs.getBool(_keyHasSeenSorting) ?? false,
      hasSeenFinalSolvePhase: prefs.getBool(_keyHasSeenFinalSolve) ?? false,
      isCompleted: prefs.getBool(_keyIsCompleted) ?? false,
      showTips: prefs.getBool(_keyShowTips) ?? true,
      currentStepIndex: prefs.getInt(_keyCurrentStep) ?? 0,
    );
  }

  /// Save tutorial progress to SharedPreferences
  Future<void> saveProgress(TutorialProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_keyHasSeenIntroduction, progress.hasSeenIntroduction);
    await prefs.setBool(_keyHasSeenGuessing, progress.hasSeenGuessingPhase);
    await prefs.setBool(_keyHasSeenSorting, progress.hasSeenSortingPhase);
    await prefs.setBool(_keyHasSeenFinalSolve, progress.hasSeenFinalSolvePhase);
    await prefs.setBool(_keyIsCompleted, progress.isCompleted);
    await prefs.setBool(_keyShowTips, progress.showTips);
    await prefs.setInt(_keyCurrentStep, progress.currentStepIndex);
  }

  /// Mark a specific phase as seen
  Future<void> markPhaseSeen(TutorialPhase phase) async {
    final progress = await loadProgress();
    TutorialProgress updatedProgress;

    switch (phase) {
      case TutorialPhase.introduction:
        updatedProgress = progress.copyWith(hasSeenIntroduction: true);
        break;
      case TutorialPhase.guessing:
        updatedProgress = progress.copyWith(hasSeenGuessingPhase: true);
        break;
      case TutorialPhase.sorting:
        updatedProgress = progress.copyWith(hasSeenSortingPhase: true);
        break;
      case TutorialPhase.finalSolve:
        updatedProgress = progress.copyWith(hasSeenFinalSolvePhase: true);
        break;
      case TutorialPhase.completion:
        updatedProgress = progress.copyWith(isCompleted: true);
        break;
    }

    await saveProgress(updatedProgress);
  }

  /// Toggle show tips setting
  Future<void> toggleShowTips() async {
    final progress = await loadProgress();
    await saveProgress(progress.copyWith(showTips: !progress.showTips));
  }

  /// Reset tutorial (for testing or user request)
  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_keyHasSeenIntroduction, false);
    await prefs.setBool(_keyHasSeenGuessing, false);
    await prefs.setBool(_keyHasSeenSorting, false);
    await prefs.setBool(_keyHasSeenFinalSolve, false);
    await prefs.setBool(_keyIsCompleted, false);
    await prefs.setInt(_keyCurrentStep, 0);
    // Don't reset showTips preference
  }

  /// Complete the entire tutorial
  Future<void> completeTutorial() async {
    final progress = await loadProgress();
    await saveProgress(progress.copyWith(
      hasSeenIntroduction: true,
      hasSeenGuessingPhase: true,
      hasSeenSortingPhase: true,
      hasSeenFinalSolvePhase: true,
      isCompleted: true,
    ));
  }

  /// Check if user should see tutorial for a specific phase
  Future<bool> shouldShowTutorial(TutorialPhase phase) async {
    final progress = await loadProgress();
    return progress.showTips && !progress.hasSeenPhase(phase);
  }
}
