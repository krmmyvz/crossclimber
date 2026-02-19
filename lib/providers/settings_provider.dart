import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  static const _customThemeSentinel = Object();

  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool timerEnabled;
  final bool autoCheck;
  final bool autoSort;
  final bool useCustomKeyboard;
  final bool highContrast;
  final String? customTheme;

  SettingsState({
    this.themeMode = ThemeMode.system,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.timerEnabled = true,
    this.autoCheck = false,
    this.autoSort = false,
    this.useCustomKeyboard = false,
    this.highContrast = false,
    this.customTheme,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? timerEnabled,
    bool? autoCheck,
    bool? autoSort,
    bool? useCustomKeyboard,
    bool? highContrast,
    Object? customTheme = _customThemeSentinel,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      timerEnabled: timerEnabled ?? this.timerEnabled,
      autoCheck: autoCheck ?? this.autoCheck,
      autoSort: autoSort ?? this.autoSort,
      useCustomKeyboard: useCustomKeyboard ?? this.useCustomKeyboard,
      highContrast: highContrast ?? this.highContrast,
      customTheme: identical(customTheme, _customThemeSentinel)
          ? this.customTheme
          : customTheme as String?,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _loadSettings();
    return SettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex =
        prefs.getInt('themeMode') ?? 0; // 0: system, 1: light, 2: dark
    final sound = prefs.getBool('sound') ?? true;
    final haptic = prefs.getBool('haptic') ?? true;
    final timer = prefs.getBool('timer') ?? true;
    final autoCheck = prefs.getBool('autoCheck') ?? false;
    final autoSort = prefs.getBool('autoSort') ?? false;
    final customKeyboard = prefs.getBool('customKeyboard') ?? false;
    final customTheme = prefs.getString('customTheme');
    final highContrast = prefs.getBool('highContrast') ?? false;

    ThemeMode mode;
    switch (themeIndex) {
      case 1:
        mode = ThemeMode.light;
        break;
      case 2:
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }

    state = SettingsState(
      themeMode: mode,
      soundEnabled: sound,
      hapticEnabled: haptic,
      timerEnabled: timer,
      autoCheck: autoCheck,
      autoSort: autoSort,
      useCustomKeyboard: customKeyboard,
      highContrast: highContrast,
      customTheme: customTheme,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(
      themeMode: mode,
      customTheme: null,
    ); // Clear custom theme when standard mode selected
    final prefs = await SharedPreferences.getInstance();
    int index = 0;
    if (mode == ThemeMode.light) index = 1;
    if (mode == ThemeMode.dark) index = 2;
    await prefs.setInt('themeMode', index);
    await prefs.remove('customTheme');
  }

  Future<void> setCustomTheme(String themeName) async {
    state = state.copyWith(customTheme: themeName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customTheme', themeName);
  }

  Future<void> toggleSound(bool value) async {
    state = state.copyWith(soundEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', value);
  }

  Future<void> toggleHaptic(bool value) async {
    state = state.copyWith(hapticEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic', value);
  }

  Future<void> toggleTimer(bool value) async {
    state = state.copyWith(timerEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('timer', value);
  }

  Future<void> toggleAutoCheck(bool value) async {
    state = state.copyWith(autoCheck: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoCheck', value);
  }

  Future<void> toggleAutoSort(bool value) async {
    state = state.copyWith(autoSort: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSort', value);
  }

  Future<void> toggleCustomKeyboard(bool value) async {
    state = state.copyWith(useCustomKeyboard: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('customKeyboard', value);
  }

  Future<void> toggleHighContrast(bool value) async {
    state = state.copyWith(highContrast: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
