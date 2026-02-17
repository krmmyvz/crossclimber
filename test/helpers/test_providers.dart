import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crossclimber/services/progress_repository.dart';
import 'package:crossclimber/services/statistics_repository.dart';
import 'package:crossclimber/services/achievement_service.dart';
import 'package:crossclimber/services/daily_challenge_service.dart';
import 'package:crossclimber/services/sound_service.dart';
import 'package:crossclimber/services/haptic_service.dart';
import 'package:crossclimber/providers/game_provider.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}
class MockStatisticsRepository extends Mock implements StatisticsRepository {}
class MockAchievementService extends Mock implements AchievementService {}
class MockDailyChallengeService extends Mock implements DailyChallengeService {}
class MockSoundService extends Mock implements SoundService {}
class MockHapticService extends Mock implements HapticService {}

/// Helper to create a ProviderContainer with common mocks
ProviderContainer createTestContainer({
  ProgressRepository? progressRepo,
  StatisticsRepository? statisticsRepo,
  AchievementService? achievementService,
  DailyChallengeService? dailyChallengeService,
  SoundService? soundService,
  HapticService? hapticService,
}) {
  return ProviderContainer(
    overrides: [
      progressRepositoryProvider.overrideWithValue(progressRepo ?? MockProgressRepository()),
      statisticsRepositoryProvider.overrideWithValue(statisticsRepo ?? MockStatisticsRepository()),
      achievementServiceProvider.overrideWithValue(achievementService ?? MockAchievementService()),
      dailyChallengeServiceProvider.overrideWithValue(dailyChallengeService ?? MockDailyChallengeService()),
      soundServiceProvider.overrideWithValue(soundService ?? MockSoundService()),
      hapticServiceProvider.overrideWithValue(hapticService ?? MockHapticService()),
    ],
  );
}
