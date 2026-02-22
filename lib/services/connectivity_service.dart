import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Monitors internet connectivity by periodically checking DNS resolution.
class ConnectivityService {
  static const _checkInterval = Duration(seconds: 15);
  static const _checkHost = 'google.com';

  final _controller = StreamController<bool>.broadcast();
  Timer? _timer;
  bool _lastKnown = true;

  /// Stream of connectivity changes (true = online, false = offline).
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Current known connectivity state.
  bool get isOnline => _lastKnown;

  /// Start periodic connectivity monitoring.
  void startMonitoring() {
    _checkNow();
    _timer = Timer.periodic(_checkInterval, (_) => _checkNow());
  }

  /// Stop monitoring.
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }

  /// Perform an immediate connectivity check.
  Future<bool> checkNow() => _checkNow();

  Future<bool> _checkNow() async {
    try {
      final result = await InternetAddress.lookup(_checkHost)
          .timeout(const Duration(seconds: 5));
      final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _update(online);
      return online;
    } on SocketException catch (_) {
      _update(false);
      return false;
    } on TimeoutException catch (_) {
      _update(false);
      return false;
    } catch (e) {
      debugPrint('ConnectivityService: check failed: $e');
      _update(false);
      return false;
    }
  }

  void _update(bool online) {
    if (online != _lastKnown) {
      _lastKnown = online;
      _controller.add(online);
    }
  }
}

// ── Riverpod providers ───────────────────────────────────────────────────────

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService()..startMonitoring();
  ref.onDispose(() => service.dispose());
  return service;
});

/// A stream provider that emits connectivity changes.
/// Widgets can `ref.watch(connectivityProvider)` to rebuild on change.
final connectivityProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  // Emit current state immediately, then stream changes
  return Stream.value(service.isOnline)
      .concatWith([service.onConnectivityChanged]);
});

/// Extension to concat streams.
extension _StreamConcat<T> on Stream<T> {
  Stream<T> concatWith(Iterable<Stream<T>> others) async* {
    yield* this;
    for (final stream in others) {
      yield* stream;
    }
  }
}
