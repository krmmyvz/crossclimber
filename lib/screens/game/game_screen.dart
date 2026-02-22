import 'dart:async';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:crossclimber/services/xp_service.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/shadows.dart';
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
import 'package:crossclimber/widgets/skeleton_loading.dart';
import 'package:crossclimber/theme/responsive.dart';
import 'package:crossclimber/services/ad_service.dart';

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
  OverlayEntry? _wrongGuessFlashEntry;
  OverlayEntry? _idleTooltipEntry;
  Timer? _idleTimer;

  late final ConfettiController _localConfettiCtrl;
  int _shakeCount = 0;

  @override
  void dispose() {
    disposeTutorial();
    _unlockOverlayEntry?.remove();
    _unlockOverlayEntry = null;
    _comboPopupEntry?.remove();
    _comboPopupEntry = null;
    _phaseBannerEntry?.remove();
    _phaseBannerEntry = null;
    _wrongGuessFlashEntry?.remove();
    _wrongGuessFlashEntry = null;
    _idleTooltipEntry?.remove();
    _idleTooltipEntry = null;
    _idleTimer?.cancel();
    _localConfettiCtrl.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _localConfettiCtrl = ConfettiController(
      duration: AnimDurations.slower,
    );

    // Listen to wrong attempts → red flash + screen shake
    ref.listenManual(gameProvider.select((s) => s.wrongAttempts), (
      previous,
      next,
    ) {
      if (!mounted) return;
      if (next > (previous ?? 0)) {
        setState(() => _shakeCount++);
        _showWrongGuessFlash();
      }
    });

    // Listen to correct guesses → local confetti
    ref.listenManual(
      gameProvider.select((s) => s.middleWordsGuessed.where((g) => g).length),
      (previous, next) {
        if (!mounted) return;
        if (next > (previous ?? 0)) {
          _showLocalConfetti();
        }
      },
    );

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

      if (next == GamePhase.guessing &&
          ref.read(gameUIProvider).selectedRowIndex == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref
                .read(gameUIProvider.notifier)
                .selectMiddleWord(0, _inputController.text);
            _inputController.text =
                ref.read(gameUIProvider).temporaryInputs['middle_0'] ?? '';
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

    // Start idle motivation timer
    _resetIdleTimer();
  }

  // ─── Idle Motivation Tooltip ────────────────────────────────────────────────

  /// Resets the idle timer. Call on any user interaction.
  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTooltipEntry?.remove();
    _idleTooltipEntry = null;
    _idleTimer = Timer(const Duration(seconds: 30), _showIdleTooltip);
  }

  void _showIdleTooltip() {
    if (!mounted) return;
    final gameState = ref.read(gameProvider);
    // Don't show if game is complete or paused
    if (gameState.phase == GamePhase.completed || gameState.isPaused) return;

    final l10n = AppLocalizations.of(context)!;
    final messages = [
      l10n.idleMotivation1,
      l10n.idleMotivation2,
      l10n.idleMotivation3,
    ];
    final message = messages[math.Random().nextInt(messages.length)];

    _idleTooltipEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: MediaQuery.of(context).size.height * 0.18,
          left: 32,
          right: 32,
          child:
              GestureDetector(
                    onTap: () {
                      _idleTooltipEntry?.remove();
                      _idleTooltipEntry = null;
                      _resetIdleTimer();
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.m,
                            vertical: Spacing.s,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.inverseSurface.withValues(alpha: Opacities.near),
                            borderRadius: RadiiBR.xxl,
                            boxShadow: AppShadows.elevation2,
                          ),
                          child: Text(
                            message,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onInverseSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: AnimDurations.normal)
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: AnimDurations.normal,
                    curve: AppCurves.spring,
                  )
                  .then(delay: const Duration(seconds: 5))
                  .fadeOut(duration: AnimDurations.normal),
        );
      },
    );
    Overlay.of(context).insert(_idleTooltipEntry!);

    // Auto-dismiss and restart timer
    Future.delayed(const Duration(seconds: 8), () {
      _idleTooltipEntry?.remove();
      _idleTooltipEntry = null;
      if (mounted) _resetIdleTimer();
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

  void _showWrongGuessFlash() {
    _wrongGuessFlashEntry?.remove();
    _wrongGuessFlashEntry = OverlayEntry(
      builder: (context) => const _WrongGuessFlashOverlay(),
    );
    Overlay.of(context).insert(_wrongGuessFlashEntry!);
    Future.delayed(AnimDurations.mediumSlow, () {
      if (mounted) {
        _wrongGuessFlashEntry?.remove();
        _wrongGuessFlashEntry = null;
      }
    });
  }

  void _showLocalConfetti() {
    _localConfettiCtrl.play();
  }

  void _showPhaseBanner(String text) {
    _phaseBannerEntry?.remove();
    _phaseBannerEntry = null;

    _phaseBannerEntry = OverlayEntry(
      builder: (ctx) => _PhaseBannerOverlay(text: text),
    );
    Overlay.of(context).insert(_phaseBannerEntry!);

    Future.delayed(AnimDurations.veryLong, () {
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
      return const Scaffold(
        body: Padding(
          padding: SpacingInsets.m,
          child: Column(
            children: [
              SkeletonCard(height: 44),
              VerticalSpacing.m,
              Expanded(child: SkeletonCard()),
              VerticalSpacing.m,
              SkeletonCard(height: 40),
              VerticalSpacing.s,
              SkeletonCard(height: 160),
            ],
          ),
        ),
      );
    }

    if (gameState.phase == GamePhase.completed) {
      return _buildCompletionScreen(context, l10n, gameState, level, locale);
    }

    if (gameState.lastError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(gameProvider.notifier).clearError();
      });
    }

    final clampedTextScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          ref.read(gameProvider.notifier).togglePause();
        },
        child: KeyboardListener(
          focusNode: FocusNode()..skipTraversal = true,
          autofocus: true,
          onKeyEvent: (event) =>
              _handleHardwareKey(event, settings, level, uiState),
          child: Listener(
            onPointerDown: (_) => _resetIdleTimer(),
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
                  : _applyShakeIfNeeded(
                      _buildGameContent(
                        context,
                        l10n,
                        gameState,
                        level,
                        settings,
                        uiState,
                      ),
                    ),
            ),
          ),
        ),
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
      // Award daily challenge XP
      final xpService = ref.read(xpServiceProvider);
      final dailyXp = XpService.xpForDailyChallenge(
        streak: 0, // streak is fetched async; base 200 XP is still fair
        maxCombo: gameState.maxCombo,
      );
      xpService.addXp(dailyXp);
      ref.invalidate(playerXpProvider);
      ref.invalidate(playerRankInfoProvider);
    }

    final isLastLevel = level.id == 60;

    // Pre-load next level: levelsProvider is already cached, this is instant.
    final nextLevelPreloaded = ref
        .watch(levelsProvider(locale))
        .maybeWhen(
          data: (levels) {
            try {
              return levels.firstWhere((l) => l.id == level.id + 1);
            } catch (_) {
              return null;
            }
          },
          orElse: () => null,
        );

    return Scaffold(
      body: SafeArea(
        child: LevelCompletionScreen(
          stars: gameState.starsEarned,
          timeElapsed: gameState.timeElapsed,
          score: gameState.score,
          creditsEarned: gameState.creditsEarned,
          maxCombo: gameState.maxCombo,
          levelId: level.id,
          isLastLevel: isLastLevel,
          nextLevelPreloaded: nextLevelPreloaded,
          onNextLevel: () => _handleNextLevel(
            context,
            level,
            locale,
            preloaded: nextLevelPreloaded,
          ),
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
    String locale, {
    Level? preloaded,
  }) async {
    Navigator.of(context).pop();

    // Show interstitial ad every N levels (skipping early levels)
    await AdService.instance.showInterstitialIfReady();

    // Use pre-loaded level if available (instant), otherwise fetch
    Level? nextLevel = preloaded;
    if (nextLevel == null) {
      try {
        final levels = await ref.read(levelsProvider(locale).future);
        nextLevel = levels.firstWhere(
          (l) => l.id == level.id + 1,
          orElse: () => throw Exception('Level not found'),
        );
      } catch (_) {
        if (context.mounted) Navigator.of(context).pop();
        return;
      }
    }

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        AppPageRoute(builder: (context) => GameScreen(level: nextLevel!)),
      );
    }
  }

  Widget _applyShakeIfNeeded(Widget child) {
    if (_shakeCount == 0) return child;
    return KeyedSubtree(
      key: ValueKey('shake_$_shakeCount'),
      child: child.animate().shake(
        duration: AnimDurations.normalSlow,
        hz: 5,
        offset: const Offset(5, 0),
        rotation: 0,
      ),
    );
  }

  Widget _buildGameBoard(
    BuildContext context,
    GameState gameState,
    Level level,
    GameUIState uiState,
  ) {
    return Expanded(
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final tileSize = Responsive.getTileSize(
                context,
                level.startWord.length,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: Spacing.m,
                  right: Spacing.m,
                  top: Spacing.s,
                  bottom: Spacing.l,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Responsive.getGameBoardMaxWidth(context),
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
                        _WordLadderConnector(
                          wordLength: level.startWord.length,
                          tileSize: tileSize,
                        ),
                        Container(
                          key: middleWordsKey,
                          child: MiddleWordsSection(
                            gameState: gameState,
                            level: level,
                            tileSize: tileSize,
                            selectedRowIndex: uiState.selectedRowIndex,
                            currentInput: _inputController.text,
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
                        _WordLadderConnector(
                          wordLength: level.startWord.length,
                          tileSize: tileSize,
                        ),
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
                  ),
                ),
              );
            },
          ),
          // Local confetti burst on correct guess
          ExcludeSemantics(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _localConfettiCtrl,
                blastDirection: math.pi / 2,
                maxBlastForce: 12,
                minBlastForce: 5,
                emissionFrequency: 0.06,
                numberOfParticles: 14,
                gravity: 0.45,
                colors: const [
                  Color(0xFF4CAF50),
                  Color(0xFF2196F3),
                  Color(0xFFFFEB3B),
                  Color(0xFFFF9800),
                  Color(0xFF9C27B0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardArea(
    GameState gameState,
    Level level,
    SettingsState settings,
    GameUIState uiState,
  ) {
    return GameKeyboardSection(
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
    );
  }

  Widget _buildGameContent(
    BuildContext context,
    AppLocalizations l10n,
    GameState gameState,
    Level level,
    SettingsState settings,
    GameUIState uiState,
  ) {
    final isLandscape = Responsive.isLandscape(context);

    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: SafeArea(
        top: false, // AppBar handles top
        child: isLandscape
            ? _buildLandscapeLayout(gameState, level, settings, uiState)
            : _buildPortraitLayout(gameState, level, settings, uiState),
      ),
    );
  }

  Widget _buildPortraitLayout(
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
        _buildGameBoard(context, gameState, level, uiState),
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
        _buildKeyboardArea(gameState, level, settings, uiState),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    GameState gameState,
    Level level,
    SettingsState settings,
    GameUIState uiState,
  ) {
    return Row(
      children: [
        // Left side: Game board + status + clue + hints
        Flexible(
          flex: 55,
          child: Column(
            children: [
              GameStatusBar(
                gameState: gameState,
                timerKey: timerKey,
                comboBadgeKey: comboBadgeKey,
              ),
              _buildGameBoard(context, gameState, level, uiState),
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
            ],
          ),
        ),
        // Right side: Keyboard
        Flexible(
          flex: 45,
          child: _buildKeyboardArea(gameState, level, settings, uiState),
        ),
      ],
    );
  }

  void _handleInputChange(
    SettingsState settings,
    Level level,
    GameUIState uiState,
  ) {
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

  void _handleHardwareKey(
    KeyEvent event,
    SettingsState settings,
    Level level,
    GameUIState uiState,
  ) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    // Escape → toggle pause
    if (key == LogicalKeyboardKey.escape) {
      ref.read(gameProvider.notifier).togglePause();
      return;
    }

    // Don't process keys while paused
    if (ref.read(gameProvider).isPaused) return;

    // Enter → submit
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _handleInputSubmit(uiState);
      return;
    }

    // Backspace → delete last character (only with custom keyboard;
    // the system keyboard's TextField already handles its own backspace
    // via onChanged — processing it here too would double-delete).
    if (key == LogicalKeyboardKey.backspace && settings.useCustomKeyboard) {
      if (_inputController.text.isNotEmpty) {
        _inputController.text = _inputController.text.substring(
          0,
          _inputController.text.length - 1,
        );
        _handleInputChange(settings, level, uiState);
      }
      return;
    }

    // A-Z letter keys → add character (only with custom keyboard)
    if (settings.useCustomKeyboard) {
      final label = event.character?.toUpperCase();
      if (label != null &&
          label.length == 1 &&
          RegExp(r'[A-ZÇĞİÖŞÜ]').hasMatch(label)) {
        if (_inputController.text.length < level.startWord.length) {
          _inputController.text += label;
          _handleInputChange(settings, level, uiState);
        }
      }
    }
  }

  void _handleSelectMiddleWord(int index) {
    final uiNotifier = ref.read(gameUIProvider.notifier);
    uiNotifier.selectMiddleWord(index, _inputController.text);
    _inputController.text =
        ref.read(gameUIProvider).temporaryInputs['middle_$index'] ?? '';

    final tutorialProgress = ref.read(tutorialProgressProvider);
    final currentStep = TutorialData.getStepAt(
      tutorialProgress.currentStepIndex,
    );
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

// ── Word Ladder Connector ─────────────────────────────────────────────────────

/// Visual "rung" connector drawn between word rows to reinforce the ladder theme.
class _WordLadderConnector extends StatelessWidget {
  final int wordLength;
  final double tileSize;
  const _WordLadderConnector({
    required this.wordLength,
    required this.tileSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Each tile has horizontal padding of Spacing.xxs on each side = Spacing.xxs * 2 per tile.
    final totalWidth = wordLength * (tileSize + Spacing.xxs * 2);
    return Center(
      child: SizedBox(
        width: totalWidth,
        height: 14,
        child: CustomPaint(
          painter: _LadderConnectorPainter(
            color: theme.colorScheme.outlineVariant.withValues(alpha: Opacities.half),
          ),
        ),
      ),
    );
  }
}

class _LadderConnectorPainter extends CustomPainter {
  final Color color;
  const _LadderConnectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final leftX = size.width * 0.35;
    final rightX = size.width * 0.65;

    // Two vertical rails
    canvas.drawLine(Offset(leftX, 0), Offset(leftX, size.height), paint);
    canvas.drawLine(Offset(rightX, 0), Offset(rightX, size.height), paint);
    // Center rung
    final midY = size.height / 2;
    canvas.drawLine(Offset(leftX, midY), Offset(rightX, midY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Wrong Guess Flash Overlay ─────────────────────────────────────────────────

class _WrongGuessFlashOverlay extends StatefulWidget {
  const _WrongGuessFlashOverlay();

  @override
  State<_WrongGuessFlashOverlay> createState() =>
      _WrongGuessFlashOverlayState();
}

class _WrongGuessFlashOverlayState extends State<_WrongGuessFlashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _alpha;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AnimDurations.mediumSlow,
    );
    _alpha = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.28), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.28, end: 0.0), weight: 2),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _alpha,
      builder: (context, _) => IgnorePointer(
        child: Container(color: Colors.red.withValues(alpha: _alpha.value)),
      ),
    );
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
            child:
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: RadiiBR.xxxl,
                        boxShadow: [
                          AppShadows.colorStrong(theme.colorScheme.primary),
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
                    .slideY(
                      begin: -0.5,
                      end: 0,
                      duration: AnimDurations.normalSlow,
                      curve: AppCurves.spring,
                    )
                    .fadeIn(duration: AnimDurations.fastNormal)
                    .then(delay: AnimDurations.long)
                    .fadeOut(duration: AnimDurations.normal),
          ),
        ), // closes Material
      ), // closes ExcludeSemantics
    );
  }
}
