import 'package:flutter/material.dart';

import '../models/difficulty_level.dart';
import '../models/game_mode.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../theme/app_colors.dart';
import 'operation_select_screen.dart';

const _levelColors = {
  DifficultyLevel.easy: AppColors.levelEasy,
  DifficultyLevel.medium: AppColors.levelMedium,
  DifficultyLevel.hard: AppColors.levelHard,
  DifficultyLevel.expert: AppColors.levelExpert,
};

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${mode.displayName} — Seviye Seç',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
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
    final color = _levelColors[level]!;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
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
