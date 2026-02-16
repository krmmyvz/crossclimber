import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/models/tutorial_step.dart';
import 'package:crossclimber/services/tutorial_repository.dart';
import 'package:crossclimber/services/tutorial_data.dart';

final tutorialRepositoryProvider = Provider((ref) => TutorialRepository());

final tutorialProgressProvider =
    NotifierProvider<TutorialNotifier, TutorialProgress>(() {
      return TutorialNotifier();
    });

class TutorialNotifier extends Notifier<TutorialProgress> {
  late final TutorialRepository _repository;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  @override
  TutorialProgress build() {
    _repository = ref.read(tutorialRepositoryProvider);
    _loadProgress();
    return const TutorialProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _repository.loadProgress();
    _isLoaded = true;
    state = progress;
  }

  /// Check if tutorial should be shown for a phase
  bool shouldShowForPhase(TutorialPhase phase) {
    if (!_isLoaded) return false;
    return state.showTips && !state.hasSeenPhase(phase);
  }

  /// Mark current phase as seen
  Future<void> markCurrentPhaseSeen(TutorialPhase phase) async {
    await _repository.markPhaseSeen(phase);
    await _loadProgress();
  }

  /// Move to next tutorial step
  void nextStep() {
    final totalSteps = TutorialData.getTotalSteps();
    if (state.currentStepIndex < totalSteps - 1) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
      _repository.saveProgress(state);
    }
  }

  /// Move to previous tutorial step
  void previousStep() {
    if (state.currentStepIndex > 0) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
      _repository.saveProgress(state);
    }
  }

  /// Skip tutorial entirely
  Future<void> skipTutorial() async {
    await _repository.completeTutorial();
    await _loadProgress();
  }

  /// Complete the tutorial
  Future<void> completeTutorial() async {
    // Update local state immediately for UI responsiveness
    state = state.copyWith(
      isCompleted: true,
      currentStepIndex: TutorialData.getTotalSteps(),
    );

    // Persist to storage
    await _repository.completeTutorial();
    // Reload to ensure sync (optional but good for consistency)
    await _loadProgress();
  }

  /// Reset tutorial progress (for testing)
  Future<void> resetTutorial() async {
    await _repository.resetTutorial();
    await _loadProgress();
  }

  /// Toggle show tips setting
  Future<void> toggleShowTips() async {
    await _repository.toggleShowTips();
    await _loadProgress();
  }

  /// Get current tutorial step
  TutorialStep? getCurrentStep() {
    return TutorialData.getStepAt(state.currentStepIndex);
  }

  /// Jump to a specific step
  void jumpToStep(int index) {
    final totalSteps = TutorialData.getTotalSteps();
    if (index >= 0 && index < totalSteps) {
      state = state.copyWith(currentStepIndex: index);
      _repository.saveProgress(state);
    }
  }

  /// Start tutorial from beginning
  void startTutorial() {
    state = state.copyWith(currentStepIndex: 0);
    _repository.saveProgress(state);
  }
}

/// Provider to check if tutorial should be shown for a specific phase
final shouldShowTutorialProvider = FutureProvider.family<bool, TutorialPhase>((
  ref,
  phase,
) async {
  final repository = ref.watch(tutorialRepositoryProvider);
  return repository.shouldShowTutorial(phase);
});
