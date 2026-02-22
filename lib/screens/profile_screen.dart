import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/l10n/app_localizations.dart';
import 'package:crossclimber/services/auth_service.dart';
import 'package:crossclimber/services/user_sync_service.dart';
import 'package:crossclimber/services/xp_service.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/widgets/app_progress_bar.dart';
import 'package:crossclimber/widgets/common_app_bar.dart';
import 'package:crossclimber/widgets/offline_banner.dart';
import 'package:crossclimber/widgets/skeleton_loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Avatar presets ─────────────────────────────────────────────────────────
const List<IconData> kAvatarIcons = [
  Icons.sentiment_satisfied_rounded,
  Icons.face_rounded,
  Icons.psychology_rounded,
  Icons.psychology_alt_rounded,
  Icons.pets_rounded,
  Icons.cruelty_free_rounded,
  Icons.air_rounded,
  Icons.spa_rounded,
  Icons.auto_awesome_rounded,
  Icons.local_fire_department_rounded,
  Icons.videogame_asset_rounded,
  Icons.terrain_rounded,
];

const String _kAvatarKey = 'profile_avatar_index';
const String _kDisplayNameKey = 'profile_display_name';

/// Provider for avatar index persisted in SharedPreferences.
final avatarIndexProvider = NotifierProvider<AvatarIndexNotifier, int>(
  AvatarIndexNotifier.new,
);

class AvatarIndexNotifier extends Notifier<int> {
  @override
  int build() {
    _load();
    return 0;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_kAvatarKey) ?? 0;
  }

  Future<void> setIndex(int index) async {
    state = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAvatarKey, index);
    // Sync to Firestore
    ref.read(userSyncServiceProvider).uploadUserData();
  }
}

/// Provider for display name persisted in SharedPreferences.
final displayNameProvider = NotifierProvider<DisplayNameNotifier, String>(
  DisplayNameNotifier.new,
);

class DisplayNameNotifier extends Notifier<String> {
  @override
  String build() {
    _load();
    return '';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kDisplayNameKey);
    if (saved != null && saved.isNotEmpty) {
      state = saved;
    } else {
      // Fall back to Firebase displayName for Google-signed-in users
      final user = ref.read(authStateProvider).asData?.value;
      if (user != null && !user.isAnonymous && user.displayName != null) {
        state = user.displayName!;
        await prefs.setString(_kDisplayNameKey, user.displayName!);
      }
    }
  }

  Future<void> setName(String name) async {
    state = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDisplayNameKey, name);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Profile Screen
// ══════════════════════════════════════════════════════════════════════════════

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final currentName = ref.read(displayNameProvider);
    _nameController = TextEditingController(text: currentName);
    _nameController.addListener(_onNameChanged);
    // Sync name from SharedPreferences async if empty
    if (currentName.isEmpty) {
      SharedPreferences.getInstance().then((prefs) {
        final saved = prefs.getString('profile_display_name') ?? '';
        if (saved.isNotEmpty && mounted) {
          _nameController.text = saved;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final original = ref.read(displayNameProvider);
    setState(() {
      _hasChanges = _nameController.text.trim() != original;
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    await ref.read(displayNameProvider.notifier).setName(name);

    // Also update Firebase display name if logged in
    final user = ref.read(authStateProvider).asData?.value;
    if (user != null && !user.isAnonymous) {
      try {
        await user.updateDisplayName(name);
      } catch (_) {}
    }

    // Sync to Firestore
    ref.read(userSyncServiceProvider).uploadUserData();

    setState(() => _hasChanges = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profileSaved),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;
    final avatarIndex = ref.watch(avatarIndexProvider);
    final rankAsync = ref.watch(playerRankInfoProvider);
    final authState = ref.watch(authStateProvider);

    final clampedTextScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
      child: Scaffold(
        appBar: CommonAppBar(
          title: l10n.profileTitle,
          type: AppBarType.standard,
        ),
        body: ListView(
          padding: const EdgeInsets.all(Spacing.m),
          children:
              [
                    // ── Avatar + Name Section ──────────────────────────────
                    _buildAvatarSection(theme, gameColors, avatarIndex, l10n),

                    VerticalSpacing.l,

                    // ── Rank & XP Section ──────────────────────────────────
                    _buildRankSection(theme, gameColors, rankAsync, l10n),

                    VerticalSpacing.l,

                    // ── Connected Accounts ──────────────────────────────────
                    _buildConnectedAccountsSection(theme, authState, l10n),

                    VerticalSpacing.l,

                    // ── Danger Zone: Account Deletion ──────────────────────
                    _buildDangerZone(theme, authState, l10n),
                  ]
                  .asMap()
                  .entries
                  .map(
                    (e) => e.value
                        .animate()
                        .fadeIn(
                          delay: StaggerDelay.fast(e.key),
                          duration: AnimDurations.normal,
                        )
                        .slideY(
                          begin: 0.04,
                          delay: StaggerDelay.fast(e.key),
                          duration: AnimDurations.normal,
                          curve: AppCurves.easeOut,
                        ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  // ── Avatar + Name ────────────────────────────────────────────────────────

  Widget _buildAvatarSection(
    ThemeData theme,
    GameColors gameColors,
    int avatarIndex,
    AppLocalizations l10n,
  ) {
    // Show Google photo if signed in with Google
    final user = ref.watch(authStateProvider).asData?.value;
    final hasGooglePhoto = user != null &&
        !user.isAnonymous &&
        user.photoURL != null &&
        user.photoURL!.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: RadiiBR.lg,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: Opacities.half),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: Column(
          children: [
            // Avatar with edit button
            GestureDetector(
              onTap: () => _showAvatarPicker(theme, avatarIndex),
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: gameColors.star.withValues(alpha: Opacities.subtle),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: gameColors.star.withValues(alpha: Opacities.semi),
                        width: 3,
                      ),
                    ),
                    child: hasGooglePhoto
                        ? ClipOval(
                            child: Image.network(
                              user.photoURL!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  kAvatarIcons[avatarIndex.clamp(0, kAvatarIcons.length - 1)],
                                  size: IconSizes.xxl,
                                  color: gameColors.star,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              kAvatarIcons[avatarIndex.clamp(
                                0,
                                kAvatarIcons.length - 1,
                              )],
                              size: IconSizes.xxl,
                              color: gameColors.star,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: IconSizes.sm,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            VerticalSpacing.m,

            // Display name text field
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: l10n.displayNameHint,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
                labelText: l10n.displayName,
                border: OutlineInputBorder(borderRadius: RadiiBR.md),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.m,
                  vertical: Spacing.s,
                ),
              ),
              maxLength: 24,
            ),

            if (_hasChanges) ...[
              VerticalSpacing.s,
              FilledButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save_rounded, size: IconSizes.smd),
                label: Text(l10n.saveProfile),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(ThemeData theme, int currentIndex) {
    final gameColors = theme.gameColors;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return Padding(
          padding: const EdgeInsets.all(Spacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.chooseAvatar,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              VerticalSpacing.m,
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(ctx).size.width < 360 ? 4 : 6,
                  mainAxisSpacing: Spacing.s,
                  crossAxisSpacing: Spacing.s,
                ),
                itemCount: kAvatarIcons.length,
                itemBuilder: (context, index) {
                  final isSelected = index == currentIndex;
                  return GestureDetector(
                    onTap: () {
                      ref.read(avatarIndexProvider.notifier).setIndex(index);
                      Navigator.of(ctx).pop();
                    },
                    child:
                        AnimatedContainer(
                              duration: AnimDurations.fast,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? gameColors.star.withValues(alpha: Opacities.soft)
                                    : theme.colorScheme.surfaceContainerHighest
                                          .withValues(alpha: Opacities.half),
                                borderRadius: RadiiBR.md,
                                border: Border.all(
                                  color: isSelected
                                      ? gameColors.star
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  kAvatarIcons[index],
                                  size: IconSizes.lg,
                                  color: isSelected
                                      ? gameColors.star
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: StaggerDelay.extraFast(index))
                            .scaleXY(
                              begin: 0.8,
                              end: 1,
                              delay: StaggerDelay.extraFast(index),
                              curve: AppCurves.spring,
                            ),
                  );
                },
              ),
              VerticalSpacing.m,
            ],
          ),
        );
      },
    );
  }

  // ── Rank & XP ────────────────────────────────────────────────────────────

  Widget _buildRankSection(
    ThemeData theme,
    GameColors gameColors,
    AsyncValue<RankInfo> rankAsync,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: RadiiBR.lg,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: Opacities.half),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: rankAsync.when(
          loading: () => const Column(
            children: [
              SkeletonCard(height: 48, width: 48),
              VerticalSpacing.s,
              SkeletonCard(height: 20, width: 120),
              VerticalSpacing.s,
              SkeletonCard(height: 12),
            ],
          ),
          error: (e, _) => Text('Error: $e'),
          data: (rankInfo) {
            final rankDef = kRankDefs[rankInfo.rankIndex];
            final localizedName = rankDef.localizedName(l10n);

            return Column(
              children: [
                // Rank badge
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: gameColors.star.withValues(alpha: Opacities.subtle),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          rankInfo.icon,
                          size: IconSizes.lg,
                          color: gameColors.star,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.rankLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            localizedName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: gameColors.star,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.totalXp,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${rankInfo.totalXp}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: gameColors.star,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                VerticalSpacing.m,

                // XP progress bar
                AppProgressBar(
                  value: rankInfo.progress,
                  color: gameColors.star,
                  backgroundColor: gameColors.star.withValues(alpha: Opacities.light),
                ),
                const SizedBox(height: Spacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${rankInfo.rankThreshold} XP',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (!rankInfo.isMaxRank)
                      Text(
                        '${rankInfo.nextThreshold} XP',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),

                if (!rankInfo.isMaxRank) ...[
                  VerticalSpacing.xs,
                  Text(
                    '${rankInfo.xpToNextRank} XP ${l10n.rankLabel.toLowerCase()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: gameColors.star,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Connected Accounts ──────────────────────────────────────────────────

  Widget _buildConnectedAccountsSection(
    ThemeData theme,
    AsyncValue authState,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: RadiiBR.lg,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: Opacities.half),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.s),
              child: Text(
                l10n.connectedAccounts,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            authState.when(
              data: (user) {
                final isAnonymous = user?.isAnonymous ?? true;
                final hasGoogle =
                    user?.providerData.any(
                      (p) => p.providerId == 'google.com',
                    ) ??
                    false;

                return _AccountRow(
                  icon: Icons.g_mobiledata_rounded,
                  iconColor: const Color(0xFF4285F4),
                  title: hasGoogle
                      ? l10n.googleConnected
                      : l10n.googleNotConnected,
                  subtitle: hasGoogle ? (user?.email ?? '') : null,
                  actionLabel: hasGoogle
                      ? l10n.disconnectGoogle
                      : isAnonymous
                      ? l10n.googleSignIn
                      : l10n.connectGoogle,
                  isConnected: hasGoogle,
                  onAction: () async {
                    if (!OfflineGuard.check(ref, context)) return;
                    final authService = ref.read(authServiceProvider);
                    final syncService = ref.read(userSyncServiceProvider);
                    if (hasGoogle) {
                      // Upload before sign-out so data isn't lost
                      await syncService.uploadUserData();
                      await authService.signOut();
                    } else {
                      final result = await authService.linkWithGoogle();
                      if (result != null) {
                        // Sync: download remote data (if exists), then upload local
                        final downloaded = await syncService.downloadUserData();
                        if (downloaded) {
                          // Refresh local providers after downloading remote data
                          ref.invalidate(avatarIndexProvider);
                          ref.invalidate(displayNameProvider);
                        }
                        await syncService.uploadUserData();
                        // Update display name from Google if local is empty
                        final googleName = result.user?.displayName;
                        final currentName = ref.read(displayNameProvider);
                        if (currentName.isEmpty && googleName != null && googleName.isNotEmpty) {
                          await ref.read(displayNameProvider.notifier).setName(googleName);
                        }
                      }
                    }
                  },
                );
              },
              loading: () => const Column(
                children: [
                  SkeletonCard(height: 56),
                  VerticalSpacing.s,
                  SkeletonCard(height: 56),
                ],
              ),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Danger Zone ──────────────────────────────────────────────────────────

  Widget _buildDangerZone(
    ThemeData theme,
    AsyncValue authState,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: RadiiBR.lg,
        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: Opacities.medium)),
      ),
      child: InkWell(
        onTap: () => _showDeleteAccountDialog(theme, l10n),
        borderRadius: RadiiBR.lg,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.m),
          child: Row(
            children: [
              Icon(
                Icons.delete_forever_rounded,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: Spacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.deleteAccount,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.deleteAccountDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error.withValues(alpha: Opacities.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(
    ThemeData theme,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
            size: IconSizes.hero,
          ),
          title: Text(l10n.deleteAccount),
          content: Text(l10n.deleteAccountConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: Text(l10n.deleteAccountButton),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        final authService = ref.read(authServiceProvider);
        final user = authService.currentUser;
        if (user != null) {
          // Clear local data
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          // Delete Firebase account
          await user.delete();
        }
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Helper Widgets
// ══════════════════════════════════════════════════════════════════════════════

class _AccountRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String actionLabel;
  final bool isConnected;
  final VoidCallback onAction;

  const _AccountRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.actionLabel,
    required this.isConnected,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: Opacities.subtle),
              borderRadius: RadiiBR.sm,
            ),
            child: Icon(icon, color: iconColor, size: IconSizes.lg),
          ),
          const SizedBox(width: Spacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          isConnected
              ? OutlinedButton(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
                    visualDensity: VisualDensity.compact,
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                      color: theme.colorScheme.error.withValues(alpha: Opacities.half),
                    ),
                  ),
                  child: Text(actionLabel),
                )
              : FilledButton.tonal(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(actionLabel),
                ),
        ],
      ),
    );
  }
}
