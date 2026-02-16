import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareResult({
    required int levelId,
    required int stars,
    required Duration time,
    required int score,
  }) async {
    final minutes = time.inMinutes;
    final seconds = time.inSeconds % 60;
    final timeStr = '$minutes:${seconds.toString().padLeft(2, '0')}';

    final starEmoji = '⭐' * stars;

    final text =
        '''
CrossClimber Level $levelId Completed!
Score: $score
Time: $timeStr
Stars: $starEmoji

#CrossClimber #WordGame #PuzzleGame
''';

    await Share.share(text, subject: 'CrossClimber Level $levelId');
  }

  static Future<void> shareAchievement({
    required String achievementName,
    required String achievementIcon,
  }) async {
    final text =
        '''
🏆 Achievement Unlocked!

$achievementIcon $achievementName

Playing CrossClimber - The ultimate word puzzle game!
#CrossClimber #Achievement
''';

    await Share.share(text);
  }

  static Future<void> shareDailyChallenge({
    required int levelId,
    required bool completed,
    required int stars,
  }) async {
    final starEmoji = completed ? '⭐' * stars : '❌';

    final text =
        '''
📅 CrossClimber Daily Challenge

Level $levelId: ${completed ? 'Completed!' : 'Failed'}
$starEmoji ${completed ? '$stars/3 Stars' : ''}

Join the daily challenge!
#CrossClimber #DailyChallenge
''';

    await Share.share(text);
  }

  static Future<void> shareStats({
    required int totalLevels,
    required int totalStars,
    required int currentStreak,
    required double winRate,
  }) async {
    final text =
        '''
📊 My CrossClimber Stats

🏆 Levels Completed: $totalLevels
⭐ Total Stars: $totalStars
🔥 Current Streak: $currentStreak
📈 Win Rate: ${winRate.toStringAsFixed(1)}%

Challenge me in CrossClimber!
#CrossClimber #GameStats
''';

    await Share.share(text);
  }

  static Future<void> shareStatistics({
    required int totalGames,
    required int totalWins,
    required int totalStars,
    required int bestTime,
  }) async {
    final winRate = totalGames > 0 ? (totalWins / totalGames * 100) : 0.0;
    final timeStr = bestTime > 0
        ? '${bestTime ~/ 60}:${(bestTime % 60).toString().padLeft(2, '0')}'
        : 'N/A';

    final text =
        '''
📊 My CrossClimber Stats

🎮 Games Played: $totalGames
🏆 Games Won: $totalWins
📈 Win Rate: ${winRate.toStringAsFixed(1)}%
⭐ Total Stars: $totalStars
⚡ Best Time: $timeStr

Can you beat my stats?
#CrossClimber #WordLadder
''';

    await Share.share(text);
  }
}
