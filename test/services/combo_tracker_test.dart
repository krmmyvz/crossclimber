import 'package:flutter_test/flutter_test.dart';
import 'package:crossclimber/services/combo_tracker.dart';

void main() {
  late ComboTracker tracker;

  setUp(() {
    tracker = ComboTracker();
  });

  group('getMultiplier', () {
    test('returns 1.0 for combo 0-2', () {
      expect(tracker.getMultiplier(0), 1.0);
      expect(tracker.getMultiplier(1), 1.0);
      expect(tracker.getMultiplier(2), 1.0);
    });

    test('returns 1.5 for combo 3-4', () {
      expect(tracker.getMultiplier(3), 1.5);
      expect(tracker.getMultiplier(4), 1.5);
    });

    test('returns 2.0 for combo 5-7', () {
      expect(tracker.getMultiplier(5), 2.0);
      expect(tracker.getMultiplier(6), 2.0);
      expect(tracker.getMultiplier(7), 2.0);
    });

    test('returns 2.5 for combo 8+', () {
      expect(tracker.getMultiplier(8), 2.5);
      expect(tracker.getMultiplier(20), 2.5);
    });
  });

  group('increment', () {
    test('increments combo from 0', () {
      final result = tracker.increment(
        currentCombo: 0,
        maxCombo: 0,
        currentBonus: 0,
      );
      expect(result.currentCombo, 1);
      expect(result.maxCombo, 1);
      expect(result.comboPoints, 10); // 10 * 1.0
      expect(result.comboBonus, 10);
    });

    test('increments combo and tracks max', () {
      final result = tracker.increment(
        currentCombo: 3,
        maxCombo: 5,
        currentBonus: 50,
      );
      expect(result.currentCombo, 4);
      expect(result.maxCombo, 5); // max stays at 5
      expect(result.comboPoints, 15); // 10 * 1.5
      expect(result.comboBonus, 65);
    });

    test('updates maxCombo when current exceeds it', () {
      final result = tracker.increment(
        currentCombo: 5,
        maxCombo: 5,
        currentBonus: 0,
      );
      expect(result.currentCombo, 6);
      expect(result.maxCombo, 6);
    });

    test('applies correct multiplier at tier boundary', () {
      // combo=4 → multiplier=1.5, after increment combo=5
      final result = tracker.increment(
        currentCombo: 4,
        maxCombo: 4,
        currentBonus: 0,
      );
      expect(
        result.comboPoints,
        15,
      ); // 10 * 1.5 (based on pre-increment combo=4)
    });
  });

  group('reset', () {
    test('resets combo to 0 and preserves maxCombo and bonus', () {
      final result = tracker.reset(maxCombo: 7, currentBonus: 100);
      expect(result.currentCombo, 0);
      expect(result.maxCombo, 7);
      expect(result.comboBonus, 100);
      expect(result.comboPoints, 0);
    });
  });
}
