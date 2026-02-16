# Tutorial System Integration Guide

## Overview
The Tutorial System provides an interactive, step-by-step guide for new players to learn the game mechanics across all three phases.

## Features Implemented

### 1. Tutorial Models
- **TutorialStep**: Defines each tutorial step with title, description, phase, highlight area, and required action
- **TutorialPhase**: Enum for game phases (introduction, guessing, sorting, finalSolve, completion)
- **TutorialHighlight**: Enum for UI elements to highlight
- **TutorialAction**: Enum for actions user needs to perform
- **TutorialProgress**: Tracks which phases have been seen and user preferences

### 2. Tutorial Data Management
- **TutorialRepository**: Manages persistence using SharedPreferences
  - Load/save tutorial progress
  - Mark phases as seen
  - Toggle show tips preference
  - Reset tutorial
  
- **TutorialData**: Provides 14 predefined tutorial steps covering:
  - 3 introduction steps
  - 4 guessing phase steps
  - 3 sorting phase steps
  - 3 final solve steps
  - 1 completion step

### 3. Tutorial Provider
- **tutorialProgressProvider**: Riverpod Notifier for tutorial state
  - Check if tutorial should show for a phase
  - Navigate between steps
  - Skip or complete tutorial
  - Reset tutorial progress

### 4. UI Components

#### TutorialOverlay
Full-screen overlay with:
- Dark background with highlighted area (spotlight effect)
- Pulsing border animation around highlighted element
- Tutorial card with title, description, and action button
- Progress bar showing step number
- Skip button
- Smooth entrance/exit animations

#### TutorialDialog
Simple dialog for quick tips:
- Title and description
- List of tutorial points with icons
- Continue and Skip buttons
- Scale and fade animations

#### TutorialTooltip
Lightweight tooltip for contextual help:
- Small notification-style tooltip
- Auto-dismiss after 5 seconds
- Slide-in animation
- Can be positioned at top of screen

## Localization

All tutorial strings are localized in both English and Turkish:

### English Keys (app_en.arb)
- `tutorial_intro_welcome_title/desc`
- `tutorial_intro_objective_title/desc`
- `tutorial_intro_rule_title/desc`
- `tutorial_guess_intro_title/desc`
- `tutorial_guess_keyboard_title/desc`
- `tutorial_guess_hints_title/desc`
- `tutorial_guess_timer_title/desc`
- `tutorial_sort_intro_title/desc`
- `tutorial_sort_action_title/desc`
- `tutorial_sort_button_title/desc`
- `tutorial_final_intro_title/desc`
- `tutorial_final_start_title/desc`
- `tutorial_final_end_title/desc`
- `tutorial_complete_congrats_title/desc`
- `skipTutorial`, `continueButton`, `showTips`, `resetTutorial`

### Turkish Keys (app_tr.arb)
All keys have Turkish translations with culturally appropriate examples.

## Integration Example

### 1. Add Tutorial Check to GameScreen

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tutorial_provider.dart';
import '../models/tutorial_step.dart';
import '../widgets/tutorial_overlay.dart';

class _GameScreenState extends ConsumerState<GameScreen> {
  OverlayEntry? _tutorialEntry;

  @override
  void initState() {
    super.initState();
    
    // Check if tutorial should be shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTutorial();
    });
  }

  Future<void> _checkTutorial() async {
    final tutorialNotifier = ref.read(tutorialProgressProvider.notifier);
    final gameState = ref.read(gameProvider);
    
    // Map game phase to tutorial phase
    TutorialPhase? tutorialPhase;
    switch (gameState.phase) {
      case GamePhase.guessing:
        tutorialPhase = TutorialPhase.guessing;
        break;
      case GamePhase.sorting:
        tutorialPhase = TutorialPhase.sorting;
        break;
      case GamePhase.finalSolve:
        tutorialPhase = TutorialPhase.finalSolve;
        break;
      default:
        return;
    }
    
    if (tutorialNotifier.shouldShowForPhase(tutorialPhase)) {
      _showTutorial(tutorialPhase);
    }
  }

  void _showTutorial(TutorialPhase phase) {
    final steps = TutorialData.getStepsForPhase(phase);
    if (steps.isEmpty) return;
    
    int currentStepIndex = 0;
    
    void showStep() {
      if (currentStepIndex >= steps.length) {
        _dismissTutorial();
        ref.read(tutorialProgressProvider.notifier)
            .markCurrentPhaseSeen(phase);
        return;
      }
      
      final step = steps[currentStepIndex];
      final l10n = AppLocalizations.of(context)!;
      
      _tutorialEntry?.remove();
      _tutorialEntry = OverlayEntry(
        builder: (context) => TutorialOverlay(
          step: step,
          currentStep: currentStepIndex,
          totalSteps: steps.length,
          highlightKey: _getHighlightKey(step.highlight),
          title: _getLocalizedTitle(l10n, step),
          description: _getLocalizedDescription(l10n, step),
          onNext: () {
            currentStepIndex++;
            showStep();
          },
          onSkip: () {
            _dismissTutorial();
            ref.read(tutorialProgressProvider.notifier).skipTutorial();
          },
        ),
      );
      
      Overlay.of(context).insert(_tutorialEntry!);
    }
    
    showStep();
  }

  void _dismissTutorial() {
    _tutorialEntry?.remove();
    _tutorialEntry = null;
  }

  GlobalKey? _getHighlightKey(TutorialHighlight? highlight) {
    // Return GlobalKeys for UI elements you want to highlight
    switch (highlight) {
      case TutorialHighlight.startWord:
        return _startWordKey;
      case TutorialHighlight.endWord:
        return _endWordKey;
      case TutorialHighlight.middleWords:
        return _middleWordsKey;
      case TutorialHighlight.keyboard:
        return _keyboardKey;
      case TutorialHighlight.hints:
        return _hintsKey;
      // ... other cases
      default:
        return null;
    }
  }

  String _getLocalizedTitle(AppLocalizations l10n, TutorialStep step) {
    // Map step.titleKey to localization method
    switch (step.titleKey) {
      case 'tutorial_guess_intro_title':
        return l10n.tutorial_guess_intro_title;
      // ... other cases
      default:
        return step.titleKey;
    }
  }

  @override
  void dispose() {
    _dismissTutorial();
    super.dispose();
  }
}
```

### 2. Add GlobalKeys to UI Elements

```dart
class _GameScreenState extends ConsumerState<GameScreen> {
  // Create keys for tutorial highlighting
  final GlobalKey _startWordKey = GlobalKey();
  final GlobalKey _endWordKey = GlobalKey();
  final GlobalKey _middleWordsKey = GlobalKey();
  final GlobalKey _keyboardKey = GlobalKey();
  final GlobalKey _hintsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add key to start word
        Container(
          key: _startWordKey,
          child: _buildStartWord(),
        ),
        
        // Add key to middle words
        Container(
          key: _middleWordsKey,
          child: _buildMiddleWords(),
        ),
        
        // Add key to keyboard
        Container(
          key: _keyboardKey,
          child: GameKeyboard(...),
        ),
      ],
    );
  }
}
```

### 3. Add Show Tips Toggle to Settings

```dart
// In settings_screen.dart
SwitchListTile(
  title: Text(l10n.showTips),
  subtitle: Text('Show tutorial hints for new features'),
  value: tutorialProgress.showTips,
  onChanged: (value) {
    ref.read(tutorialProgressProvider.notifier).toggleShowTips();
  },
)
```

### 4. Add Reset Tutorial Button to Settings (Debug)

```dart
// In settings_screen.dart (development builds only)
if (kDebugMode)
  ListTile(
    title: Text(l10n.resetTutorial),
    subtitle: Text('Reset tutorial progress for testing'),
    leading: Icon(Icons.refresh),
    onTap: () async {
      await ref.read(tutorialProgressProvider.notifier).resetTutorial();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tutorial reset!')),
      );
    },
  )
```

### 5. Show Quick Tips with TutorialTooltip

```dart
// Show a quick tip after first combo
if (gameState.currentCombo == 2 && !hasShownComboTip) {
  TutorialTooltip.showTop(
    context,
    title: 'Combo Started!',
    message: 'Keep getting correct answers to build your combo multiplier!',
    icon: Icons.whatshot,
    color: Colors.orange,
  );
  hasShownComboTip = true;
}
```

### 6. Show Feature Introduction Dialog

```dart
// Show tutorial dialog for new features
TutorialDialog.show(
  context,
  title: 'New Feature: Undo System',
  description: 'You can now undo your last actions!',
  points: [
    TutorialPoint(
      title: '5 Undos Per Level',
      description: 'You get 5 undo chances for each level',
      icon: Icons.replay,
    ),
    TutorialPoint(
      title: 'History Tracked',
      description: 'Your last 10 actions are saved',
      icon: Icons.history,
    ),
  ],
  onComplete: () {
    // Mark as seen
  },
  onSkip: () {
    // Skip this tutorial
  },
);
```

## Tutorial Flow

### First Launch
1. User starts first level
2. Introduction tutorial shows (3 steps)
3. User learns basic objective and rules

### Guessing Phase (First Time)
1. Tutorial highlights middle words
2. Shows keyboard usage
3. Explains hints and timer
4. Waits for user to guess a word

### Sorting Phase (First Time)
1. Tutorial explains sorting concept
2. Demonstrates drag and drop
3. Shows check button
4. Waits for user to sort correctly

### Final Solve Phase (First Time)
1. Tutorial explains final challenge
2. Highlights start word input
3. Highlights end word input
4. User completes the level

### Subsequent Levels
- Tutorial doesn't show again for seen phases
- Tips can be toggled off in settings
- Tutorial can be reset for review

## Customization Options

### Skip Behavior
- Users can skip tutorial at any time
- Skipping marks all phases as seen
- Can be re-enabled by toggling "Show Tips"

### Highlight Animation
- Pulsing border effect (configurable)
- Spotlight effect with dark overlay
- Smooth transitions between steps

### Tutorial Steps
- Easy to add new steps in `TutorialData`
- Localize in .arb files
- Link to specific UI elements with highlights

## Best Practices

1. **Keep It Short**: Each tutorial step should be concise (1-2 sentences)
2. **Show, Don't Tell**: Highlight the actual UI element being explained
3. **Let Users Practice**: Allow interaction during tutorial
4. **Make It Skippable**: Always provide a skip option
5. **Use Progressive Disclosure**: Show tutorials for each phase as they're encountered
6. **Respect User Choice**: Remember if user disabled tips

## Testing Checklist

- [ ] Tutorial shows on first launch
- [ ] Each phase tutorial shows at correct time
- [ ] Skip button works and marks all as seen
- [ ] Continue button advances to next step
- [ ] Highlighted elements are correctly positioned
- [ ] Animations are smooth
- [ ] Localization works for both languages
- [ ] Show Tips toggle persists
- [ ] Reset Tutorial works in debug mode
- [ ] Tutorial doesn't show again after completion
- [ ] Tutorial respects Show Tips setting

## Performance Notes

- Tutorial overlay uses CustomPainter for efficient rendering
- Animations use flutter_animate for optimized performance
- Tutorial state is cached in memory after first load
- Overlay entries are properly disposed
- Highlight positioning calculated once per step
