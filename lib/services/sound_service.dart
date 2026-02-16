import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

enum SoundEffect { correct, wrong, complete, hint, tap, move, star }

final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService();
});

class SoundService {
  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;

  Future<void> initialize() async {
    // Set global audio context if needed
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  Future<void> play(SoundEffect effect) async {
    if (!_soundEnabled) return;

    try {
      final soundPath = _getSoundPath(effect);
      final volume = _getVolume(effect);

      // We use a new player for overlapping sounds (like rapid taps)
      // or stop and play for single channel.
      // For simple UI sounds, stop->play is often enough or AudioPlayer mode.
      // crossclimber: rapid taps might cut off. Let's start simple with one player
      // or use AudioCache (now built-in).
      // Ideally for UI taps we want overlap.

      // Using mode: PlayerMode.lowLatency is default for sound effects
      await _player.play(
        AssetSource(soundPath),
        volume: volume,
        ctx: AudioContext(
          android: const AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none, // Don't duck music
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient, // Mix with music
          ),
        ),
      );
    } catch (e) {
      // Silently fail if sound can't be played (e.g. asset missing)
      // debugPrint('Error playing sound: $e');
    }
  }

  String _getSoundPath(SoundEffect effect) {
    // Assets should be in assets/sounds/
    switch (effect) {
      case SoundEffect.correct:
        return 'sounds/correct.mp3';
      case SoundEffect.wrong:
        return 'sounds/wrong.mp3';
      case SoundEffect.complete:
        return 'sounds/complete.mp3';
      case SoundEffect.hint:
        return 'sounds/hint.mp3';
      case SoundEffect.tap:
        return 'sounds/tap.mp3';
      case SoundEffect.move:
        return 'sounds/move.mp3';
      case SoundEffect.star:
        return 'sounds/star.mp3';
    }
  }

  double _getVolume(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.complete:
      case SoundEffect.star:
        return 0.8;
      case SoundEffect.correct:
        return 0.6;
      case SoundEffect.tap:
      case SoundEffect.move:
        return 0.3;
      default:
        return 0.5;
    }
  }

  void dispose() {
    _player.dispose();
  }
}
