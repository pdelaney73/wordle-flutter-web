import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

/// The main entry point of the application.
void main() {
  runApp(const WordleApp());
}

/// Root widget for the Wordle app. Manages theme and app-wide settings.
class WordleApp extends StatefulWidget {
  const WordleApp({super.key});

  @override
  State<WordleApp> createState() => _WordleAppState();
}

class _WordleAppState extends State<WordleApp> {
  /// Controls whether the app uses light or dark theme.
  ThemeMode _themeMode = ThemeMode.system;

  /// Toggles between light and dark mode when the user presses the theme icon.
  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  /// Builds the app UI with light/dark theme support and injects the toggle logic into GameScreen.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner in the top corner
      title: 'Wordle Game', // Title used by the app/window

      // Applies the selected theme mode (light, dark, or system default)
      themeMode: _themeMode,

      // Light theme settings
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),

      // Dark theme settings
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
      ),

      // Sets the initial screen and passes the theme toggle function
      home: GameScreen(
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
