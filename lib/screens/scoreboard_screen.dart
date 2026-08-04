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
            if (mode == GameMode.climb)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ClimbSummaryCard(scoreService: scoreService),
              )
            else
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

/// Tırmanış modu, ayrı DifficultyLevel seçimi olmadığı için diğer modların
/// dört seviyelik satır listesi yerine tek bir özet kart gösterir (bkz.
/// CLAUDE.md Bölüm 3b).
class _ClimbSummaryCard extends StatelessWidget {
  final ScoreService scoreService;

  const _ClimbSummaryCard({required this.scoreService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: Future.wait([
        scoreService.getClimbBestRound(),
        scoreService.getClimbBestScore(),
      ]),
      builder: (context, snapshot) {
        final bestRound = snapshot.data?[0] ?? 0;
        final bestScore = snapshot.data?[1] ?? 0;
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          elevation: 3,
          shadowColor: AppColors.levelEasy.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.levelEasy,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.terrain_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'En iyi bölüm: $bestRound',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'En iyi skor: $bestScore',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.emoji_events_rounded,
                  size: 20,
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
