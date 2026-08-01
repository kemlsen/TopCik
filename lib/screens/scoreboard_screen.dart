import 'package:flutter/material.dart';

import '../models/difficulty_level.dart';
import '../models/game_mode.dart';
import '../services/score_service.dart';
import '../theme/app_colors.dart';

class ScoreboardScreen extends StatelessWidget {
  final ScoreService scoreService;

  const ScoreboardScreen({super.key, required this.scoreService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Skor Tablosu',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (final mode in GameMode.values) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 6),
                child: Text(
                  mode.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
              ...DifficultyLevel.values.map((level) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: FutureBuilder<int>(
                    future: scoreService.getBestScore(level, mode: mode),
                    builder: (context, snapshot) {
                      final best = snapshot.data ?? 0;
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  level.displayName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '$best',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
