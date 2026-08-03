import 'dart:async';
import 'dart:math';

import '../models/difficulty_level.dart';
import '../models/game_mode.dart';
import '../models/grid_cell.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import 'game_constants.dart';
import 'grid_playable.dart';
import 'problem_generator.dart';

/// Summary handed to the match-mode result screen once a run ends.
class MatchGameResult {
  final DifficultyLevel level;
  final Set<Operation> operations;
  final int score;
  final int matchedPairs;
  final int totalPairs;
  final int wrongAttempts;
  final bool isNewBest;
  final bool levelCompleted;
  final bool outOfLives;

  const MatchGameResult({
    required this.level,
    required this.operations,
    required this.score,
    required this.matchedPairs,
    required this.totalPairs,
    required this.wrongAttempts,
    required this.isNewBest,
    required this.levelCompleted,
    this.outOfLives = false,
  });
}

/// Owns all live game state for Eşleştirme modu: a grid where every
/// cell's math problem shares its answer with exactly one other cell.
/// Players tap two cells; a matching pair fades away, a mismatch flashes
/// red and resets. Uses the same can (lives) and süre (timer) mechanics as
/// Sayı Avı modu (bkz. CLAUDE.md Bölüm 6, 7).
class MatchGameController extends GridPlayable {
  MatchGameController({
    required this.level,
    required this.operations,
    required AudioService audioService,
    required ScoreService scoreService,
    ProblemGenerator? generator,
    Random? random,
  }) : _audio = audioService,
       // ignore: prefer_initializing_formals
       _scoreService = scoreService,
       _generator = generator ?? ProblemGenerator(random: random);

  final DifficultyLevel level;
  final Set<Operation> operations;
  final AudioService _audio;
  final ScoreService _scoreService;
  final ProblemGenerator _generator;

  static const int totalPairs = gridSize ~/ 2;

  @override
  late List<GridCell> cells;
  int score = 0;
  int matchedPairs = 0;
  int wrongAttempts = 0;
  int comboStreak = 0;
  int livesRemaining = maxLives;
  late int timeRemainingSeconds;
  GameStatus status = GameStatus.playing;

  /// The first tile picked while looking for its match, if any.
  int? firstIndex;

  /// The two indices currently flashing red after a mismatched pair.
  List<int>? wrongPair;

  Timer? _timer;
  DateTime _firstPickedAt = DateTime.now();
  bool _busy = false;
  bool _disposed = false;

  /// Called once the run ends (grid cleared or time ran out).
  void Function(MatchGameResult result)? onGameEnd;

  void start() {
    cells = _generator
        .generateMatchGrid(level, operations: operations, pairCount: totalPairs)
        .map((problem) => GridCell(problem: problem))
        .toList();
    score = 0;
    matchedPairs = 0;
    wrongAttempts = 0;
    comboStreak = 0;
    livesRemaining = maxLives;
    firstIndex = null;
    wrongPair = null;
    status = GameStatus.playing;
    timeRemainingSeconds = level.timeLimitSeconds;

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
    if (status != GameStatus.playing || _busy) return;
    final cell = cells[index];

    if (firstIndex == index) {
      // Tapping the already-selected tile again cancels the pick.
      cell.state = CellState.idle;
      firstIndex = null;
      notifyListeners();
      return;
    }

    if (cell.state != CellState.idle) return;

    if (firstIndex == null) {
      firstIndex = index;
      cell.state = CellState.selected;
      _firstPickedAt = DateTime.now();
      notifyListeners();
      return;
    }

    final firstIdx = firstIndex!;
    final first = cells[firstIdx];
    if (first.problem.answer == cell.problem.answer) {
      _handleMatch(firstIdx, index);
    } else {
      _handleMismatch(firstIdx, index);
    }
  }

  void _handleMatch(int a, int b) {
    _busy = true;
    firstIndex = null;
    cells[a].state = CellState.correct;
    cells[b].state = CellState.correct;
    matchedPairs++;
    comboStreak++;
    score += _scoreForMatch();
    _audio.playCorrect();
    notifyListeners();

    Future.delayed(correctAnimationDuration, () {
      if (_disposed) return;
      cells[a].state = CellState.empty;
      cells[b].state = CellState.empty;
      _busy = false;
      if (cells.every((c) => c.state == CellState.empty)) {
        _endGame(levelCompleted: true);
        return;
      }
      notifyListeners();
    });
  }

  void _handleMismatch(int a, int b) {
    _busy = true;
    firstIndex = null;
    cells[a].state = CellState.wrong;
    cells[b].state = CellState.wrong;
    wrongPair = [a, b];
    comboStreak = 0;
    wrongAttempts++;
    livesRemaining = max(0, livesRemaining - 1);
    _audio.playWrong();
    notifyListeners();

    Future.delayed(wrongAnimationDuration, () {
      if (_disposed) return;
      cells[a].state = CellState.idle;
      cells[b].state = CellState.idle;
      wrongPair = null;
      _busy = false;
      if (livesRemaining <= 0) {
        _endGame(levelCompleted: false, outOfLives: true);
        return;
      }
      notifyListeners();
    });
  }

  int _scoreForMatch() {
    const base = 10;
    final elapsedMs = DateTime.now().difference(_firstPickedAt).inMilliseconds;
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

  Future<void> _endGame({
    required bool levelCompleted,
    bool outOfLives = false,
  }) async {
    _timer?.cancel();
    status = levelCompleted
        ? GameStatus.levelComplete
        : (outOfLives ? GameStatus.outOfLives : GameStatus.timeUp);
    if (levelCompleted) {
      score += timeRemainingSeconds * 2;
      _audio.playLevelComplete();
    } else {
      _audio.playTimeUp();
    }
    notifyListeners();

    final isNewBest = await _scoreService.submitScore(
      level,
      score,
      mode: GameMode.match,
    );
    onGameEnd?.call(
      MatchGameResult(
        level: level,
        operations: operations,
        score: score,
        matchedPairs: matchedPairs,
        totalPairs: totalPairs,
        wrongAttempts: wrongAttempts,
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
