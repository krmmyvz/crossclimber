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
  String get tutorialResetSuccess => 'Tutorial progress has been reset.';

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
  String get buyOneLife => 'Buy 1 Life (50 Credits)';

  @override
  String get buyAllLives => 'Buy All Lives (100 Credits)';

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
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: '$amount Lives',
      one: '1 Life',
    );
    return '$_temp0';
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
  String get dailyRewardClaim => 'Claim Your Daily Reward!';

  @override
  String get dailyRewardAmount => '20+ Credits + Bonuses';

  @override
  String dailyRewardStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Streak: $_temp0';
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
  String get achievementStreak7Days => 'Week Warrior';

  @override
  String get achievementStreak14Days => 'Fortnight Fighter';

  @override
  String get achievementStreak30Days => 'Monthly Champion';

  @override
  String get achievementStreak60Days => '2-Month Streak';

  @override
  String get achievementStreak100Days => 'Centurion';

  @override
  String get achievementCombo5x => 'Combo Starter';

  @override
  String get achievementCombo8x => 'Combo Artist';

  @override
  String get achievementCombo10x => 'Combo Master';

  @override
  String get achievementSpeed60s => 'Speed Runner';

  @override
  String get achievementSpeed45s => 'Lightning Fast';

  @override
  String get achievementAllLevels => 'All Levels Cleared';

  @override
  String get achievementLegendaryRank => 'Legendary';

  @override
  String get achievementShareResults => 'Sharer';

  @override
  String get achievementDailyChallengeFirst => 'Daily Challenger';

  @override
  String get achievementDailyChallenge30 => 'Daily Champion';

  @override
  String get achievementDescStreak7Days => 'Log in 7 days in a row';

  @override
  String get achievementDescStreak14Days => 'Log in 14 days in a row';

  @override
  String get achievementDescStreak30Days => 'Log in 30 days in a row';

  @override
  String get achievementDescStreak60Days => 'Log in 60 days in a row';

  @override
  String get achievementDescStreak100Days => 'Log in 100 days in a row';

  @override
  String get achievementDescCombo5x => 'Reach a 5x combo';

  @override
  String get achievementDescCombo8x => 'Reach an 8x combo';

  @override
  String get achievementDescCombo10x => 'Reach a 10x combo';

  @override
  String get achievementDescSpeed60s => 'Complete a level in under 60 seconds';

  @override
  String get achievementDescSpeed45s => 'Complete a level in under 45 seconds';

  @override
  String get achievementDescAllLevels => 'Complete all available levels';

  @override
  String get achievementDescLegendaryRank => 'Reach the Legendary rank';

  @override
  String get achievementDescShareResults => 'Share your results 5 times';

  @override
  String get achievementDescDailyChallengeFirst =>
      'Complete your first daily challenge';

  @override
  String get achievementDescDailyChallenge30 => 'Complete 30 daily challenges';

  @override
  String get achievementRarityCommon => 'Common';

  @override
  String get achievementRarityRare => 'Rare';

  @override
  String get achievementRarityLegendary => 'Legendary';

  @override
  String get achievementBadgeSelect => 'Set Badge';

  @override
  String get achievementBadgeActive => 'Active Badge';

  @override
  String get achievementBadgeRemove => 'Remove Badge';

  @override
  String get achievementBadgeRemoved => 'Badge removed';

  @override
  String get achievementBadgeSelected => 'Badge set!';

  @override
  String get achievementUnlocked => 'Achievement Unlocked';

  @override
  String get streakMilestoneTitle => 'Streak Milestone!';

  @override
  String streakMilestoneDesc(int days, int credits) {
    return '$days-day streak! +$credits credits!';
  }

  @override
  String get streakFreezeTitle => 'Streak Freeze';

  @override
  String get streakFreezeDesc => 'Protects your streak for 1 missed day';

  @override
  String streakFreezeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count freezes available',
      one: '1 freeze available',
    );
    return '$_temp0';
  }

  @override
  String get streakFreezeAutoUsed => 'Streak freeze used! Your streak is safe.';

  @override
  String get streakLossWarningTitle => 'Streak at risk!';

  @override
  String get streakLossWarning => 'Don\'t lose your streak! Play today!';

  @override
  String get streakDays => 'day streak';

  @override
  String get streakTodayCompleted => 'Today done';

  @override
  String get streakTodayIncomplete => 'Play today!';

  @override
  String get streakFreezeAvailable => 'freeze';

  @override
  String streakNextMilestone(int days) {
    return 'Next milestone: $days days';
  }

  @override
  String streakMilestoneReward(int credits) {
    return 'Reward: $credits credits';
  }

  @override
  String get streakMilestones => 'Milestones';

  @override
  String get streakAllMilestonesReached => 'All milestones reached!';

  @override
  String get streakFreezeShopTitle => 'Streak Protection';

  @override
  String get streakFreezeShopSubtitle => 'Never lose your streak again';

  @override
  String get buyStreakFreeze1 => '1 Freeze';

  @override
  String get buyStreakFreeze3 => '3 Freezes';

  @override
  String get streakFreezePurchased => 'Streak freeze purchased!';

  @override
  String get streakFreezeZero => 'No freezes';

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
  String get shareAchievementUnlocked => 'Achievement Unlocked!';

  @override
  String get shareAchievementCTA =>
      'Playing CrossClimber - The ultimate word puzzle game!';

  @override
  String get shareDailyChallengeTitle => 'CrossClimber Daily Challenge';

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
  String get shareMyStatsTitle => 'My CrossClimber Stats';

  @override
  String get shareStatsCTA => 'Challenge me in CrossClimber!';

  @override
  String get shareStatisticsCTA => 'Can you beat my stats?';

  @override
  String get onboardingPage1Title => 'Climb the Words!';

  @override
  String get onboardingPage1Desc =>
      'Climb from the starting word to the end word — find the hidden steps!';

  @override
  String get onboardingPage2Title => 'Guess, Sort, Solve!';

  @override
  String get onboardingPage2Desc =>
      '3 phases to win: Guess hidden words → Sort them correctly → Solve the final word!';

  @override
  String get onboardingPage3Title => 'Daily Challenge';

  @override
  String get onboardingPage3Desc =>
      'A brand new puzzle every day. Build your streak and beat your own record!';

  @override
  String get onboardingPage4Title => 'Build Combos!';

  @override
  String get onboardingPage4Desc =>
      'Guess correctly in a row to multiply your score — 2x, 3x, 4x bonus points!';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Let\'s Go!';

  @override
  String get tutorialDontShowAgain => 'Don\'t show again';

  @override
  String get emptyAchievementsTitle => 'No Achievements Yet';

  @override
  String get emptyAchievementsDesc =>
      'Play games to start unlocking achievements and earning bonus credits!';

  @override
  String get emptyStatisticsTitle => 'No Stats Yet';

  @override
  String get emptyStatisticsDesc =>
      'Your statistics will appear here after your first game.';

  @override
  String get dailyMotivationTitle => 'Ready for Today\'s Challenge?';

  @override
  String get dailyMotivationDesc =>
      'A new puzzle every day. Complete it to keep your streak alive!';

  @override
  String get dailyMotivationButton => 'Play Now';

  @override
  String get discoveryShopTitle => 'Welcome to the Shop!';

  @override
  String get discoveryShopDesc =>
      'Use your credits to buy hints and lives. Watch ads for free daily rewards!';

  @override
  String get discoveryAchievementsTitle => 'Unlock Achievements!';

  @override
  String get discoveryAchievementsDesc =>
      'Complete milestones to unlock badges and earn bonus credits.';

  @override
  String get discoveryDailyTitle => 'Build Your Streak!';

  @override
  String get discoveryDailyDesc =>
      'Complete the daily challenge every day to keep your streak alive and earn rewards.';

  @override
  String get discoveryGotIt => 'Got it!';

  @override
  String get homeSubtitle => 'Climb the words to the top!';

  @override
  String get homeQuickPlay => 'Quick Play';

  @override
  String homeLevelsWithProgress(int level) {
    return 'Levels (Level $level)';
  }

  @override
  String homeContinueLevel(int level) {
    return 'Continue: Level $level';
  }

  @override
  String homeStreakDays(int days) {
    return '$days';
  }

  @override
  String homeTotalStars(int count) {
    return '$count';
  }

  @override
  String homeAchievementsProgress(int unlocked, int total) {
    return '$unlocked/$total';
  }

  @override
  String zoneProgress(int completed, int total) {
    return '$completed/$total completed';
  }

  @override
  String get phaseSortBanner => 'Sort Now!';

  @override
  String get phaseFinalBanner => 'Find Final Words!';

  @override
  String get completion3Stars => 'Perfect! All stars!';

  @override
  String get completion2Stars => 'Great job!';

  @override
  String get completion1Star => 'Not bad! Try again for more stars.';

  @override
  String get completion0Stars => 'Keep going, you can do it! Try again.';

  @override
  String get completionHintSuggestion =>
      'Tip: Use hints to improve your score.';

  @override
  String get sharePreviewTitle => 'Share Result';

  @override
  String get sharePreviewCopy => 'Copy';

  @override
  String get sharePreviewCopied => 'Copied!';

  @override
  String get sharePreviewClose => 'Close';

  @override
  String get settingsHighContrast => 'High Contrast Mode';

  @override
  String get settingsHighContrastDesc =>
      'Increase color contrast for better readability';

  @override
  String get semanticsDragInstruction =>
      'Double tap and hold to drag and reorder';

  @override
  String semanticsComboMultiplier(int count, String multiplier) {
    return 'Combo: $count in a row, ${multiplier}x multiplier';
  }

  @override
  String semanticsLevelCard(int id, String status, int stars) {
    return 'Level $id, $status, $stars stars';
  }

  @override
  String get semanticsLocked => 'locked';

  @override
  String get semanticsUnlocked => 'unlocked';

  @override
  String get semanticsCompleted => 'completed';

  @override
  String get semanticsActionPlay => 'play';

  @override
  String get semanticsActionOpen => 'open';

  @override
  String get semanticsActionAddLetter => 'add letter';

  @override
  String get rankNovice => 'Novice';

  @override
  String get rankWordStudent => 'Word Student';

  @override
  String get rankWordMaster => 'Word Master';

  @override
  String get rankPuzzleSolver => 'Puzzle Solver';

  @override
  String get rankMountainClimber => 'Mountain Climber';

  @override
  String get rankWordEagle => 'Word Eagle';

  @override
  String get rankWordKing => 'Word King';

  @override
  String get rankDiamondMind => 'Diamond Mind';

  @override
  String get rankLegend => 'Legend';

  @override
  String get rankCrossClimberMaster => 'CrossClimber Master';

  @override
  String xpGained(int amount) {
    return '+$amount XP';
  }

  @override
  String totalXpLabel(int amount) {
    return 'Total XP: $amount';
  }

  @override
  String get rankUpTitle => 'Rank Up!';

  @override
  String rankUpMessage(String rankName) {
    return 'You\'ve reached $rankName!';
  }

  @override
  String get profileCardTitle => 'Player Profile';

  @override
  String xpProgress(int current, int target) {
    return '$current / $target XP';
  }

  @override
  String get dailyChallengeXp => 'Daily Challenge XP';

  @override
  String comboXpBonus(int amount) {
    return 'Combo Bonus: +$amount XP';
  }

  @override
  String get dailyCalendarTitle => 'Daily Reward Calendar';

  @override
  String dailyCalendarDay(int day) {
    return 'Day $day';
  }

  @override
  String get dailyCalendarClaim => 'Claim!';

  @override
  String get dailyCalendarClaimed => 'Claimed';

  @override
  String dailyCalendarNextIn(String time) {
    return 'Next in $time';
  }

  @override
  String get dailyCalendarStreakReset => 'Streak reset — back to Day 1!';

  @override
  String dailyCalendarRewardCredits(int amount) {
    return '$amount credits';
  }

  @override
  String get dailyCalendarRewardReveal => '1 Reveal';

  @override
  String get dailyCalendarRewardUndo => '1 Undo';

  @override
  String get dailyCalendarRewardSpecial => 'Special Theme!';

  @override
  String get dailyCalendarRewardSummary => 'Reward claimed!';

  @override
  String get dailyCalendarFomoWarning => 'Don\'t miss tomorrow!';

  @override
  String get tournamentTitle => 'Weekly Tournament';

  @override
  String tournamentWeek(String week) {
    return 'Week $week';
  }

  @override
  String get tournamentActive => 'Active';

  @override
  String get tournamentEnded => 'Ended';

  @override
  String tournamentEndsIn(String time) {
    return 'Ends in $time';
  }

  @override
  String tournamentNextIn(String time) {
    return 'Next in $time';
  }

  @override
  String get tournamentLeaderboard => 'Leaderboard';

  @override
  String get tournamentLevels => 'Tournament Levels';

  @override
  String get tournamentMyRank => 'Your Rank';

  @override
  String tournamentRank(int rank) {
    return '#$rank';
  }

  @override
  String tournamentScore(int score) {
    return '$score pts';
  }

  @override
  String get tournamentRewards => 'Rewards';

  @override
  String get tournamentPlay => 'Play';

  @override
  String get tournamentLevelCompleted => 'Done';

  @override
  String get tournamentNotParticipating => 'Not participating yet';

  @override
  String tournamentLevelsProgress(int count) {
    return '$count/7 levels';
  }

  @override
  String tournamentCreditsReward(int amount) {
    return '$amount Credits';
  }

  @override
  String get tournamentParticipation => 'Participation';

  @override
  String get tournamentOffline => 'Tournament requires an internet connection';

  @override
  String get tournamentLoadError => 'Could not load tournament';

  @override
  String get tournamentScoreSubmitted => 'Score saved to leaderboard!';

  @override
  String get tournamentHomeBanner => 'Weekly Tournament';

  @override
  String get tournamentJoin => 'Join!';

  @override
  String get tournamentDifficultyEasy => 'Easy';

  @override
  String get tournamentDifficultyMedium => 'Medium';

  @override
  String get tournamentDifficultyHard => 'Hard';

  @override
  String get idleMotivation1 => 'One more word?';

  @override
  String get idleMotivation2 => 'You can do it!';

  @override
  String get idleMotivation3 => 'Try a different approach?';

  @override
  String get settingsGroupProfile => 'Profile & Account';

  @override
  String get settingsGroupAppearance => 'Appearance';

  @override
  String get settingsGroupGameplay => 'Gameplay';

  @override
  String get settingsGroupSoundHaptic => 'Sound & Haptics';

  @override
  String get settingsGroupHelp => 'Help & Info';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get premiumTheme => 'Premium';

  @override
  String get unlockInShop => 'Unlock in Shop';

  @override
  String get themeUnlocked => 'Theme unlocked!';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get chooseAvatar => 'Choose Avatar';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayNameHint => 'Enter your name';

  @override
  String get saveProfile => 'Save';

  @override
  String get profileSaved => 'Profile saved!';

  @override
  String get connectedAccounts => 'Connected Accounts';

  @override
  String get googleConnected => 'Google — Connected';

  @override
  String get googleNotConnected => 'Google — Not connected';

  @override
  String get connectGoogle => 'Connect';

  @override
  String get disconnectGoogle => 'Disconnect';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountDesc =>
      'Permanently delete your account and all data. This action cannot be undone.';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? All progress, achievements, and purchases will be permanently lost.';

  @override
  String get deleteAccountButton => 'Delete Forever';

  @override
  String get rankLabel => 'Rank';

  @override
  String get totalXp => 'Total XP';

  @override
  String get faq => 'FAQ';

  @override
  String get licenses => 'Licenses';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String unlockThemeTitle(String themeName) {
    return 'Unlock $themeName';
  }

  @override
  String unlockThemeDesc(int cost) {
    return 'Unlock this premium theme for $cost credits.';
  }

  @override
  String get unlockButton => 'Unlock';

  @override
  String yourCredits(int amount) {
    return 'Your credits: $amount';
  }

  @override
  String get solveMiddleWordsFirst => 'Solve middle words first to unlock';

  @override
  String get offlineBanner =>
      'You are offline. Some features may be unavailable.';

  @override
  String get backOnline => 'You are back online!';

  @override
  String get doubleRewards => 'Double Rewards';

  @override
  String get watchAdForLife => 'Watch Ad for Free Life';

  @override
  String get adNotAvailable =>
      'Ad not available right now. Please try again later.';
}
