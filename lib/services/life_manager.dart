import 'package:crossclimber/services/progress_repository.dart';

/// Result of a life operation.
class LifeResult {
  final int lives;
  final DateTime? lastRegenTime;
  final bool success;

  const LifeResult({
    required this.lives,
    required this.lastRegenTime,
    this.success = true,
  });
}

/// Manages the player's life system: decrease, restore, and regeneration.
///
/// Delegates persistence to [ProgressRepository].
class LifeManager {
  final ProgressRepository _progressRepo;

  /// Maximum lives a player can have.
  static const int maxLives = 5;

  /// Minutes between life regenerations.
  static const int regenIntervalMinutes = 30;

  LifeManager(this._progressRepo);

  /// Decreases life by 1. Returns updated life state.
  Future<LifeResult> decreaseLife() async {
    await _progressRepo.removeLife();
    final newLives = await _progressRepo.getLives();
    final newRegenTime = await _progressRepo.getLastLifeRegenTime();
    return LifeResult(lives: newLives, lastRegenTime: newRegenTime);
  }

  /// Restores a single life, optionally using credits.
  Future<LifeResult> restoreLife({
    bool useCredits = false,
    int creditCost = 50,
  }) async {
    final success = await _progressRepo.addLife(
      useCredits: useCredits,
      creditCost: creditCost,
    );

    if (!success) {
      final currentLives = await _progressRepo.getLives();
      final regenTime = await _progressRepo.getLastLifeRegenTime();
      return LifeResult(
        lives: currentLives,
        lastRegenTime: regenTime,
        success: false,
      );
    }

    final newLives = await _progressRepo.getLives();
    final newRegenTime = await _progressRepo.getLastLifeRegenTime();
    return LifeResult(lives: newLives, lastRegenTime: newRegenTime);
  }

  /// Restores all lives to max, optionally using credits.
  Future<LifeResult> restoreAllLives({
    bool useCredits = false,
    int creditCost = 100,
  }) async {
    await _progressRepo.restoreAllLives(
      useCredits: useCredits,
      creditCost: creditCost,
    );

    final newLives = await _progressRepo.getLives();
    return LifeResult(lives: newLives, lastRegenTime: null);
  }

  /// Checks if a life should be regenerated based on elapsed time.
  /// Returns null if no regeneration is needed.
  Future<LifeResult?> checkRegeneration({
    required int currentLives,
    required DateTime? lastRegenTime,
  }) async {
    if (currentLives >= maxLives || lastRegenTime == null) return null;

    final now = DateTime.now();
    final timeSinceRegen = now.difference(lastRegenTime);

    if (timeSinceRegen.inMinutes < regenIntervalMinutes) return null;

    final newLives = await _progressRepo.getLives();
    final newRegenTime = await _progressRepo.getLastLifeRegenTime();

    // Only return result if lives actually changed
    if (newLives <= currentLives) return null;

    return LifeResult(lives: newLives, lastRegenTime: newRegenTime);
  }
}
