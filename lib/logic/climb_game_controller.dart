import 'dart:async';
import 'dart:math';

import '../models/difficulty_level.dart';
import '../models/grid_cell.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import 'climb_progression.dart';
import 'game_constants.dart';
import 'grid_playable.dart';
import 'problem_generator.dart';

/// Summary handed to the climb-mode result screen once a run ends.
class ClimbGameResult {
  final int round;
  final int score;
  final int correctCount;
  final int wrongCount;
  final bool isNewBestRound;
  final bool isNewBestScore;
  final bool outOfLives;

  const ClimbGameResult({
    required this.round,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.isNewBestRound,
    required this.isNewBestScore,
    required this.outOfLives,
  });
}

/// Owns all live game state for Tırmanış modu (bkz. CLAUDE.md Bölüm 3b): a
/// single continuous run split into short "bölüm"s whose grid grows
/// (1x2 -> 2x2 -> 3x3 -> 4x4, sabitlenir) and whose arithmetic difficulty
/// scales in lockstep (bkz. [climbGridShapeForRound]/[climbLevelForRound]).
/// Finding the target cell instantly advances to the next round with a
/// freshly generated grid; there is a single depleting run timer (not
/// per-round) that gets a small bonus on every correct answer, so the
/// player must keep a fast pace or run out. A wrong answer costs a life
/// but does NOT reset the round — the same grid/target persists.
class ClimbGameController extends GridPlayable {
  ClimbGameController({
    required AudioService audioService,
    required ScoreService scoreService,
    ProblemGenerator? generator,
    Random? random,
  }) : _audio = audioService,
       // ignore: prefer_initializing_formals
       _scoreService = scoreService,
       _generator = generator ?? ProblemGenerator(random: random),
       _random = random ?? Random();

  final AudioService _audio;
  final ScoreService _scoreService;
  final ProblemGenerator _generator;
  final Random _random;

  static const int initialTimeBudgetSeconds = 45;
  static const int timeBonusPerCorrectSeconds = 3;

  @override
  late List<GridCell> cells;
  @override
  int get columns => climbGridShapeForRound(round).columns;

  int round = 1;
  late DifficultyLevel level;
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
  DateTime _roundStartedAt = DateTime.now();
  bool _disposed = false;

  /// Called once the run ends (time ran out or lives ran out — Tırmanış
  /// modunda "tam temizleme" ile biten bir kazanma durumu yok).
  void Function(ClimbGameResult result)? onGameEnd;

  void start() {
    round = 1;
    score = 0;
    correctCount = 0;
    wrongCount = 0;
    comboStreak = 0;
    livesRemaining = maxLives;
    wrongIndex = null;
    status = GameStatus.playing;
    timeRemainingSeconds = initialTimeBudgetSeconds;
    _generateRound();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  /// Generates the current [round]'s grid/target without touching
  /// score/lives/time — unlike hunt modu, her bölümde grid tamamen
  /// yenilenir (tek hücre boşaltılmaz), bu yüzden yeni grid'in tüm
  /// hücreleri zaten idle olur.
  void _generateRound() {
    level = climbLevelForRound(round);
    final shape = climbGridShapeForRound(round);
    cells = _generator
        .generateGrid(
          level,
          operations: climbOperationsForRound(round),
          count: shape.cellCount,
        )
        .map((problem) => GridCell(problem: problem))
        .toList();
    targetNumber = cells[_random.nextInt(cells.length)].problem.answer;
    _roundStartedAt = DateTime.now();
  }

  void _tick() {
    if (status != GameStatus.playing) return;
    timeRemainingSeconds--;
    if (timeRemainingSeconds <= 10 && timeRemainingSeconds > 0) {
      _audio.playTick();
    }
    if (timeRemainingSeconds <= 0) {
      timeRemainingSeconds = 0;
      _endGame(outOfLives: false);
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
    timeRemainingSeconds += timeBonusPerCorrectSeconds;
    _audio.playCorrect();
    notifyListeners();

    Future.delayed(correctAnimationDuration, () {
      if (_disposed) return;
      round++;
      _generateRound();
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
        _endGame(outOfLives: true);
        return;
      }
      notifyListeners();
    });
  }

  int _scoreForAnswer() {
    const base = 10;
    final elapsedMs = DateTime.now().difference(_roundStartedAt).inMilliseconds;
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

  Future<void> _endGame({required bool outOfLives}) async {
    _timer?.cancel();
    status = outOfLives ? GameStatus.outOfLives : GameStatus.timeUp;
    _audio.playTimeUp();
    notifyListeners();

    final isNewBestRound = await _scoreService.submitClimbBestRound(round);
    final isNewBestScore = await _scoreService.submitClimbBestScore(score);
    onGameEnd?.call(
      ClimbGameResult(
        round: round,
        score: score,
        correctCount: correctCount,
        wrongCount: wrongCount,
        isNewBestRound: isNewBestRound,
        isNewBestScore: isNewBestScore,
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
