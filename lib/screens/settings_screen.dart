import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/locale_provider.dart';
import 'package:crossclimber/providers/settings_provider.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';

import 'package:crossclimber/services/auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final authState = ref.watch(authStateProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: CommonAppBar(title: l10n.settings, type: AppBarType.standard),
      body: ListView(
        children: [
          // Profile Section
          _SettingsSection(
            title: l10n.profile,
            children: [
              authState.when(
                data: (user) {
                  final isAnonymous = user?.isAnonymous ?? true;
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          isAnonymous
                              ? l10n.guestUser
                              : l10n.loggedInAs(user?.email ?? ''),
                        ),
                        subtitle: isAnonymous ? Text(l10n.linkAccountDesc) : null,
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            isAnonymous ? Icons.person_outline : Icons.person,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
                        child: SizedBox(
                          width: double.infinity,
                          child: isAnonymous
                              ? ElevatedButton.icon(
                                  onPressed: () => authService.linkWithGoogle(),
                                  icon: const Icon(Icons.login),
                                  label: Text(l10n.googleSignIn),
                                )
                              : TextButton.icon(
                                  onPressed: () => authService.signOut(),
                                  icon: const Icon(Icons.logout),
                                  label: Text(l10n.signOut),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => ListTile(title: Text('Error: $err')),
              ),
            ],
          ),
          const Divider(),

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
              SwitchListTile(
                title: Text(l10n.settingsHighContrast),
                subtitle: Text(l10n.settingsHighContrastDesc),
                value: settings.highContrast,
                secondary: const Icon(Icons.contrast),
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .toggleHighContrast(value);
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
