import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/locale_provider.dart';
import 'package:crossclimber/providers/settings_provider.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: CommonAppBar(title: l10n.settings, type: AppBarType.standard),
      body: ListView(
        children: [
          // Language Section
          ListTile(
            title: Text(l10n.language),
            leading: const Icon(Icons.language),
            trailing: DropdownButton<Locale>(
              value: currentLocale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  ref.read(localeProvider.notifier).setLocale(newLocale);
                }
              },
              items: [
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text(l10n.english),
                ),
                DropdownMenuItem(
                  value: const Locale('tr'),
                  child: Text(l10n.turkish),
                ),
              ],
            ),
          ),
          const Divider(),

          // Theme Section
          _SettingsSection(
            title: l10n.appearance,
            children: [
              ListTile(
                title: Text(l10n.theme),
                trailing: DropdownButton<String>(
                  value: settings.customTheme ?? settings.themeMode.toString(),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system.toString(),
                      child: Text(l10n.system),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light.toString(),
                      child: Text(l10n.light),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark.toString(),
                      child: Text(l10n.dark),
                    ),
                    const DropdownMenuItem(
                      value: 'dracula',
                      child: Text('Dracula'),
                    ),
                    const DropdownMenuItem(value: 'nord', child: Text('Nord')),
                    const DropdownMenuItem(
                      value: 'gruvbox',
                      child: Text('Gruvbox'),
                    ),
                    const DropdownMenuItem(
                      value: 'monokai',
                      child: Text('Monokai'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null &&
                        (value == 'dracula' ||
                            value == 'nord' ||
                            value == 'gruvbox' ||
                            value == 'monokai')) {
                      ref.read(settingsProvider.notifier).setCustomTheme(value);
                    } else if (value != null) {
                      ThemeMode mode = ThemeMode.system;
                      if (value == ThemeMode.light.toString()) {
                        mode = ThemeMode.light;
                      }
                      if (value == ThemeMode.dark.toString()) {
                        mode = ThemeMode.dark;
                      }
                      ref.read(settingsProvider.notifier).setThemeMode(mode);
                    }
                  },
                ),
              ),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.customKeyboard),
                subtitle: Text(
                  AppLocalizations.of(context)!.customKeyboardDesc,
                ),
                value: settings.useCustomKeyboard,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .toggleCustomKeyboard(value);
                },
              ),
            ],
          ),

          const Divider(),

          // Gameplay Options
          ListTile(
            title: Text(l10n.soundEffects),
            leading: const Icon(Icons.volume_up),
            trailing: Switch(
              value: settings.soundEnabled,
              onChanged: (value) => settingsNotifier.toggleSound(value),
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.hapticFeedback),
            subtitle: Text(AppLocalizations.of(context)!.hapticFeedbackDesc),
            leading: const Icon(Icons.vibration),
            trailing: Switch(
              value: settings.hapticEnabled,
              onChanged: (value) => settingsNotifier.toggleHaptic(value),
            ),
          ),
          ListTile(
            title: Text(l10n.showTimer),
            leading: const Icon(Icons.timer),
            trailing: Switch(
              value: settings.timerEnabled,
              onChanged: (value) => settingsNotifier.toggleTimer(value),
            ),
          ),
          ListTile(
            title: Text(l10n.autoCheck),
            subtitle: Text(l10n.autoCheckDesc),
            leading: const Icon(Icons.check_circle_outline),
            trailing: Switch(
              value: settings.autoCheck,
              onChanged: (value) => settingsNotifier.toggleAutoCheck(value),
            ),
          ),
          ListTile(
            title: Text(l10n.autoSort),
            subtitle: Text(l10n.autoSortDesc),
            leading: const Icon(Icons.sort),
            trailing: Switch(
              value: settings.autoSort,
              onChanged: (value) => settingsNotifier.toggleAutoSort(value),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.m,
            Spacing.m,
            Spacing.m,
            Spacing.s,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
