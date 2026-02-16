import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crossclimber/theme/game_colors.dart';

class AppTheme {
  static ThemeData getTheme(String? customTheme, bool isSystemDark) {
    if (customTheme != null) {
      switch (customTheme) {
        case 'dracula':
          return dracula;
        case 'nord':
          return nord;
        case 'gruvbox':
          return gruvbox;
        case 'monokai':
          return monokai;
      }
    }
    return isSystemDark ? dark : light;
  }

  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(),
    extensions: const <ThemeExtension<dynamic>>[GameColors.light],
  );

  static final dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[GameColors.dark],
  );

  static final dracula = ThemeData(
    colorScheme: _buildCustomDarkScheme(
      seed: const Color(0xFFBD93F9),
      primary: const Color(0xFFBD93F9),
      onPrimary: const Color(0xFF1E1F29),
      secondary: const Color(0xFFFF79C6),
      onSecondary: const Color(0xFF1E1F29),
      tertiary: const Color(0xFF8BE9FD),
      surface: const Color(0xFF282A36),
      onSurface: const Color(0xFFF8F8F2),
      surfaceContainer: const Color(0xFF44475A),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF282A36),
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[GameColors.dracula],
  );

  static final nord = ThemeData(
    colorScheme: _buildCustomDarkScheme(
      seed: const Color(0xFF88C0D0),
      primary: const Color(0xFF88C0D0),
      onPrimary: const Color(0xFF2E3440),
      secondary: const Color(0xFF81A1C1),
      onSecondary: const Color(0xFF2E3440),
      tertiary: const Color(0xFFB48EAD),
      surface: const Color(0xFF2E3440),
      onSurface: const Color(0xFFECEFF4),
      surfaceContainer: const Color(0xFF3B4252),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF2E3440),
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[GameColors.nord],
  );

  static final gruvbox = ThemeData(
    colorScheme: _buildCustomDarkScheme(
      seed: const Color(0xFFFB4934),
      primary: const Color(0xFFFB4934),
      onPrimary: const Color(0xFF1D2021),
      secondary: const Color(0xFFB8BB26),
      onSecondary: const Color(0xFF1D2021),
      tertiary: const Color(0xFFFE8019),
      surface: const Color(0xFF282828),
      onSurface: const Color(0xFFFBF1C7),
      surfaceContainer: const Color(0xFF3C3836),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF282828),
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[GameColors.gruvbox],
  );

  static final monokai = ThemeData(
    colorScheme: _buildCustomDarkScheme(
      seed: const Color(0xFFF92672),
      primary: const Color(0xFFF92672),
      onPrimary: const Color(0xFF1B1C18),
      secondary: const Color(0xFFA6E22E),
      onSecondary: const Color(0xFF1B1C18),
      tertiary: const Color(0xFFFD971F),
      surface: const Color(0xFF272822),
      onSurface: const Color(0xFFF8F8F2),
      surfaceContainer: const Color(0xFF3E3D32),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF272822),
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[GameColors.monokai],
  );

  static ColorScheme _buildCustomDarkScheme({
    required Color seed,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color onSecondary,
    required Color tertiary,
    required Color surface,
    required Color onSurface,
    required Color surfaceContainer,
  }) {
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      tertiary: tertiary,
      surface: surface,
      onSurface: onSurface,
      surfaceContainer: surfaceContainer,
    );
  }
}
