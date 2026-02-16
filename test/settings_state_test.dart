import 'package:flutter_test/flutter_test.dart';
import 'package:crossclimber/providers/settings_provider.dart';

void main() {
  group('SettingsState.copyWith', () {
    test('allows clearing the custom theme explicitly', () {
      final state = SettingsState(customTheme: 'dracula');

      final updated = state.copyWith(customTheme: null);

      expect(updated.customTheme, isNull);
    });

    test('updates custom theme when provided', () {
      final state = SettingsState(customTheme: 'dracula');

      final updated = state.copyWith(customTheme: 'nord');

      expect(updated.customTheme, 'nord');
    });
  });
}
