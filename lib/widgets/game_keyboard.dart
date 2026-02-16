import 'package:flutter/material.dart';
import 'package:crossclimber/theme/border_radius.dart';
import 'package:crossclimber/theme/spacing.dart';

class GameKeyboard extends StatefulWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onEnter;
  final bool showTurkishChars;

  const GameKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onEnter,
    this.showTurkishChars = false,
  });

  @override
  State<GameKeyboard> createState() => _GameKeyboardState();
}

class _GameKeyboardState extends State<GameKeyboard> {
  bool _showTurkishLayout = false;

  @override
  Widget build(BuildContext context) {
    final keys = _showTurkishLayout
        ? [
            ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ğ', 'Ü'],
            ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ş', 'İ'],
            ['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'Ö', 'Ç'],
          ]
        : [
            ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
            ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
            ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
          ];

    return Container(
      padding: SpacingInsets.s,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row in keys)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((key) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: _KeyButton(
                      label: key,
                      onTap: () => widget.onKeyPressed(key),
                    ),
                  );
                }).toList(),
              ),
            ),
          VerticalSpacing.xs,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.showTurkishChars)
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: _ActionButton(
                    icon: _showTurkishLayout
                        ? Icons.language
                        : Icons.language_outlined,
                    label: 'TR',
                    onTap: () {
                      setState(() {
                        _showTurkishLayout = !_showTurkishLayout;
                      });
                    },
                  ),
                ),
              HorizontalSpacing.s,
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: _ActionButton(
                  icon: Icons.backspace_outlined,
                  onTap: widget.onBackspace,
                  width: 64,
                ),
              ),
              HorizontalSpacing.m,
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: _ActionButton(
                  icon: Icons.check,
                  onTap: widget.onEnter,
                  isPrimary: true,
                  width: 72,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: RadiiBR.sm,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiiBR.sm,
        child: Container(
          width: 30,
          height: 44,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final double width;
  final String? label;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.width = 56,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: isPrimary ? colorScheme.primary : colorScheme.surfaceContainerHigh,
      borderRadius: RadiiBR.sm,
      elevation: isPrimary ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiiBR.sm,
        child: Container(
          width: width,
          height: 44,
          alignment: Alignment.center,
          child: label != null
              ? Text(
                  label!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPrimary
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                )
              : Icon(
                  icon,
                  size: 20,
                  color: isPrimary
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
        ),
      ),
    );
  }
}
