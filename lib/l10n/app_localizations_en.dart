// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CrossClimber';

  @override
  String get play => 'Play';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Turkish';

  @override
  String level(int levelNumber) {
    return 'Level $levelNumber';
  }

  @override
  String get nextLevel => 'Next Level';

  @override
  String get allLevelsCompleted => 'Amazing! You\'ve Completed All Levels!';

  @override
  String allLevelsCompletedDesc(int totalLevels) {
    return 'You\'ve mastered all $totalLevels levels! Stay tuned for more challenges coming soon.';
  }

  @override
  String get hint => 'Hint';

  @override
  String get correct => 'Correct!';

  @override
  String get wrong => 'Wrong!';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get youWon => 'You completed the level!';

  @override
  String get phase1Title => 'Guess the Words';

  @override
  String get phase2Title => 'Sort the Words';

  @override
  String get phase3Title => 'Find Final Words';

  @override
  String phaseProgress(int current, int total) {
    return 'Step $current / $total';
  }

  @override
  String wordsFound(int found, int total) {
    return '$found / $total words found';
  }

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get restart => 'Restart';

  @override
  String get mainMenu => 'Main Menu';

  @override
  String get paused => 'Paused';

  @override
  String get useHint => 'Use Hint';

  @override
  String hintsRemaining(int count) {
    return '$count hints remaining';
  }

  @override
  String get noHintsLeft => 'No hints left';

  @override
  String get hintUsed => 'Hint used!';

  @override
  String get tapToGuess => 'Tap to guess';

  @override
  String get enterWord => 'Enter word';

  @override
  String get locked => 'Locked';

  @override
  String get completed => 'Completed!';

  @override
  String get timeElapsed => 'Time Elapsed';

  @override
  String get yourScore => 'Your Score';

  @override
  String stars(int count) {
    return '$count Stars';
  }

  @override
  String get newBestTime => 'New Best Time!';

  @override
  String get playAgain => 'Play Again';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get checkOrder => 'Check Order';

  @override
  String get orderCorrect => 'Order is correct!';

  @override
  String get orderIncorrect => 'Order is incorrect, try again';

  @override
  String get invalidWord => 'Invalid word!';

  @override
  String get alreadyGuessed => 'Word already guessed';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get vibration => 'Vibration';

  @override
  String get showTimer => 'Show Timer';

  @override
  String get autoCheck => 'Auto Check';

  @override
  String get autoCheckDesc => 'Auto-check when you complete a word';

  @override
  String get autoSort => 'Auto Sort';

  @override
  String get autoSortDesc => 'Auto-sort when you find all words';

  @override
  String get appearance => 'Appearance';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get music => 'Music';

  @override
  String get tutorial => 'How to Play';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get achievements => 'Achievements';

  @override
  String get statistics => 'Statistics';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get profile => 'Profile';

  @override
  String get guestUser => 'Guest User';

  @override
  String loggedInAs(String email) {
    return 'Logged in as: $email';
  }

  @override
  String get linkAccount => 'Link Account';

  @override
  String get linkAccountDesc =>
      'Link your account to save progress to the cloud.';

  @override
  String get signOut => 'Sign Out';

  @override
  String get googleSignIn => 'Sign in with Google';

  @override
  String get tutorial_intro_welcome_title => 'Welcome to CrossClimber!';

  @override
  String get tutorial_intro_welcome_desc =>
      'Learn how to play this fun word puzzle game. Connect words by changing one letter at a time!';

  @override
  String get tutorial_intro_objective_title => 'Game Objective';

  @override
  String get tutorial_intro_objective_desc =>
      'Your goal is to find the missing words between the START and END words. Each word differs by exactly one letter from the previous word.';

  @override
  String get tutorial_intro_rule_title => 'The Golden Rule';

  @override
  String get tutorial_intro_rule_desc =>
      'You can only change ONE letter at a time. For example: CAT → BAT → BAD → BED';

  @override
  String get tutorial_guess_intro_title => 'Phase 1: Guessing';

  @override
  String get tutorial_guess_intro_desc =>
      'First, you need to guess all the middle words. Tap on any empty slot to start guessing.';

  @override
  String get tutorial_guess_success_title => 'Great Job!';

  @override
  String get tutorial_guess_success_desc =>
      'You found your first word! Keep going to complete the puzzle.';

  @override
  String get tutorial_guess_keyboard_title => 'Type Your Guess';

  @override
  String get tutorial_guess_keyboard_desc =>
      'Use the keyboard to type a word. Remember: it must differ by only one letter from neighboring words!';

  @override
  String get tutorial_guess_hints_title => 'Need Help?';

  @override
  String get tutorial_guess_hints_desc =>
      'You have 3 hints per level. Use them wisely to reveal letters or get clues when stuck.';

  @override
  String get tutorial_guess_timer_title => 'Beat the Clock';

  @override
  String get tutorial_guess_timer_desc =>
      'Faster completion gives more stars! Don\'t worry, there\'s no time limit.';

  @override
  String get tutorial_combo_intro_title => 'Combo System!';

  @override
  String get tutorial_combo_intro_desc =>
      'Keep guessing correctly to build combos and multiply your score! Each correct answer in a row increases your multiplier.';

  @override
  String get tutorial_sort_intro_title => 'Phase 2: Sorting';

  @override
  String get tutorial_sort_intro_desc =>
      'Excellent! You found all the middle words. Now arrange them in the correct order - each word must differ by only ONE letter from the next.';

  @override
  String get tutorial_sort_action_title => 'Real-time Validation';

  @override
  String get tutorial_sort_action_desc =>
      'Drag and reorder the words. You\'ll see green borders for correct positions and red for incorrect ones. When all words are green, the START and END will unlock automatically!';

  @override
  String get tutorial_final_intro_title => 'Phase 3: Final Challenge';

  @override
  String get tutorial_final_intro_desc =>
      'Almost done! Now figure out what the START and END words are based on the sorted middle words.';

  @override
  String get tutorial_final_start_title => 'Guess the Start Word';

  @override
  String get tutorial_final_start_desc =>
      'What word comes before the first middle word? It should differ by one letter.';

  @override
  String get tutorial_final_end_title => 'Guess the End Word';

  @override
  String get tutorial_final_end_desc =>
      'What word comes after the last middle word? Complete the ladder!';

  @override
  String get tutorial_complete_congrats_title => 'You\'re Ready!';

  @override
  String get tutorial_complete_congrats_desc =>
      'Congratulations! You now know how to play CrossClimber. Have fun and challenge yourself!';

  @override
  String get skipTutorial => 'Skip Tutorial';

  @override
  String get continueButton => 'Continue';

  @override
  String get showTips => 'Show Tips';

  @override
  String get resetTutorial => 'Reset Tutorial';

  @override
  String get outOfLivesTitle => 'Out of Lives!';

  @override
  String get outOfLivesMessage =>
      'You\'ve run out of lives. Wait for regeneration or use credits to continue.';

  @override
  String nextLifeIn(String time) {
    return 'Next life in: $time';
  }

  @override
  String get buyOneLife => 'Buy 1 Life (50 💰)';

  @override
  String get buyAllLives => 'Buy All Lives (100 💰)';

  @override
  String get exitGame => 'Exit Game';

  @override
  String get returnToMainMenu => 'Return to Main Menu?';

  @override
  String get progressLostWarning =>
      'Your current progress will be lost. Are you sure?';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get startEndUnlocked => 'START & END Unlocked!';

  @override
  String get shopTitle => 'Market';

  @override
  String get freeCreditsTitle => 'Earn Free';

  @override
  String get freeCreditsSubtitle => 'Watch ads, earn free credits';

  @override
  String get creditPackageTitle => 'Credit Package';

  @override
  String get creditPackageSubtitle => 'Buy credits with real money';

  @override
  String get lifePackageTitle => 'Life Package';

  @override
  String get lifePackageSubtitle => 'Buy lives with credits';

  @override
  String get hintPackageTitle => 'Hint Package';

  @override
  String get hintPackageSubtitle => 'Buy hints with credits';

  @override
  String nCredits(int amount) {
    return '$amount Credits';
  }

  @override
  String get mostPopular => 'MOST POPULAR';

  @override
  String get popularLabel => 'POPULAR';

  @override
  String nLives(int amount) {
    return '$amount Lives';
  }

  @override
  String get buyOneLifeDesc => 'Buy a single life';

  @override
  String get buyFiveLives => 'Upgrade to 5 lives';

  @override
  String get revealWord => 'Reveal Word';

  @override
  String get revealWordDesc => 'Fully reveals the selected word';

  @override
  String get undoMove => 'Undo';

  @override
  String get undoMoveDesc => 'Undo your last move';

  @override
  String get dailyRewardClaim => 'Claim Your Daily Reward! 🎁';

  @override
  String get dailyRewardAmount => '20+ Credits + Bonuses';

  @override
  String dailyRewardStreak(int days) {
    return 'Streak: $days days';
  }

  @override
  String get watchAdsTitle => 'Watch Ads, Earn';

  @override
  String get watchAdsSubtitle => 'You can watch 5 ads per day';

  @override
  String get watchAdCredits => '+10 Credits';

  @override
  String get watchAdHint => '+1 Hint';

  @override
  String get dailyRewardTitle => 'Daily Reward!';

  @override
  String get alreadyClaimedToday => 'You already claimed today\'s reward!';

  @override
  String get notEnoughCredits => 'Not enough credits!';

  @override
  String get livesAlreadyFull => 'Lives already full!';

  @override
  String get great => 'Great!';

  @override
  String get share => 'Share';

  @override
  String get shareResult => 'Share Result';

  @override
  String get customKeyboard => 'Custom Keyboard';

  @override
  String get customKeyboardDesc => 'Use in-game QWERTY keyboard';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackDesc => 'Vibration and tactile feedback';

  @override
  String get gotIt => 'Got it!';

  @override
  String get skipLabel => 'Skip';

  @override
  String get progress => 'Progress';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get achievementFirstWin => 'First Win';

  @override
  String get achievementTenLevels => 'Ten Levels';

  @override
  String get achievementSpeedDemon => 'Speed Demon';

  @override
  String get achievementMarathonRunner => 'Marathon Runner';

  @override
  String get achievementThirtyLevels => 'Thirty Levels';

  @override
  String get achievementPerfectStreak5 => 'Perfect Streak 5';

  @override
  String get achievementCenturyClub => 'Century Club';

  @override
  String get achievementHintlessHero => 'Hintless Hero';

  @override
  String get achievementErrorFree => 'Error Free';

  @override
  String get achievementEarlyBird => 'Early Bird';

  @override
  String get achievementNightOwl => 'Night Owl';

  @override
  String get achievementPerfectStreak10 => 'Perfect Streak 10';

  @override
  String get achievementFiftyLevels => 'Fifty Levels';

  @override
  String get achievementThreeStarPerfectionist => 'Three Star Perfectionist';

  @override
  String get achievementNoHintsMaster => 'No Hints Master';

  @override
  String get achievementDescFirstWin => 'Complete your first level';

  @override
  String get achievementDescTenLevels => 'Complete 10 levels';

  @override
  String get achievementDescSpeedDemon =>
      'Complete a level in under 30 seconds';

  @override
  String get achievementDescMarathonRunner =>
      'Play 10 levels in a single session';

  @override
  String get achievementDescThirtyLevels => 'Complete 30 levels';

  @override
  String get achievementDescPerfectStreak5 =>
      'Get 3 stars on 5 consecutive levels';

  @override
  String get achievementDescCenturyClub => 'Complete 100 levels';

  @override
  String get achievementDescHintlessHero =>
      'Complete 10 levels without using hints';

  @override
  String get achievementDescErrorFree =>
      'Complete a level without any wrong attempts';

  @override
  String get achievementDescEarlyBird => 'Complete a level before 9 AM';

  @override
  String get achievementDescNightOwl => 'Complete a level after 11 PM';

  @override
  String get achievementDescPerfectStreak10 =>
      'Get 3 stars on 10 consecutive levels';

  @override
  String get achievementDescFiftyLevels => 'Complete 50 levels';

  @override
  String get achievementDescThreeStarPerfectionist =>
      'Get 3 stars on 20 levels';

  @override
  String get achievementDescNoHintsMaster =>
      'Complete 50 levels without using hints';

  @override
  String get yourStatistics => 'Your Statistics';

  @override
  String get gamesPlayed => 'Games Played';

  @override
  String get gamesWon => 'Games Won';

  @override
  String get performance => 'Performance';

  @override
  String get winRate => 'Win Rate';

  @override
  String get avgStars => 'Avg Stars';

  @override
  String get timeStatistics => 'Time Statistics';

  @override
  String get totalTimePlayed => 'Total Time Played';

  @override
  String get bestTime => 'Best Time';

  @override
  String get averageTime => 'Average Time';

  @override
  String get starDistribution => 'Star Distribution';

  @override
  String get totalStarsEarned => 'Total Stars Earned';

  @override
  String get perfectGames => 'Perfect Games';

  @override
  String get noGamesPlayedYet => 'No games played yet';

  @override
  String get wins => 'Wins';

  @override
  String get losses => 'Losses';

  @override
  String get shareStatistics => 'Share Statistics';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get failedToLoadDailyChallenge => 'Failed to load daily challenge';

  @override
  String get failedToLoadChallenge => 'Failed to load challenge';

  @override
  String get difficultyLabel => 'Difficulty';

  @override
  String get wordsLabel => 'Words';

  @override
  String get starsLabel => 'Stars';

  @override
  String get timeLabel => 'Time';

  @override
  String get scoreLabel => 'Score';

  @override
  String get viewResult => 'View Result';

  @override
  String get playNow => 'Play Now';

  @override
  String get expert => 'Expert';

  @override
  String get unknown => 'Unknown';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get yourStats => 'Your Stats';

  @override
  String get completedLabel => 'Completed';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String comboLabel(int count) {
    return '$count COMBO';
  }

  @override
  String comboMultiplierLabel(String multiplier) {
    return '${multiplier}x Multiplier';
  }

  @override
  String comboXLabel(int count, String multiplier) {
    return 'Combo x$count (${multiplier}x)';
  }

  @override
  String get comboBreak => 'COMBO BREAK';

  @override
  String comboLostLabel(int count) {
    return 'Lost ${count}x combo';
  }

  @override
  String undoTooltipMessage(String action, int count) {
    return 'Undo: $action\n$count undos remaining';
  }

  @override
  String get noUndosAvailable => 'No more undos available';

  @override
  String get undoConfirmTitle => 'Undo?';

  @override
  String undoConfirmMessageWithAction(String action, int count) {
    return 'This action will be undone:\n\n\"$action\"\n\nUndos remaining: $count';
  }

  @override
  String undoConfirmMessage(int count) {
    return 'Undo the last action?\n\nUndos remaining: $count';
  }

  @override
  String get undoReverted => 'Action undone';

  @override
  String undosRemainingCount(int count) {
    return '$count undos remaining';
  }

  @override
  String rewardCreditsLabel(int amount) {
    return '+$amount Credits';
  }

  @override
  String rewardRevealHints(int count) {
    return '+$count Reveal Hint';
  }

  @override
  String rewardUndoHints(int count) {
    return '+$count Undo Hint';
  }

  @override
  String get dailyAdLimitReached => 'Daily limit reached! (5/5)';

  @override
  String creditsEarnedNotification(int amount) {
    return '+$amount credits earned!';
  }

  @override
  String get revealHintEarned => '+1 Reveal hint earned!';

  @override
  String get undoHintEarned => '+1 Undo hint earned!';

  @override
  String hintsPurchasedNotification(int amount) {
    return '$amount hints purchased!';
  }

  @override
  String livesPurchasedNotification(int amount) {
    return '$amount lives purchased!';
  }

  @override
  String creditPurchaseComingSoon(int amount, String price) {
    return 'Buying $amount credits for $price (Coming soon!)';
  }

  @override
  String get levelsLabel => 'Levels';

  @override
  String get streakLabel => 'Streak';

  @override
  String get creditsEarnedLabel => 'Credits Earned';

  @override
  String get completedToday => 'Completed Today!';

  @override
  String get todaysChallenge => 'Today\'s Challenge';

  @override
  String shareResultHeader(int levelId) {
    return 'CrossClimber Level $levelId Completed!';
  }

  @override
  String get shareAchievementUnlocked => '🏆 Achievement Unlocked!';

  @override
  String get shareAchievementCTA =>
      'Playing CrossClimber - The ultimate word puzzle game!';

  @override
  String get shareDailyChallengeTitle => '📅 CrossClimber Daily Challenge';

  @override
  String shareDailyLevelCompleted(int levelId) {
    return 'Level $levelId: Completed!';
  }

  @override
  String shareDailyLevelFailed(int levelId) {
    return 'Level $levelId: Failed';
  }

  @override
  String get shareDailyChallengeCTA => 'Join the daily challenge!';

  @override
  String get shareMyStatsTitle => '📊 My CrossClimber Stats';

  @override
  String get shareStatsCTA => 'Challenge me in CrossClimber!';

  @override
  String get shareStatisticsCTA => 'Can you beat my stats?';
}
