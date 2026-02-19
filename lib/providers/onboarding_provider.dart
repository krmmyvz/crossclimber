import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kHasLaunchedBefore = 'hasLaunchedBefore';

/// Returns `true` when this is the user's first launch (onboarding not yet seen).
final isFirstLaunchProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kHasLaunchedBefore) != true;
});

/// Exposes [completeOnboarding] to mark first-launch finished.
final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, void>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasLaunchedBefore, true);
  }
}
