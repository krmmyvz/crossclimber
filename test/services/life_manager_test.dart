import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crossclimber/services/life_manager.dart';
import 'package:crossclimber/services/progress_repository.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late LifeManager lifeManager;
  late MockProgressRepository mockRepo;

  setUp(() {
    mockRepo = MockProgressRepository();
    lifeManager = LifeManager(mockRepo);
  });

  group('LifeManager', () {
    group('decreaseLife', () {
      test('decreases life and returns new state', () async {
        when(() => mockRepo.removeLife()).thenAnswer((_) async {});
        when(() => mockRepo.getLives()).thenAnswer((_) async => 4);
        when(() => mockRepo.getLastLifeRegenTime()).thenAnswer((_) async => DateTime(2023, 1, 1));

        final result = await lifeManager.decreaseLife();

        verify(() => mockRepo.removeLife()).called(1);
        expect(result.lives, 4);
        expect(result.lastRegenTime, isNotNull);
        expect(result.success, isTrue);
      });
    });

    group('restoreLife', () {
      test('restores life successfully', () async {
        when(() => mockRepo.addLife(useCredits: true, creditCost: 50))
            .thenAnswer((_) async => true);
        when(() => mockRepo.getLives()).thenAnswer((_) async => 5);
        when(() => mockRepo.getLastLifeRegenTime()).thenAnswer((_) async => null);

        final result = await lifeManager.restoreLife(useCredits: true);

        expect(result.success, isTrue);
        expect(result.lives, 5);
      });

      test('fails to restore if addLife returns false', () async {
        when(() => mockRepo.addLife(useCredits: true, creditCost: 50))
            .thenAnswer((_) async => false);
        when(() => mockRepo.getLives()).thenAnswer((_) async => 0);
        when(() => mockRepo.getLastLifeRegenTime()).thenAnswer((_) async => null);

        final result = await lifeManager.restoreLife(useCredits: true);

        expect(result.success, isFalse);
        expect(result.lives, 0);
      });
    });

    group('checkRegeneration', () {
      test('returns null if lives are full', () async {
        final result = await lifeManager.checkRegeneration(
          currentLives: 5,
          lastRegenTime: DateTime.now().subtract(const Duration(minutes: 31)),
        );
        expect(result, isNull);
      });

      test('returns null if not enough time passed', () async {
        final result = await lifeManager.checkRegeneration(
          currentLives: 4,
          lastRegenTime: DateTime.now().subtract(const Duration(minutes: 10)),
        );
        expect(result, isNull);
      });

      test('returns updated state if time passed and repo updated', () async {
        // Mock repo to simulate it having regenerated life independently (since checkRegeneration queries repo)
        // Note: The logic in LifeManager relies on repo.getLives() returning a value > currentLives.
        // It seems LifeManager depends on ProgressRepository's internal logic for actual regeneration check during getLives()?
        // Re-reading LifeManager code:
        // if (timeSinceRegen.inMinutes < regenIntervalMinutes) return null;
        // final newLives = await _progressRepo.getLives();
        // if (newLives <= currentLives) return null;
        
        when(() => mockRepo.getLives()).thenAnswer((_) async => 5);
        when(() => mockRepo.getLastLifeRegenTime()).thenAnswer((_) async => null);

        final result = await lifeManager.checkRegeneration(
          currentLives: 4,
          lastRegenTime: DateTime.now().subtract(const Duration(minutes: 31)),
        );

        expect(result, isNotNull);
        expect(result!.lives, 5);
      });
    });
  });
}
