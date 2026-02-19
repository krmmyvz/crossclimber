import 'package:share_plus/share_plus.dart';
import 'package:crossclimber/l10n/app_localizations.dart';

class ShareService {
  static Future<void> shareResult({
    required AppLocalizations l10n,
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
${l10n.shareResultHeader(levelId)}
${l10n.scoreLabel}: $score
${l10n.timeLabel}: $timeStr
${l10n.starsLabel}: $starEmoji

#CrossClimber #WordGame #PuzzleGame
''';

    await Share.share(text, subject: 'CrossClimber Level $levelId');
  }

  static Future<void> shareAchievement({
    required AppLocalizations l10n,
    required String achievementName,
    required String achievementIcon,
  }) async {
    final text =
        '''
${l10n.shareAchievementUnlocked}

$achievementIcon $achievementName

${l10n.shareAchievementCTA}
#CrossClimber #Achievement
''';

    await Share.share(text);
  }

  static Future<void> shareDailyChallenge({
    required AppLocalizations l10n,
    required int levelId,
    required bool completed,
    required int stars,
    int? score,
    Duration? time,
  }) async {
    final starEmoji = completed ? '⭐' * stars : '❌';

    final scoreStr = score != null ? '\n🏆 ${l10n.scoreLabel}: $score' : '';
    String timeStr = '';
    if (time != null) {
      final minutes = time.inMinutes;
      final seconds = time.inSeconds % 60;
      timeStr = '\n⏱️ ${l10n.timeLabel}: $minutes:${seconds.toString().padLeft(2, '0')}';
    }

    final text =
        '''
${l10n.shareDailyChallengeTitle}

${completed ? l10n.shareDailyLevelCompleted(levelId) : l10n.shareDailyLevelFailed(levelId)}
$starEmoji ${completed ? '$stars/3 Stars' : ''}$scoreStr$timeStr

${l10n.shareDailyChallengeCTA}
#CrossClimber #DailyChallenge
''';

    await Share.share(text);
  }

  static Future<void> shareStats({
    required AppLocalizations l10n,
    required int totalLevels,
    required int totalStars,
    required int currentStreak,
    required double winRate,
  }) async {
    final text =
        '''
${l10n.shareMyStatsTitle}

🏆 ${l10n.levelsLabel}: $totalLevels
⭐ ${l10n.totalStarsEarned}: $totalStars
🔥 ${l10n.currentStreak}: $currentStreak
📈 ${l10n.winRate}: ${winRate.toStringAsFixed(1)}%

${l10n.shareStatsCTA}
#CrossClimber #GameStats
''';

    await Share.share(text);
  }

  static Future<void> shareStatistics({
    required AppLocalizations l10n,
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
${l10n.shareMyStatsTitle}

🎮 ${l10n.gamesPlayed}: $totalGames
🏆 ${l10n.gamesWon}: $totalWins
📈 ${l10n.winRate}: ${winRate.toStringAsFixed(1)}%
⭐ ${l10n.totalStarsEarned}: $totalStars
⚡ ${l10n.bestTime}: $timeStr

${l10n.shareStatisticsCTA}
#CrossClimber #WordLadder
''';

    await Share.share(text);
  }
}
