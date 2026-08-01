import 'package:shared_preferences/shared_preferences.dart';

import '../models/difficulty_level.dart';
import '../models/game_mode.dart';

const _operationSeparator = ',';

/// Persists best scores per difficulty level and game mode locally
/// (Bölüm 6, 13). Sayı Avı modu keeps its original (pre-Eşleştirme modu)
/// key so existing best scores aren't lost; Eşleştirme modu gets its own
/// namespaced key.
class ScoreService {
  static const _lastLevelKey = 'last_level';
  static const _lastModeKey = 'last_mode';
  static const _lastOperationsKey = 'last_operations';

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

  /// Oyuncunun en son oynadığı modu döner (varsayılan: Sayı Avı). Ana
  /// menüdeki "Oyna" hızlı başlatma butonu, en son seçilen mod + seviye
  /// kombinasyonuna devam etmek için bunu kullanır.
  Future<GameMode> getLastMode() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_lastModeKey);
    return GameMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => GameMode.hunt,
    );
  }

  Future<void> setLastMode(GameMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastModeKey, mode.name);
  }

  /// Oyuncunun en son İşlem Türü Seç ekranında bıraktığı seçimi döner.
  /// Hiç kaydedilmemişse [level]'in varsayılan işlem seti kullanılır (bkz.
  /// `DifficultyLevel.operations`), yani Ana Menü'deki "Oyna" ilk açılışta
  /// bile mantıklı bir kombinasyonla başlar.
  Future<Set<Operation>> getLastOperations(DifficultyLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_lastOperationsKey);
    if (stored == null || stored.isEmpty) {
      return level.operations.toSet();
    }
    final names = stored.split(_operationSeparator);
    final operations = Operation.values
        .where((o) => names.contains(o.name))
        .toSet();
    return operations.isEmpty ? level.operations.toSet() : operations;
  }

  Future<void> setLastOperations(Set<Operation> operations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastOperationsKey,
      operations.map((o) => o.name).join(_operationSeparator),
    );
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
