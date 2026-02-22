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

  /// App Title
  ///
  /// In en, this message translates to:
  /// **'CrossClimber'**
  String get appTitle;

  /// Play
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Turkish
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// Level number label
  ///
  /// In en, this message translates to:
  /// **'Level {levelNumber}'**
  String level(int levelNumber);

  /// Next Level
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// All Levels Completed
  ///
  /// In en, this message translates to:
  /// **'Amazing! You\'ve Completed All Levels!'**
  String get allLevelsCompleted;

  /// Message shown when all levels are completed
  ///
  /// In en, this message translates to:
  /// **'You\'ve mastered all {totalLevels} levels! Stay tuned for more challenges coming soon.'**
  String allLevelsCompletedDesc(int totalLevels);

  /// Hint
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// Correct
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// Wrong
  ///
  /// In en, this message translates to:
  /// **'Wrong!'**
  String get wrong;

  /// Congratulations
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// You Won
  ///
  /// In en, this message translates to:
  /// **'You completed the level!'**
  String get youWon;

  /// Phase1 Title
  ///
  /// In en, this message translates to:
  /// **'Guess the Words'**
  String get phase1Title;

  /// Phase2 Title
  ///
  /// In en, this message translates to:
  /// **'Sort the Words'**
  String get phase2Title;

  /// Phase3 Title
  ///
  /// In en, this message translates to:
  /// **'Find Final Words'**
  String get phase3Title;

  /// Phase step indicator
  ///
  /// In en, this message translates to:
  /// **'Step {current} / {total}'**
  String phaseProgress(int current, int total);

  /// Words found progress indicator
  ///
  /// In en, this message translates to:
  /// **'{found} / {total} words found'**
  String wordsFound(int found, int total);

  /// Pause
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Resume
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Restart
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// Main Menu
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get mainMenu;

  /// Paused
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// Use Hint
  ///
  /// In en, this message translates to:
  /// **'Use Hint'**
  String get useHint;

  /// Hints remaining count
  ///
  /// In en, this message translates to:
  /// **'{count} hints remaining'**
  String hintsRemaining(int count);

  /// No Hints Left
  ///
  /// In en, this message translates to:
  /// **'No hints left'**
  String get noHintsLeft;

  /// Hint Used
  ///
  /// In en, this message translates to:
  /// **'Hint used!'**
  String get hintUsed;

  /// Tap To Guess
  ///
  /// In en, this message translates to:
  /// **'Tap to guess'**
  String get tapToGuess;

  /// Enter Word
  ///
  /// In en, this message translates to:
  /// **'Enter word'**
  String get enterWord;

  /// Locked
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// Completed
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get completed;

  /// Time Elapsed
  ///
  /// In en, this message translates to:
  /// **'Time Elapsed'**
  String get timeElapsed;

  /// Your Score
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// Stars count label
  ///
  /// In en, this message translates to:
  /// **'{count} Stars'**
  String stars(int count);

  /// New Best Time
  ///
  /// In en, this message translates to:
  /// **'New Best Time!'**
  String get newBestTime;

  /// Play Again
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// Drag To Reorder
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// Check Order
  ///
  /// In en, this message translates to:
  /// **'Check Order'**
  String get checkOrder;

  /// Order Correct
  ///
  /// In en, this message translates to:
  /// **'Order is correct!'**
  String get orderCorrect;

  /// Order Incorrect
  ///
  /// In en, this message translates to:
  /// **'Order is incorrect, try again'**
  String get orderIncorrect;

  /// Invalid Word
  ///
  /// In en, this message translates to:
  /// **'Invalid word!'**
  String get invalidWord;

  /// Already Guessed
  ///
  /// In en, this message translates to:
  /// **'Word already guessed'**
  String get alreadyGuessed;

  /// Theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// System
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Vibration
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// Show Timer
  ///
  /// In en, this message translates to:
  /// **'Show Timer'**
  String get showTimer;

  /// Auto Check
  ///
  /// In en, this message translates to:
  /// **'Auto Check'**
  String get autoCheck;

  /// Auto Check Desc
  ///
  /// In en, this message translates to:
  /// **'Auto-check when you complete a word'**
  String get autoCheckDesc;

  /// Auto Sort
  ///
  /// In en, this message translates to:
  /// **'Auto Sort'**
  String get autoSort;

  /// Auto Sort Desc
  ///
  /// In en, this message translates to:
  /// **'Auto-sort when you find all words'**
  String get autoSortDesc;

  /// Appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Sound Effects
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// Music
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// Tutorial
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get tutorial;

  /// About
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Difficulty
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Easy
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// Medium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Hard
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// Achievements
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Statistics
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Daily Challenge
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// Profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Guest User
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// Logged in as email
  ///
  /// In en, this message translates to:
  /// **'Logged in as: {email}'**
  String loggedInAs(String email);

  /// Link Account
  ///
  /// In en, this message translates to:
  /// **'Link Account'**
  String get linkAccount;

  /// Link Account Desc
  ///
  /// In en, this message translates to:
  /// **'Link your account to save progress to the cloud.'**
  String get linkAccountDesc;

  /// Sign Out
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Google Sign In
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleSignIn;

  /// Tutorial intro welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome to CrossClimber!'**
  String get tutorial_intro_welcome_title;

  /// Tutorial intro welcome desc
  ///
  /// In en, this message translates to:
  /// **'Learn how to play this fun word puzzle game. Connect words by changing one letter at a time!'**
  String get tutorial_intro_welcome_desc;

  /// Tutorial intro objective title
  ///
  /// In en, this message translates to:
  /// **'Game Objective'**
  String get tutorial_intro_objective_title;

  /// Tutorial intro objective desc
  ///
  /// In en, this message translates to:
  /// **'Your goal is to find the missing words between the START and END words. Each word differs by exactly one letter from the previous word.'**
  String get tutorial_intro_objective_desc;

  /// Tutorial intro rule title
  ///
  /// In en, this message translates to:
  /// **'The Golden Rule'**
  String get tutorial_intro_rule_title;

  /// Tutorial intro rule desc
  ///
  /// In en, this message translates to:
  /// **'You can only change ONE letter at a time. For example: CAT → BAT → BAD → BED'**
  String get tutorial_intro_rule_desc;

  /// Tutorial guess intro title
  ///
  /// In en, this message translates to:
  /// **'Phase 1: Guessing'**
  String get tutorial_guess_intro_title;

  /// Tutorial guess intro desc
  ///
  /// In en, this message translates to:
  /// **'First, you need to guess all the middle words. Tap on any empty slot to start guessing.'**
  String get tutorial_guess_intro_desc;

  /// Tutorial guess success title
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get tutorial_guess_success_title;

  /// Tutorial guess success desc
  ///
  /// In en, this message translates to:
  /// **'You found your first word! Keep going to complete the puzzle.'**
  String get tutorial_guess_success_desc;

  /// Tutorial guess keyboard title
  ///
  /// In en, this message translates to:
  /// **'Type Your Guess'**
  String get tutorial_guess_keyboard_title;

  /// Tutorial guess keyboard desc
  ///
  /// In en, this message translates to:
  /// **'Use the keyboard to type a word. Remember: it must differ by only one letter from neighboring words!'**
  String get tutorial_guess_keyboard_desc;

  /// Tutorial guess hints title
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get tutorial_guess_hints_title;

  /// Tutorial guess hints desc
  ///
  /// In en, this message translates to:
  /// **'You have 3 hints per level. Use them wisely to reveal letters or get clues when stuck.'**
  String get tutorial_guess_hints_desc;

  /// Tutorial guess timer title
  ///
  /// In en, this message translates to:
  /// **'Beat the Clock'**
  String get tutorial_guess_timer_title;

  /// Tutorial guess timer desc
  ///
  /// In en, this message translates to:
  /// **'Faster completion gives more stars! Don\'t worry, there\'s no time limit.'**
  String get tutorial_guess_timer_desc;

  /// Tutorial combo intro title
  ///
  /// In en, this message translates to:
  /// **'Combo System!'**
  String get tutorial_combo_intro_title;

  /// Tutorial combo intro desc
  ///
  /// In en, this message translates to:
  /// **'Keep guessing correctly to build combos and multiply your score! Each correct answer in a row increases your multiplier.'**
  String get tutorial_combo_intro_desc;

  /// Tutorial sort intro title
  ///
  /// In en, this message translates to:
  /// **'Phase 2: Sorting'**
  String get tutorial_sort_intro_title;

  /// Tutorial sort intro desc
  ///
  /// In en, this message translates to:
  /// **'Excellent! You found all the middle words. Now arrange them in the correct order - each word must differ by only ONE letter from the next.'**
  String get tutorial_sort_intro_desc;

  /// Tutorial sort action title
  ///
  /// In en, this message translates to:
  /// **'Real-time Validation'**
  String get tutorial_sort_action_title;

  /// Tutorial sort action desc
  ///
  /// In en, this message translates to:
  /// **'Drag and reorder the words. You\'ll see green borders for correct positions and red for incorrect ones. When all words are green, the START and END will unlock automatically!'**
  String get tutorial_sort_action_desc;

  /// Tutorial final intro title
  ///
  /// In en, this message translates to:
  /// **'Phase 3: Final Challenge'**
  String get tutorial_final_intro_title;

  /// Tutorial final intro desc
  ///
  /// In en, this message translates to:
  /// **'Almost done! Now figure out what the START and END words are based on the sorted middle words.'**
  String get tutorial_final_intro_desc;

  /// Tutorial final start title
  ///
  /// In en, this message translates to:
  /// **'Guess the Start Word'**
  String get tutorial_final_start_title;

  /// Tutorial final start desc
  ///
  /// In en, this message translates to:
  /// **'What word comes before the first middle word? It should differ by one letter.'**
  String get tutorial_final_start_desc;

  /// Tutorial final end title
  ///
  /// In en, this message translates to:
  /// **'Guess the End Word'**
  String get tutorial_final_end_title;

  /// Tutorial final end desc
  ///
  /// In en, this message translates to:
  /// **'What word comes after the last middle word? Complete the ladder!'**
  String get tutorial_final_end_desc;

  /// Tutorial complete congrats title
  ///
  /// In en, this message translates to:
  /// **'You\'re Ready!'**
  String get tutorial_complete_congrats_title;

  /// Tutorial complete congrats desc
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You now know how to play CrossClimber. Have fun and challenge yourself!'**
  String get tutorial_complete_congrats_desc;

  /// Skip Tutorial
  ///
  /// In en, this message translates to:
  /// **'Skip Tutorial'**
  String get skipTutorial;

  /// Continue Button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Show Tips
  ///
  /// In en, this message translates to:
  /// **'Show Tips'**
  String get showTips;

  /// Reset Tutorial
  ///
  /// In en, this message translates to:
  /// **'Reset Tutorial'**
  String get resetTutorial;

  /// Tutorial Reset Success
  ///
  /// In en, this message translates to:
  /// **'Tutorial progress has been reset.'**
  String get tutorialResetSuccess;

  /// Out Of Lives Title
  ///
  /// In en, this message translates to:
  /// **'Out of Lives!'**
  String get outOfLivesTitle;

  /// Out Of Lives Message
  ///
  /// In en, this message translates to:
  /// **'You\'ve run out of lives. Wait for regeneration or use credits to continue.'**
  String get outOfLivesMessage;

  /// Next life regeneration timer
  ///
  /// In en, this message translates to:
  /// **'Next life in: {time}'**
  String nextLifeIn(String time);

  /// Buy One Life
  ///
  /// In en, this message translates to:
  /// **'Buy 1 Life (50 Credits)'**
  String get buyOneLife;

  /// Buy All Lives
  ///
  /// In en, this message translates to:
  /// **'Buy All Lives (100 Credits)'**
  String get buyAllLives;

  /// Exit Game
  ///
  /// In en, this message translates to:
  /// **'Exit Game'**
  String get exitGame;

  /// Return To Main Menu
  ///
  /// In en, this message translates to:
  /// **'Return to Main Menu?'**
  String get returnToMainMenu;

  /// Progress Lost Warning
  ///
  /// In en, this message translates to:
  /// **'Your current progress will be lost. Are you sure?'**
  String get progressLostWarning;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Exit
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// Start End Unlocked
  ///
  /// In en, this message translates to:
  /// **'START & END Unlocked!'**
  String get startEndUnlocked;

  /// Shop Title
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get shopTitle;

  /// Free Credits Title
  ///
  /// In en, this message translates to:
  /// **'Earn Free'**
  String get freeCreditsTitle;

  /// Free Credits Subtitle
  ///
  /// In en, this message translates to:
  /// **'Watch ads, earn free credits'**
  String get freeCreditsSubtitle;

  /// Credit Package Title
  ///
  /// In en, this message translates to:
  /// **'Credit Package'**
  String get creditPackageTitle;

  /// Credit Package Subtitle
  ///
  /// In en, this message translates to:
  /// **'Buy credits with real money'**
  String get creditPackageSubtitle;

  /// Life Package Title
  ///
  /// In en, this message translates to:
  /// **'Life Package'**
  String get lifePackageTitle;

  /// Life Package Subtitle
  ///
  /// In en, this message translates to:
  /// **'Buy lives with credits'**
  String get lifePackageSubtitle;

  /// Hint Package Title
  ///
  /// In en, this message translates to:
  /// **'Hint Package'**
  String get hintPackageTitle;

  /// Hint Package Subtitle
  ///
  /// In en, this message translates to:
  /// **'Buy hints with credits'**
  String get hintPackageSubtitle;

  /// Number of credits
  ///
  /// In en, this message translates to:
  /// **'{amount} Credits'**
  String nCredits(int amount);

  /// Most Popular
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get mostPopular;

  /// Popular Label
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popularLabel;

  /// Number of lives
  ///
  /// In en, this message translates to:
  /// **'{amount, plural, =1{1 Life} other{{amount} Lives}}'**
  String nLives(int amount);

  /// Buy One Life Desc
  ///
  /// In en, this message translates to:
  /// **'Buy a single life'**
  String get buyOneLifeDesc;

  /// Buy Five Lives
  ///
  /// In en, this message translates to:
  /// **'Upgrade to 5 lives'**
  String get buyFiveLives;

  /// Reveal Word
  ///
  /// In en, this message translates to:
  /// **'Reveal Word'**
  String get revealWord;

  /// Reveal Word Desc
  ///
  /// In en, this message translates to:
  /// **'Fully reveals the selected word'**
  String get revealWordDesc;

  /// Undo Move
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoMove;

  /// Undo Move Desc
  ///
  /// In en, this message translates to:
  /// **'Undo your last move'**
  String get undoMoveDesc;

  /// Daily Reward Claim
  ///
  /// In en, this message translates to:
  /// **'Claim Your Daily Reward!'**
  String get dailyRewardClaim;

  /// Daily Reward Amount
  ///
  /// In en, this message translates to:
  /// **'20+ Credits + Bonuses'**
  String get dailyRewardAmount;

  /// Daily reward streak days
  ///
  /// In en, this message translates to:
  /// **'Streak: {days, plural, =1{1 day} other{{days} days}}'**
  String dailyRewardStreak(int days);

  /// Watch Ads Title
  ///
  /// In en, this message translates to:
  /// **'Watch Ads, Earn'**
  String get watchAdsTitle;

  /// Watch Ads Subtitle
  ///
  /// In en, this message translates to:
  /// **'You can watch 5 ads per day'**
  String get watchAdsSubtitle;

  /// Watch Ad Credits
  ///
  /// In en, this message translates to:
  /// **'+10 Credits'**
  String get watchAdCredits;

  /// Watch Ad Hint
  ///
  /// In en, this message translates to:
  /// **'+1 Hint'**
  String get watchAdHint;

  /// Daily Reward Title
  ///
  /// In en, this message translates to:
  /// **'Daily Reward!'**
  String get dailyRewardTitle;

  /// Already Claimed Today
  ///
  /// In en, this message translates to:
  /// **'You already claimed today\'s reward!'**
  String get alreadyClaimedToday;

  /// Not Enough Credits
  ///
  /// In en, this message translates to:
  /// **'Not enough credits!'**
  String get notEnoughCredits;

  /// Lives Already Full
  ///
  /// In en, this message translates to:
  /// **'Lives already full!'**
  String get livesAlreadyFull;

  /// Great
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// Share
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Share Result
  ///
  /// In en, this message translates to:
  /// **'Share Result'**
  String get shareResult;

  /// Custom Keyboard
  ///
  /// In en, this message translates to:
  /// **'Custom Keyboard'**
  String get customKeyboard;

  /// Custom Keyboard Desc
  ///
  /// In en, this message translates to:
  /// **'Use in-game QWERTY keyboard'**
  String get customKeyboardDesc;

  /// Haptic Feedback
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// Haptic Feedback Desc
  ///
  /// In en, this message translates to:
  /// **'Vibration and tactile feedback'**
  String get hapticFeedbackDesc;

  /// Got It
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// Skip Label
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipLabel;

  /// Progress
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Days ago label
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// Achievement First Win
  ///
  /// In en, this message translates to:
  /// **'First Win'**
  String get achievementFirstWin;

  /// Achievement Ten Levels
  ///
  /// In en, this message translates to:
  /// **'Ten Levels'**
  String get achievementTenLevels;

  /// Achievement Speed Demon
  ///
  /// In en, this message translates to:
  /// **'Speed Demon'**
  String get achievementSpeedDemon;

  /// Achievement Marathon Runner
  ///
  /// In en, this message translates to:
  /// **'Marathon Runner'**
  String get achievementMarathonRunner;

  /// Achievement Thirty Levels
  ///
  /// In en, this message translates to:
  /// **'Thirty Levels'**
  String get achievementThirtyLevels;

  /// Achievement Perfect Streak5
  ///
  /// In en, this message translates to:
  /// **'Perfect Streak 5'**
  String get achievementPerfectStreak5;

  /// Achievement Century Club
  ///
  /// In en, this message translates to:
  /// **'Century Club'**
  String get achievementCenturyClub;

  /// Achievement Hintless Hero
  ///
  /// In en, this message translates to:
  /// **'Hintless Hero'**
  String get achievementHintlessHero;

  /// Achievement Error Free
  ///
  /// In en, this message translates to:
  /// **'Error Free'**
  String get achievementErrorFree;

  /// Achievement Early Bird
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get achievementEarlyBird;

  /// Achievement Night Owl
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get achievementNightOwl;

  /// Achievement Perfect Streak10
  ///
  /// In en, this message translates to:
  /// **'Perfect Streak 10'**
  String get achievementPerfectStreak10;

  /// Achievement Fifty Levels
  ///
  /// In en, this message translates to:
  /// **'Fifty Levels'**
  String get achievementFiftyLevels;

  /// Achievement Three Star Perfectionist
  ///
  /// In en, this message translates to:
  /// **'Three Star Perfectionist'**
  String get achievementThreeStarPerfectionist;

  /// Achievement No Hints Master
  ///
  /// In en, this message translates to:
  /// **'No Hints Master'**
  String get achievementNoHintsMaster;

  /// Achievement Desc First Win
  ///
  /// In en, this message translates to:
  /// **'Complete your first level'**
  String get achievementDescFirstWin;

  /// Achievement Desc Ten Levels
  ///
  /// In en, this message translates to:
  /// **'Complete 10 levels'**
  String get achievementDescTenLevels;

  /// Achievement Desc Speed Demon
  ///
  /// In en, this message translates to:
  /// **'Complete a level in under 30 seconds'**
  String get achievementDescSpeedDemon;

  /// Achievement Desc Marathon Runner
  ///
  /// In en, this message translates to:
  /// **'Play 10 levels in a single session'**
  String get achievementDescMarathonRunner;

  /// Achievement Desc Thirty Levels
  ///
  /// In en, this message translates to:
  /// **'Complete 30 levels'**
  String get achievementDescThirtyLevels;

  /// Achievement Desc Perfect Streak5
  ///
  /// In en, this message translates to:
  /// **'Get 3 stars on 5 consecutive levels'**
  String get achievementDescPerfectStreak5;

  /// Achievement Desc Century Club
  ///
  /// In en, this message translates to:
  /// **'Complete 100 levels'**
  String get achievementDescCenturyClub;

  /// Achievement Desc Hintless Hero
  ///
  /// In en, this message translates to:
  /// **'Complete 10 levels without using hints'**
  String get achievementDescHintlessHero;

  /// Achievement Desc Error Free
  ///
  /// In en, this message translates to:
  /// **'Complete a level without any wrong attempts'**
  String get achievementDescErrorFree;

  /// Achievement Desc Early Bird
  ///
  /// In en, this message translates to:
  /// **'Complete a level before 9 AM'**
  String get achievementDescEarlyBird;

  /// Achievement Desc Night Owl
  ///
  /// In en, this message translates to:
  /// **'Complete a level after 11 PM'**
  String get achievementDescNightOwl;

  /// Achievement Desc Perfect Streak10
  ///
  /// In en, this message translates to:
  /// **'Get 3 stars on 10 consecutive levels'**
  String get achievementDescPerfectStreak10;

  /// Achievement Desc Fifty Levels
  ///
  /// In en, this message translates to:
  /// **'Complete 50 levels'**
  String get achievementDescFiftyLevels;

  /// Achievement Desc Three Star Perfectionist
  ///
  /// In en, this message translates to:
  /// **'Get 3 stars on 20 levels'**
  String get achievementDescThreeStarPerfectionist;

  /// Achievement Desc No Hints Master
  ///
  /// In en, this message translates to:
  /// **'Complete 50 levels without using hints'**
  String get achievementDescNoHintsMaster;

  /// Achievement Streak7 Days
  ///
  /// In en, this message translates to:
  /// **'Week Warrior'**
  String get achievementStreak7Days;

  /// Achievement Streak14 Days
  ///
  /// In en, this message translates to:
  /// **'Fortnight Fighter'**
  String get achievementStreak14Days;

  /// Achievement Streak30 Days
  ///
  /// In en, this message translates to:
  /// **'Monthly Champion'**
  String get achievementStreak30Days;

  /// Achievement Streak60 Days
  ///
  /// In en, this message translates to:
  /// **'2-Month Streak'**
  String get achievementStreak60Days;

  /// Achievement Streak100 Days
  ///
  /// In en, this message translates to:
  /// **'Centurion'**
  String get achievementStreak100Days;

  /// Achievement Combo5x
  ///
  /// In en, this message translates to:
  /// **'Combo Starter'**
  String get achievementCombo5x;

  /// Achievement Combo8x
  ///
  /// In en, this message translates to:
  /// **'Combo Artist'**
  String get achievementCombo8x;

  /// Achievement Combo10x
  ///
  /// In en, this message translates to:
  /// **'Combo Master'**
  String get achievementCombo10x;

  /// Achievement Speed60s
  ///
  /// In en, this message translates to:
  /// **'Speed Runner'**
  String get achievementSpeed60s;

  /// Achievement Speed45s
  ///
  /// In en, this message translates to:
  /// **'Lightning Fast'**
  String get achievementSpeed45s;

  /// Achievement All Levels
  ///
  /// In en, this message translates to:
  /// **'All Levels Cleared'**
  String get achievementAllLevels;

  /// Achievement Legendary Rank
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get achievementLegendaryRank;

  /// Achievement Share Results
  ///
  /// In en, this message translates to:
  /// **'Sharer'**
  String get achievementShareResults;

  /// Achievement Daily Challenge First
  ///
  /// In en, this message translates to:
  /// **'Daily Challenger'**
  String get achievementDailyChallengeFirst;

  /// Achievement Daily Challenge30
  ///
  /// In en, this message translates to:
  /// **'Daily Champion'**
  String get achievementDailyChallenge30;

  /// Achievement Desc Streak7 Days
  ///
  /// In en, this message translates to:
  /// **'Log in 7 days in a row'**
  String get achievementDescStreak7Days;

  /// Achievement Desc Streak14 Days
  ///
  /// In en, this message translates to:
  /// **'Log in 14 days in a row'**
  String get achievementDescStreak14Days;

  /// Achievement Desc Streak30 Days
  ///
  /// In en, this message translates to:
  /// **'Log in 30 days in a row'**
  String get achievementDescStreak30Days;

  /// Achievement Desc Streak60 Days
  ///
  /// In en, this message translates to:
  /// **'Log in 60 days in a row'**
  String get achievementDescStreak60Days;

  /// Achievement Desc Streak100 Days
  ///
  /// In en, this message translates to:
  /// **'Log in 100 days in a row'**
  String get achievementDescStreak100Days;

  /// Achievement Desc Combo5x
  ///
  /// In en, this message translates to:
  /// **'Reach a 5x combo'**
  String get achievementDescCombo5x;

  /// Achievement Desc Combo8x
  ///
  /// In en, this message translates to:
  /// **'Reach an 8x combo'**
  String get achievementDescCombo8x;

  /// Achievement Desc Combo10x
  ///
  /// In en, this message translates to:
  /// **'Reach a 10x combo'**
  String get achievementDescCombo10x;

  /// Achievement Desc Speed60s
  ///
  /// In en, this message translates to:
  /// **'Complete a level in under 60 seconds'**
  String get achievementDescSpeed60s;

  /// Achievement Desc Speed45s
  ///
  /// In en, this message translates to:
  /// **'Complete a level in under 45 seconds'**
  String get achievementDescSpeed45s;

  /// Achievement Desc All Levels
  ///
  /// In en, this message translates to:
  /// **'Complete all available levels'**
  String get achievementDescAllLevels;

  /// Achievement Desc Legendary Rank
  ///
  /// In en, this message translates to:
  /// **'Reach the Legendary rank'**
  String get achievementDescLegendaryRank;

  /// Achievement Desc Share Results
  ///
  /// In en, this message translates to:
  /// **'Share your results 5 times'**
  String get achievementDescShareResults;

  /// Achievement Desc Daily Challenge First
  ///
  /// In en, this message translates to:
  /// **'Complete your first daily challenge'**
  String get achievementDescDailyChallengeFirst;

  /// Achievement Desc Daily Challenge30
  ///
  /// In en, this message translates to:
  /// **'Complete 30 daily challenges'**
  String get achievementDescDailyChallenge30;

  /// Achievement Rarity Common
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get achievementRarityCommon;

  /// Achievement Rarity Rare
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get achievementRarityRare;

  /// Achievement Rarity Legendary
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get achievementRarityLegendary;

  /// Achievement Badge Select
  ///
  /// In en, this message translates to:
  /// **'Set Badge'**
  String get achievementBadgeSelect;

  /// Achievement Badge Active
  ///
  /// In en, this message translates to:
  /// **'Active Badge'**
  String get achievementBadgeActive;

  /// Achievement Badge Remove
  ///
  /// In en, this message translates to:
  /// **'Remove Badge'**
  String get achievementBadgeRemove;

  /// Achievement Badge Removed
  ///
  /// In en, this message translates to:
  /// **'Badge removed'**
  String get achievementBadgeRemoved;

  /// Achievement Badge Selected
  ///
  /// In en, this message translates to:
  /// **'Badge set!'**
  String get achievementBadgeSelected;

  /// Achievement Unlocked
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked'**
  String get achievementUnlocked;

  /// Streak Milestone Title
  ///
  /// In en, this message translates to:
  /// **'Streak Milestone!'**
  String get streakMilestoneTitle;

  /// Streak milestone reached message
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak! +{credits} credits!'**
  String streakMilestoneDesc(int days, int credits);

  /// Streak Freeze Title
  ///
  /// In en, this message translates to:
  /// **'Streak Freeze'**
  String get streakFreezeTitle;

  /// Streak Freeze Desc
  ///
  /// In en, this message translates to:
  /// **'Protects your streak for 1 missed day'**
  String get streakFreezeDesc;

  /// Number of streak freezes available
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 freeze available} other{{count} freezes available}}'**
  String streakFreezeCount(int count);

  /// Streak Freeze Auto Used
  ///
  /// In en, this message translates to:
  /// **'Streak freeze used! Your streak is safe.'**
  String get streakFreezeAutoUsed;

  /// Streak Loss Warning Title
  ///
  /// In en, this message translates to:
  /// **'Streak at risk!'**
  String get streakLossWarningTitle;

  /// Streak Loss Warning
  ///
  /// In en, this message translates to:
  /// **'Don\'t lose your streak! Play today!'**
  String get streakLossWarning;

  /// Streak Days
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get streakDays;

  /// Streak Today Completed
  ///
  /// In en, this message translates to:
  /// **'Today done'**
  String get streakTodayCompleted;

  /// Streak Today Incomplete
  ///
  /// In en, this message translates to:
  /// **'Play today!'**
  String get streakTodayIncomplete;

  /// Streak Freeze Available
  ///
  /// In en, this message translates to:
  /// **'freeze'**
  String get streakFreezeAvailable;

  /// No description provided for @streakNextMilestone.
  ///
  /// In en, this message translates to:
  /// **'Next milestone: {days} days'**
  String streakNextMilestone(int days);

  /// No description provided for @streakMilestoneReward.
  ///
  /// In en, this message translates to:
  /// **'Reward: {credits} credits'**
  String streakMilestoneReward(int credits);

  /// Streak Milestones
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get streakMilestones;

  /// Streak All Milestones Reached
  ///
  /// In en, this message translates to:
  /// **'All milestones reached!'**
  String get streakAllMilestonesReached;

  /// Streak Freeze Shop Title
  ///
  /// In en, this message translates to:
  /// **'Streak Protection'**
  String get streakFreezeShopTitle;

  /// Streak Freeze Shop Subtitle
  ///
  /// In en, this message translates to:
  /// **'Never lose your streak again'**
  String get streakFreezeShopSubtitle;

  /// Buy Streak Freeze1
  ///
  /// In en, this message translates to:
  /// **'1 Freeze'**
  String get buyStreakFreeze1;

  /// Buy Streak Freeze3
  ///
  /// In en, this message translates to:
  /// **'3 Freezes'**
  String get buyStreakFreeze3;

  /// Streak Freeze Purchased
  ///
  /// In en, this message translates to:
  /// **'Streak freeze purchased!'**
  String get streakFreezePurchased;

  /// Streak Freeze Zero
  ///
  /// In en, this message translates to:
  /// **'No freezes'**
  String get streakFreezeZero;

  /// Your Statistics
  ///
  /// In en, this message translates to:
  /// **'Your Statistics'**
  String get yourStatistics;

  /// Games Played
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayed;

  /// Games Won
  ///
  /// In en, this message translates to:
  /// **'Games Won'**
  String get gamesWon;

  /// Performance
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// Win Rate
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// Avg Stars
  ///
  /// In en, this message translates to:
  /// **'Avg Stars'**
  String get avgStars;

  /// Time Statistics
  ///
  /// In en, this message translates to:
  /// **'Time Statistics'**
  String get timeStatistics;

  /// Total Time Played
  ///
  /// In en, this message translates to:
  /// **'Total Time Played'**
  String get totalTimePlayed;

  /// Best Time
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get bestTime;

  /// Average Time
  ///
  /// In en, this message translates to:
  /// **'Average Time'**
  String get averageTime;

  /// Star Distribution
  ///
  /// In en, this message translates to:
  /// **'Star Distribution'**
  String get starDistribution;

  /// Total Stars Earned
  ///
  /// In en, this message translates to:
  /// **'Total Stars Earned'**
  String get totalStarsEarned;

  /// Perfect Games
  ///
  /// In en, this message translates to:
  /// **'Perfect Games'**
  String get perfectGames;

  /// No Games Played Yet
  ///
  /// In en, this message translates to:
  /// **'No games played yet'**
  String get noGamesPlayedYet;

  /// Wins
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// Losses
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// Share Statistics
  ///
  /// In en, this message translates to:
  /// **'Share Statistics'**
  String get shareStatistics;

  /// Current Streak
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Failed To Load Daily Challenge
  ///
  /// In en, this message translates to:
  /// **'Failed to load daily challenge'**
  String get failedToLoadDailyChallenge;

  /// Failed To Load Challenge
  ///
  /// In en, this message translates to:
  /// **'Failed to load challenge'**
  String get failedToLoadChallenge;

  /// Difficulty Label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficultyLabel;

  /// Words Label
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get wordsLabel;

  /// Stars Label
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get starsLabel;

  /// Time Label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// Score Label
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// View Result
  ///
  /// In en, this message translates to:
  /// **'View Result'**
  String get viewResult;

  /// Play Now
  ///
  /// In en, this message translates to:
  /// **'Play Now'**
  String get playNow;

  /// Expert
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// Unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Month January
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// Month February
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// Month March
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// Month April
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// Month May
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// Month June
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// Month July
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// Month August
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// Month September
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// Month October
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// Month November
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// Month December
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// Your Stats
  ///
  /// In en, this message translates to:
  /// **'Your Stats'**
  String get yourStats;

  /// Completed Label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabel;

  /// Best Streak
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// Combo count label
  ///
  /// In en, this message translates to:
  /// **'{count} COMBO'**
  String comboLabel(int count);

  /// Combo multiplier label
  ///
  /// In en, this message translates to:
  /// **'{multiplier}x Multiplier'**
  String comboMultiplierLabel(String multiplier);

  /// Combo with count and multiplier label
  ///
  /// In en, this message translates to:
  /// **'Combo x{count} ({multiplier}x)'**
  String comboXLabel(int count, String multiplier);

  /// Combo Break
  ///
  /// In en, this message translates to:
  /// **'COMBO BREAK'**
  String get comboBreak;

  /// Lost combo count label
  ///
  /// In en, this message translates to:
  /// **'Lost {count}x combo'**
  String comboLostLabel(int count);

  /// Undo tooltip with action and remaining count
  ///
  /// In en, this message translates to:
  /// **'Undo: {action}\n{count} undos remaining'**
  String undoTooltipMessage(String action, int count);

  /// No Undos Available
  ///
  /// In en, this message translates to:
  /// **'No more undos available'**
  String get noUndosAvailable;

  /// Undo Confirm Title
  ///
  /// In en, this message translates to:
  /// **'Undo?'**
  String get undoConfirmTitle;

  /// Undo confirmation with specific action
  ///
  /// In en, this message translates to:
  /// **'This action will be undone:\n\n\"{action}\"\n\nUndos remaining: {count}'**
  String undoConfirmMessageWithAction(String action, int count);

  /// Undo confirmation with remaining count
  ///
  /// In en, this message translates to:
  /// **'Undo the last action?\n\nUndos remaining: {count}'**
  String undoConfirmMessage(int count);

  /// Undo Reverted
  ///
  /// In en, this message translates to:
  /// **'Action undone'**
  String get undoReverted;

  /// Undos remaining count
  ///
  /// In en, this message translates to:
  /// **'{count} undos remaining'**
  String undosRemainingCount(int count);

  /// Reward credits amount label
  ///
  /// In en, this message translates to:
  /// **'+{amount} Credits'**
  String rewardCreditsLabel(int amount);

  /// Reward reveal hints count
  ///
  /// In en, this message translates to:
  /// **'+{count} Reveal Hint'**
  String rewardRevealHints(int count);

  /// Reward undo hints count
  ///
  /// In en, this message translates to:
  /// **'+{count} Undo Hint'**
  String rewardUndoHints(int count);

  /// Daily Ad Limit Reached
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached! (5/5)'**
  String get dailyAdLimitReached;

  /// Credits earned notification
  ///
  /// In en, this message translates to:
  /// **'+{amount} credits earned!'**
  String creditsEarnedNotification(int amount);

  /// Reveal Hint Earned
  ///
  /// In en, this message translates to:
  /// **'+1 Reveal hint earned!'**
  String get revealHintEarned;

  /// Undo Hint Earned
  ///
  /// In en, this message translates to:
  /// **'+1 Undo hint earned!'**
  String get undoHintEarned;

  /// Hints purchased notification
  ///
  /// In en, this message translates to:
  /// **'{amount} hints purchased!'**
  String hintsPurchasedNotification(int amount);

  /// Lives purchased notification
  ///
  /// In en, this message translates to:
  /// **'{amount} lives purchased!'**
  String livesPurchasedNotification(int amount);

  /// Credit purchase coming soon message
  ///
  /// In en, this message translates to:
  /// **'Buying {amount} credits for {price} (Coming soon!)'**
  String creditPurchaseComingSoon(int amount, String price);

  /// Levels Label
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levelsLabel;

  /// Streak Label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// Credits Earned Label
  ///
  /// In en, this message translates to:
  /// **'Credits Earned'**
  String get creditsEarnedLabel;

  /// Completed Today
  ///
  /// In en, this message translates to:
  /// **'Completed Today!'**
  String get completedToday;

  /// Todays Challenge
  ///
  /// In en, this message translates to:
  /// **'Today\'s Challenge'**
  String get todaysChallenge;

  /// Share result header with level ID
  ///
  /// In en, this message translates to:
  /// **'CrossClimber Level {levelId} Completed!'**
  String shareResultHeader(int levelId);

  /// Share Achievement Unlocked
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get shareAchievementUnlocked;

  /// Share Achievement C T A
  ///
  /// In en, this message translates to:
  /// **'Playing CrossClimber - The ultimate word puzzle game!'**
  String get shareAchievementCTA;

  /// Share Daily Challenge Title
  ///
  /// In en, this message translates to:
  /// **'CrossClimber Daily Challenge'**
  String get shareDailyChallengeTitle;

  /// Share daily level completed message
  ///
  /// In en, this message translates to:
  /// **'Level {levelId}: Completed!'**
  String shareDailyLevelCompleted(int levelId);

  /// Share daily level failed message
  ///
  /// In en, this message translates to:
  /// **'Level {levelId}: Failed'**
  String shareDailyLevelFailed(int levelId);

  /// Share Daily Challenge C T A
  ///
  /// In en, this message translates to:
  /// **'Join the daily challenge!'**
  String get shareDailyChallengeCTA;

  /// Share My Stats Title
  ///
  /// In en, this message translates to:
  /// **'My CrossClimber Stats'**
  String get shareMyStatsTitle;

  /// Share Stats C T A
  ///
  /// In en, this message translates to:
  /// **'Challenge me in CrossClimber!'**
  String get shareStatsCTA;

  /// Share Statistics C T A
  ///
  /// In en, this message translates to:
  /// **'Can you beat my stats?'**
  String get shareStatisticsCTA;

  /// Onboarding Page1 Title
  ///
  /// In en, this message translates to:
  /// **'Climb the Words!'**
  String get onboardingPage1Title;

  /// Onboarding Page1 Desc
  ///
  /// In en, this message translates to:
  /// **'Climb from the starting word to the end word — find the hidden steps!'**
  String get onboardingPage1Desc;

  /// Onboarding Page2 Title
  ///
  /// In en, this message translates to:
  /// **'Guess, Sort, Solve!'**
  String get onboardingPage2Title;

  /// Onboarding Page2 Desc
  ///
  /// In en, this message translates to:
  /// **'3 phases to win: Guess hidden words → Sort them correctly → Solve the final word!'**
  String get onboardingPage2Desc;

  /// Onboarding Page3 Title
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get onboardingPage3Title;

  /// Onboarding Page3 Desc
  ///
  /// In en, this message translates to:
  /// **'A brand new puzzle every day. Build your streak and beat your own record!'**
  String get onboardingPage3Desc;

  /// Onboarding Page4 Title
  ///
  /// In en, this message translates to:
  /// **'Build Combos!'**
  String get onboardingPage4Title;

  /// Onboarding Page4 Desc
  ///
  /// In en, this message translates to:
  /// **'Guess correctly in a row to multiply your score — 2x, 3x, 4x bonus points!'**
  String get onboardingPage4Desc;

  /// Onboarding Skip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Onboarding Next
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Onboarding Start
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go!'**
  String get onboardingStart;

  /// Tutorial Dont Show Again
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get tutorialDontShowAgain;

  /// Empty Achievements Title
  ///
  /// In en, this message translates to:
  /// **'No Achievements Yet'**
  String get emptyAchievementsTitle;

  /// Empty Achievements Desc
  ///
  /// In en, this message translates to:
  /// **'Play games to start unlocking achievements and earning bonus credits!'**
  String get emptyAchievementsDesc;

  /// Empty Statistics Title
  ///
  /// In en, this message translates to:
  /// **'No Stats Yet'**
  String get emptyStatisticsTitle;

  /// Empty Statistics Desc
  ///
  /// In en, this message translates to:
  /// **'Your statistics will appear here after your first game.'**
  String get emptyStatisticsDesc;

  /// Daily Motivation Title
  ///
  /// In en, this message translates to:
  /// **'Ready for Today\'s Challenge?'**
  String get dailyMotivationTitle;

  /// Daily Motivation Desc
  ///
  /// In en, this message translates to:
  /// **'A new puzzle every day. Complete it to keep your streak alive!'**
  String get dailyMotivationDesc;

  /// Daily Motivation Button
  ///
  /// In en, this message translates to:
  /// **'Play Now'**
  String get dailyMotivationButton;

  /// Discovery Shop Title
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Shop!'**
  String get discoveryShopTitle;

  /// Discovery Shop Desc
  ///
  /// In en, this message translates to:
  /// **'Use your credits to buy hints and lives. Watch ads for free daily rewards!'**
  String get discoveryShopDesc;

  /// Discovery Achievements Title
  ///
  /// In en, this message translates to:
  /// **'Unlock Achievements!'**
  String get discoveryAchievementsTitle;

  /// Discovery Achievements Desc
  ///
  /// In en, this message translates to:
  /// **'Complete milestones to unlock badges and earn bonus credits.'**
  String get discoveryAchievementsDesc;

  /// Discovery Daily Title
  ///
  /// In en, this message translates to:
  /// **'Build Your Streak!'**
  String get discoveryDailyTitle;

  /// Discovery Daily Desc
  ///
  /// In en, this message translates to:
  /// **'Complete the daily challenge every day to keep your streak alive and earn rewards.'**
  String get discoveryDailyDesc;

  /// Discovery Got It
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get discoveryGotIt;

  /// Home Subtitle
  ///
  /// In en, this message translates to:
  /// **'Climb the words to the top!'**
  String get homeSubtitle;

  /// Home Quick Play
  ///
  /// In en, this message translates to:
  /// **'Quick Play'**
  String get homeQuickPlay;

  /// Levels button showing current progress
  ///
  /// In en, this message translates to:
  /// **'Levels (Level {level})'**
  String homeLevelsWithProgress(int level);

  /// Continue button with level number
  ///
  /// In en, this message translates to:
  /// **'Continue: Level {level}'**
  String homeContinueLevel(int level);

  /// Home streak days badge
  ///
  /// In en, this message translates to:
  /// **'{days}'**
  String homeStreakDays(int days);

  /// Home total stars badge
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String homeTotalStars(int count);

  /// Home achievements unlocked/total
  ///
  /// In en, this message translates to:
  /// **'{unlocked}/{total}'**
  String homeAchievementsProgress(int unlocked, int total);

  /// Zone completed/total progress
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} completed'**
  String zoneProgress(int completed, int total);

  /// Phase Sort Banner
  ///
  /// In en, this message translates to:
  /// **'Sort Now!'**
  String get phaseSortBanner;

  /// Phase Final Banner
  ///
  /// In en, this message translates to:
  /// **'Find Final Words!'**
  String get phaseFinalBanner;

  /// Completion3 Stars
  ///
  /// In en, this message translates to:
  /// **'Perfect! All stars!'**
  String get completion3Stars;

  /// Completion2 Stars
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get completion2Stars;

  /// Completion1 Star
  ///
  /// In en, this message translates to:
  /// **'Not bad! Try again for more stars.'**
  String get completion1Star;

  /// Completion0 Stars
  ///
  /// In en, this message translates to:
  /// **'Keep going, you can do it! Try again.'**
  String get completion0Stars;

  /// Completion Hint Suggestion
  ///
  /// In en, this message translates to:
  /// **'Tip: Use hints to improve your score.'**
  String get completionHintSuggestion;

  /// Share Preview Title
  ///
  /// In en, this message translates to:
  /// **'Share Result'**
  String get sharePreviewTitle;

  /// Share Preview Copy
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get sharePreviewCopy;

  /// Share Preview Copied
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get sharePreviewCopied;

  /// Share Preview Close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get sharePreviewClose;

  /// Settings High Contrast
  ///
  /// In en, this message translates to:
  /// **'High Contrast Mode'**
  String get settingsHighContrast;

  /// Settings High Contrast Desc
  ///
  /// In en, this message translates to:
  /// **'Increase color contrast for better readability'**
  String get settingsHighContrastDesc;

  /// Semantics Drag Instruction
  ///
  /// In en, this message translates to:
  /// **'Double tap and hold to drag and reorder'**
  String get semanticsDragInstruction;

  /// Accessibility label for combo multiplier
  ///
  /// In en, this message translates to:
  /// **'Combo: {count} in a row, {multiplier}x multiplier'**
  String semanticsComboMultiplier(int count, String multiplier);

  /// Accessibility label for level card
  ///
  /// In en, this message translates to:
  /// **'Level {id}, {status}, {stars} stars'**
  String semanticsLevelCard(int id, String status, int stars);

  /// Semantics Locked
  ///
  /// In en, this message translates to:
  /// **'locked'**
  String get semanticsLocked;

  /// Semantics Unlocked
  ///
  /// In en, this message translates to:
  /// **'unlocked'**
  String get semanticsUnlocked;

  /// Semantics Completed
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get semanticsCompleted;

  /// Semantics Action Play
  ///
  /// In en, this message translates to:
  /// **'play'**
  String get semanticsActionPlay;

  /// Semantics Action Open
  ///
  /// In en, this message translates to:
  /// **'open'**
  String get semanticsActionOpen;

  /// Semantics Action Add Letter
  ///
  /// In en, this message translates to:
  /// **'add letter'**
  String get semanticsActionAddLetter;

  /// Rank Novice
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get rankNovice;

  /// Rank Word Student
  ///
  /// In en, this message translates to:
  /// **'Word Student'**
  String get rankWordStudent;

  /// Rank Word Master
  ///
  /// In en, this message translates to:
  /// **'Word Master'**
  String get rankWordMaster;

  /// Rank Puzzle Solver
  ///
  /// In en, this message translates to:
  /// **'Puzzle Solver'**
  String get rankPuzzleSolver;

  /// Rank Mountain Climber
  ///
  /// In en, this message translates to:
  /// **'Mountain Climber'**
  String get rankMountainClimber;

  /// Rank Word Eagle
  ///
  /// In en, this message translates to:
  /// **'Word Eagle'**
  String get rankWordEagle;

  /// Rank Word King
  ///
  /// In en, this message translates to:
  /// **'Word King'**
  String get rankWordKing;

  /// Rank Diamond Mind
  ///
  /// In en, this message translates to:
  /// **'Diamond Mind'**
  String get rankDiamondMind;

  /// Rank Legend
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get rankLegend;

  /// Rank Cross Climber Master
  ///
  /// In en, this message translates to:
  /// **'CrossClimber Master'**
  String get rankCrossClimberMaster;

  /// XP gained amount
  ///
  /// In en, this message translates to:
  /// **'+{amount} XP'**
  String xpGained(int amount);

  /// Total XP label with amount
  ///
  /// In en, this message translates to:
  /// **'Total XP: {amount}'**
  String totalXpLabel(int amount);

  /// Rank Up Title
  ///
  /// In en, this message translates to:
  /// **'Rank Up!'**
  String get rankUpTitle;

  /// Rank up celebration message
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached {rankName}!'**
  String rankUpMessage(String rankName);

  /// Profile Card Title
  ///
  /// In en, this message translates to:
  /// **'Player Profile'**
  String get profileCardTitle;

  /// XP progress current/target
  ///
  /// In en, this message translates to:
  /// **'{current} / {target} XP'**
  String xpProgress(int current, int target);

  /// Daily Challenge Xp
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge XP'**
  String get dailyChallengeXp;

  /// Combo XP bonus amount
  ///
  /// In en, this message translates to:
  /// **'Combo Bonus: +{amount} XP'**
  String comboXpBonus(int amount);

  /// Daily reward calendar section title
  ///
  /// In en, this message translates to:
  /// **'Daily Reward Calendar'**
  String get dailyCalendarTitle;

  /// Day label in the 7-day calendar
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dailyCalendarDay(int day);

  /// Button label to claim today's daily reward
  ///
  /// In en, this message translates to:
  /// **'Claim!'**
  String get dailyCalendarClaim;

  /// Status label shown when today's reward has been claimed
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get dailyCalendarClaimed;

  /// Countdown label showing time until next daily reward
  ///
  /// In en, this message translates to:
  /// **'Next in {time}'**
  String dailyCalendarNextIn(String time);

  /// FOMO warning shown when the streak was reset due to a missed day
  ///
  /// In en, this message translates to:
  /// **'Streak reset — back to Day 1!'**
  String get dailyCalendarStreakReset;

  /// Credits reward amount in the calendar
  ///
  /// In en, this message translates to:
  /// **'{amount} credits'**
  String dailyCalendarRewardCredits(int amount);

  /// Reveal hint reward label in the calendar
  ///
  /// In en, this message translates to:
  /// **'1 Reveal'**
  String get dailyCalendarRewardReveal;

  /// Undo hint reward label in the calendar
  ///
  /// In en, this message translates to:
  /// **'1 Undo'**
  String get dailyCalendarRewardUndo;

  /// Special theme bonus reward label for Day 7
  ///
  /// In en, this message translates to:
  /// **'Special Theme!'**
  String get dailyCalendarRewardSpecial;

  /// SnackBar message shown after successfully claiming a daily reward
  ///
  /// In en, this message translates to:
  /// **'Reward claimed!'**
  String get dailyCalendarRewardSummary;

  /// FOMO reminder shown after claiming today's reward
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss tomorrow!'**
  String get dailyCalendarFomoWarning;

  /// Weekly tournament section title
  ///
  /// In en, this message translates to:
  /// **'Weekly Tournament'**
  String get tournamentTitle;

  /// Tournament week label
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String tournamentWeek(String week);

  /// Status label for an active tournament
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get tournamentActive;

  /// Status label for an ended tournament
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get tournamentEnded;

  /// Countdown label showing time until tournament ends
  ///
  /// In en, this message translates to:
  /// **'Ends in {time}'**
  String tournamentEndsIn(String time);

  /// Countdown label showing time until next tournament
  ///
  /// In en, this message translates to:
  /// **'Next in {time}'**
  String tournamentNextIn(String time);

  /// Tournament leaderboard section title
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get tournamentLeaderboard;

  /// Tournament levels section title
  ///
  /// In en, this message translates to:
  /// **'Tournament Levels'**
  String get tournamentLevels;

  /// User's own rank in the tournament
  ///
  /// In en, this message translates to:
  /// **'Your Rank'**
  String get tournamentMyRank;

  /// Rank number with hash prefix
  ///
  /// In en, this message translates to:
  /// **'#{rank}'**
  String tournamentRank(int rank);

  /// Tournament score display
  ///
  /// In en, this message translates to:
  /// **'{score} pts'**
  String tournamentScore(int score);

  /// Tournament rewards section title
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get tournamentRewards;

  /// Button to play a tournament level
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get tournamentPlay;

  /// Label shown on a completed tournament level card
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tournamentLevelCompleted;

  /// Shown when user hasn't played any tournament level yet
  ///
  /// In en, this message translates to:
  /// **'Not participating yet'**
  String get tournamentNotParticipating;

  /// Number of completed tournament levels out of 7
  ///
  /// In en, this message translates to:
  /// **'{count}/7 levels'**
  String tournamentLevelsProgress(int count);

  /// Credit reward amount in tournament tiers
  ///
  /// In en, this message translates to:
  /// **'{amount} Credits'**
  String tournamentCreditsReward(int amount);

  /// Participation tier label in tournament rewards
  ///
  /// In en, this message translates to:
  /// **'Participation'**
  String get tournamentParticipation;

  /// Error message when tournament cannot be loaded offline
  ///
  /// In en, this message translates to:
  /// **'Tournament requires an internet connection'**
  String get tournamentOffline;

  /// Error message when tournament data fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load tournament'**
  String get tournamentLoadError;

  /// Confirmation shown when a tournament score is successfully submitted
  ///
  /// In en, this message translates to:
  /// **'Score saved to leaderboard!'**
  String get tournamentScoreSubmitted;

  /// Tournament banner title on the home screen
  ///
  /// In en, this message translates to:
  /// **'Weekly Tournament'**
  String get tournamentHomeBanner;

  /// Call-to-action button on the tournament home banner
  ///
  /// In en, this message translates to:
  /// **'Join!'**
  String get tournamentJoin;

  /// Easy difficulty label
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get tournamentDifficultyEasy;

  /// Medium difficulty label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get tournamentDifficultyMedium;

  /// Hard difficulty label
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get tournamentDifficultyHard;

  /// Idle motivation tooltip message 1
  ///
  /// In en, this message translates to:
  /// **'One more word?'**
  String get idleMotivation1;

  /// Idle motivation tooltip message 2
  ///
  /// In en, this message translates to:
  /// **'You can do it!'**
  String get idleMotivation2;

  /// Idle motivation tooltip message 3
  ///
  /// In en, this message translates to:
  /// **'Try a different approach?'**
  String get idleMotivation3;

  /// Settings group: profile
  ///
  /// In en, this message translates to:
  /// **'Profile & Account'**
  String get settingsGroupProfile;

  /// Settings group: appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsGroupAppearance;

  /// Settings group: gameplay
  ///
  /// In en, this message translates to:
  /// **'Gameplay'**
  String get settingsGroupGameplay;

  /// Settings group: sound
  ///
  /// In en, this message translates to:
  /// **'Sound & Haptics'**
  String get settingsGroupSoundHaptic;

  /// Settings group: help
  ///
  /// In en, this message translates to:
  /// **'Help & Info'**
  String get settingsGroupHelp;

  /// Theme section label
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// Premium theme badge
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumTheme;

  /// Prompt to unlock premium theme
  ///
  /// In en, this message translates to:
  /// **'Unlock in Shop'**
  String get unlockInShop;

  /// Theme unlock confirmation
  ///
  /// In en, this message translates to:
  /// **'Theme unlocked!'**
  String get themeUnlocked;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Edit profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Avatar picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar'**
  String get chooseAvatar;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// Username field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get displayNameHint;

  /// Save profile button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveProfile;

  /// Profile save confirmation
  ///
  /// In en, this message translates to:
  /// **'Profile saved!'**
  String get profileSaved;

  /// Connected accounts section
  ///
  /// In en, this message translates to:
  /// **'Connected Accounts'**
  String get connectedAccounts;

  /// Google account connected
  ///
  /// In en, this message translates to:
  /// **'Google — Connected'**
  String get googleConnected;

  /// Google account not connected
  ///
  /// In en, this message translates to:
  /// **'Google — Not connected'**
  String get googleNotConnected;

  /// Connect Google account button
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectGoogle;

  /// Disconnect Google account button
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnectGoogle;

  /// Delete account button
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account description
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all data. This action cannot be undone.'**
  String get deleteAccountDesc;

  /// Delete account confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? All progress, achievements, and purchases will be permanently lost.'**
  String get deleteAccountConfirm;

  /// Confirm delete button
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get deleteAccountButton;

  /// Rank label
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rankLabel;

  /// Total XP label
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get totalXp;

  /// FAQ button
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// Licenses button
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// Privacy policy button
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Theme purchase dialog title
  ///
  /// In en, this message translates to:
  /// **'Unlock {themeName}'**
  String unlockThemeTitle(String themeName);

  /// Theme purchase dialog body
  ///
  /// In en, this message translates to:
  /// **'Unlock this premium theme for {cost} credits.'**
  String unlockThemeDesc(int cost);

  /// Unlock purchase button
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockButton;

  /// Current credit balance
  ///
  /// In en, this message translates to:
  /// **'Your credits: {amount}'**
  String yourCredits(int amount);

  /// Tooltip for locked end word rows
  ///
  /// In en, this message translates to:
  /// **'Solve middle words first to unlock'**
  String get solveMiddleWordsFirst;

  /// Banner shown when device has no internet connection
  ///
  /// In en, this message translates to:
  /// **'You are offline. Some features may be unavailable.'**
  String get offlineBanner;

  /// Snackbar shown when internet connection is restored
  ///
  /// In en, this message translates to:
  /// **'You are back online!'**
  String get backOnline;

  /// Button to watch ad and double level completion credits
  ///
  /// In en, this message translates to:
  /// **'Double Rewards'**
  String get doubleRewards;

  /// Button in out-of-lives dialog to watch rewarded ad for a free life
  ///
  /// In en, this message translates to:
  /// **'Watch Ad for Free Life'**
  String get watchAdForLife;

  /// Shown when rewarded ad failed to load or is not ready
  ///
  /// In en, this message translates to:
  /// **'Ad not available right now. Please try again later.'**
  String get adNotAvailable;
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
