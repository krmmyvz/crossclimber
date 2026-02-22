import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/providers/locale_provider.dart';
import 'package:crossclimber/providers/game_provider.dart';
import 'package:crossclimber/providers/settings_provider.dart';
import 'package:crossclimber/screens/profile_screen.dart';
import 'package:crossclimber/services/progress_repository.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/page_transitions.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/responsive.dart';
import 'package:crossclimber/widgets/animated_settings_switch.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/widgets/theme_grid_selector.dart';
import 'package:crossclimber/services/auth_service.dart';
import 'package:crossclimber/providers/tutorial_provider.dart';

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
    final isTablet = Responsive.isTablet(context);
    final unlockedThemes = ref.watch(unlockedThemesProvider);
    final progressRepo = ref.read(progressRepositoryProvider);

    // Determine current theme key for the grid selector
    final currentThemeKey =
        settings.customTheme ??
        (settings.themeMode == ThemeMode.light
            ? 'light'
            : settings.themeMode == ThemeMode.dark
            ? 'dark'
            : 'system');

    // ── Build section groups ──────────────────────────────────────────────

    // 1. Profile & Account
    final profileGroup = _SettingsGroup(
      icon: Icons.person_rounded,
      title: l10n.settingsGroupProfile,
      children: [
        authState.when(
          data: (user) {
            final isAnonymous = user?.isAnonymous ?? true;
            // Use displayNameProvider for consistent name across the app
            final localName = ref.watch(displayNameProvider);
            final effectiveName = localName.isNotEmpty
                ? localName
                : user?.displayName;
            return _ProfileTile(
              isAnonymous: isAnonymous,
              email: user?.email,
              displayName: effectiveName,
              photoUrl: user?.photoURL,
              onTap: () {
                Navigator.of(
                  context,
                ).push(AppPageRoute(builder: (_) => const ProfileScreen()));
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(Spacing.m),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => ListTile(title: Text('Error: $err')),
        ),
      ],
    );

    // 2. Appearance (Language + Theme grid + high contrast)
    final appearanceGroup = _SettingsGroup(
      icon: Icons.palette_rounded,
      title: l10n.settingsGroupAppearance,
      children: [
        // Language selector
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.xs,
          ),
          child: Row(
            children: [
              Icon(
                Icons.language_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: IconSizes.mld,
              ),
              const SizedBox(width: Spacing.m),
              Expanded(
                child: Text(l10n.language, style: theme.textTheme.bodyLarge),
              ),
              DropdownButton<Locale>(
                value: currentLocale,
                underline: const SizedBox.shrink(),
                borderRadius: RadiiBR.md,
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
            ],
          ),
        ),
        const Divider(indent: Spacing.xl, endIndent: Spacing.m, height: 1),

        // Theme grid selector
        Padding(
          padding: const EdgeInsets.only(
            left: Spacing.m,
            top: Spacing.s,
            bottom: Spacing.xs,
          ),
          child: Text(
            l10n.chooseTheme,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ThemeGridSelector(
          currentThemeKey: currentThemeKey,
          unlockedPremiumThemes: unlockedThemes.value ?? const <String>{},
          onThemeSelected: (option) {
            final unlocked = unlockedThemes.value ?? const <String>{};
            final isLocked = option.isPremium && !unlocked.contains(option.key);
            if (isLocked) {
              _showPurchaseDialog(context, ref, option, progressRepo);
            } else {
              _applyTheme(option, settingsNotifier);
            }
          },
        ),
        const SizedBox(height: Spacing.xs),
        const Divider(indent: Spacing.xl, endIndent: Spacing.m, height: 1),

        // High contrast & custom keyboard
        AnimatedSwitchTile(
          icon: Icons.contrast_rounded,
          title: l10n.settingsHighContrast,
          subtitle: l10n.settingsHighContrastDesc,
          value: settings.highContrast,
          onChanged: (v) => settingsNotifier.toggleHighContrast(v),
        ),
        const Divider(indent: Spacing.xl, endIndent: Spacing.m, height: 1),
        AnimatedSwitchTile(
          icon: Icons.keyboard_rounded,
          title: l10n.customKeyboard,
          subtitle: l10n.customKeyboardDesc,
          value: settings.useCustomKeyboard,
          onChanged: (v) => settingsNotifier.toggleCustomKeyboard(v),
        ),
      ],
    );

    // 3. Sound & Haptics
    final soundGroup = _SettingsGroup(
      icon: Icons.volume_up_rounded,
      title: l10n.settingsGroupSoundHaptic,
      children: [
        AnimatedSwitchTile(
          icon: Icons.music_note_rounded,
          title: l10n.soundEffects,
          value: settings.soundEnabled,
          onChanged: (v) => settingsNotifier.toggleSound(v),
        ),
        AnimatedSwitchTile(
          icon: Icons.vibration_rounded,
          title: l10n.hapticFeedback,
          subtitle: l10n.hapticFeedbackDesc,
          value: settings.hapticEnabled,
          onChanged: (v) => settingsNotifier.toggleHaptic(v),
        ),
      ],
    );

    // 4. Gameplay
    final gameplayGroup = _SettingsGroup(
      icon: Icons.sports_esports_rounded,
      title: l10n.settingsGroupGameplay,
      children: [
        AnimatedSwitchTile(
          icon: Icons.timer_rounded,
          title: l10n.showTimer,
          value: settings.timerEnabled,
          onChanged: (v) => settingsNotifier.toggleTimer(v),
        ),
        AnimatedSwitchTile(
          icon: Icons.check_circle_outline_rounded,
          title: l10n.autoCheck,
          subtitle: l10n.autoCheckDesc,
          value: settings.autoCheck,
          onChanged: (v) => settingsNotifier.toggleAutoCheck(v),
        ),
        AnimatedSwitchTile(
          icon: Icons.sort_rounded,
          title: l10n.autoSort,
          subtitle: l10n.autoSortDesc,
          value: settings.autoSort,
          onChanged: (v) => settingsNotifier.toggleAutoSort(v),
        ),
      ],
    );

    // 5. Help & Info
    final helpGroup = _SettingsGroup(
      icon: Icons.help_outline_rounded,
      title: l10n.settingsGroupHelp,
      children: [
        _SettingsNavTile(
          icon: Icons.school_rounded,
          title: l10n.resetTutorial,
          onTap: () async {
            await ref.read(tutorialProgressProvider.notifier).resetTutorial();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.tutorialResetSuccess),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        _SettingsNavTile(
          icon: Icons.description_rounded,
          title: l10n.licenses,
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'CrossClimber',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.s + 2,
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: IconSizes.mld,
              ),
              const SizedBox(width: Spacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.about, style: theme.textTheme.bodyLarge),
                    Text(
                      '${l10n.version} 1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final allGroups = <Widget>[
      profileGroup,
      appearanceGroup,
      soundGroup,
      gameplayGroup,
      helpGroup,
    ];

    final clampedTextScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
      child: Scaffold(
        appBar: CommonAppBar(title: l10n.settings, type: AppBarType.standard),
        body: isTablet
            ? _buildTabletLayout(allGroups)
            : _buildPhoneLayout(allGroups),
      ),
    );
  }

  Widget _buildPhoneLayout(List<Widget> groups) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: Spacing.s, bottom: Spacing.xl),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return groups[index]
            .animate()
            .fadeIn(
              delay: StaggerDelay.fast(index),
              duration: AnimDurations.normal,
            )
            .slideY(
              begin: 0.04,
              end: 0,
              delay: StaggerDelay.fast(index),
              duration: AnimDurations.normal,
              curve: AppCurves.easeOut,
            );
      },
    );
  }

  Widget _buildTabletLayout(List<Widget> groups) {
    final leftGroups = groups.take(2).toList();
    final rightGroups = groups.skip(2).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: Spacing.s, bottom: Spacing.xl),
            children: leftGroups,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: Spacing.s, bottom: Spacing.xl),
            children: rightGroups,
          ),
        ),
      ],
    );
  }

  void _applyTheme(ThemeOption option, SettingsNotifier notifier) {
    switch (option.key) {
      case 'system':
        notifier.setThemeMode(ThemeMode.system);
        break;
      case 'light':
        notifier.setThemeMode(ThemeMode.light);
        break;
      case 'dark':
        notifier.setThemeMode(ThemeMode.dark);
        break;
      default:
        notifier.setCustomTheme(option.key);
    }
  }

  /// Shows a confirmation dialog to purchase a locked premium theme.
  void _showPurchaseDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeOption option,
    ProgressRepository progressRepo,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    const cost = ProgressRepository.themeCost;
    final credits = await progressRepo.getCredits();

    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dlgTheme = Theme.of(ctx);
        final canAfford = credits >= cost;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: RadiiBR.lg),
          title: Row(
            children: [
              Icon(Icons.palette_rounded, color: dlgTheme.colorScheme.primary),
              const SizedBox(width: Spacing.s),
              Expanded(
                child: Text(
                  l10n.unlockThemeTitle(option.label),
                  style: dlgTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini theme preview
              SizedBox(
                height: 80,
                child: ClipRRect(
                  borderRadius: RadiiBR.md,
                  child: Container(
                    color: option.surface,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPreviewSwatch(option.primary),
                        _buildPreviewSwatch(option.secondary),
                        _buildPreviewSwatch(option.tertiary),
                        _buildPreviewSwatch(option.surfaceContainer),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.m),
              Text(
                l10n.unlockThemeDesc(cost),
                style: dlgTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.s),
              Text(
                l10n.yourCredits(credits),
                style: dlgTheme.textTheme.bodySmall?.copyWith(
                  color: canAfford
                      ? dlgTheme.colorScheme.onSurfaceVariant
                      : dlgTheme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!canAfford) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  l10n.notEnoughCredits,
                  style: dlgTheme.textTheme.bodySmall?.copyWith(
                    color: dlgTheme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton.icon(
              onPressed: canAfford ? () => Navigator.of(ctx).pop(true) : null,
              icon: const Icon(Icons.diamond_rounded, size: IconSizes.smd),
              label: Text('${l10n.unlockButton}  $cost'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final success = await progressRepo.purchaseTheme(option.key);
      if (success && context.mounted) {
        // Refresh the unlocked themes provider
        ref.invalidate(unlockedThemesProvider);
        // Apply the newly unlocked theme
        final notifier = ref.read(settingsProvider.notifier);
        _applyTheme(option, notifier);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: Spacing.s),
                Text(l10n.themeUnlocked),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: RadiiBR.md),
          ),
        );
      }
    }
  }

  Widget _buildPreviewSwatch(Color color) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: RadiiBR.sm,
        border: Border.all(color: Colors.white.withValues(alpha: Opacities.gentle)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Grouped Settings Card (iOS-style)
// ══════════════════════════════════════════════════════════════════════════════

class _SettingsGroup extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SettingsGroup({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header: icon + title
          Padding(
            padding: const EdgeInsets.only(
              left: Spacing.s,
              bottom: Spacing.xs,
              top: Spacing.s,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: IconSizes.smd,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Card body
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: RadiiBR.lg,
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: Opacities.half),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Reusable tiles
// ══════════════════════════════════════════════════════════════════════════════

/// Profile preview tile with avatar and chevron.
class _ProfileTile extends StatelessWidget {
  final bool isAnonymous;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.isAnonymous,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty && !isAnonymous;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.m),
        child: Row(
          children: [
            hasPhoto
                ? CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(photoUrl!),
                    onBackgroundImageError: (_, __) {},
                    backgroundColor: theme.colorScheme.primaryContainer,
                  )
                : CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      isAnonymous ? Icons.person_outline : Icons.person,
                      color: theme.colorScheme.primary,
                    ),
                  ),
            const SizedBox(width: Spacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName ??
                        (isAnonymous ? l10n.guestUser : (email ?? '')),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isAnonymous ? l10n.linkAccountDesc : (email ?? ''),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation tile with icon, title, and chevron.
class _SettingsNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsNavTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m,
          vertical: Spacing.s + 2,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.onSurfaceVariant,
              size: IconSizes.mld,
            ),
            const SizedBox(width: Spacing.m),
            Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: IconSizes.md,
            ),
          ],
        ),
      ),
    );
  }
}
