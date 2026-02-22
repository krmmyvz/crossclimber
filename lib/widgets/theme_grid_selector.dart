import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/theme/app_theme.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/shadows.dart';
import 'package:crossclimber/theme/spacing.dart';

/// Data class representing a theme option with its preview colors.
class ThemeOption {
  final String key;
  final String label;
  final ThemeData themeData;
  final bool isPremium;

  const ThemeOption({
    required this.key,
    required this.label,
    required this.themeData,
    this.isPremium = false,
  });

  Color get surface => themeData.colorScheme.surface;
  Color get primary => themeData.colorScheme.primary;
  Color get secondary => themeData.colorScheme.secondary;
  Color get tertiary => themeData.colorScheme.tertiary;
  Color get onSurface => themeData.colorScheme.onSurface;
  Color get surfaceContainer => themeData.colorScheme.surfaceContainer;
}

/// A visual grid of theme preview cards. Each card shows a mini game board
/// preview with the theme's actual colors.
class ThemeGridSelector extends StatelessWidget {
  final String currentThemeKey;
  final ValueChanged<ThemeOption> onThemeSelected;
  final Set<String> unlockedPremiumThemes;

  const ThemeGridSelector({
    super.key,
    required this.currentThemeKey,
    required this.onThemeSelected,
    this.unlockedPremiumThemes = const {},
  });

  static List<ThemeOption> buildOptions(String Function(String) localizer) {
    return [
      ThemeOption(
        key: 'system',
        label: localizer('system'),
        themeData: AppTheme.light,
      ),
      ThemeOption(
        key: 'light',
        label: localizer('light'),
        themeData: AppTheme.light,
      ),
      ThemeOption(
        key: 'dark',
        label: localizer('dark'),
        themeData: AppTheme.dark,
      ),
      ThemeOption(
        key: 'dracula',
        label: 'Dracula',
        themeData: AppTheme.dracula,
        isPremium: true,
      ),
      ThemeOption(
        key: 'nord',
        label: 'Nord',
        themeData: AppTheme.nord,
        isPremium: true,
      ),
      ThemeOption(
        key: 'gruvbox',
        label: 'Gruvbox',
        themeData: AppTheme.gruvbox,
        isPremium: true,
      ),
      ThemeOption(
        key: 'monokai',
        label: 'Monokai',
        themeData: AppTheme.monokai,
        isPremium: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final options = buildOptions((key) {
      switch (key) {
        case 'system':
          return 'System';
        case 'light':
          return 'Light';
        case 'dark':
          return 'Dark';
        default:
          return key;
      }
    });

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: Spacing.s,
        crossAxisSpacing: Spacing.s,
        childAspectRatio: 0.82,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = currentThemeKey == option.key;
        final isLocked = option.isPremium &&
            !unlockedPremiumThemes.contains(option.key);

        return _ThemePreviewCard(
          option: option,
          isSelected: isSelected,
          isLocked: isLocked,
          onTap: () => onThemeSelected(option),
        )
            .animate()
            .fadeIn(
              delay: StaggerDelay.extraFast(index),
              duration: AnimDurations.normal,
            )
            .scaleXY(
              begin: 0.9,
              end: 1,
              delay: StaggerDelay.extraFast(index),
              duration: AnimDurations.normal,
              curve: AppCurves.spring,
            );
      },
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final ThemeOption option;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.option,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AnimDurations.normal,
        curve: AppCurves.standard,
        decoration: BoxDecoration(
          borderRadius: RadiiBR.md,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: Opacities.half),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  AppShadows.colorMedium(theme.colorScheme.primary),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: RadiiBR.sm,
          child: Stack(
            children: [
              // Mini game board preview
              _buildMiniPreview(option),

              // Lock overlay for premium themes
              if (isLocked)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: Opacities.semi),
                    child: Center(
                      child: Icon(
                        Icons.lock_rounded,
                        color: Colors.white.withValues(alpha: Opacities.heavy),
                        size: IconSizes.lg,
                      ),
                    ),
                  ),
                ),

              // Selection checkmark
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: IconSizes.xsm,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Theme name label
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: option.surface.withValues(alpha: Opacities.near),
                  ),
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: option.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a mini game board preview showing the theme's colors.
  /// Mimics a simplified CrossClimber game board with colored tiles.
  Widget _buildMiniPreview(ThemeOption option) {
    return Container(
      color: option.surface,
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 2),
          // Top word row
          _buildTileRow(
            [option.primary, option.primary, option.primary, option.primary],
            option.surfaceContainer,
          ),
          const SizedBox(height: 3),
          // Middle word rows
          _buildTileRow(
            [option.secondary, option.secondary, option.surfaceContainer, option.surfaceContainer],
            option.surfaceContainer,
          ),
          const SizedBox(height: 3),
          _buildTileRow(
            [option.surfaceContainer, option.tertiary, option.tertiary, option.surfaceContainer],
            option.surfaceContainer,
          ),
          const SizedBox(height: 3),
          // Bottom word row
          _buildTileRow(
            [option.primary, option.primary, option.primary, option.primary],
            option.surfaceContainer,
          ),
          const SizedBox(height: 6),
          // Mini keyboard hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => Container(
                width: 8,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: option.surfaceContainer,
                  borderRadius: RadiiBR.xxs,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileRow(List<Color> colors, Color emptyColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors.map((c) {
        return Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: c,
            borderRadius: RadiiBR.xxs,
          ),
        );
      }).toList(),
    );
  }
}
