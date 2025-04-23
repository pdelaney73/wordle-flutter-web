import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const WordleApp());
}

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      title: 'Wordle Game',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Sets the primary theme color
      ),
      home: const GameScreen(), // Entry point to the app
    );
  }
}
