import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crossclimber/services/haptic_service.dart';
import 'package:crossclimber/theme/animations.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/game_colors.dart';
import 'package:crossclimber/theme/spacing.dart';
import 'package:crossclimber/theme/responsive.dart';

class CustomKeyboard extends ConsumerWidget {
  final Function(String) onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final String languageCode;
  final Set<String> highlightedKeys;

  const CustomKeyboard({
    super.key,
    required this.onKeyTap,
    required this.onBackspace,
    required this.onSubmit,
    this.languageCode = 'en',
    this.highlightedKeys = const {},
  });

  // Get keyboard layout for language - all keys must fit in 3 rows
  List<List<String>> _getKeyboardLayout(String langCode) {
    if (langCode == 'tr') {
      return [
        ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ğ', 'Ü'],
        ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ş', 'İ'],
        ['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'Ö', 'Ç'],
      ];
    }
    // English - default
    return [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final layout = _getKeyboardLayout(languageCode);
    final hapticService = ref.read(hapticServiceProvider);

    // Calculate the maximum keys in any row to determine sizing
    final maxKeysInRow = layout
        .map((row) => row.length)
        .reduce((a, b) => a > b ? a : b);

    return SafeArea(
      child:
          Container(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            color: theme.colorScheme.surfaceContainerHigh,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1
                _buildRow(context, layout[0], maxKeysInRow, hapticService),
                const SizedBox(height: Spacing.xs + Spacing.xxs),
                // Row 2
                _buildRow(context, layout[1], maxKeysInRow, hapticService),
                const SizedBox(height: 6),
                // Row 3 with action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.check,
                      label: 'Submit',
                      color: theme.colorScheme.primary,
                      onTap: onSubmit,
                      keyCount: maxKeysInRow,
                      hapticService: hapticService,
                    ),
                    ..._buildKeyList(
                      context,
                      layout[2],
                      maxKeysInRow,
                      hapticService,
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.backspace_outlined,
                      label: 'Backspace',
                      color: theme.colorScheme.error,
                      onTap: onBackspace,
                      keyCount: maxKeysInRow,
                      hapticService: hapticService,
                    ),
                  ],
                ),
              ],
            ),
          ).animate().slideY(
            begin: 1,
            end: 0,
            duration: AnimDurations.normal,
            curve: Curves.easeOutQuad,
          ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    List<String> keys,
    int maxKeys,
    HapticService hapticService,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildKeyList(context, keys, maxKeys, hapticService),
    );
  }

  List<Widget> _buildKeyList(
    BuildContext context,
    List<String> keys,
    int maxKeys,
    HapticService hapticService,
  ) {
    return keys
        .map((key) => _buildKey(context, key, maxKeys, hapticService))
        .toList();
  }

  Widget _buildKey(
    BuildContext context,
    String key,
    int maxKeys,
    HapticService hapticService,
  ) {
    return _KeyButton(
      letter: key,
      maxKeys: maxKeys,
      isHighlighted: highlightedKeys.contains(key),
      onTap: () {
        hapticService.trigger(HapticType.selection);
        onKeyTap(key);
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int keyCount,
    required HapticService hapticService,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = Responsive.isCompact(context);
    final availableWidth = screenWidth - (isCompact ? 16 : 90);
    final baseKeyWidth = (availableWidth / keyCount).clamp(
      26.0,
      Responsive.isTablet(context) ? 64.0 : 42.0,
    );
    final width = (baseKeyWidth * 1.5).clamp(
      42.0,
      Responsive.isTablet(context) ? 80.0 : 58.0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      width: width,
      height: Responsive.isTablet(context) ? 56 : 44,
      child: Material(
        color: color.withValues(alpha: 0.2),
        borderRadius: RadiiBR.xs,
        child: InkWell(
          onTap: () {
            hapticService.trigger(HapticType.light);
            onTap();
          },
          borderRadius: RadiiBR.xs,
          child: Semantics(
            label: label,
            button: true,
            enabled: true,
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: Responsive.getIconSize(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyButton extends StatefulWidget {
  final String letter;
  final int maxKeys;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _KeyButton({
    required this.letter,
    required this.maxKeys,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColors = theme.gameColors;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = Responsive.isCompact(context);
    final isTablet = Responsive.isTablet(context);

    final availableWidth = screenWidth - (isCompact ? 16 : 90);
    final keyWidth = (availableWidth / widget.maxKeys).clamp(
      26.0,
      isTablet ? 64.0 : 42.0,
    );
    final keyHeight = isTablet ? 56.0 : 44.0;

    // Background color with highlight support
    Color backgroundColor;
    if (widget.isHighlighted) {
      // Glowing green when highlighted by hint
      backgroundColor = gameColors.correct.withValues(alpha: 0.3);
    } else if (_isPressed) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.4);
    } else {
      backgroundColor = theme.colorScheme.surfaceContainerHigh;
    }

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child:
          AnimatedContainer(
                duration: AnimDurations.micro,
                margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                width: keyWidth,
                height: keyHeight,
                transform: _isPressed
                    ? (Matrix4.identity()..scale(0.95))
                    : Matrix4.identity(),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: RadiiBR.xs,
                  boxShadow: widget.isHighlighted
                      ? [
                          // Glowing effect when highlighted
                          BoxShadow(
                            color: gameColors.correct.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : _isPressed
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    widget.letter,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getFontSize(
                        context,
                        keyWidth > 32 ? 15 : 13,
                      ),
                      color: widget.isHighlighted
                          ? gameColors
                                .correct // Correct color when highlighted
                          : _isPressed
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ),
              )
              .animate(target: widget.isHighlighted ? 1 : 0)
              .scale(
                duration: AnimDurations.normal,
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.1, 1.1),
                curve: Curves.easeOut,
              )
              .then()
              .shimmer(
                duration: AnimDurations.slower,
                color: gameColors.correct.withValues(alpha: 0.3),
              ),
    );
  }
}
