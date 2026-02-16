import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/models/tutorial_step.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/providers/tutorial_provider.dart';
import 'package:crossclimber/services/tutorial_data.dart';
import 'package:crossclimber/widgets/tutorial_overlay.dart';

/// Mixin providing tutorial functionality for GameScreen
mixin GameScreenTutorial<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  OverlayEntry? tutorialEntry;

  // We no longer track activeTutorialPhase locally, we rely on the global step
  ProviderSubscription<TutorialProgress>? tutorialSubscription;

  // Global keys for tutorial highlights
  final GlobalKey startWordKey = GlobalKey();
  final GlobalKey endWordKey = GlobalKey();
  final GlobalKey middleWordsKey = GlobalKey();
  final GlobalKey keyboardKey = GlobalKey();
  final GlobalKey hintsKey = GlobalKey();
  final GlobalKey timerKey = GlobalKey();
  final GlobalKey sortButtonKey = GlobalKey();
  final GlobalKey pauseButtonKey = GlobalKey();
  final GlobalKey comboBadgeKey = GlobalKey();
  final GlobalKey undoButtonKey = GlobalKey();
  final GlobalKey clueKey = GlobalKey();

  /// Check if tutorial should be shown
  void checkTutorial([TutorialProgress? progressOverride]) {
    final notifier = ref.read(tutorialProgressProvider.notifier);
    final TutorialProgress progress =
        progressOverride ?? ref.read(tutorialProgressProvider);

    if (!notifier.isLoaded || !progress.showTips || progress.isCompleted) {
      dismissTutorial();
      return;
    }

    final currentStep = notifier.getCurrentStep();
    if (currentStep == null) {
      dismissTutorial();
      return;
    }

    // Check if tutorial is lagging behind game phase
    final gameState = ref.read(gameProvider);

    if (_shouldSkipStepForPhase(currentStep, gameState.phase)) {
      // Tutorial is behind game progress, skip to next step
      notifier.nextStep();
      return;
    }

    // Check if step is compatible with current game phase
    if (!_isStepCompatibleWithPhase(currentStep, gameState.phase)) {
      // If not compatible (e.g. step is Sorting but game is Guessing),
      // we hide the tutorial and wait for the game to catch up.
      dismissTutorial();
      return;
    }

    // Show the step
    showTutorialStep(currentStep);
  }

  /// Check if step should be skipped based on current game phase
  bool _shouldSkipStepForPhase(TutorialStep step, GamePhase gamePhase) {
    // If we are in sorting phase, skip intro and guessing steps
    if (gamePhase == GamePhase.sorting) {
      return step.phase == TutorialPhase.introduction ||
          step.phase == TutorialPhase.guessing;
    }

    // If we are in final solve phase, skip intro, guessing and sorting steps
    if (gamePhase == GamePhase.finalSolve) {
      return step.phase == TutorialPhase.introduction ||
          step.phase == TutorialPhase.guessing ||
          step.phase == TutorialPhase.sorting;
    }

    return false;
  }

  bool _isStepCompatibleWithPhase(TutorialStep step, GamePhase gamePhase) {
    switch (step.phase) {
      case TutorialPhase.introduction:
      case TutorialPhase.completion:
        return true; // Always show intro/outro
      case TutorialPhase.guessing:
        return gamePhase == GamePhase.guessing;
      case TutorialPhase.sorting:
        return gamePhase == GamePhase.sorting;
      case TutorialPhase.finalSolve:
        return gamePhase == GamePhase.finalSolve;
    }
  }

  /// Show a specific tutorial step
  void showTutorialStep(TutorialStep step) {
    final l10n = AppLocalizations.of(context)!;

    tutorialEntry?.remove();
    tutorialEntry = OverlayEntry(
      builder: (context) => TutorialOverlay(
        step: step,
        currentStep: step.order,
        totalSteps: TutorialData.getTotalSteps(),
        highlightKey: getHighlightKey(step.highlight),
        title: getLocalizedText(l10n, step.titleKey),
        description: getLocalizedText(l10n, step.descriptionKey),
        onNext: onTutorialAction,
        onSkip: () {
          dismissTutorial();
          ref.read(tutorialProgressProvider.notifier).skipTutorial();
        },
      ),
    );

    Overlay.of(context).insert(tutorialEntry!);
  }

  /// Get localized text for tutorial key
  String getLocalizedText(AppLocalizations l10n, String key) {
    switch (key) {
      // Introduction Phase
      case 'tutorial_intro_welcome_title':
        return l10n.tutorial_intro_welcome_title;
      case 'tutorial_intro_welcome_desc':
        return l10n.tutorial_intro_welcome_desc;
      case 'tutorial_intro_objective_title':
        return l10n.tutorial_intro_objective_title;
      case 'tutorial_intro_objective_desc':
        return l10n.tutorial_intro_objective_desc;
      case 'tutorial_intro_rule_title':
        return l10n.tutorial_intro_rule_title;
      case 'tutorial_intro_rule_desc':
        return l10n.tutorial_intro_rule_desc;

      // Guessing Phase
      case 'tutorial_guess_intro_title':
        return l10n.tutorial_guess_intro_title;
      case 'tutorial_guess_intro_desc':
        return l10n.tutorial_guess_intro_desc;
      case 'tutorial_guess_keyboard_title':
        return l10n.tutorial_guess_keyboard_title;
      case 'tutorial_guess_keyboard_desc':
        return l10n.tutorial_guess_keyboard_desc;
      case 'tutorial_guess_hints_title':
        return l10n.tutorial_guess_hints_title;
      case 'tutorial_guess_hints_desc':
        return l10n.tutorial_guess_hints_desc;
      case 'tutorial_guess_timer_title':
        return l10n.tutorial_guess_timer_title;
      case 'tutorial_guess_timer_desc':
        return l10n.tutorial_guess_timer_desc;
      case 'tutorial_guess_success_title':
        return l10n.tutorial_guess_success_title;
      case 'tutorial_guess_success_desc':
        return l10n.tutorial_guess_success_desc;

      // Sorting Phase
      case 'tutorial_sort_intro_title':
        return l10n.tutorial_sort_intro_title;
      case 'tutorial_sort_intro_desc':
        return l10n.tutorial_sort_intro_desc;
      case 'tutorial_sort_action_title':
        return l10n.tutorial_sort_action_title;
      case 'tutorial_sort_action_desc':
        return l10n.tutorial_sort_action_desc;

      // Final Solve Phase
      case 'tutorial_final_intro_title':
        return l10n.tutorial_final_intro_title;
      case 'tutorial_final_intro_desc':
        return l10n.tutorial_final_intro_desc;
      case 'tutorial_final_start_title':
        return l10n.tutorial_final_start_title;
      case 'tutorial_final_start_desc':
        return l10n.tutorial_final_start_desc;
      case 'tutorial_final_end_title':
        return l10n.tutorial_final_end_title;
      case 'tutorial_final_end_desc':
        return l10n.tutorial_final_end_desc;

      // Completion Phase
      case 'tutorial_complete_congrats_title':
        return l10n.tutorial_complete_congrats_title;
      case 'tutorial_complete_congrats_desc':
        return l10n.tutorial_complete_congrats_desc;

      // Combo System
      case 'tutorial_combo_intro_title':
        return l10n.tutorial_combo_intro_title;
      case 'tutorial_combo_intro_desc':
        return l10n.tutorial_combo_intro_desc;

      default:
        return key;
    }
  }

  /// Dismiss current tutorial
  void dismissTutorial() {
    tutorialEntry?.remove();
    tutorialEntry = null;
  }

  /// Force update tutorial overlay (e.g.  /// Force rebuild of tutorial overlay
  void updateTutorial() {
    tutorialEntry?.markNeedsBuild();
  }

  /// Hide tutorial card when slot is tapped
  /// Used during guess_interactive step
  void hideTutorialCard() {
    dismissTutorial();
  }

  /// Get highlight key for tutorial step
  GlobalKey? getHighlightKey(TutorialHighlight? highlight) {
    switch (highlight) {
      case TutorialHighlight.startWord:
        return startWordKey;
      case TutorialHighlight.endWord:
        return endWordKey;
      case TutorialHighlight.middleWords:
        return middleWordsKey;
      case TutorialHighlight.keyboard:
        return keyboardKey;
      case TutorialHighlight.hints:
        return hintsKey;
      case TutorialHighlight.timer:
        return timerKey;
      case TutorialHighlight.sortButton:
        return sortButtonKey;
      case TutorialHighlight.topInput:
        return startWordKey;
      case TutorialHighlight.bottomInput:
        return endWordKey;
      case TutorialHighlight.pauseButton:
        return pauseButtonKey;
      case TutorialHighlight.combo:
        return comboBadgeKey;
      case TutorialHighlight.undo:
        return undoButtonKey;
      default:
        return null;
    }
  }

  /// Handle guess submission event
  void onGuessSubmitted(bool isCorrect) {
    if (!isCorrect) return;

    final notifier = ref.read(tutorialProgressProvider.notifier);
    final currentStep = notifier.getCurrentStep();

    // Advance to congratulations step after first successful guess
    if (currentStep?.id == 'guess_interactive') {
      notifier.nextStep();
      // Subscription will handle update and show congratulations
    } else if (currentStep?.action == TutorialAction.guessWord) {
      notifier.nextStep();
      // Subscription will handle update
    }
  }

  /// Handle reorder event
  void onReorderCompleted() {
    final notifier = ref.read(tutorialProgressProvider.notifier);
    final currentStep = notifier.getCurrentStep();

    if (currentStep?.action == TutorialAction.reorderWords) {
      notifier.nextStep();
    }
  }

  /// Handle tutorial action (Next/Continue button)
  void onTutorialAction() {
    final notifier = ref.read(tutorialProgressProvider.notifier);
    final currentStep = notifier.getCurrentStep();

    // Handle completion step
    if (currentStep?.phase == TutorialPhase.completion) {
      dismissTutorial();
      notifier.completeTutorial();
      return;
    }

    notifier.nextStep();
  }

  /// Handle final guess event
  void onFinalGuessSubmitted(bool isTop, bool isCorrect) {
    if (!isCorrect) return;

    final notifier = ref.read(tutorialProgressProvider.notifier);
    final currentStep = notifier.getCurrentStep();

    if (isTop && currentStep?.action == TutorialAction.guessStartWord) {
      notifier.nextStep();
    } else if (!isTop && currentStep?.action == TutorialAction.guessEndWord) {
      notifier.nextStep();
    }
  }

  /// Cleanup tutorial resources
  void disposeTutorial() {
    tutorialEntry?.remove();
    tutorialEntry = null;
    tutorialSubscription?.close();
  }
}
