import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ScoreService {
  Future<int> loadAggregateScore() async {
    final prefs = await SharedPreferences.getInstance();
    final storedScore = prefs.getInt('aggregateScore') ?? 0;
    final lastPlayedDate = prefs.getString('lastPlayedDate');
    
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (lastPlayedDate != today) {
      await prefs.setInt('aggregateScore', 0);
      await prefs.setString('lastPlayedDate', today);
      return 0;
    }
    
    return storedScore;
  }

  Future<int> updateAggregateScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    int currentScore = prefs.getInt('aggregateScore') ?? 0;
    currentScore += score;
    await prefs.setInt('aggregateScore', currentScore);
    
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('lastPlayedDate', today);
    
    return currentScore;
  }
}