import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/connectivity_service.dart';
import 'package:crossclimber/theme/spacing.dart';

/// Contextual offline guard — checks connectivity and shows a snackbar
/// when the user tries to perform an action that requires internet.
///
/// Returns `true` if online (action can proceed), `false` if offline.
///
/// Usage in a ConsumerWidget:
/// ```dart
/// onTap: () {
///   if (!OfflineGuard.check(ref, context)) return;
///   // proceed with online action
/// }
/// ```
class OfflineGuard {
  OfflineGuard._();

  /// Checks if the device is online. If offline, shows a snackbar
  /// with the offline message and returns `false`.
  static bool check(WidgetRef ref, BuildContext context) {
    final connectivity = ref.read(connectivityProvider);
    final isOnline = connectivity.whenOrNull(data: (v) => v) ?? true;

    if (!isOnline) {
      _showOfflineSnackBar(context);
      return false;
    }
    return true;
  }

  /// Async version — performs a fresh DNS check before deciding.
  /// Use when accuracy is more important than speed.
  static Future<bool> checkAsync(WidgetRef ref, BuildContext context) async {
    final service = ref.read(connectivityServiceProvider);
    final isOnline = await service.checkNow();

    if (!isOnline && context.mounted) {
      _showOfflineSnackBar(context);
      return false;
    }
    return isOnline;
  }

  static void _showOfflineSnackBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: theme.colorScheme.onError, size: 18),
              HorizontalSpacing.s,
              Expanded(
                child: Text(
                  l10n?.offlineBanner ?? 'You are offline. Some features may be unavailable.',
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
