import 'package:flutter/material.dart';

import '../logic/climb_game_controller.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../theme/app_colors.dart';
import '../widgets/climb_status_widget.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/grid_widget.dart';
import '../widgets/lives_badge.dart';
import '../widgets/target_number_widget.dart';
import '../widgets/timer_widget.dart';
import 'climb_result_screen.dart';

/// Tırmanış modu oyun ekranı: bölüme göre büyüyen grid + üstte hedef sayı,
/// bölüm rozeti ve tek süre sayacı + skor (bkz. CLAUDE.md Bölüm 3b).
class ClimbGameScreen extends StatefulWidget {
  final AudioService audioService;
  final ScoreService scoreService;

  const ClimbGameScreen({
    super.key,
    required this.audioService,
    required this.scoreService,
  });

  @override
  State<ClimbGameScreen> createState() => _ClimbGameScreenState();
}

class _ClimbGameScreenState extends State<ClimbGameScreen> {
  late final ClimbGameController _controller;
  bool _navigatedToResult = false;

  @override
  void initState() {
    super.initState();
    _controller = ClimbGameController(
      audioService: widget.audioService,
      scoreService: widget.scoreService,
    );
    _controller.onGameEnd = _handleGameEnd;
    _controller.start();
  }

  void _handleGameEnd(ClimbGameResult result) {
    if (_navigatedToResult || !mounted) return;
    _navigatedToResult = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ClimbResultScreen(
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
          title: 'Tırmanış',
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
                          totalSeconds:
                              ClimbGameController.initialTimeBudgetSeconds,
                        ),
                        Expanded(
                          child: Center(
                            child: TargetNumberWidget(
                              targetNumber: _controller.targetNumber,
                            ),
                          ),
                        ),
                        _ScoreBadge(score: _controller.score),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClimbStatusWidget(round: _controller.round),
                    const SizedBox(height: 10),
                    LivesBadge(livesRemaining: _controller.livesRemaining),
                  ],
                ),
              ),
              Expanded(child: GridWidget(controller: _controller)),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _controller.wrongIndex != null ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Yanlış! Tekrar dene 🙂',
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
