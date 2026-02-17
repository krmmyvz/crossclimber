import 'package:flutter_test/flutter_test.dart';
import 'package:crossclimber/services/combo_tracker.dart';

void main() {
  late ComboTracker tracker;

  setUp(() {
    tracker = ComboTracker();
  });

  group('ComboTracker', () {
    group('getMultiplier', () {
      test('returns 1.0 for combo < 3', () {
        expect(tracker.getMultiplier(0), 1.0);
        expect(tracker.getMultiplier(2), 1.0);
      });

      test('returns 1.5 for combo 3-4', () {
        expect(tracker.getMultiplier(3), 1.5);
        expect(tracker.getMultiplier(4), 1.5);
      });

      test('returns 2.0 for combo 5-7', () {
        expect(tracker.getMultiplier(5), 2.0);
        expect(tracker.getMultiplier(7), 2.0);
      });

      test('returns 2.5 for combo 8+', () {
        expect(tracker.getMultiplier(8), 2.5);
        expect(tracker.getMultiplier(10), 2.5);
      });
    });

    group('increment', () {
      test('increases combo and updates maxCombo', () {
        final result = tracker.increment(
          currentCombo: 0,
          maxCombo: 0,
          currentBonus: 0,
        );

        expect(result.currentCombo, 1);
        expect(result.maxCombo, 1);
        // Base points: 10 * 1.0 = 10
        expect(result.comboPoints, 10);
        expect(result.comboBonus, 10);
      });

      test('does not update maxCombo if current is lower', () {
        final result = tracker.increment(
          currentCombo: 2,
          maxCombo: 10,
          currentBonus: 100,
        );

        expect(result.currentCombo, 3);
        expect(result.maxCombo, 10);
      });

      test('calculates points with multiplier', () {
        // Entering combo 3 (so current was 2, multiplier is 1.0 for the *next* step logic in code, wait)
        // Code says: `final multiplier = getMultiplier(currentCombo);` where currentCombo is the PRE-increment value passed in.
        // If passed 3, it uses multiplier for 3 (1.5).
        
        final result = tracker.increment(
          currentCombo: 3,
          maxCombo: 3,
          currentBonus: 50,
        );

        // Multiplier for 3 is 1.5. Points = 10 * 1.5 = 15.
        expect(result.currentCombo, 4);
        expect(result.comboPoints, 15);
        expect(result.comboBonus, 50 + 15);
      });
    });

    group('reset', () {
      test('resets current combo to 0 but keeps stats', () {
        final result = tracker.reset(
          maxCombo: 5,
          currentBonus: 200,
        );

        expect(result.currentCombo, 0);
        expect(result.maxCombo, 5);
        expect(result.comboBonus, 200);
        expect(result.comboPoints, 0);
      });
    });
  });
}
