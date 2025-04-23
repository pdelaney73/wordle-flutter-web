import 'package:flutter/material.dart';
import '../logic/game_logic.dart';

/// The main GameScreen widget that manages game logic, UI rendering, and state.
class GameScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme; 
  const GameScreen({super.key, this.onToggleTheme});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

/// State class for GameScreen, handling gameplay and UI updates.
class _GameScreenState extends State<GameScreen> {
  late WordleGame _game;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _guesses = [];
  final List<Map<int, String>> _feedbackList = [];
  bool _isLoading = true;
  bool _gameOver = false;
  int _score = 0;
  int _aggregateScore = 0;
  String _message = ''; // Message displayed to the user

  @override
  void initState() {
    super.initState();
    _initializeGame(); // Start game on screen load
  }

  /// Initializes a new Wordle game and resets relevant UI state.
  Future<void> _initializeGame() async {
    setState(() {
      _isLoading = true;
      _gameOver = false;
      _guesses.clear();
      _feedbackList.clear();
      _message = '';
    });

    try {
      final generatedGame = await WordleGame.generateRandomGame();
      setState(() {
        _game = generatedGame;
        _isLoading = false;
      });
    } catch (e) {
      _setMessage("Failed to initialize the game. Please try again.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handles the guess submission logic including validation, scoring, and feedback updates.
  void _submitGuess() {
    if (_gameOver) {
      _setMessage('The game is over. Start a new game!');
      return;
    }

    String guess = _controller.text.trim().toUpperCase();

    if (guess.length != 5) {
      _setMessage('Please enter a 5-letter word.');
      return;
    }

    final invalidLetters = guess.split('').where((letter) {
      return _game.incorrectLetters.contains(letter);
    }).toList();

    if (invalidLetters.isNotEmpty) {
      _setMessage('Invalid letter(s): ${invalidLetters.join(", ")}. Please try again.');
      return;
    }

    FocusScope.of(context).unfocus();
    final feedback = _game.makeGuess(guess);

    setState(() {
      _guesses.add(guess);
      _feedbackList.add(feedback);

      if (feedback.values.every((value) => value == 'correct')) {
        _score = _game.currentScore;
        _aggregateScore += _score;
        _gameOver = true;
        _setMessage('You guessed the word "${_game.targetWord}" correctly! Your score: $_score');
      } else if (_guesses.length >= 6) {
        _gameOver = true;
        _setMessage('Game over! The correct word was "${_game.targetWord}".');
      }

      _controller.clear();
      _focusNode.requestFocus();
    });
  }

  /// Displays the in-app help overlay explaining color codes.
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('How to Play'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _colorTile(color: Colors.blue, label: 'Blue = Correct letter in correct position'),
              const SizedBox(height: 8),
              _colorTile(color: Colors.red, label: 'Red = Correct letter in wrong position'),
              const SizedBox(height: 8),
              _colorTile(color: Colors.grey, label: 'Gray = Incorrect letter'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a color-coded instruction tile.
  Widget _colorTile({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Flexible(child: Text(label)),
      ],
    );
  }

  /// Updates the user-facing message.
  void _setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  /// Exit the game screen (back navigation).
  void _exitGame() {
    Navigator.of(context).pop();
  }

  /// Returns the background color associated with the given feedback state.
  Color _getFeedbackColor(String feedback) {
    switch (feedback) {
      case 'correct':
        return Colors.blue;
      case 'misplaced':
        return Colors.red;
      case 'incorrect':
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordle Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'How to Play',
            onPressed: _showHelpDialog,
          ),
          if (widget.onToggleTheme != null)
      IconButton(
        icon: const Icon(Icons.brightness_6),
        tooltip: 'Toggle Theme',
        onPressed: widget.onToggleTheme,
      ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ScoreDisplay(aggregateScore: _aggregateScore),
                    const SizedBox(height: 10),
                    Flexible(
                      child: _WordGrid(
                        guesses: _guesses,
                        feedbackList: _feedbackList,
                        getFeedbackColor: _getFeedbackColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _InputSection(
                      controller: _controller,
                      focusNode: _focusNode,
                      onSubmit: _submitGuess,
                      gameOver: _gameOver,
                      onNewGame: _initializeGame,
                      onExitGame: _exitGame,
                    ),
                    _MessageDisplay(message: _message),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}

/// Displays the current aggregate score at the top of the screen.
class _ScoreDisplay extends StatelessWidget {
  final int aggregateScore;

  const _ScoreDisplay({required this.aggregateScore});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Aggregate Score: $aggregateScore',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

/// Renders the grid of past guesses with appropriate feedback colors.
class _WordGrid extends StatelessWidget {
  final List<String> guesses;
  final List<Map<int, String>> feedbackList;
  final Color Function(String) getFeedbackColor;

  const _WordGrid({
    required this.guesses,
    required this.feedbackList,
    required this.getFeedbackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(6, (index) {
        if (index < guesses.length) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              guesses[index].length,
              (i) => Container(
                margin: const EdgeInsets.all(4.0),
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: getFeedbackColor(feedbackList[index][i] ?? 'incorrect'),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  guesses[index][i],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}

/// Contains the text input and control buttons (Submit, New Game, Exit).
class _InputSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final VoidCallback onNewGame;
  final VoidCallback onExitGame;
  final bool gameOver;

  const _InputSection({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.gameOver,
    required this.onNewGame,
    required this.onExitGame,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Enter your guess',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          enabled: !gameOver,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: !gameOver ? onSubmit : null, child: const Text('Submit')),
            ElevatedButton(onPressed: gameOver ? onNewGame : null, child: const Text('New Game')),
            ElevatedButton(onPressed: onExitGame, child: const Text('Exit')),
          ],
        ),
      ],
    );
  }
}

/// Displays feedback or status messages to the player.
class _MessageDisplay extends StatelessWidget {
  final String message;

  const _MessageDisplay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
