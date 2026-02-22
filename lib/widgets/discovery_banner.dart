import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crossclimber/providers/discovery_tip_provider.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/icon_sizes.dart';
import 'package:crossclimber/theme/opacities.dart';
import 'package:crossclimber/theme/spacing.dart';

/// Animated banner shown once on first visit to a feature screen.
///
/// Wrap a screen's body with this widget or insert it at the top of
/// the content column.
///
/// ```dart
/// DiscoveryBanner(
///   feature: DiscoveryFeature.shop,
///   icon: Icons.storefront_rounded,
///   title: l10n.discoveryShopTitle,
///   description: l10n.discoveryShopDesc,
///   ctaLabel: l10n.discoveryGotIt,
/// )
/// ```
class DiscoveryBanner extends ConsumerStatefulWidget {
  final DiscoveryFeature feature;
  final IconData icon;
  final String title;
  final String description;
  final String ctaLabel;

  const DiscoveryBanner({
    super.key,
    required this.feature,
    required this.icon,
    required this.title,
    required this.description,
    required this.ctaLabel,
  });

  @override
  ConsumerState<DiscoveryBanner> createState() => _DiscoveryBannerState();
}

class _DiscoveryBannerState extends ConsumerState<DiscoveryBanner> {
  bool _dismissed = false;

  Future<void> _dismiss() async {
    setState(() => _dismissed = true);
    await markDiscoveryTipSeen(widget.feature);
    // Invalidate provider so the banner is hidden on next visit too
    ref.invalidate(discoveryTipProvider(widget.feature));
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final asyncValue = ref.watch(discoveryTipProvider(widget.feature));

    return asyncValue.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (bool isFirstVisit) {
        if (!isFirstVisit) return const SizedBox.shrink();

        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.m,
            Spacing.s,
            Spacing.m,
            0,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
              ),
              borderRadius: RadiiBR.lg,
            ),
            child: Padding(
              padding: SpacingInsets.m,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Icon ──────────────────────────────────────────
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: Opacities.soft),
                      borderRadius: RadiiBR.md,
                    ),
                    child: Icon(
                      widget.icon,
                      size: IconSizes.mld,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  HorizontalSpacing.m,

                  // ── Text ──────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        VerticalSpacing.xs,
                        Text(
                          widget.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: Opacities.heavy),
                            height: 1.4,
                          ),
                        ),
                        VerticalSpacing.s,
                        TextButton(
                          onPressed: _dismiss,
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.m,
                              vertical: Spacing.xs,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor:
                                theme.colorScheme.primary.withValues(
                                  alpha: Opacities.soft,
                                ),
                            foregroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: RadiiBR.sm,
                            ),
                          ),
                          child: Text(
                            widget.ctaLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Close ─────────────────────────────────────────
                  GestureDetector(
                    onTap: _dismiss,
                    child: Icon(
                      Icons.close_rounded,
                      size: IconSizes.smd,
                      color: theme.colorScheme.onPrimaryContainer
                          .withValues(alpha: Opacities.strong),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: AnimDurations.medium, delay: AnimDurations.normal)
            .slideY(
              begin: -0.2,
              end: 0,
              duration: AnimDurations.medium,
              delay: AnimDurations.normal,
              curve: Curves.easeOut,
            );
      },
    );
  }
}
