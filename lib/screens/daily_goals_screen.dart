import 'package:flutter/material.dart';

import '../models/daily_goal.dart';
import '../services/daily_goals_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_scaffold.dart';

/// Günlük hedefler + seri (streak) + rütbe ekranı (bkz. CLAUDE.md Bölüm 17).
/// Ana Menü'deki seri rozetinden açılır.
class DailyGoalsScreen extends StatelessWidget {
  final DailyGoalsService dailyGoalsService;

  const DailyGoalsScreen({super.key, required this.dailyGoalsService});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Günlük Hedefler',
      body: FutureBuilder<DailyGoalsSnapshot>(
        future: dailyGoalsService.getTodaySnapshot(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            children: [
              _StreakCard(streak: data.streak, rank: data.rank),
              const SizedBox(height: 24),
              const Text(
                'Bugünün hedefleri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...data.goals.map(
                (goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GoalTile(goal: goal),
                ),
              ),
              if (data.allCompletedToday) ...[
                const SizedBox(height: 8),
                const Text(
                  '🎉 Bugünün hedeflerini tamamladın, yarın seri devam ediyor!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  final DailyRank rank;

  const _StreakCard({required this.streak, required this.rank});

  @override
  Widget build(BuildContext context) {
    final next = rank.nextThreshold;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak == 1 ? '1 gün' : '$streak gün',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    rank.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  if (next != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${next - streak} gün sonra bir sonraki rütbe',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final DailyGoalProgress goal;

  const _GoalTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: goal.isCompleted
                    ? AppColors.success
                    : AppColors.levelMedium,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                goal.isCompleted ? Icons.check_rounded : goal.kind.icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.kind.description,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: goal.ratio,
                      minHeight: 8,
                      backgroundColor: Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        goal.isCompleted ? AppColors.success : AppColors.cta,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${goal.current}/${goal.target}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
