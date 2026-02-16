import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

enum HapticType { light, medium, heavy, success, warning, error, selection }

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});

class HapticService {
  bool _hapticEnabled = true;

  void setHapticEnabled(bool enabled) {
    _hapticEnabled = enabled;
  }

  Future<void> trigger(HapticType type) async {
    if (!_hapticEnabled) return;

    try {
      final hasVibrator = await Vibration.hasVibrator();

      if (!hasVibrator) {
        // Fallback to system haptics
        _triggerSystemHaptic(type);
        return;
      }

      switch (type) {
        case HapticType.light:
          await Vibration.vibrate(duration: 10, amplitude: 50);
          break;
        case HapticType.medium:
          await Vibration.vibrate(duration: 20, amplitude: 128);
          break;
        case HapticType.heavy:
          await Vibration.vibrate(duration: 30, amplitude: 200);
          break;
        case HapticType.success:
          // Double tap pattern
          await Vibration.vibrate(duration: 50, amplitude: 150);
          await Future.delayed(const Duration(milliseconds: 50));
          await Vibration.vibrate(duration: 50, amplitude: 150);
          break;
        case HapticType.warning:
          // Triple short taps
          for (int i = 0; i < 3; i++) {
            await Vibration.vibrate(duration: 30, amplitude: 100);
            await Future.delayed(const Duration(milliseconds: 30));
          }
          break;
        case HapticType.error:
          // Longer buzz
          await Vibration.vibrate(duration: 200, amplitude: 255);
          break;
        case HapticType.selection:
          // Very light tap
          await Vibration.vibrate(duration: 5, amplitude: 30);
          break;
      }
    } catch (e) {
      // Fallback to system haptics if custom vibration fails
      _triggerSystemHaptic(type);
    }
  }

  void _triggerSystemHaptic(HapticType type) {
    switch (type) {
      case HapticType.light:
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
      case HapticType.error:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.success:
        HapticFeedback.lightImpact();
        break;
      case HapticType.warning:
        HapticFeedback.vibrate();
        break;
    }
  }
}
