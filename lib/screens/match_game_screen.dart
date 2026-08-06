import 'package:flutter/material.dart';

import '../logic/match_game_controller.dart';
import '../models/difficulty_level.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/grid_widget.dart';
import '../widgets/lives_badge.dart';
import '../widgets/match_status_widget.dart';
import '../widgets/timer_widget.dart';
import 'match_result_screen.dart';

/// Eşleştirme modu oyun ekranı: seviyeye göre sabit boyutlu grid + üstte
/// kalan çift sayısı + süre sayacı + skor. Hedef sayı yerine, oyuncu
/// sonucu aynı olan iki hücreyi eşleştirir (bkz. CLAUDE.md Bölüm 3a).
class MatchGameScreen extends StatefulWidget {
  final DifficultyLevel level;
  final Set<Operation> operations;
  final AudioService audioService;
  final ScoreService scoreService;

  const MatchGameScreen({
    super.key,
    required this.level,
    required this.operations,
    required this.audioService,
    required this.scoreService,
  });

  @override
  State<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends State<MatchGameScreen> {
  late final MatchGameController _controller;
  bool _navigatedToResult = false;

  @override
  void initState() {
    super.initState();
    _controller = MatchGameController(
      level: widget.level,
      operations: widget.operations,
      audioService: widget.audioService,
      scoreService: widget.scoreService,
    );
    _controller.onGameEnd = _handleGameEnd;
    _controller.start();
  }

  void _handleGameEnd(MatchGameResult result) {
    if (_navigatedToResult || !mounted) return;
    _navigatedToResult = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MatchResultScreen(
          result: result,
          audioService: widget.audioService,
          scoreService: widget.scoreService,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return GradientScaffold(
          title: '${widget.level.displayName} · Eşleştirme',
          dimmed:
              _controller.timeRemainingSeconds <= 10 &&
              _controller.timeRemainingSeconds > 0,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TimerWidget(
                          remainingSeconds: _controller.timeRemainingSeconds,
                          totalSeconds: widget.level.timeLimitSeconds,
                        ),
                        Expanded(
                          child: Center(
                            child: MatchStatusWidget(
                              matchedPairs: _controller.clearedPairsInGrid,
                              totalPairs: _controller.totalPairs,
                            ),
                          ),
                        ),
                        _ScoreBadge(score: _controller.score),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LivesBadge(livesRemaining: _controller.livesRemaining),
                  ],
                ),
              ),
              Expanded(child: GridWidget(controller: _controller)),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _controller.wrongPair != null ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Eşleşmedi! Tekrar dene 🙂',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: AppColors.error.withValues(alpha: 0.9),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cta,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Skor',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
