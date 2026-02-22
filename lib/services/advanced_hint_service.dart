import 'package:flutter/material.dart';

enum HintType {
  revealWord,        // Current: reveals entire word
  revealFirstLetter, // Shows first letter only
  revealLastLetter,  // Shows last letter only
  revealRandomLetter, // Shows one random letter
  showWordLength,    // Shows number of letters
  eliminateWrongLetters, // Grays out letters not in word
}

class HintCost {
  static const Map<HintType, int> costs = {
    HintType.showWordLength: 1,
    HintType.revealFirstLetter: 1,
    HintType.revealLastLetter: 1,
    HintType.revealRandomLetter: 2,
    HintType.eliminateWrongLetters: 2,
    HintType.revealWord: 3,
  };

  static int getCost(HintType type) => costs[type] ?? 1;
}

class AdvancedHintService {
  String applyHint(HintType type, String word, {String? currentGuess}) {
    switch (type) {
      case HintType.revealWord:
        return word;
        
      case HintType.revealFirstLetter:
        if (currentGuess == null || currentGuess.isEmpty) {
          return word[0] + '_' * (word.length - 1);
        }
        return word[0] + currentGuess.substring(1);
        
      case HintType.revealLastLetter:
        if (currentGuess == null || currentGuess.isEmpty) {
          return '_' * (word.length - 1) + word[word.length - 1];
        }
        return currentGuess.substring(0, word.length - 1) + word[word.length - 1];
        
      case HintType.revealRandomLetter:
        if (currentGuess == null || currentGuess.isEmpty) {
          currentGuess = '_' * word.length;
        }
        
        // Find unrevealed positions
        final unrevealedPositions = <int>[];
        for (int i = 0; i < word.length; i++) {
          if (currentGuess[i] == '_' || currentGuess[i] == ' ') {
            unrevealedPositions.add(i);
          }
        }
        
        if (unrevealedPositions.isEmpty) return word;
        
        // Reveal random position
        final randomIndex = unrevealedPositions[
          DateTime.now().millisecondsSinceEpoch % unrevealedPositions.length
        ];
        
        final chars = currentGuess.split('');
        chars[randomIndex] = word[randomIndex];
        return chars.join();
        
      case HintType.showWordLength:
        return word.length.toString();
        
      case HintType.eliminateWrongLetters:
        // This would return a list of valid letters for the keyboard
        // Implementation depends on keyboard widget structure
        return word;
    }
  }

  List<String> getValidLetters(String word) {
    return word.toUpperCase().split('').toSet().toList();
  }

  String getHintDescription(HintType type) {
    switch (type) {
      case HintType.revealWord:
        return 'Reveal entire word (3 hints)';
      case HintType.revealFirstLetter:
        return 'Show first letter (1 hint)';
      case HintType.revealLastLetter:
        return 'Show last letter (1 hint)';
      case HintType.revealRandomLetter:
        return 'Reveal one random letter (2 hints)';
      case HintType.showWordLength:
        return 'Show word length (1 hint)';
      case HintType.eliminateWrongLetters:
        return 'Eliminate wrong letters (2 hints)';
    }
  }

  IconData getHintIcon(HintType type) {
    switch (type) {
      case HintType.revealWord:
        return Icons.lightbulb_rounded;
      case HintType.revealFirstLetter:
        return Icons.first_page_rounded;
      case HintType.revealLastLetter:
        return Icons.last_page_rounded;
      case HintType.revealRandomLetter:
        return Icons.casino_rounded;
      case HintType.showWordLength:
        return Icons.straighten_rounded;
      case HintType.eliminateWrongLetters:
        return Icons.block_rounded;
    }
  }
}
