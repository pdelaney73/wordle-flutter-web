import 'package:flutter/material.dart';

class GameProvider with ChangeNotifier {
  // Game logic will be implemented here
  final String _currentWord = "FLARE"; // Example word
  int _attemptsLeft = 6;

  String get currentWord => _currentWord;
  int get attemptsLeft => _attemptsLeft;

  void makeGuess(String guess) {
    // Validate guess logic
    _attemptsLeft--;
    notifyListeners();
  }
}
