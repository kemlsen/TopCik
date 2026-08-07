import 'package:flutter/material.dart';

import '../logic/game_controller.dart';
import '../services/audio_service.dart';
import '../services/daily_goals_service.dart';
import '../services/score_service.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_symbols_background.dart';
import '../widgets/mascot_widget.dart';
import 'game_screen.dart';
import 'main_menu_screen.dart';

class ResultScreen extends StatelessWidget {
  final GameResult result;
  final AudioService audioService;
  final ScoreService scoreService;
  final DailyGoalsService dailyGoalsService;

  const ResultScreen({
    super.key,
    required this.result,
    required this.audioService,
    required this.scoreService,
    required this.dailyGoalsService,
  });

  @override
  Widget build(BuildContext context) {
    final title = result.outOfLives ? 'Deneme Hakkın Bitti!' : 'Süre Doldu!';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: Stack(
          children: [
            const Positioned.fill(child: FloatingSymbolsBackground()),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MascotWidget(
                            mood: result.outOfLives
                                ? MascotMood.sad
                                : MascotMood.happy,
                            size: 108,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${result.score}',
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Text(
                                  'Skor',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _StatColumn(
                                      label: 'Doğru',
                                      value: result.correctCount,
                                      color: AppColors.success,
                                    ),
                                    _StatColumn(
                                      label: 'Yanlış',
                                      value: result.wrongCount,
                                      color: AppColors.error,
                                    ),
                                  ],
                                ),
                                if (result.isNewBest) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    '🏆 Yeni rekor!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => GameScreen(
                                      level: result.level,
                                      operations: result.operations,
                                      audioService: audioService,
                                      scoreService: scoreService,
                                      dailyGoalsService: dailyGoalsService,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cta,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Tekrar Oyna',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => MainMenuScreen(
                                      audioService: audioService,
                                      scoreService: scoreService,
                                      dailyGoalsService: dailyGoalsService,
                                    ),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Ana Menü',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
