import 'dart:async';
import 'dart:math';

import '../models/difficulty_level.dart';
import '../models/grid_cell.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import 'game_constants.dart';
import 'grid_playable.dart';
import 'problem_generator.dart';

export 'game_constants.dart';

/// Summary handed to the result screen once a run ends.
class GameResult {
  final DifficultyLevel level;
  final Set<Operation> operations;
  final int score;
  final int correctCount;
  final int wrongCount;
  final bool isNewBest;
  final bool levelCompleted;
  final bool outOfLives;

  const GameResult({
    required this.level,
    required this.operations,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.isNewBest,
    required this.levelCompleted,
    this.outOfLives = false,
  });
}

/// Owns all live game state for the grid screen: the problem grid,
/// the current target number, score, combo streak and the countdown timer.
///
/// Uses "Seçenek B — Azalan Grid" (Bölüm 3): cells empty out as they are
/// solved and the level ends once all [gridSize] cells are cleared.
class GameController extends GridPlayable {
  GameController({
    required this.level,
    required this.operations,
    required AudioService audioService,
    required ScoreService scoreService,
    ProblemGenerator? generator,
    Random? random,
  }) : _audio = audioService,
       // ignore: prefer_initializing_formals
       _scoreService = scoreService,
       _generator = generator ?? ProblemGenerator(random: random),
       _random = random ?? Random();

  final DifficultyLevel level;

  /// Kullanıcının işlem türü seçim ekranında işaretlediği işlemler
  /// (Toplama/Çıkarma/Çarpma/Bölme veya "Hepsi").
  final Set<Operation> operations;
  final AudioService _audio;
  final ScoreService _scoreService;
  final ProblemGenerator _generator;
  final Random _random;

  @override
  late List<GridCell> cells;
  late int targetNumber;
  int score = 0;
  int correctCount = 0;
  int wrongCount = 0;
  int comboStreak = 0;
  int livesRemaining = maxLives;
  late int timeRemainingSeconds;
  GameStatus status = GameStatus.playing;

  /// Index whose wrong-answer animation is currently playing, so the UI
  /// can show the "Yanlış!" hint next to that specific cell.
  int? wrongIndex;

  Timer? _timer;
  DateTime _targetSetAt = DateTime.now();
  bool _disposed = false;

  /// Called once the run ends (grid cleared or time ran out).
  void Function(GameResult result)? onGameEnd;

  void start() {
    cells = _generator
        .generateGrid(level, operations: operations, count: gridSize)
        .map((problem) => GridCell(problem: problem))
        .toList();
    score = 0;
    correctCount = 0;
    wrongCount = 0;
    comboStreak = 0;
    livesRemaining = maxLives;
    wrongIndex = null;
    status = GameStatus.playing;
    timeRemainingSeconds = level.timeLimitSeconds;
    targetNumber = _pickTarget();
    _targetSetAt = DateTime.now();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    if (status != GameStatus.playing) return;
    timeRemainingSeconds--;
    if (timeRemainingSeconds <= 10 && timeRemainingSeconds > 0) {
      _audio.playTick();
    }
    if (timeRemainingSeconds <= 0) {
      timeRemainingSeconds = 0;
      _endGame(levelCompleted: false);
      return;
    }
    notifyListeners();
  }

  @override
  void selectCell(int index) {
    if (status != GameStatus.playing) return;
    final cell = cells[index];
    if (cell.state != CellState.idle) return;

    if (cell.problem.answer == targetNumber) {
      _handleCorrect(index);
    } else {
      _handleWrong(index);
    }
  }

  void _handleCorrect(int index) {
    cells[index].state = CellState.correct;
    comboStreak++;
    correctCount++;
    score += _scoreForAnswer();
    _audio.playCorrect();
    notifyListeners();

    Future.delayed(correctAnimationDuration, () {
      if (_disposed) return;
      cells[index].state = CellState.empty;
      if (cells.every((c) => c.state == CellState.empty)) {
        _endGame(levelCompleted: true);
        return;
      }
      targetNumber = _pickTarget();
      _targetSetAt = DateTime.now();
      notifyListeners();
    });
  }

  void _handleWrong(int index) {
    cells[index].state = CellState.wrong;
    comboStreak = 0;
    wrongCount++;
    livesRemaining = max(0, livesRemaining - 1);
    wrongIndex = index;
    _audio.playWrong();
    notifyListeners();

    Future.delayed(wrongAnimationDuration, () {
      if (_disposed) return;
      cells[index].state = CellState.idle;
      if (wrongIndex == index) wrongIndex = null;
      if (livesRemaining <= 0) {
        _endGame(levelCompleted: false, outOfLives: true);
        return;
      }
      notifyListeners();
    });
  }

  int _scoreForAnswer() {
    const base = 10;
    final elapsedMs = DateTime.now().difference(_targetSetAt).inMilliseconds;
    int speedBonus;
    if (elapsedMs < 2000) {
      speedBonus = 10;
    } else if (elapsedMs < 4000) {
      speedBonus = 5;
    } else {
      speedBonus = 0;
    }
    final comboBonus = min(comboStreak, 5) * 2;
    return base + speedBonus + comboBonus;
  }

  /// Picks a target number from among the still-unsolved cells. Bölüm 4:
  /// several cells may share the same answer — any of them is valid.
  int _pickTarget() {
    final candidates = cells
        .where((c) => c.state == CellState.idle)
        .map((c) => c.problem.answer)
        .toList();
    return candidates[_random.nextInt(candidates.length)];
  }

  Future<void> _endGame({
    required bool levelCompleted,
    bool outOfLives = false,
  }) async {
    _timer?.cancel();
    status = levelCompleted
        ? GameStatus.levelComplete
        : (outOfLives ? GameStatus.outOfLives : GameStatus.timeUp);
    if (levelCompleted) {
      // Bölüm 6 — süre bonusu: kalan süreye göre ekstra puan.
      score += timeRemainingSeconds * 2;
      _audio.playLevelComplete();
    } else {
      _audio.playTimeUp();
    }
    notifyListeners();

    final isNewBest = await _scoreService.submitScore(level, score);
    onGameEnd?.call(
      GameResult(
        level: level,
        operations: operations,
        score: score,
        correctCount: correctCount,
        wrongCount: wrongCount,
        isNewBest: isNewBest,
        levelCompleted: levelCompleted,
        outOfLives: outOfLives,
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
