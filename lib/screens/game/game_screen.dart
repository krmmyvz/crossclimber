import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/services/tutorial_data.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/providers/settings_provider.dart';
import 'package:crossclimber/providers/tutorial_provider.dart';
import 'package:crossclimber/providers/locale_provider.dart';
import 'package:crossclimber/widgets/custom_keyboard.dart';
import 'package:crossclimber/widgets/combo_indicator.dart';
import 'package:crossclimber/services/daily_challenge_service.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/screens/level_completion_screen.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/screens/game/game_screen_dialogs.dart';
import 'package:crossclimber/screens/game/game_screen_tutorial.dart';
import 'package:crossclimber/screens/game/game_screen_hints.dart';
import 'package:crossclimber/screens/game/widgets/game_status_bar.dart';
import 'package:crossclimber/screens/game/widgets/middle_words_section.dart';
import 'package:crossclimber/screens/game/widgets/end_word_row.dart';
import 'package:crossclimber/screens/game/widgets/game_keyboard_section.dart';

class GameScreen extends ConsumerStatefulWidget {
  final Level level;
  final bool isDailyChallenge;

  const GameScreen({
    super.key,
    required this.level,
    this.isDailyChallenge = false,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin,
        GameScreenDialogs,
        GameScreenTutorial,
        GameScreenHints {
  int? _selectedRowIndex;
  bool _isTopSelected = false;
  bool _isBottomSelected = false;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _keyboardVisible = false;

  OverlayEntry? _unlockOverlayEntry;
  OverlayEntry? _comboPopupEntry;
  final Map<String, String> _temporaryInputs = {};

  @override
  void dispose() {
    disposeTutorial();
    _unlockOverlayEntry?.remove();
    _unlockOverlayEntry = null;
    _comboPopupEntry?.remove();
    _comboPopupEntry = null;
    WidgetsBinding.instance.removeObserver(this);
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen to phase changes for unlock animations
    ref.listenManual(gameProvider.select((state) => state.phase), (
      previous,
      next,
    ) {
      if (!mounted) return;

      if (previous == GamePhase.sorting && next == GamePhase.finalSolve) {
        showUnlockAnimation(
          () => _unlockOverlayEntry,
          (entry) => _unlockOverlayEntry = entry,
        );
      }

      if (next == GamePhase.guessing && _selectedRowIndex == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedRowIndex = 0;
              _isTopSelected = false;
              _isBottomSelected = false;
            });
            _focusNode.requestFocus();
          }
        });
      }

      // Check tutorial when phase changes (e.g. guessing -> sorting)
      // If transitioning to Final Solve, wait for unlock animation
      if (next == GamePhase.finalSolve) {
        Future.delayed(AnimDurations.extraLong + AnimDurations.slowest, () {
          if (mounted) {
            checkTutorial(ref.read(tutorialProgressProvider));
          }
        });
      } else {
        checkTutorial(ref.read(tutorialProgressProvider));
      }
    });

    // Listen to lives for out-of-lives dialog
    ref.listenManual(gameProvider.select((state) => state.lives), (
      previous,
      next,
    ) {
      if (!mounted) return;
      if (previous != null && previous > 0 && next == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showOutOfLivesDialog();
          }
        });
      }
    });

    // Listen to combo changes for popups
    ref.listenManual(gameProvider.select((state) => state.currentCombo), (
      previous,
      next,
    ) {
      if (!mounted) return;
      if (next > (previous ?? 0) && next >= 2) {
        _showComboPopup();
      } else if (next == 0 && (previous ?? 0) >= 2) {
        _showComboBreak(previous!);
      }
    });

    tutorialSubscription = ref.listenManual(tutorialProgressProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;
      checkTutorial(next);
    });

    // Initial focus on first word
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedRowIndex = 0;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).startLevel(widget.level);
      checkTutorial(ref.read(tutorialProgressProvider));
    });
  }

  void _showComboPopup() {
    _comboPopupEntry?.remove();
    final gameState = ref.read(gameProvider);

    _comboPopupEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: 0,
        right: 0,
        child: Center(
          child: ComboPopup(
            comboCount: gameState.currentCombo,
            points: (10 * gameState.comboMultiplier).round(),
            multiplier: gameState.comboMultiplier,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_comboPopupEntry!);

    Future.delayed(AnimDurations.extraLong, () {
      if (mounted) {
        _comboPopupEntry?.remove();
        _comboPopupEntry = null;
      }
    });
  }

  void _showComboBreak(int lostCombo) {
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: 0,
        right: 0,
        child: Center(child: ComboBreakIndicator(lostCombo: lostCombo)),
      ),
    );

    Overlay.of(context).insert(entry);

    Future.delayed(AnimDurations.extraLong + AnimDurations.fast, () {
      if (mounted) {
        entry.remove();
      }
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = View.of(context).viewInsets.bottom;
    final keyboardVisible = bottomInset > 0;
    if (_keyboardVisible != keyboardVisible) {
      setState(() {
        _keyboardVisible = keyboardVisible;
      });

      // Update tutorial overlay to reposition highlights when keyboard changes
      // Use a small delay to ensure layout is fully settled
      Future.delayed(AnimDurations.micro, () {
        if (mounted && tutorialEntry != null) {
          // If we're in guess_interactive with card hidden, rebuild overlay
          final tutorialProgress = ref.read(tutorialProgressProvider);
          final currentStep = TutorialData.getStepAt(
            tutorialProgress.currentStepIndex,
          );
          if (currentStep?.id == 'guess_interactive') {
            // Rebuild to ensure highlights update
            hideTutorialCard();
          } else {
            updateTutorial();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gameState = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);
    final level = gameState.currentLevel;
    final locale = Localizations.localeOf(context).languageCode;

    // Listen to pause state for tutorial visibility
    // We do this in build() to ensure it persists across hot reloads
    ref.listen(gameProvider.select((state) => state.isPaused), (
      previous,
      next,
    ) {
      if (next) {
        dismissTutorial();
      } else {
        // When resuming, check if we need to show tutorial
        // We use a small delay to ensure the UI has settled
        Future.delayed(AnimDurations.micro, () {
          if (mounted && tutorialEntry == null) {
            checkTutorial();
          }
        });
      }
    });

    if (level == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show completion screen
    if (gameState.phase == GamePhase.completed) {
      return _buildCompletionScreen(context, l10n, gameState, level, locale);
    }

    // Clear error after showing shake animation
    if (gameState.lastError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(gameProvider.notifier).clearError();
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Toggle pause state regardless of current state
        // This creates a loop: Playing -> Paused -> Playing
        ref.read(gameProvider.notifier).togglePause();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: !settings.useCustomKeyboard,
        appBar: CommonAppBar(
          title: l10n.level(widget.level.id),
          // Use static hero tag to link with LevelMap
          heroTag: 'level_title_${widget.level.id}',
          type: AppBarType.game,
          onPausePressed: () {
            ref.read(gameProvider.notifier).togglePause();
          },
        ),
        body: gameState.isPaused
            ? buildPauseMenu(context, l10n)
            : _buildGameContent(context, l10n, gameState, level, settings),
      ),
    );
  }

  Widget _buildCompletionScreen(
    BuildContext context,
    AppLocalizations l10n,
    GameState gameState,
    Level level,
    String locale,
  ) {
    if (widget.isDailyChallenge) {
      DailyChallengeService().completeChallenge(
        score: gameState.score,
        time: gameState.timeElapsed,
        stars: gameState.starsEarned,
      );
    }

    final isLastLevel = level.id == 60;

    return Scaffold(
      body: SafeArea(
        child: LevelCompletionScreen(
          stars: gameState.starsEarned,
          timeElapsed: gameState.timeElapsed,
          score: gameState.score,
          creditsEarned: gameState.creditsEarned,
          levelId: level.id,
          isLastLevel: isLastLevel,
          onNextLevel: () => _handleNextLevel(context, level, locale),
          onPlayAgain: () {
            ref.read(gameProvider.notifier).restartLevel();
          },
          onMainMenu: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _handleNextLevel(
    BuildContext context,
    Level level,
    String locale,
  ) async {
    Navigator.of(context).pop();
    final nextLevelId = level.id + 1;

    try {
      final levels = await ref.read(levelsProvider(locale).future);
      final nextLevel = levels.firstWhere(
        (l) => l.id == nextLevelId,
        orElse: () => throw Exception('Level not found'),
      );

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          AppPageRoute(builder: (context) => GameScreen(level: nextLevel)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildGameContent(
    BuildContext context,
    AppLocalizations l10n,
    GameState gameState,
    Level level,
    SettingsState settings,
  ) {
    return Column(
      children: [
        GameStatusBar(
          gameState: gameState,
          timerKey: timerKey,
          comboBadgeKey: comboBadgeKey,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth - 32;
              final maxWordLength = level.startWord.length;
              final tileSize = (availableWidth / (maxWordLength + 1)).clamp(
                20.0,
                32.0,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.m,
                  vertical: Spacing.s,
                ),
                child: Column(
                  children: [
                    Container(
                      key: startWordKey,
                      child: EndWordRow(
                        isTop: true,
                        gameState: gameState,
                        level: level,
                        tileSize: tileSize,
                        isSelected: _isTopSelected,
                        currentInput: _inputController.text,
                        tempInput: _temporaryInputs['top'],
                        onSelect: () => _selectEndWord(true),
                      ),
                    ),
                    VerticalSpacing.xs,
                    Container(
                      key: middleWordsKey,
                      child: MiddleWordsSection(
                        gameState: gameState,
                        level: level,
                        tileSize: tileSize,
                        selectedRowIndex: _selectedRowIndex,
                        onReorder: (oldIndex, newIndex) {
                          ref
                              .read(gameProvider.notifier)
                              .reorderMiddleWords(oldIndex, newIndex);
                          onReorderCompleted();
                        },
                        onSelect: _selectMiddleWord,
                        onPointerDown: hideTutorialCard,
                      ),
                    ),
                    VerticalSpacing.xs,
                    Container(
                      key: endWordKey,
                      child: EndWordRow(
                        isTop: false,
                        gameState: gameState,
                        level: level,
                        tileSize: tileSize,
                        isSelected: _isBottomSelected,
                        currentInput: _inputController.text,
                        tempInput: _temporaryInputs['bottom'],
                        onSelect: () => _selectEndWord(false),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (_selectedRowIndex != null || _isTopSelected || _isBottomSelected)
          buildClueDisplay(
            context,
            l10n,
            gameState,
            level,
            key: clueKey,
            selectedRowIndex: _selectedRowIndex,
            isTopSelected: _isTopSelected,
            isBottomSelected: _isBottomSelected,
          ),
        buildHintQuickAccessBar(
          context,
          l10n,
          gameState,
          level,
          selectedRowIndex: _selectedRowIndex,
          onShowMarket: showMarketDialog,
          onHintUsed: () {
            setState(() {
              _selectedRowIndex = null;
              _inputController.clear();
            });
          },
        ),
        GameKeyboardSection(
          gameState: gameState,
          level: level,
          settings: settings,
          controller: _inputController,
          focusNode: _focusNode,
          languageCode: ref.watch(localeProvider).languageCode,
          onKeyTap: (key) {
            if (_inputController.text.length < level.startWord.length) {
              _inputController.text += key;
              _handleInputChange(settings, level);
            }
          },
          onBackspace: () {
            if (_inputController.text.isNotEmpty) {
              _inputController.text = _inputController.text.substring(
                0,
                _inputController.text.length - 1,
              );
              _handleInputChange(settings, level);
            }
          },
          onSubmit: () {
            _handleInputSubmit();
          },
          onChanged: (value) => _handleInputChange(settings, level),
        ),
      ],
    );
  }

  void _handleInputChange(SettingsState settings, Level level) {
    setState(() {});

    if (settings.autoCheck) {
      int? targetLength;
      if (_selectedRowIndex != null) {
        targetLength = level.solution[_selectedRowIndex! + 1].length;
      } else if (_isTopSelected || _isBottomSelected) {
        targetLength = level.startWord.length;
      }

      if (targetLength != null &&
          _inputController.text.length == targetLength) {
        Future.delayed(AnimDurations.normal, () {
          if (!mounted) return;
          _handleInputSubmit();
        });
      }
    }
  }

  void _handleInputSubmit() {
    final value = _inputController.text;
    if (_selectedRowIndex != null) {
      ref
          .read(gameProvider.notifier)
          .submitMiddleGuess(_selectedRowIndex!, value);

      final gameState = ref.read(gameProvider);
      if (gameState.lastError != 'wrong') {
        onGuessSubmitted(true);
        setState(() {
          _selectedRowIndex = null;
          _inputController.clear();
          _focusNode.unfocus();
        });
      }
    } else if (_isTopSelected) {
      ref.read(gameProvider.notifier).submitFinalGuess(true, value);
      final gameState = ref.read(gameProvider);
      if (gameState.lastError != 'wrong') {
        onFinalGuessSubmitted(true, true);
        setState(() {
          _isTopSelected = false;
          _inputController.clear();
          _focusNode.unfocus();
        });
      }
    } else if (_isBottomSelected) {
      ref.read(gameProvider.notifier).submitFinalGuess(false, value);
      final gameState = ref.read(gameProvider);
      if (gameState.lastError != 'wrong') {
        onFinalGuessSubmitted(false, true);
        setState(() {
          _isBottomSelected = false;
          _inputController.clear();
          _focusNode.unfocus();
        });
      }
    }
  }

  void _selectMiddleWord(int index) {
    _saveCurrentInput();

    // Hide tutorial card if on step 3 (guess_interactive) but keep highlights
    final tutorialProgress = ref.read(tutorialProgressProvider);
    final currentStep = TutorialData.getStepAt(
      tutorialProgress.currentStepIndex,
    );
    if (currentStep?.id == 'guess_interactive') {
      hideTutorialCard();
    }
    setState(() {
      _selectedRowIndex = index;
      _isTopSelected = false;
      _isBottomSelected = false;
      _inputController.text = _temporaryInputs['middle_$index'] ?? '';
    });

    // If keyboard is already open, just request focus
    // If keyboard is closed, unfocus then refocus to ensure it opens
    if (_keyboardVisible) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  void _saveCurrentInput() {
    if (_selectedRowIndex != null) {
      _temporaryInputs['middle_$_selectedRowIndex'] = _inputController.text;
    } else if (_isTopSelected) {
      _temporaryInputs['top'] = _inputController.text;
    } else if (_isBottomSelected) {
      _temporaryInputs['bottom'] = _inputController.text;
    }
  }

  void _selectEndWord(bool isTop) {
    hideTutorialCard();
    _saveCurrentInput();

    setState(() {
      _isTopSelected = isTop;
      _isBottomSelected = !isTop;
      _selectedRowIndex = null;
      _inputController.text = isTop
          ? (_temporaryInputs['top'] ?? '')
          : (_temporaryInputs['bottom'] ?? '');
    });

    // If keyboard is already open, just request focus
    // If keyboard is closed, unfocus then refocus to ensure it opens
    if (_keyboardVisible) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }
}
