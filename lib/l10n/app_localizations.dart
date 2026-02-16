import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CrossClimber'**
  String get appTitle;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level {levelNumber}'**
  String level(int levelNumber);

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @allLevelsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Amazing! You\'ve Completed All Levels!'**
  String get allLevelsCompleted;

  /// No description provided for @allLevelsCompletedDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'ve mastered all {totalLevels} levels! Stay tuned for more challenges coming soon.'**
  String allLevelsCompletedDesc(int totalLevels);

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @wrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong!'**
  String get wrong;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @youWon.
  ///
  /// In en, this message translates to:
  /// **'You completed the level!'**
  String get youWon;

  /// No description provided for @phase1Title.
  ///
  /// In en, this message translates to:
  /// **'Guess the Words'**
  String get phase1Title;

  /// No description provided for @phase2Title.
  ///
  /// In en, this message translates to:
  /// **'Sort the Words'**
  String get phase2Title;

  /// No description provided for @phase3Title.
  ///
  /// In en, this message translates to:
  /// **'Find Final Words'**
  String get phase3Title;

  /// No description provided for @phaseProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} / {total}'**
  String phaseProgress(int current, int total);

  /// No description provided for @wordsFound.
  ///
  /// In en, this message translates to:
  /// **'{found} / {total} words found'**
  String wordsFound(int found, int total);

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get mainMenu;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @useHint.
  ///
  /// In en, this message translates to:
  /// **'Use Hint'**
  String get useHint;

  /// No description provided for @hintsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} hints remaining'**
  String hintsRemaining(int count);

  /// No description provided for @noHintsLeft.
  ///
  /// In en, this message translates to:
  /// **'No hints left'**
  String get noHintsLeft;

  /// No description provided for @hintUsed.
  ///
  /// In en, this message translates to:
  /// **'Hint used!'**
  String get hintUsed;

  /// No description provided for @tapToGuess.
  ///
  /// In en, this message translates to:
  /// **'Tap to guess'**
  String get tapToGuess;

  /// No description provided for @enterWord.
  ///
  /// In en, this message translates to:
  /// **'Enter word'**
  String get enterWord;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get completed;

  /// No description provided for @timeElapsed.
  ///
  /// In en, this message translates to:
  /// **'Time Elapsed'**
  String get timeElapsed;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'{count} Stars'**
  String stars(int count);

  /// No description provided for @newBestTime.
  ///
  /// In en, this message translates to:
  /// **'New Best Time!'**
  String get newBestTime;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// No description provided for @checkOrder.
  ///
  /// In en, this message translates to:
  /// **'Check Order'**
  String get checkOrder;

  /// No description provided for @orderCorrect.
  ///
  /// In en, this message translates to:
  /// **'Order is correct!'**
  String get orderCorrect;

  /// No description provided for @orderIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Order is incorrect, try again'**
  String get orderIncorrect;

  /// No description provided for @invalidWord.
  ///
  /// In en, this message translates to:
  /// **'Invalid word!'**
  String get invalidWord;

  /// No description provided for @alreadyGuessed.
  ///
  /// In en, this message translates to:
  /// **'Word already guessed'**
  String get alreadyGuessed;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @showTimer.
  ///
  /// In en, this message translates to:
  /// **'Show Timer'**
  String get showTimer;

  /// No description provided for @autoCheck.
  ///
  /// In en, this message translates to:
  /// **'Auto Check'**
  String get autoCheck;

  /// No description provided for @autoCheckDesc.
  ///
  /// In en, this message translates to:
  /// **'Auto-check when you complete a word'**
  String get autoCheckDesc;

  /// No description provided for @autoSort.
  ///
  /// In en, this message translates to:
  /// **'Auto Sort'**
  String get autoSort;

  /// No description provided for @autoSortDesc.
  ///
  /// In en, this message translates to:
  /// **'Auto-sort when you find all words'**
  String get autoSortDesc;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @tutorial.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get tutorial;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @dailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// No description provided for @tutorial_intro_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CrossClimber!'**
  String get tutorial_intro_welcome_title;

  /// No description provided for @tutorial_intro_welcome_desc.
  ///
  /// In en, this message translates to:
  /// **'Learn how to play this fun word puzzle game. Connect words by changing one letter at a time!'**
  String get tutorial_intro_welcome_desc;

  /// No description provided for @tutorial_intro_objective_title.
  ///
  /// In en, this message translates to:
  /// **'Game Objective'**
  String get tutorial_intro_objective_title;

  /// No description provided for @tutorial_intro_objective_desc.
  ///
  /// In en, this message translates to:
  /// **'Your goal is to find the missing words between the START and END words. Each word differs by exactly one letter from the previous word.'**
  String get tutorial_intro_objective_desc;

  /// No description provided for @tutorial_intro_rule_title.
  ///
  /// In en, this message translates to:
  /// **'The Golden Rule'**
  String get tutorial_intro_rule_title;

  /// No description provided for @tutorial_intro_rule_desc.
  ///
  /// In en, this message translates to:
  /// **'You can only change ONE letter at a time. For example: CAT → BAT → BAD → BED'**
  String get tutorial_intro_rule_desc;

  /// No description provided for @tutorial_guess_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Phase 1: Guessing'**
  String get tutorial_guess_intro_title;

  /// No description provided for @tutorial_guess_intro_desc.
  ///
  /// In en, this message translates to:
  /// **'First, you need to guess all the middle words. Tap on any empty slot to start guessing.'**
  String get tutorial_guess_intro_desc;

  /// No description provided for @tutorial_guess_success_title.
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get tutorial_guess_success_title;

  /// No description provided for @tutorial_guess_success_desc.
  ///
  /// In en, this message translates to:
  /// **'You found your first word! Keep going to complete the puzzle.'**
  String get tutorial_guess_success_desc;

  /// No description provided for @tutorial_guess_keyboard_title.
  ///
  /// In en, this message translates to:
  /// **'Type Your Guess'**
  String get tutorial_guess_keyboard_title;

  /// No description provided for @tutorial_guess_keyboard_desc.
  ///
  /// In en, this message translates to:
  /// **'Use the keyboard to type a word. Remember: it must differ by only one letter from neighboring words!'**
  String get tutorial_guess_keyboard_desc;

  /// No description provided for @tutorial_guess_hints_title.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get tutorial_guess_hints_title;

  /// No description provided for @tutorial_guess_hints_desc.
  ///
  /// In en, this message translates to:
  /// **'You have 3 hints per level. Use them wisely to reveal letters or get clues when stuck.'**
  String get tutorial_guess_hints_desc;

  /// No description provided for @tutorial_guess_timer_title.
  ///
  /// In en, this message translates to:
  /// **'Beat the Clock'**
  String get tutorial_guess_timer_title;

  /// No description provided for @tutorial_guess_timer_desc.
  ///
  /// In en, this message translates to:
  /// **'Faster completion gives more stars! Don\'t worry, there\'s no time limit.'**
  String get tutorial_guess_timer_desc;

  /// No description provided for @tutorial_combo_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Combo System!'**
  String get tutorial_combo_intro_title;

  /// No description provided for @tutorial_combo_intro_desc.
  ///
  /// In en, this message translates to:
  /// **'Keep guessing correctly to build combos and multiply your score! Each correct answer in a row increases your multiplier.'**
  String get tutorial_combo_intro_desc;

  /// No description provided for @tutorial_sort_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Phase 2: Sorting'**
  String get tutorial_sort_intro_title;

  /// No description provided for @tutorial_sort_intro_desc.
  ///
  /// In en, this message translates to:
  /// **'Excellent! You found all the middle words. Now arrange them in the correct order - each word must differ by only ONE letter from the next.'**
  String get tutorial_sort_intro_desc;

  /// No description provided for @tutorial_sort_action_title.
  ///
  /// In en, this message translates to:
  /// **'Real-time Validation'**
  String get tutorial_sort_action_title;

  /// No description provided for @tutorial_sort_action_desc.
  ///
  /// In en, this message translates to:
  /// **'Drag and reorder the words. You\'ll see green borders for correct positions and red for incorrect ones. When all words are green, the START and END will unlock automatically!'**
  String get tutorial_sort_action_desc;

  /// No description provided for @tutorial_final_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Phase 3: Final Challenge'**
  String get tutorial_final_intro_title;

  /// No description provided for @tutorial_final_intro_desc.
  ///
  /// In en, this message translates to:
  /// **'Almost done! Now figure out what the START and END words are based on the sorted middle words.'**
  String get tutorial_final_intro_desc;

  /// No description provided for @tutorial_final_start_title.
  ///
  /// In en, this message translates to:
  /// **'Guess the Start Word'**
  String get tutorial_final_start_title;

  /// No description provided for @tutorial_final_start_desc.
  ///
  /// In en, this message translates to:
  /// **'What word comes before the first middle word? It should differ by one letter.'**
  String get tutorial_final_start_desc;

  /// No description provided for @tutorial_final_end_title.
  ///
  /// In en, this message translates to:
  /// **'Guess the End Word'**
  String get tutorial_final_end_title;

  /// No description provided for @tutorial_final_end_desc.
  ///
  /// In en, this message translates to:
  /// **'What word comes after the last middle word? Complete the ladder!'**
  String get tutorial_final_end_desc;

  /// No description provided for @tutorial_complete_congrats_title.
  ///
  /// In en, this message translates to:
  /// **'You\'re Ready!'**
  String get tutorial_complete_congrats_title;

  /// No description provided for @tutorial_complete_congrats_desc.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You now know how to play CrossClimber. Have fun and challenge yourself!'**
  String get tutorial_complete_congrats_desc;

  /// No description provided for @skipTutorial.
  ///
  /// In en, this message translates to:
  /// **'Skip Tutorial'**
  String get skipTutorial;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @showTips.
  ///
  /// In en, this message translates to:
  /// **'Show Tips'**
  String get showTips;

  /// No description provided for @resetTutorial.
  ///
  /// In en, this message translates to:
  /// **'Reset Tutorial'**
  String get resetTutorial;

  /// No description provided for @outOfLivesTitle.
  ///
  /// In en, this message translates to:
  /// **'Out of Lives!'**
  String get outOfLivesTitle;

  /// No description provided for @outOfLivesMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve run out of lives. Wait for regeneration or use credits to continue.'**
  String get outOfLivesMessage;

  /// No description provided for @nextLifeIn.
  ///
  /// In en, this message translates to:
  /// **'Next life in: {time}'**
  String nextLifeIn(String time);

  /// No description provided for @buyOneLife.
  ///
  /// In en, this message translates to:
  /// **'Buy a single life'**
  String get buyOneLife;

  /// No description provided for @buyAllLives.
  ///
  /// In en, this message translates to:
  /// **'Buy All Lives (100 💰)'**
  String get buyAllLives;

  /// No description provided for @exitGame.
  ///
  /// In en, this message translates to:
  /// **'Exit Game'**
  String get exitGame;

  /// No description provided for @returnToMainMenu.
  ///
  /// In en, this message translates to:
  /// **'Return to Main Menu?'**
  String get returnToMainMenu;

  /// No description provided for @progressLostWarning.
  ///
  /// In en, this message translates to:
  /// **'Your current progress will be lost. Are you sure?'**
  String get progressLostWarning;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @startEndUnlocked.
  ///
  /// In en, this message translates to:
  /// **'START & END Unlocked!'**
  String get startEndUnlocked;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get shopTitle;

  /// No description provided for @freeCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Earn Free'**
  String get freeCreditsTitle;

  /// No description provided for @freeCreditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Watch ads, earn free credits'**
  String get freeCreditsSubtitle;

  /// No description provided for @creditPackageTitle.
  ///
  /// In en, this message translates to:
  /// **'Credit Package'**
  String get creditPackageTitle;

  /// No description provided for @creditPackageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy credits with real money'**
  String get creditPackageSubtitle;

  /// No description provided for @lifePackageTitle.
  ///
  /// In en, this message translates to:
  /// **'Life Package'**
  String get lifePackageTitle;

  /// No description provided for @lifePackageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy lives with credits'**
  String get lifePackageSubtitle;

  /// No description provided for @hintPackageTitle.
  ///
  /// In en, this message translates to:
  /// **'Hint Package'**
  String get hintPackageTitle;

  /// No description provided for @hintPackageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy hints with credits'**
  String get hintPackageSubtitle;

  /// No description provided for @nCredits.
  ///
  /// In en, this message translates to:
  /// **'{amount} Credits'**
  String nCredits(int amount);

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get mostPopular;

  /// No description provided for @popularLabel.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popularLabel;

  /// No description provided for @nLives.
  ///
  /// In en, this message translates to:
  /// **'{amount} Lives'**
  String nLives(int amount);

  /// No description provided for @buyFiveLives.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to 5 lives'**
  String get buyFiveLives;

  /// No description provided for @revealWord.
  ///
  /// In en, this message translates to:
  /// **'Reveal Word'**
  String get revealWord;

  /// No description provided for @revealWordDesc.
  ///
  /// In en, this message translates to:
  /// **'Fully reveals the selected word'**
  String get revealWordDesc;

  /// No description provided for @undoMove.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoMove;

  /// No description provided for @undoMoveDesc.
  ///
  /// In en, this message translates to:
  /// **'Undo your last move'**
  String get undoMoveDesc;

  /// No description provided for @dailyRewardClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim Your Daily Reward! 🎁'**
  String get dailyRewardClaim;

  /// No description provided for @dailyRewardAmount.
  ///
  /// In en, this message translates to:
  /// **'20+ Credits + Bonuses'**
  String get dailyRewardAmount;

  /// No description provided for @dailyRewardStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak: {days} days'**
  String dailyRewardStreak(int days);

  /// No description provided for @watchAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch Ads, Earn'**
  String get watchAdsTitle;

  /// No description provided for @watchAdsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can watch 5 ads per day'**
  String get watchAdsSubtitle;

  /// No description provided for @watchAdCredits.
  ///
  /// In en, this message translates to:
  /// **'+10 Credits'**
  String get watchAdCredits;

  /// No description provided for @watchAdHint.
  ///
  /// In en, this message translates to:
  /// **'+1 Hint'**
  String get watchAdHint;

  /// No description provided for @dailyRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reward!'**
  String get dailyRewardTitle;

  /// No description provided for @alreadyClaimedToday.
  ///
  /// In en, this message translates to:
  /// **'You already claimed today\'s reward!'**
  String get alreadyClaimedToday;

  /// No description provided for @notEnoughCredits.
  ///
  /// In en, this message translates to:
  /// **'Not enough credits!'**
  String get notEnoughCredits;

  /// No description provided for @livesAlreadyFull.
  ///
  /// In en, this message translates to:
  /// **'Lives already full!'**
  String get livesAlreadyFull;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareResult.
  ///
  /// In en, this message translates to:
  /// **'Share Result'**
  String get shareResult;

  /// No description provided for @customKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Custom Keyboard'**
  String get customKeyboard;

  /// No description provided for @customKeyboardDesc.
  ///
  /// In en, this message translates to:
  /// **'Use in-game QWERTY keyboard'**
  String get customKeyboardDesc;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Vibration and tactile feedback'**
  String get hapticFeedbackDesc;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @skipLabel.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipLabel;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @achievementFirstWin.
  ///
  /// In en, this message translates to:
  /// **'First Win'**
  String get achievementFirstWin;

  /// No description provided for @achievementTenLevels.
  ///
  /// In en, this message translates to:
  /// **'Ten Levels'**
  String get achievementTenLevels;

  /// No description provided for @achievementSpeedDemon.
  ///
  /// In en, this message translates to:
  /// **'Speed Demon'**
  String get achievementSpeedDemon;

  /// No description provided for @achievementMarathonRunner.
  ///
  /// In en, this message translates to:
  /// **'Marathon Runner'**
  String get achievementMarathonRunner;

  /// No description provided for @achievementThirtyLevels.
  ///
  /// In en, this message translates to:
  /// **'Thirty Levels'**
  String get achievementThirtyLevels;

  /// No description provided for @achievementPerfectStreak5.
  ///
  /// In en, this message translates to:
  /// **'Perfect Streak 5'**
  String get achievementPerfectStreak5;

  /// No description provided for @achievementCenturyClub.
  ///
  /// In en, this message translates to:
  /// **'Century Club'**
  String get achievementCenturyClub;

  /// No description provided for @achievementHintlessHero.
  ///
  /// In en, this message translates to:
  /// **'Hintless Hero'**
  String get achievementHintlessHero;

  /// No description provided for @achievementErrorFree.
  ///
  /// In en, this message translates to:
  /// **'Error Free'**
  String get achievementErrorFree;

  /// No description provided for @achievementEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get achievementEarlyBird;

  /// No description provided for @achievementNightOwl.
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get achievementNightOwl;

  /// No description provided for @achievementPerfectStreak10.
  ///
  /// In en, this message translates to:
  /// **'Perfect Streak 10'**
  String get achievementPerfectStreak10;

  /// No description provided for @achievementFiftyLevels.
  ///
  /// In en, this message translates to:
  /// **'Fifty Levels'**
  String get achievementFiftyLevels;

  /// No description provided for @achievementThreeStarPerfectionist.
  ///
  /// In en, this message translates to:
  /// **'Three Star Perfectionist'**
  String get achievementThreeStarPerfectionist;

  /// No description provided for @achievementNoHintsMaster.
  ///
  /// In en, this message translates to:
  /// **'No Hints Master'**
  String get achievementNoHintsMaster;

  /// No description provided for @achievementDescFirstWin.
  ///
  /// In en, this message translates to:
  /// **'Complete your first level'**
  String get achievementDescFirstWin;

  /// No description provided for @achievementDescTenLevels.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 levels'**
  String get achievementDescTenLevels;

  /// No description provided for @achievementDescSpeedDemon.
  ///
  /// In en, this message translates to:
  /// **'Complete a level in under 30 seconds'**
  String get achievementDescSpeedDemon;

  /// No description provided for @achievementDescMarathonRunner.
  ///
  /// In en, this message translates to:
  /// **'Play 10 levels in a single session'**
  String get achievementDescMarathonRunner;

  /// No description provided for @achievementDescThirtyLevels.
  ///
  /// In en, this message translates to:
  /// **'Complete 30 levels'**
  String get achievementDescThirtyLevels;

  /// No description provided for @achievementDescPerfectStreak5.
  ///
  /// In en, this message translates to:
  /// **'Get 3 stars on 5 consecutive levels'**
  String get achievementDescPerfectStreak5;

  /// No description provided for @achievementDescCenturyClub.
  ///
  /// In en, this message translates to:
  /// **'Complete 100 levels'**
  String get achievementDescCenturyClub;

  /// No description provided for @achievementDescHintlessHero.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 levels without using hints'**
  String get achievementDescHintlessHero;

  /// No description provided for @achievementDescErrorFree.
  ///
  /// In en, this message translates to:
  /// **'Complete a level without any wrong attempts'**
  String get achievementDescErrorFree;

  /// No description provided for @achievementDescEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Complete a level before 9 AM'**
  String get achievementDescEarlyBird;

  /// No description provided for @achievementDescNightOwl.
  ///
  /// In en, this message translates to:
  /// **'Complete a level after 11 PM'**
  String get achievementDescNightOwl;

  /// No description provided for @achievementDescPerfectStreak10.
  ///
  /// In en, this message translates to:
  /// **'Get 3 stars on 10 consecutive levels'**
  String get achievementDescPerfectStreak10;

  /// No description provided for @achievementDescFiftyLevels.
  ///
  /// In en, this message translates to:
  /// **'Complete 50 levels'**
  String get achievementDescFiftyLevels;

  /// No description provided for @achievementDescThreeStarPerfectionist.
  ///
  /// In en, this message translates to:
  /// **'Get 3 stars on 20 levels'**
  String get achievementDescThreeStarPerfectionist;

  /// No description provided for @achievementDescNoHintsMaster.
  ///
  /// In en, this message translates to:
  /// **'Complete 50 levels without using hints'**
  String get achievementDescNoHintsMaster;

  /// No description provided for @yourStatistics.
  ///
  /// In en, this message translates to:
  /// **'Your Statistics'**
  String get yourStatistics;

  /// No description provided for @gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayed;

  /// No description provided for @gamesWon.
  ///
  /// In en, this message translates to:
  /// **'Games Won'**
  String get gamesWon;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @winRate.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// No description provided for @avgStars.
  ///
  /// In en, this message translates to:
  /// **'Avg Stars'**
  String get avgStars;

  /// No description provided for @timeStatistics.
  ///
  /// In en, this message translates to:
  /// **'Time Statistics'**
  String get timeStatistics;

  /// No description provided for @totalTimePlayed.
  ///
  /// In en, this message translates to:
  /// **'Total Time Played'**
  String get totalTimePlayed;

  /// No description provided for @bestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get bestTime;

  /// No description provided for @averageTime.
  ///
  /// In en, this message translates to:
  /// **'Average Time'**
  String get averageTime;

  /// No description provided for @starDistribution.
  ///
  /// In en, this message translates to:
  /// **'Star Distribution'**
  String get starDistribution;

  /// No description provided for @totalStarsEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Stars Earned'**
  String get totalStarsEarned;

  /// No description provided for @perfectGames.
  ///
  /// In en, this message translates to:
  /// **'Perfect Games'**
  String get perfectGames;

  /// No description provided for @noGamesPlayedYet.
  ///
  /// In en, this message translates to:
  /// **'No games played yet'**
  String get noGamesPlayedYet;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// No description provided for @shareStatistics.
  ///
  /// In en, this message translates to:
  /// **'Share Statistics'**
  String get shareStatistics;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @failedToLoadDailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Failed to load daily challenge'**
  String get failedToLoadDailyChallenge;

  /// No description provided for @failedToLoadChallenge.
  ///
  /// In en, this message translates to:
  /// **'Failed to load challenge'**
  String get failedToLoadChallenge;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficultyLabel;

  /// No description provided for @wordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get wordsLabel;

  /// No description provided for @starsLabel.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get starsLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @viewResult.
  ///
  /// In en, this message translates to:
  /// **'View Result'**
  String get viewResult;

  /// No description provided for @playNow.
  ///
  /// In en, this message translates to:
  /// **'Play Now'**
  String get playNow;

  /// No description provided for @expert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @yourStats.
  ///
  /// In en, this message translates to:
  /// **'Your Stats'**
  String get yourStats;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabel;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
