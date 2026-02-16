import 'package:crossclimber/models/tutorial_step.dart';

/// Tutorial step definitions for the game
class TutorialData {
  /// Get all tutorial steps in order
  static List<TutorialStep> getAllSteps() {
    return [
      // 1. Welcome & Objective (Merged)
      const TutorialStep(
        id: 'intro_welcome',
        titleKey: 'tutorial_intro_welcome_title',
        descriptionKey:
            'tutorial_intro_welcome_desc', // "Welcome! Your goal is to change the start word to the end word."
        phase: TutorialPhase.introduction,
        action: TutorialAction.tapContinue,
        order: 0,
      ),

      // 2. The Rule (Short & Sweet)
      const TutorialStep(
        id: 'intro_rule',
        titleKey: 'tutorial_intro_rule_title',
        descriptionKey:
            'tutorial_intro_rule_desc', // "Change one letter at a time."
        phase: TutorialPhase.introduction,
        highlight: TutorialHighlight.middleWords,
        action: TutorialAction.tapContinue,
        order: 1,
      ),

      // 3. Interactive Guessing (Must guess to proceed)
      const TutorialStep(
        id: 'guess_interactive',
        titleKey: 'tutorial_guess_intro_title',
        descriptionKey:
            'tutorial_guess_intro_desc', // "Try it now! Tap a word and type your guess."
        phase: TutorialPhase.guessing,
        highlight: TutorialHighlight.middleWords,
        action: TutorialAction.guessWord, // Requires actual guess
        order: 2,
        allowInteractionEverywhere: true,
      ),

      // 4. First guess success congratulations
      const TutorialStep(
        id: 'guess_first_success',
        titleKey: 'tutorial_guess_success_title',
        descriptionKey: 'tutorial_guess_success_desc',
        phase: TutorialPhase.guessing,
        action: TutorialAction.tapContinue,
        order: 3,
      ),

      // 5. Sorting Intro (Merged with Action)
      const TutorialStep(
        id: 'sort_interactive',
        titleKey: 'tutorial_sort_intro_title',
        descriptionKey:
            'tutorial_sort_intro_desc', // "Great! Now drag and drop the words to put them in order."
        phase: TutorialPhase.sorting,
        highlight: TutorialHighlight.middleWords,
        action: TutorialAction.reorderWords, // Requires actual sort
        allowInteractionEverywhere: true,
        order: 4,
      ),

      // 6. Final Solve - Start
      const TutorialStep(
        id: 'final_start',
        titleKey: 'tutorial_final_start_title',
        descriptionKey:
            'tutorial_final_start_desc', // "Almost done! Guess the starting word."
        phase: TutorialPhase.finalSolve,
        highlight: TutorialHighlight.topInput,
        action: TutorialAction.guessStartWord,
        order: 5,
        allowInteractionEverywhere: true,
      ),

      // 7. Final Solve - End
      const TutorialStep(
        id: 'final_end',
        titleKey: 'tutorial_final_end_title',
        descriptionKey:
            'tutorial_final_end_desc', // "And finally, the ending word."
        phase: TutorialPhase.finalSolve,
        highlight: TutorialHighlight.bottomInput,
        action: TutorialAction.guessEndWord,
        order: 6,
        allowInteractionEverywhere: true,
      ),

      // 8. Completion
      const TutorialStep(
        id: 'complete_congrats',
        titleKey: 'tutorial_complete_congrats_title',
        descriptionKey:
            'tutorial_complete_congrats_desc', // "You did it! You're ready to climb."
        phase: TutorialPhase.completion,
        action: TutorialAction.tapContinue,
        order: 7,
      ),
    ];
  }

  /// Get steps for a specific phase
  static List<TutorialStep> getStepsForPhase(TutorialPhase phase) {
    return getAllSteps().where((step) => step.phase == phase).toList();
  }

  /// Get a specific step by ID
  static TutorialStep? getStepById(String id) {
    try {
      return getAllSteps().firstWhere((step) => step.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get total number of steps
  static int getTotalSteps() {
    return getAllSteps().length;
  }

  /// Get step at index
  static TutorialStep? getStepAt(int index) {
    final steps = getAllSteps();
    if (index >= 0 && index < steps.length) {
      return steps[index];
    }
    return null;
  }
}
