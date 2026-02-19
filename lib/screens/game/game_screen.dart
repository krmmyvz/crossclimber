import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/services/tutorial_data.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/providers/game_ui_provider.dart';
import 'package:crossclimber/providers/settings_provider.dart';
import 'package:crossclimber/providers/tutorial_provider.dart';
import 'package:crossclimber/providers/locale_provider.dart';
import 'package:crossclimber/widgets/combo_indicator.dart';
import 'package:crossclimber/services/daily_challenge_service.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/screens/level_completion_screen.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/screens/game/game_screen_dialogs.dart';
import 'package:crossclimber/screens/game/game_screen_tutorial.dart';
import 'package:crossclimber/screens/game/widgets/game_status_bar.dart';
import 'package:crossclimber/screens/game/widgets/middle_words_section.dart';
import 'package:crossclimber/screens/game/widgets/end_word_row.dart';
import 'package:crossclimber/screens/game/widgets/game_keyboard_section.dart';
import 'package:crossclimber/screens/game/widgets/hint_quick_access_bar.dart';
import 'package:crossclimber/screens/game/widgets/clue_display.dart';
import 'package:crossclimber/theme/responsive.dart';

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
        GameScreenTutorial {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _keyboardVisible = false;

  OverlayEntry? _unlockOverlayEntry;
  OverlayEntry? _comboPopupEntry;
  OverlayEntry? _phaseBannerEntry;

  @override
  void dispose() {
    disposeTutorial();
    _unlockOverlayEntry?.remove();
    _unlockOverlayEntry = null;
    _comboPopupEntry?.remove();
    _comboPopupEntry = null;
    _phaseBannerEntry?.remove();
    _phaseBannerEntry = null;
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

      // Phase transition banners
      if (previous == GamePhase.guessing && next == GamePhase.sorting) {
        _showPhaseBanner(AppLocalizations.of(context)!.phaseSortBanner);
      } else if (next == GamePhase.finalSolve) {
        _showPhaseBanner(AppLocalizations.of(context)!.phaseFinalBanner);
      }

      if (next == GamePhase.guessing && ref.read(gameUIProvider).selectedRowIndex == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(gameUIProvider.notifier).selectMiddleWord(0, _inputController.text);
            _inputController.text = ref.read(gameUIProvider).temporaryInputs['middle_0'] ?? '';
            _focusNode.requestFocus();
          }
        });
      }

      // Check tutorial when phase changes
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
        ref.read(gameUIProvider.notifier).selectMiddleWord(0, '');
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

  void _showPhaseBanner(String text) {
    _phaseBannerEntry?.remove();
    _phaseBannerEntry = null;

    _phaseBannerEntry = OverlayEntry(
      builder: (ctx) => _PhaseBannerOverlay(text: text),
    );
    Overlay.of(context).insert(_phaseBannerEntry!);

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _phaseBannerEntry?.remove();
        _phaseBannerEntry = null;
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

      Future.delayed(AnimDurations.micro, () {
        if (mounted && tutorialEntry != null) {
          final tutorialProgress = ref.read(tutorialProgressProvider);
          final currentStep = TutorialData.getStepAt(
            tutorialProgress.currentStepIndex,
          );
          if (currentStep?.id == 'guess_interactive') {
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
    final uiState = ref.watch(gameUIProvider);

    ref.listen(gameProvider.select((state) => state.isPaused), (
      previous,
      next,
    ) {
      if (next) {
        dismissTutorial();
      } else {
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

    if (gameState.phase == GamePhase.completed) {
      return _buildCompletionScreen(context, l10n, gameState, level, locale);
    }

    if (gameState.lastError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(gameProvider.notifier).clearError();
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        ref.read(gameProvider.notifier).togglePause();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: !settings.useCustomKeyboard,
        appBar: CommonAppBar(
          title: l10n.level(widget.level.id),
          heroTag: 'level_title_${widget.level.id}',
          type: AppBarType.game,
          onPausePressed: () {
            ref.read(gameProvider.notifier).togglePause();
          },
        ),
        body: gameState.isPaused
            ? buildPauseMenu(context, l10n)
            : _buildGameContent(context, l10n, gameState, level, settings, uiState),
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
    GameUIState uiState,
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
              final tileSize = Responsive.getTileSize(
                context,
                level.startWord.length,
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
                        isSelected: uiState.isTopSelected,
                        currentInput: _inputController.text,
                        tempInput: uiState.temporaryInputs['top'],
                        onSelect: () => _handleSelectEndWord(true),
                      ),
                    ),
                    VerticalSpacing.xs,
                    Container(
                      key: middleWordsKey,
                      child: MiddleWordsSection(
                        gameState: gameState,
                        level: level,
                        tileSize: tileSize,
                        selectedRowIndex: uiState.selectedRowIndex,
                        onReorder: (oldIndex, newIndex) {
                          ref
                              .read(gameProvider.notifier)
                              .reorderMiddleWords(oldIndex, newIndex);
                          onReorderCompleted();
                        },
                        onSelect: (index) => _handleSelectMiddleWord(index),
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
                        isSelected: uiState.isBottomSelected,
                        currentInput: _inputController.text,
                        tempInput: uiState.temporaryInputs['bottom'],
                        onSelect: () => _handleSelectEndWord(false),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ClueDisplay(
          key: clueKey,
          gameState: gameState,
          level: level,
          selectedRowIndex: uiState.selectedRowIndex,
          isTopSelected: uiState.isTopSelected,
          isBottomSelected: uiState.isBottomSelected,
        ),
        HintQuickAccessBar(
          selectedRowIndex: uiState.selectedRowIndex,
          onShowMarket: showMarketDialog,
          onHintUsed: () {
            ref.read(gameUIProvider.notifier).clearSelection();
            _inputController.clear();
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
              _handleInputChange(settings, level, uiState);
            }
          },
          onBackspace: () {
            if (_inputController.text.isNotEmpty) {
              _inputController.text = _inputController.text.substring(
                0,
                _inputController.text.length - 1,
              );
              _handleInputChange(settings, level, uiState);
            }
          },
          onSubmit: () {
            _handleInputSubmit(uiState);
          },
          onChanged: (value) => _handleInputChange(settings, level, uiState),
        ),
      ],
    );
  }

  void _handleInputChange(SettingsState settings, Level level, GameUIState uiState) {
    setState(() {});

    if (settings.autoCheck) {
      int? targetLength;
      if (uiState.selectedRowIndex != null) {
        targetLength = level.solution[uiState.selectedRowIndex! + 1].length;
      } else if (uiState.isTopSelected || uiState.isBottomSelected) {
        targetLength = level.startWord.length;
      }

      if (targetLength != null &&
          _inputController.text.length == targetLength) {
        Future.delayed(AnimDurations.normal, () {
          if (!mounted) return;
          _handleInputSubmit(uiState);
        });
      }
    }
  }

  void _handleInputSubmit(GameUIState uiState) {
    final value = _inputController.text;
    final notifier = ref.read(gameProvider.notifier);
    final uiNotifier = ref.read(gameUIProvider.notifier);

    if (uiState.selectedRowIndex != null) {
      notifier.submitMiddleGuess(uiState.selectedRowIndex!, value);

      final gameState = ref.read(gameProvider);
      if (gameState.lastError != 'wrong') {
        onGuessSubmitted(true);
        uiNotifier.clearSelection();
        _inputController.clear();
        _focusNode.unfocus();
      }
    } else if (uiState.isTopSelected) {
      notifier.submitFinalGuess(true, value);
      final gameState = ref.read(gameProvider);
      if (gameState.lastError != 'wrong') {
        onFinalGuessSubmitted(true, true);
        uiNotifier.clearSelection();
        _inputController.clear();
        _focusNode.unfocus();
      }
    } else if (uiState.isBottomSelected) {
      notifier.submitFinalGuess(false, value);
      final gameState = ref.read(gameProvider);
      if (gameState.lastError != 'wrong') {
        onFinalGuessSubmitted(false, true);
        uiNotifier.clearSelection();
        _inputController.clear();
        _focusNode.unfocus();
      }
    }
  }

  void _handleSelectMiddleWord(int index) {
    final uiNotifier = ref.read(gameUIProvider.notifier);
    uiNotifier.selectMiddleWord(index, _inputController.text);
    _inputController.text = ref.read(gameUIProvider).temporaryInputs['middle_$index'] ?? '';

    final tutorialProgress = ref.read(tutorialProgressProvider);
    final currentStep = TutorialData.getStepAt(tutorialProgress.currentStepIndex);
    if (currentStep?.id == 'guess_interactive') {
      hideTutorialCard();
    }

    _requestFocus();
  }

  void _handleSelectEndWord(bool isTop) {
    hideTutorialCard();
    final uiNotifier = ref.read(gameUIProvider.notifier);
    uiNotifier.selectEndWord(isTop, _inputController.text);
    _inputController.text = isTop
        ? (ref.read(gameUIProvider).temporaryInputs['top'] ?? '')
        : (ref.read(gameUIProvider).temporaryInputs['bottom'] ?? '');

    _requestFocus();
  }

  void _requestFocus() {
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

// ── Phase transition banner ───────────────────────────────────────────────────

class _PhaseBannerOverlay extends StatelessWidget {
  final String text;
  const _PhaseBannerOverlay({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      top: MediaQuery.of(context).padding.top + 64,
      left: 32,
      right: 32,
      child: ExcludeSemantics(
        child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              )
              .animate()
              .slideY(begin: -0.5, end: 0, duration: 350.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 250.ms)
              .then(delay: 1100.ms)
              .fadeOut(duration: 300.ms),
        ),
      ),       // closes Material
      ),       // closes ExcludeSemantics
    );
  }
}
