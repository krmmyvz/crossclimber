import 'dart:async';

/// Manages the game timer with start/stop/pause capability.
///
/// Ticks every second and calls [onTick] with the elapsed duration.
class GameTimerService {
  Timer? _timer;

  /// Starts the timer. [onTick] is called every second with the incremented duration.
  void start(void Function() onTick) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      onTick();
    });
  }

  /// Stops the timer without disposing.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Disposes the timer and releases resources.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
