
// Game logic for the Wordle game
import 'dart:convert';
import 'package:http/http.dart' as http;

class WordleGame {
  late String _targetWord; // The target word for the game
  int attempts = 0; // Number of attempts made by the player
  int _currentScore = 0; // The score for the current round
  static int _aggregateScore = 0; // Total accumulated score across all games
  final Set<String> _incorrectLetters = {}; // Tracks incorrect letters guessed

  // Constructor sets the target word for the game
  WordleGame({required String targetWord}) {
    _targetWord = targetWord.toUpperCase();
  }

  // Generates a new game instance by fetching a random word
  static Future<WordleGame> generateRandomGame() async {
    final targetWord = await _fetchRandomWord();
    return WordleGame(targetWord: targetWord);
  }

  // Fetches a random 5-letter word using a public API
  static Future<String> _fetchRandomWord() async {
    const apiUrl = 'https://random-word-api.herokuapp.com/word?number=1&length=5';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> words = jsonDecode(response.body);
        return words.first.toString().toUpperCase();
      } else {
        throw Exception('Failed to fetch word from API');
      }
    } catch (e) {
      return 'APPLE'; // Fallback word
    }
  }

  // Handles user guess, returns feedback map indicating status of each letter
  Map<int, String> makeGuess(String guess) {

    guess = guess.toUpperCase();

    // Reject letters that were previously guessed as incorrect
    for (var letter in guess.split('')) {
      if (_incorrectLetters.contains(letter)) {
        return {0: 'Invalid letter "$letter". Please try again.'};
      }
    }

    attempts++; // Increment number of guesses

    final feedback = _generateDetailedFeedback(guess); // Get feedback per letter

    // If the word is guessed correctly
    if (guess == _targetWord) {
      _currentScore += (7 - attempts); // Score decreases with more attempts
      _aggregateScore += _currentScore; // Add to session score
      // Override all feedback to 'correct' to highlight win visually
      feedback.forEach((index, _) {
        feedback[index] = 'correct';
      });

      return feedback;
    }

    // Track incorrect letters
    for (int i = 0; i < guess.length; i++) {
      if (feedback[i] == 'incorrect') {
        _incorrectLetters.add(guess[i]);
      }
    }
    return feedback;
  }

  // Internal helper to compare guess and generate feedback
  Map<int, String> _generateDetailedFeedback(String guess) {
    final feedback = <int, String>{};
    final targetChars = _targetWord.split('');
    final guessChars = guess.split('');

    for (int i = 0; i < guess.length; i++) {
      if (i >= targetChars.length) {
        feedback[i] = 'incorrect'; // Guard in case of overflow
      } else if (guessChars[i] == targetChars[i]) {
        feedback[i] = 'correct'; // Letter and position correct
      } else if (targetChars.contains(guessChars[i])) {
        feedback[i] = 'misplaced'; // Letter correct but in wrong spot
      } else {
        feedback[i] = 'incorrect'; // Letter not in word
      }
    }

    return feedback;
  }

  // Adds extra points to aggregate score if needed externally
  void addToAggregateScore(int score) {
    _aggregateScore += score;
  }

  // Reset the game for a new round
  void resetGame(String newTargetWord) {
    _targetWord = newTargetWord.toUpperCase();
    attempts = 0;
    _currentScore = 0;
    _incorrectLetters.clear(); // Clear memory of bad letters
  }

  // Public getters
  int get currentScore => _currentScore;
  static int get aggregateScore => _aggregateScore;
  Set<String> get incorrectLetters => _incorrectLetters;
  String get targetWord => _targetWord; // Used for game-over message
}
