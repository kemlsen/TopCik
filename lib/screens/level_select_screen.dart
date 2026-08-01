import 'package:flutter/material.dart';

import '../models/difficulty_level.dart';
import '../models/game_mode.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../widgets/gradient_scaffold.dart';
import 'operation_select_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  final GameMode mode;
  final AudioService audioService;
  final ScoreService scoreService;

  const LevelSelectScreen({
    super.key,
    required this.mode,
    required this.audioService,
    required this.scoreService,
  });

  Future<void> _startLevel(BuildContext context, DifficultyLevel level) async {
    await scoreService.setLastLevel(level);
    await scoreService.setLastMode(mode);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OperationSelectScreen(
          level: level,
          mode: mode,
          audioService: audioService,
          scoreService: scoreService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: '${mode.displayName} — Seviye Seç',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: DifficultyLevel.values
            .map(
              (level) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _LevelCard(
                  level: level,
                  mode: mode,
                  scoreService: scoreService,
                  onTap: () => _startLevel(context, level),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final DifficultyLevel level;
  final GameMode mode;
  final ScoreService scoreService;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.mode,
    required this.scoreService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = level.color;
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
      ),
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.displayName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.ageRange,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<int>(
                      future: scoreService.getBestScore(level, mode: mode),
                      builder: (context, snapshot) {
                        final best = snapshot.data ?? 0;
                        return Text(
                          'En iyi skor: $best',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 36,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
