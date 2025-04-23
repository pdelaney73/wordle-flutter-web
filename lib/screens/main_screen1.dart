import 'package:flutter/material.dart';
import 'game_screen.dart'; // Import the game screen
import '../services/score_service.dart'; // Import the score service

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _aggregateScore = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAggregateScore();
  }

  /// Loads the aggregate score from ScoreService
  Future<void> _loadAggregateScore() async {
    final scoreService = ScoreService();
    final score = await scoreService.loadAggregateScore();
    setState(() {
      _aggregateScore = score;
      _isLoading = false;
    });
  }

  /// Navigates to GameScreen and updates aggregate score if the game ends
  Future<void> _navigateToGameScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GameScreen(),
      ),
    );

    if (result != null && result is int) {
      _loadAggregateScore(); // Refresh score after game
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Wordle Game - Main Menu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display aggregate score
            Text(
              'Aggregate Score: $_aggregateScore',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToGameScreen,
              child: const Text('Play Wordle'),
            ),
          ],
        ),
      ),
    );
  }
}
