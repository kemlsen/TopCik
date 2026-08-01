import 'package:shared_preferences/shared_preferences.dart';

import '../models/difficulty_level.dart';
import '../models/game_mode.dart';

/// Persists best scores per difficulty level and game mode locally
/// (Bölüm 6, 13). Sayı Avı modu keeps its original (pre-Eşleştirme modu)
/// key so existing best scores aren't lost; Eşleştirme modu gets its own
/// namespaced key.
class ScoreService {
  static const _lastLevelKey = 'last_level';

  String _bestScoreKey(DifficultyLevel level, GameMode mode) {
    return mode == GameMode.hunt
        ? 'best_score_${level.name}'
        : 'best_score_${mode.name}_${level.name}';
  }

  Future<DifficultyLevel> getLastLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_lastLevelKey);
    return DifficultyLevel.values.firstWhere(
      (l) => l.name == name,
      orElse: () => DifficultyLevel.easy,
    );
  }

  Future<void> setLastLevel(DifficultyLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLevelKey, level.name);
  }

  Future<int> getBestScore(
    DifficultyLevel level, {
    GameMode mode = GameMode.hunt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey(level, mode)) ?? 0;
  }

  /// Saves [score] as the new best for [level]/[mode] if it beats the
  /// previous best. Returns true when a new best score was set.
  Future<bool> submitScore(
    DifficultyLevel level,
    int score, {
    GameMode mode = GameMode.hunt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _bestScoreKey(level, mode);
    final current = prefs.getInt(key) ?? 0;
    if (score > current) {
      await prefs.setInt(key, score);
      return true;
    }
    return false;
  }
}
