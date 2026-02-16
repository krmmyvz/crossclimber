class Level {
  final int id;
  final List<String> startWord;
  final List<String> endWord;
  final List<String> solution; // Contains ALL words in order
  final List<String> clues; // Clues for the middle words (scrambled or ordered?)
  final String startClue;
  final String endClue;
  final int difficulty; // 1: Easy, 2: Medium, 3: Hard

  Level({
    required this.id,
    required this.startWord,
    required this.endWord,
    required this.solution,
    required this.clues,
    required this.startClue,
    required this.endClue,
    required this.difficulty,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    // Helper function to convert startWord/endWord to List<String>
    // Handles both String format (daily challenges) and List format (regular levels)
    List<String> parseWord(dynamic word) {
      if (word is String) {
        // Daily challenge format: "LOVE" -> ["L", "O", "V", "E"]
        return word.split('');
      } else if (word is List) {
        // Regular level format: ["L", "O", "V", "E"]
        return List<String>.from(word);
      }
      throw FormatException('Invalid word format: $word');
    }

    return Level(
      id: json['id'] as int,
      startWord: parseWord(json['startWord']),
      endWord: parseWord(json['endWord']),
      solution: List<String>.from(json['solution']),
      clues: List<String>.from(json['clues']),
      startClue: json['startClue'] ?? '',
      endClue: json['endClue'] ?? '',
      difficulty: json['difficulty'] ?? 1,
    );
  }
}
