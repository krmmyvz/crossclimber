import 'package:shared_preferences/shared_preferences.dart';

class ProgressRepository {
  static const String _keyHighestLevel = 'highest_unlocked_level';
  static const String _keyTotalScore = 'total_score';

  Future<int> getHighestUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHighestLevel) ?? 1;
  }

  Future<void> setHighestUnlockedLevel(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getHighestUnlockedLevel();
    if (levelId > current) {
      await prefs.setInt(_keyHighestLevel, levelId);
    }
  }

  Future<int> getTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalScore) ?? 0;
  }

  Future<void> addScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getTotalScore();
    await prefs.setInt(_keyTotalScore, current + score);
  }

  static const String _keyCredits = 'credits';
  
  // Lives keys
  static const String _keyLives = 'lives';
  static const String _keyLastLifeRegenTime = 'last_life_regen_time';
  static const int maxLives = 5;
  static const Duration lifeRegenDuration = Duration(minutes: 30); // 30 minutes per life
  
  // Hint stock keys
  static const String _keyRevealLetterHints = 'hint_reveal_letter';
  static const String _keyRevealWordHints = 'hint_reveal_word';
  static const String _keyRemoveWrongHints = 'hint_remove_wrong';
  static const String _keyShowFirstHints = 'hint_show_first';
  static const String _keyUndoHints = 'hint_undo';

  Future<int> getCredits() async {
    final prefs = await SharedPreferences.getInstance();
    // Start with 999 credits for testing
    if (!prefs.containsKey(_keyCredits)) {
      await prefs.setInt(_keyCredits, 999);
      return 999;
    }
    return prefs.getInt(_keyCredits) ?? 999;
  }

  Future<void> addCredits(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCredits();
    await prefs.setInt(_keyCredits, current + amount);
  }

  Future<bool> removeCredits(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCredits();
    if (current >= amount) {
      await prefs.setInt(_keyCredits, current - amount);
      return true;
    }
    return false;
  }

  // Hint stock management
  Future<int> getHintStock(String hintType) async {
    final prefs = await SharedPreferences.getInstance();
    String key;
    int defaultValue = 0;
    
    switch (hintType) {
      case 'revealLetter':
        key = _keyRevealLetterHints;
        defaultValue = 3; // Start with 3 free hints
        break;
      case 'revealWord':
        key = _keyRevealWordHints;
        defaultValue = 1; // Start with 1 free hint
        break;
      case 'removeWrongLetters':
      case 'removeWrong':
        key = _keyRemoveWrongHints;
        defaultValue = 2; // Start with 2 free hints
        break;
      case 'showFirst':
        key = _keyShowFirstHints;
        defaultValue = 2; // Start with 2 free hints
        break;
      case 'undo':
        key = _keyUndoHints;
        defaultValue = 5; // Start with 5 free undos
        break;
      default:
        return 0;
    }
    
    if (!prefs.containsKey(key)) {
      await prefs.setInt(key, defaultValue);
      return defaultValue;
    }
    return prefs.getInt(key) ?? 0;
  }

  Future<void> addHintStock(String hintType, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getHintStock(hintType);
    String key;
    
    switch (hintType) {
      case 'revealLetter':
        key = _keyRevealLetterHints;
        break;
      case 'revealWord':
        key = _keyRevealWordHints;
        break;
      case 'removeWrongLetters':
      case 'removeWrong':
        key = _keyRemoveWrongHints;
        break;
      case 'showFirst':
        key = _keyShowFirstHints;
        break;
      case 'undo':
        key = _keyUndoHints;
        break;
      default:
        return;
    }
    
    await prefs.setInt(key, current + amount);
  }

  Future<bool> useHintStock(String hintType) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getHintStock(hintType);
    
    if (current <= 0) return false;
    
    String key;
    switch (hintType) {
      case 'revealLetter':
        key = _keyRevealLetterHints;
        break;
      case 'revealWord':
        key = _keyRevealWordHints;
        break;
      case 'removeWrongLetters':
      case 'removeWrong':
        key = _keyRemoveWrongHints;
        break;
      case 'showFirst':
        key = _keyShowFirstHints;
        break;
      case 'undo':
        key = _keyUndoHints;
        break;
      default:
        return false;
    }
    
    await prefs.setInt(key, current - 1);
    return true;
  }

  // Lives management
  Future<int> getLives() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if we need to regenerate lives
    final lives = prefs.getInt(_keyLives) ?? maxLives;
    if (lives < maxLives) {
      final lastRegenString = prefs.getString(_keyLastLifeRegenTime);
      if (lastRegenString != null) {
        final lastRegen = DateTime.parse(lastRegenString);
        final now = DateTime.now();
        final timeSinceRegen = now.difference(lastRegen);
        final livesToRegenerate = timeSinceRegen.inMinutes ~/ lifeRegenDuration.inMinutes;
        
        if (livesToRegenerate > 0) {
          final newLives = (lives + livesToRegenerate).clamp(0, maxLives);
          await prefs.setInt(_keyLives, newLives);
          
          // Update last regen time
          final newLastRegen = lastRegen.add(Duration(minutes: livesToRegenerate * lifeRegenDuration.inMinutes));
          await prefs.setString(_keyLastLifeRegenTime, newLastRegen.toIso8601String());
          
          return newLives;
        }
      }
    }
    return lives;
  }

  Future<DateTime?> getLastLifeRegenTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRegenString = prefs.getString(_keyLastLifeRegenTime);
    if (lastRegenString != null) {
      return DateTime.parse(lastRegenString);
    }
    return null;
  }

  Future<void> removeLife() async {
    final prefs = await SharedPreferences.getInstance();
    final currentLives = await getLives();
    final newLives = (currentLives - 1).clamp(0, maxLives);
    await prefs.setInt(_keyLives, newLives);
    
    // If this is the first time losing a life (going from max to max-1), start the timer
    if (currentLives == maxLives && newLives < maxLives) {
      await prefs.setString(_keyLastLifeRegenTime, DateTime.now().toIso8601String());
    }
  }

  Future<bool> addLife({bool useCredits = false, int creditCost = 50}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentLives = await getLives();
    
    if (currentLives >= maxLives) return false;
    
    if (useCredits) {
      final hasCredits = await removeCredits(creditCost);
      if (!hasCredits) return false;
    }
    
    final newLives = (currentLives + 1).clamp(0, maxLives);
    await prefs.setInt(_keyLives, newLives);
    
    // If we reached max lives, clear the regen timer
    if (newLives == maxLives) {
      await prefs.remove(_keyLastLifeRegenTime);
    }
    
    return true;
  }

  Future<void> restoreAllLives({bool useCredits = false, int creditCost = 100}) async {
    if (useCredits) {
      final hasCredits = await removeCredits(creditCost);
      if (!hasCredits) return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLives, maxLives);
    await prefs.remove(_keyLastLifeRegenTime);
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHighestLevel);
    await prefs.remove(_keyTotalScore);
    await prefs.remove(_keyCredits);
    await prefs.remove(_keyRevealLetterHints);
    await prefs.remove(_keyRevealWordHints);
    await prefs.remove(_keyRemoveWrongHints);
    await prefs.remove(_keyShowFirstHints);
    await prefs.remove(_keyLives);
    await prefs.remove(_keyLastLifeRegenTime);
  }
}
