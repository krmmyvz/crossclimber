import 'package:flutter/material.dart';

/// Theme extension for game-specific colors
/// Provides semantic color names that adapt to the current theme
class GameColors extends ThemeExtension<GameColors> {
  // Success/Achievement colors
  final Color success;
  final Color successContainer;
  final Color onSuccess;
  final Color onSuccessContainer;

  // Warning/Attention colors
  final Color warning;
  final Color warningContainer;
  final Color onWarning;
  final Color onWarningContainer;

  // Star/Achievement colors
  final Color star;
  final Color starContainer;
  final Color onStar;

  // Streak/Fire colors
  final Color streak;
  final Color streakContainer;
  final Color onStreak;

  // Validation colors (for correct/incorrect answers)
  final Color correct;
  final Color incorrect;
  final Color onCorrect;
  final Color onIncorrect;

  // Hint colors
  final Color hint;
  final Color hintContainer;
  final Color onHint;

  // Lives/Health colors
  final Color lives;
  final Color onLives;

  const GameColors({
    required this.success,
    required this.successContainer,
    required this.onSuccess,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarning,
    required this.onWarningContainer,
    required this.star,
    required this.starContainer,
    required this.onStar,
    required this.streak,
    required this.streakContainer,
    required this.onStreak,
    required this.correct,
    required this.incorrect,
    required this.onCorrect,
    required this.onIncorrect,
    required this.hint,
    required this.hintContainer,
    required this.onHint,
    required this.lives,
    required this.onLives,
  });

  @override
  GameColors copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccess,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarning,
    Color? onWarningContainer,
    Color? star,
    Color? starContainer,
    Color? onStar,
    Color? streak,
    Color? streakContainer,
    Color? onStreak,
    Color? correct,
    Color? incorrect,
    Color? onCorrect,
    Color? onIncorrect,
    Color? hint,
    Color? hintContainer,
    Color? onHint,
    Color? lives,
    Color? onLives,
  }) {
    return GameColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccess: onSuccess ?? this.onSuccess,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarning: onWarning ?? this.onWarning,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      star: star ?? this.star,
      starContainer: starContainer ?? this.starContainer,
      onStar: onStar ?? this.onStar,
      streak: streak ?? this.streak,
      streakContainer: streakContainer ?? this.streakContainer,
      onStreak: onStreak ?? this.onStreak,
      correct: correct ?? this.correct,
      incorrect: incorrect ?? this.incorrect,
      onCorrect: onCorrect ?? this.onCorrect,
      onIncorrect: onIncorrect ?? this.onIncorrect,
      hint: hint ?? this.hint,
      hintContainer: hintContainer ?? this.hintContainer,
      onHint: onHint ?? this.onHint,
      lives: lives ?? this.lives,
      onLives: onLives ?? this.onLives,
    );
  }

  @override
  GameColors lerp(ThemeExtension<GameColors>? other, double t) {
    if (other is! GameColors) return this;

    return GameColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      star: Color.lerp(star, other.star, t)!,
      starContainer: Color.lerp(starContainer, other.starContainer, t)!,
      onStar: Color.lerp(onStar, other.onStar, t)!,
      streak: Color.lerp(streak, other.streak, t)!,
      streakContainer: Color.lerp(streakContainer, other.streakContainer, t)!,
      onStreak: Color.lerp(onStreak, other.onStreak, t)!,
      correct: Color.lerp(correct, other.correct, t)!,
      incorrect: Color.lerp(incorrect, other.incorrect, t)!,
      onCorrect: Color.lerp(onCorrect, other.onCorrect, t)!,
      onIncorrect: Color.lerp(onIncorrect, other.onIncorrect, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      hintContainer: Color.lerp(hintContainer, other.hintContainer, t)!,
      onHint: Color.lerp(onHint, other.onHint, t)!,
      lives: Color.lerp(lives, other.lives, t)!,
      onLives: Color.lerp(onLives, other.onLives, t)!,
    );
  }

  // Light theme colors
  static const light = GameColors(
    success: Color(0xFF4CAF50),
    successContainer: Color(0xFFE8F5E9),
    onSuccess: Colors.white,
    onSuccessContainer: Color(0xFF1B5E20),
    warning: Color(0xFFFF9800),
    warningContainer: Color(0xFFFFF3E0),
    onWarning: Colors.black,
    onWarningContainer: Color(0xFFE65100),
    star: Color(0xFFFFB300), // Amber
    starContainer: Color(0xFFFFF8E1),
    onStar: Colors.black,
    streak: Color(0xFFFF6F00), // Deep Orange
    streakContainer: Color(0xFFFBE9E7),
    onStreak: Colors.white,
    correct: Color(0xFF4CAF50),
    incorrect: Color(0xFFEF5350),
    onCorrect: Colors.white,
    onIncorrect: Colors.white,
    hint: Color(0xFF2196F3), // Blue
    hintContainer: Color(0xFFE3F2FD),
    onHint: Colors.white,
    lives: Color(0xFFD32F2F), // Red
    onLives: Colors.white,
  );

  // Dark theme colors
  static const dark = GameColors(
    success: Color(0xFF81C784),
    successContainer: Color(0xFF2E7D32),
    onSuccess: Color(0xFF003300), // Dark text on light green
    onSuccessContainer: Color(0xFFE8F5E9),
    warning: Color(0xFFFFB74D),
    warningContainer: Color(0xFFEF6C00),
    onWarning: Color(0xFF4E2600), // Dark text on light orange
    onWarningContainer: Color(0xFFFFF3E0),
    star: Color(0xFFFFD54F),
    starContainer: Color(0xFFF57F17),
    onStar: Color(0xFF4E2600),
    streak: Color(0xFFFF8A65),
    streakContainer: Color(0xFFD84315),
    onStreak: Color(0xFF4E1500),
    correct: Color(0xFF81C784),
    incorrect: Color(0xFFE57373),
    onCorrect: Color(0xFF003300),
    onIncorrect: Color(0xFF4E1500),
    hint: Color(0xFF64B5F6), // Light Blue
    hintContainer: Color(0xFF1565C0),
    onHint: Colors.white,
    lives: Color(0xFFE57373), // Soft Red
    onLives: Color(0xFF4E1500),
  );

  // Dracula theme colors (purple/pink based)
  static const dracula = GameColors(
    success: Color(0xFF50FA7B), // Dracula green
    successContainer: Color(0xFF2E4D35),
    onSuccess: Color(0xFF282A36), // Dark bg color for contrast
    onSuccessContainer: Color(0xFFF8F8F2),
    warning: Color(0xFFFFB86C), // Dracula orange
    warningContainer: Color(0xFF4D3D2E),
    onWarning: Color(0xFF282A36),
    onWarningContainer: Color(0xFFF8F8F2),
    star: Color(0xFFF1FA8C), // Dracula yellow
    starContainer: Color(0xFF4D4A2E),
    onStar: Color(0xFF282A36),
    streak: Color(0xFFFF79C6), // Dracula pink
    streakContainer: Color(0xFF4D2E3D),
    onStreak: Color(0xFF282A36),
    correct: Color(0xFF50FA7B),
    incorrect: Color(0xFFFF5555), // Dracula red
    onCorrect: Color(0xFF282A36),
    onIncorrect: Color(0xFF282A36),
    hint: Color(0xFF8BE9FD), // Dracula cyan
    hintContainer: Color(0xFF44475A), // Dracula selection
    onHint: Color(0xFF282A36),
    lives: Color(0xFFFF5555), // Dracula red
    onLives: Color(0xFF282A36),
  );

  // Nord theme colors (blue/cyan based)
  static const nord = GameColors(
    success: Color(0xFFA3BE8C), // Nord green
    successContainer: Color(0xFF3B4A3E),
    onSuccess: Color(0xFF2E3440),
    onSuccessContainer: Color(0xFFECEFF4),
    warning: Color(0xFFEBCB8B), // Nord yellow
    warningContainer: Color(0xFF4A453E),
    onWarning: Color(0xFF2E3440),
    onWarningContainer: Color(0xFFECEFF4),
    star: Color(0xFFEBCB8B),
    starContainer: Color(0xFF4A453E),
    onStar: Color(0xFF2E3440),
    streak: Color(0xFF81A1C1), // Nord frost blue
    streakContainer: Color(0xFF3E4A52),
    onStreak: Color(0xFF2E3440),
    correct: Color(0xFFA3BE8C),
    incorrect: Color(0xFFBF616A), // Nord red
    onCorrect: Color(0xFF2E3440),
    onIncorrect: Color(0xFFECEFF4),
    hint: Color(0xFF88C0D0), // Nord frost 2
    hintContainer: Color(0xFF4C566A), // Nord polar night 4
    onHint: Color(0xFF2E3440),
    lives: Color(0xFFBF616A), // Nord red
    onLives: Color(0xFFECEFF4),
  );

  // Gruvbox theme colors (retro/earthy)
  static const gruvbox = GameColors(
    success: Color(0xFFB8BB26), // Gruvbox green
    successContainer: Color(0xFF32302F), // Darker background
    onSuccess: Color(0xFF1D2021),
    onSuccessContainer: Color(0xFFFBF1C7),
    warning: Color(0xFFFABD2F), // Gruvbox yellow
    warningContainer: Color(0xFF32302F),
    onWarning: Color(0xFF1D2021),
    onWarningContainer: Color(0xFFFBF1C7),
    star: Color(0xFFFABD2F),
    starContainer: Color(0xFF504945),
    onStar: Color(0xFF1D2021),
    streak: Color(0xFFFE8019), // Gruvbox orange
    streakContainer: Color(0xFF32302F),
    onStreak: Color(0xFF1D2021),
    correct: Color(0xFFB8BB26),
    incorrect: Color(0xFFFB4934), // Gruvbox red
    onCorrect: Color(0xFF1D2021),
    onIncorrect: Color(0xFF1D2021),
    hint: Color(0xFF83A598), // Gruvbox blue
    hintContainer: Color(0xFF504945),
    onHint: Color(0xFFFBF1C7),
    lives: Color(0xFFFB4934), // Gruvbox red
    onLives: Color(0xFFFBF1C7),
  );

  // Monokai theme colors (vibrant/contrast)
  static const monokai = GameColors(
    success: Color(0xFFA6E22E), // Monokai green
    successContainer: Color(0xFF272822),
    onSuccess: Color(0xFF1B1C18),
    onSuccessContainer: Color(0xFFF8F8F2),
    warning: Color(0xFFE6DB74), // Monokai yellow
    warningContainer: Color(0xFF272822),
    onWarning: Color(0xFF1B1C18),
    onWarningContainer: Color(0xFFF8F8F2),
    star: Color(0xFFE6DB74),
    starContainer: Color(0xFF49483E),
    onStar: Color(0xFF1B1C18),
    streak: Color(0xFFFD971F), // Monokai orange
    streakContainer: Color(0xFF272822),
    onStreak: Color(0xFF1B1C18),
    correct: Color(0xFFA6E22E),
    incorrect: Color(0xFFF92672), // Monokai pink/red
    onCorrect: Color(0xFF1B1C18),
    onIncorrect: Color(0xFFF8F8F2),
    hint: Color(0xFF66D9EF), // Monokai blue
    hintContainer: Color(0xFF3E3D32),
    onHint: Color(0xFFF8F8F2),
    lives: Color(0xFFF92672), // Monokai pink/red
    onLives: Color(0xFFF8F8F2),
  );
}

/// Helper extension to easily access GameColors from BuildContext
extension GameColorsExtension on ThemeData {
  GameColors get gameColors => extension<GameColors>() ?? GameColors.light;
}
