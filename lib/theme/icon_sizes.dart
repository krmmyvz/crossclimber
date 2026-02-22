/// Design token: Standardized icon sizes
///
/// Replaces 40+ hardcoded icon size values across the codebase
/// with a consistent, semantic scale.
///
/// Usage:
/// ```dart
/// Icon(Icons.star, size: IconSizes.md)
/// ```
abstract final class IconSizes {
  /// 12px – Badge icons, tiny indicators
  static const double xs = 12;

  /// 14px – Small inline icons, compact UI elements
  static const double xsm = 14;

  /// 16px – Small icons, dense lists, secondary actions
  static const double sm = 16;

  /// 18px – Medium-small icons, buttons, navigation items
  static const double smd = 18;

  /// 20px – Medium icons, standard action buttons
  static const double md = 20;

  /// 22px – Medium-large icons, settings, list leading
  static const double mld = 22;

  /// 24px – Default icon size, primary actions
  static const double lg = 24;

  /// 28px – Large icons, prominent actions, card headers
  static const double xl = 28;

  /// 32px – Extra-large icons, shop items, feature cards
  static const double xxl = 32;

  /// 48px – Hero icons, dialogs, empty states
  static const double hero = 48;

  /// 64px – Display icons, onboarding, celebrations
  static const double display = 64;
}
