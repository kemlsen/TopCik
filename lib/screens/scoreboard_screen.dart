import 'package:flutter/material.dart';

import '../models/difficulty_level.dart';
import '../models/game_mode.dart';
import '../services/score_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_scaffold.dart';

class ScoreboardScreen extends StatelessWidget {
  final ScoreService scoreService;

  const ScoreboardScreen({super.key, required this.scoreService});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Skor Tablosu',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          for (final mode in GameMode.values) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 6),
              child: Text(
                mode.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
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
                      elevation: 3,
                      shadowColor: level.color.withValues(alpha: 0.5),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: level.color,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                level.displayName[0],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                level.displayName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.emoji_events_rounded,
                              size: 20,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 6),
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
    );
  }
}
