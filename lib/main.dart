import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crossclimber/l10n/app_localizations.dart';

import 'package:crossclimber/screens/home_screen.dart';
import 'package:crossclimber/providers/locale_provider.dart';
import 'package:crossclimber/providers/settings_provider.dart';
import 'package:crossclimber/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: CrossclimbApp()));
}

class CrossclimbApp extends ConsumerWidget {
  const CrossclimbApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'CrossClimber',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(settings.customTheme, false),
      darkTheme: AppTheme.getTheme(settings.customTheme, true),
      themeMode: settings.customTheme != null
          ? ThemeMode.dark
          : settings.themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tr')],
      home: const HomeScreen(),
    );
  }
}
