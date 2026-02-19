import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Feature keys for discovery tips
enum DiscoveryFeature { shop, achievements, daily }

extension DiscoveryFeatureKey on DiscoveryFeature {
  String get prefKey {
    switch (this) {
      case DiscoveryFeature.shop:
        return 'discovery_shop_seen';
      case DiscoveryFeature.achievements:
        return 'discovery_achievements_seen';
      case DiscoveryFeature.daily:
        return 'discovery_daily_seen';
    }
  }
}

/// Returns `true` if the discovery tip for [feature] has NOT yet been seen.
final discoveryTipProvider = FutureProvider.family<bool, DiscoveryFeature>((
  ref,
  feature,
) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(feature.prefKey) != true;
});

/// Marks the discovery tip for [feature] as seen.
Future<void> markDiscoveryTipSeen(DiscoveryFeature feature) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(feature.prefKey, true);
}
