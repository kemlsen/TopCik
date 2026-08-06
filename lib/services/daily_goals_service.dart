import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../logic/climb_game_controller.dart';
import '../logic/game_controller.dart';
import '../logic/match_game_controller.dart';
import '../models/daily_goal.dart';

/// Bugünün hedefleri + ilerlemesi + seri + rütbe, tek bir anlık görüntüde.
class DailyGoalsSnapshot {
  final List<DailyGoalProgress> goals;
  final int streak;
  final DailyRank rank;
  final bool allCompletedToday;

  const DailyGoalsSnapshot({
    required this.goals,
    required this.streak,
    required this.rank,
    required this.allCompletedToday,
  });
}

/// Günlük hedefler, seri (streak) ve rütbe sistemini yönetir (bkz.
/// CLAUDE.md Bölüm 17). Her gün, sabit bir havuzdan tarihe göre
/// deterministik 3 hedef seçilir (`_kindsForDate`); üç modun oyun sonuçları
/// (`recordHuntResult`/`recordMatchResult`/`recordClimbResult`) bu
/// hedeflerin ilerlemesine eklenir — canlı (oyun içi anlık) takip yoktur,
/// sadece her koşunun özeti günün toplamına eklenir. Bir önceki gün
/// tamamlanmadıysa (veya bir gün tamamen atlanmışsa) seri sıfırlanır; bu
/// kontrol, uygulama her açıldığında/bir sonuç kaydedildiğinde pasif
/// olarak yapılır (ayrı bir arka plan görevi veya bildirim gerekmez).
class DailyGoalsService {
  static const _progressDateKey = 'daily_progress_date';
  static const _progressKeyPrefix = 'daily_progress_';
  static const _streakKey = 'daily_streak';
  static const _streakLastCompletedKey = 'daily_streak_last_completed';
  static const _goalsPerDay = 3;

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// O günün 3 hedefi — tarihe göre sabit bir tohumla seçildiği için gün
  /// içinde uygulama kaç kez açılırsa açılsın aynı kalır, ertesi gün değişir.
  List<DailyGoalKind> _kindsForDate(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final pool = List<DailyGoalKind>.of(DailyGoalKind.values)
      ..shuffle(Random(seed));
    return pool.take(_goalsPerDay).toList();
  }

  /// Gün değiştiyse: seri bayatlamışsa (dünden beri tamamlanmış bir gün
  /// yoksa) sıfırlar, ardından ilerleme sayaçlarını sıfırlar. Hem okuma hem
  /// yazma yollarının başında çağrılır, bu yüzden çağrı sırası önemli değildir.
  Future<void> _ensureToday(SharedPreferences prefs) async {
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    if (prefs.getString(_progressDateKey) == todayKey) return;

    final yesterdayKey = _dateKey(now.subtract(const Duration(days: 1)));
    final lastCompleted = prefs.getString(_streakLastCompletedKey);
    if (lastCompleted != null &&
        lastCompleted != todayKey &&
        lastCompleted != yesterdayKey) {
      await prefs.setInt(_streakKey, 0);
    }

    for (final kind in DailyGoalKind.values) {
      await prefs.setInt('$_progressKeyPrefix${kind.name}', 0);
    }
    await prefs.setString(_progressDateKey, todayKey);
  }

  Future<DailyGoalsSnapshot> getTodaySnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureToday(prefs);
    final goals = _kindsForDate(DateTime.now())
        .map(
          (kind) => DailyGoalProgress(
            kind: kind,
            current: prefs.getInt('$_progressKeyPrefix${kind.name}') ?? 0,
          ),
        )
        .toList();
    final streak = prefs.getInt(_streakKey) ?? 0;
    return DailyGoalsSnapshot(
      goals: goals,
      streak: streak,
      rank: rankForStreak(streak),
      allCompletedToday: goals.every((g) => g.isCompleted),
    );
  }

  Future<void> _addProgress(DailyGoalKind kind, int delta) async {
    if (delta == 0) return;
    final prefs = await SharedPreferences.getInstance();
    await _ensureToday(prefs);
    final key = '$_progressKeyPrefix${kind.name}';
    await prefs.setInt(key, (prefs.getInt(key) ?? 0) + delta);
  }

  Future<void> _applyMax(DailyGoalKind kind, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureToday(prefs);
    final key = '$_progressKeyPrefix${kind.name}';
    if (value > (prefs.getInt(key) ?? 0)) {
      await prefs.setInt(key, value);
    }
  }

  Future<void> recordHuntResult(GameResult result) async {
    await _addProgress(DailyGoalKind.playCount, 1);
    await _addProgress(DailyGoalKind.totalScore, result.score);
    await _addProgress(DailyGoalKind.huntCorrect, result.correctCount);
    await _checkStreakCompletion();
  }

  Future<void> recordMatchResult(MatchGameResult result) async {
    await _addProgress(DailyGoalKind.playCount, 1);
    await _addProgress(DailyGoalKind.totalScore, result.score);
    await _addProgress(DailyGoalKind.matchPairs, result.matchedPairs);
    await _checkStreakCompletion();
  }

  Future<void> recordClimbResult(ClimbGameResult result) async {
    await _addProgress(DailyGoalKind.playCount, 1);
    await _addProgress(DailyGoalKind.totalScore, result.score);
    await _applyMax(DailyGoalKind.climbRound, result.round);
    await _checkStreakCompletion();
  }

  /// Bugünün 3 hedefi de tamamlandıysa seriye bir gün ekler (dünden devam
  /// ediyorsa) veya 1'den başlatır (bir gün atlanmışsa); bugün için zaten
  /// işlenmişse tekrar işlemez (aksi halde ikinci bir tamamlanışta seri
  /// yanlışlıkla 1'e sıfırlanır).
  Future<void> _checkStreakCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureToday(prefs);
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    if (prefs.getString(_streakLastCompletedKey) == todayKey) return;

    final allCompleted = _kindsForDate(now).every((kind) {
      final value = prefs.getInt('$_progressKeyPrefix${kind.name}') ?? 0;
      return value >= kind.target;
    });
    if (!allCompleted) return;

    final yesterdayKey = _dateKey(now.subtract(const Duration(days: 1)));
    final wasYesterday =
        prefs.getString(_streakLastCompletedKey) == yesterdayKey;
    final currentStreak = prefs.getInt(_streakKey) ?? 0;
    await prefs.setInt(_streakKey, wasYesterday ? currentStreak + 1 : 1);
    await prefs.setString(_streakLastCompletedKey, todayKey);
  }
}
