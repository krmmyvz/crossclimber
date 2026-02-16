/// Model for tutorial steps
class TutorialStep {
  final String id;
  final String titleKey; // Localization key
  final String descriptionKey; // Localization key
  final TutorialPhase phase;
  final TutorialHighlight? highlight;
  final TutorialAction? action;
  final int order;
  final bool allowInteractionEverywhere;

  const TutorialStep({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.phase,
    this.highlight,
    this.action,
    required this.order,
    this.allowInteractionEverywhere = false,
  });
}

/// Which game phase this tutorial step belongs to
enum TutorialPhase {
  introduction, // Welcome screen
  guessing, // Guessing phase
  sorting, // Sorting phase
  finalSolve, // Final solve phase
  completion, // Completion
}

/// What UI element to highlight
enum TutorialHighlight {
  startWord,
  endWord,
  middleWords,
  keyboard,
  timer,
  hints,
  sortButton,
  topInput,
  bottomInput,
  pauseButton,
  combo,
  undo,
}

/// What action user needs to perform
enum TutorialAction {
  tapContinue, // Just tap continue button
  guessWord, // Guess a middle word
  reorderWords, // Drag and drop words
  guessStartWord, // Guess the start word
  guessEndWord, // Guess the end word
  useHint, // Use a hint
  pause, // Pause the game
}

/// Tutorial progress state
class TutorialProgress {
  final bool hasSeenIntroduction;
  final bool hasSeenGuessingPhase;
  final bool hasSeenSortingPhase;
  final bool hasSeenFinalSolvePhase;
  final bool isCompleted;
  final bool showTips; // User preference for showing tips
  final int currentStepIndex;

  const TutorialProgress({
    this.hasSeenIntroduction = false,
    this.hasSeenGuessingPhase = false,
    this.hasSeenSortingPhase = false,
    this.hasSeenFinalSolvePhase = false,
    this.isCompleted = false,
    this.showTips = true,
    this.currentStepIndex = 0,
  });

  TutorialProgress copyWith({
    bool? hasSeenIntroduction,
    bool? hasSeenGuessingPhase,
    bool? hasSeenSortingPhase,
    bool? hasSeenFinalSolvePhase,
    bool? isCompleted,
    bool? showTips,
    int? currentStepIndex,
  }) {
    return TutorialProgress(
      hasSeenIntroduction: hasSeenIntroduction ?? this.hasSeenIntroduction,
      hasSeenGuessingPhase: hasSeenGuessingPhase ?? this.hasSeenGuessingPhase,
      hasSeenSortingPhase: hasSeenSortingPhase ?? this.hasSeenSortingPhase,
      hasSeenFinalSolvePhase:
          hasSeenFinalSolvePhase ?? this.hasSeenFinalSolvePhase,
      isCompleted: isCompleted ?? this.isCompleted,
      showTips: showTips ?? this.showTips,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    );
  }

  bool hasSeenPhase(TutorialPhase phase) {
    switch (phase) {
      case TutorialPhase.introduction:
        return hasSeenIntroduction;
      case TutorialPhase.guessing:
        return hasSeenGuessingPhase;
      case TutorialPhase.sorting:
        return hasSeenSortingPhase;
      case TutorialPhase.finalSolve:
        return hasSeenFinalSolvePhase;
      case TutorialPhase.completion:
        return isCompleted;
    }
  }
}
