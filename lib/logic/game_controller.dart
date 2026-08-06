import 'dart:async';
import 'dart:math';

import '../models/difficulty_level.dart';
import '../models/grid_cell.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import 'game_constants.dart';
import 'grid_playable.dart';
import 'grid_shape.dart';
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
  final bool outOfLives;

  const GameResult({
    required this.level,
    required this.operations,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.isNewBest,
    this.outOfLives = false,
  });
}

/// Owns all live game state for the grid screen: the problem grid, the
/// current target number, score, combo streak and the countdown timer.
///
/// Tırmanış moduyla aynı sürekli-koşu mekaniğini kullanır (bkz. CLAUDE.md
/// Bölüm 2): grid boyutu seçilen [level]'e göre sabittir (bkz.
/// [gridShapeForLevel]), doğru cevap bulununca tüm grid anında yenilenir
/// (tek hücre boşaltıp aynı gridde devam etmez), ve tek bir eriyen süre
/// sayacı (45 sn) her doğru cevapta küçük bir bonusla beslenir. Tırmanış'tan
/// farkı, bölüm bölüm otomatik ilerleme yerine seviye/işlem türünün
/// oyuncu tarafından seçilebilir kalması — "45 saniyede kaç tane
/// yapabilirsin" modu.
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

  static const int initialTimeBudgetSeconds = 45;
  static const int timeBonusPerCorrectSeconds = 3;

  @override
  late List<GridCell> cells;
  @override
  int get columns => gridShapeForLevel(level).columns;
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

  /// Called once the run ends (time ran out or lives ran out).
  void Function(GameResult result)? onGameEnd;

  void start() {
    score = 0;
    correctCount = 0;
    wrongCount = 0;
    comboStreak = 0;
    livesRemaining = maxLives;
    wrongIndex = null;
    status = GameStatus.playing;
    timeRemainingSeconds = initialTimeBudgetSeconds;
    _generateGrid();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  /// Generates a fresh grid/target without touching score/lives/time — her
  /// doğru cevapta tüm grid yenilenir (tek hücre boşaltılmaz), bu yüzden
  /// yeni grid'in tüm hücreleri zaten idle olur.
  void _generateGrid() {
    final shape = gridShapeForLevel(level);
    cells = _generator
        .generateGrid(level, operations: operations, count: shape.cellCount)
        .map((problem) => GridCell(problem: problem))
        .toList();
    targetNumber = cells[_random.nextInt(cells.length)].problem.answer;
    _targetSetAt = DateTime.now();
  }

  void _tick() {
    if (status != GameStatus.playing) return;
    timeRemainingSeconds--;
    if (timeRemainingSeconds <= 10 && timeRemainingSeconds > 0) {
      _audio.playTick();
    }
    if (timeRemainingSeconds <= 0) {
      timeRemainingSeconds = 0;
      _endGame();
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
      _generateGrid();
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

  Future<void> _endGame({bool outOfLives = false}) async {
    _timer?.cancel();
    status = outOfLives ? GameStatus.outOfLives : GameStatus.timeUp;
    _audio.playTimeUp();
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
