import 'package:flutter/material.dart';
import 'package:crossclimber/providers/game_state.dart';
import 'package:crossclimber/models/level.dart';
import 'package:crossclimber/providers/settings_provider.dart';
import 'package:crossclimber/widgets/custom_keyboard.dart';

class GameKeyboardSection extends StatelessWidget {
  final GameState gameState;
  final Level level;
  final SettingsState settings;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String languageCode;
  final Function(String) onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final Function(String) onChanged;

  const GameKeyboardSection({
    super.key,
    required this.gameState,
    required this.level,
    required this.settings,
    required this.controller,
    required this.focusNode,
    required this.languageCode,
    required this.onKeyTap,
    required this.onBackspace,
    required this.onSubmit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (settings.useCustomKeyboard) {
      return CustomKeyboard(
        languageCode: languageCode,
        highlightedKeys: gameState.temporaryHighlightedKeys,
        onKeyTap: onKeyTap,
        onBackspace: onBackspace,
        onSubmit: onSubmit,
      );
    }

    // Use a 1x1 invisible container instead of Offstage to ensure
    // the TextField is part of the layout and handles focus/keyboard correctly.
    return Opacity(
      opacity: 0,
      child: SizedBox(
        width: 1,
        height: 1,
        child: Semantics(
          label: 'Hidden input for keyboard',
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLength: level.startWord.length,
            textCapitalization: TextCapitalization.characters,
            onChanged: onChanged,
            onSubmitted: (_) => onSubmit(),
          ),
        ),
      ),
    );
  }
}
