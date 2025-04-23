// import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WordleGame {
  late String _targetWord; // The target word for the game
  int attempts = 0; // Number of attempts made
  int _currentScore = 0; // The current game acore
  static int _aggregateScore = 0; // Accumulated score across games
  final Set<String> _incorrectLetters = {}; // Track incorrect letters
  // final Map<int, String> _misplacedLetters = {}; // Track misplaced letters by position

    WordleGame({required String targetWord}) {
    _targetWord = targetWord.toUpperCase();
  }

  // Generate a random game instance by fetching a word from the API
  static Future<WordleGame> generateRandomGame() async {
    final targetWord = await _fetchRandomWord();
    return WordleGame(targetWord: targetWord);
  }

  /// Fetch a random 5-letter word from the Random Words API
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
      print('Error fetching word: $e');
      // Fallback to a mock word if the API fails
      return 'APPLE';
    }
  }

  /// Process the user's guess and provide feedback
  Map<int, String> makeGuess(String guess) {
    print('makeGuess called with: $guess'); // Debug
    guess = guess.toUpperCase();

    // Check for previously guessed incorrect letters
    for (var letter in guess.split('')) {
      if (_incorrectLetters.contains(letter)) {
        return {0: 'Invalid letter "$letter". Please try again.'};
      }
    }

    // Check for misplaced letters in the same position
   // for (int i = 0; i < guess.length; i++) {
//if (_misplacedLetters[i] == guess[i]) {
   //     return {0: 'Letter "${guess[i]}" has already been guessed in this position. Please try again.'};
 //     }
  //  }

    // Increment attempts
    attempts++;

    // Generate detailed feedback for the guess
    final feedback = _generateDetailedFeedback(guess);

    // Check if the guess matches the target word
    if (guess == _targetWord) {
      // Update the score based on the remaining attempts
      _currentScore += (7 - attempts); // Example scoring logic
      _aggregateScore += _currentScore; // Accumulate aggregate score
      print('Congratulations! Correct guess: $guess'); // Debugging
      // Ensure the correct guess feedback is preserved
      feedback.forEach((index, _) {
        feedback[index] = 'correct';
      });
      return feedback; // Return 'correct' feedback for all letters
    }


    // Add incorrect letters to the set
    for (int i = 0; i < guess.length; i++) {
      if (feedback[i] == 'incorrect') {
        _incorrectLetters.add(guess[i]);
      }
    }

    // Add misplaced letters to the set
    // for (int i = 0; i < guess.length; i++) {
    // if (feedback[i] == 'misplaced') {
    //   _misplacedLetters[i] = guess[i];
    // Add incorrect letters to the set
    //   } else if (feedback[i] == 'incorrect') {
    //    _incorrectLetters.add(guess[i]);
    //  }
    // }

    print('Feedback for "$guess": $feedback'); // Debugging log
    return feedback;
  }

  /// Generate detailed feedback for the user's guess
  Map<int, String> _generateDetailedFeedback(String guess) {
    final feedback = <int, String>{};
    final targetChars = _targetWord.split('');
    final guessChars = guess.split('');

    print('Target Word: $_targetWord');
    print('Guess Word: $guess');

    for (int i = 0; i < guess.length; i++) {
      if (i >= targetChars.length) {
        feedback[i] = 'incorrect'; // Handle guesses longer than the target word
      } else if (guessChars[i] == targetChars[i]) {
        feedback[i] = 'correct'; // Correct letter in the correct position
      } else if (targetChars.contains(guessChars[i])) {
        feedback[i] = 'misplaced'; // Correct letter in the wrong position
      } else {
        feedback[i] = 'incorrect'; // Incorrect letter
      }

      // Debugging each letter
      print('Letter: ${guessChars[i]}, Feedback: ${feedback[i]}');
    }

    return feedback;
  }

// Method to update aggregate score
void addToAggregateScore(int score) {
  _aggregateScore += score;
}

  /// Reset the game state for a new round
  void resetGame(String newTargetWord) {
    _targetWord = newTargetWord.toUpperCase();
    attempts = 0;
    _currentScore = 0; // Reset score
     _incorrectLetters.clear(); // Clear incorrect letters for the new game
    // _misplacedLetters.clear(); // Clear misplaced letters for the new game
  }

  /// Getter for current score
  int get currentScore => _currentScore;

  /// Getter for aggregate score
  static int get aggregateScore => _aggregateScore;

   Set<String> get incorrectLetters => _incorrectLetters; // Getter for incorrect letters

  /// Getter for target word (for debugging purposes)
  String get targetWord => _targetWord;
}
