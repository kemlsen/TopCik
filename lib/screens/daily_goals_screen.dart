import 'package:flutter/material.dart';

import '../models/daily_goal.dart';
import '../services/daily_goals_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/mascot_widget.dart';

/// Rütbe -> maskot kıyafeti eşlemesi (bkz. CLAUDE.md Bölüm 17 ve
/// [MascotOutfit] doküman yorumu) — `DailyRank` enum sırasıyla birebir
/// örtüşür.
MascotOutfit _outfitForRank(DailyRank rank) {
  switch (rank) {
    case DailyRank.apprentice:
      return MascotOutfit.none;
    case DailyRank.additionMaster:
      return MascotOutfit.cape;
    case DailyRank.multiplicationHero:
      return MascotOutfit.hero;
    case DailyRank.divisionWizard:
      return MascotOutfit.wizard;
    case DailyRank.mathGenius:
      return MascotOutfit.genius;
  }
}

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
              const SizedBox(height: 16),
              _RankLadderCard(currentRank: data.rank),
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
        // Üstte fazladan boşluk: bazı kıyafetler (büyücü şapkası, taç)
        // maskotun kendi kutusunun üstüne taşar (bkz. MascotWidget içindeki
        // Clip.none Stack'ler) — bu boşluk olmadan kartın üst kenarını aşabilir.
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
        child: Row(
          children: [
            MascotWidget(
              mood: MascotMood.happy,
              size: 76,
              outfit: _outfitForRank(rank),
              outfitColor: rank.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak == 1 ? '🔥 1 gün' : '🔥 $streak gün',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${rank.emoji} ${rank.displayName}',
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

/// Tüm rütbeleri, hangilerinin açıldığını ve şu an hangisinde olunduğunu
/// tek bakışta gösteren dikey "yol" — kullanıcı sadece mevcut rütbesini
/// değil, önünde neler olduğunu görüp hırslansın diye (bkz. kullanıcı
/// isteği: diğer rütbeler bilinmeyince motivasyon eksik kalıyordu).
class _RankLadderCard extends StatelessWidget {
  final DailyRank currentRank;

  const _RankLadderCard({required this.currentRank});

  @override
  Widget build(BuildContext context) {
    final ranks = DailyRank.values;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rütbe Yolu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < ranks.length; i++)
              _RankLadderRow(
                rank: ranks[i],
                isLast: i == ranks.length - 1,
                isCurrent: ranks[i] == currentRank,
                isUnlocked: ranks[i].requiredStreak <= currentRank.requiredStreak,
              ),
          ],
        ),
      ),
    );
  }
}

class _RankLadderRow extends StatelessWidget {
  final DailyRank rank;
  final bool isLast;
  final bool isCurrent;
  final bool isUnlocked;

  const _RankLadderRow({
    required this.rank,
    required this.isLast,
    required this.isCurrent,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = isUnlocked ? rank.color : Colors.black12;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: AppColors.gold, width: 3)
                      : null,
                ),
                // Maskotun kendi kutusu dairenin dışına taşabilir (bkz.
                // MascotWidget'ın Clip.none Stack'leri, örn. büyücü
                // şapkası) — ClipOval bunu tıpkı yuvarlak bir profil
                // fotoğrafı gibi daire sınırında kırpar, kıyafeti tanınır
                // kılan gövde/rozet kısmı hep görünür kalır.
                child: ClipOval(
                  child: Container(
                    color: circleColor,
                    alignment: Alignment.center,
                    child: isUnlocked
                        ? Transform.translate(
                            offset: const Offset(0, 8),
                            child: MascotWidget(
                              mood: MascotMood.idle,
                              size: 40,
                              outfit: _outfitForRank(rank),
                              outfitColor: rank.color,
                            ),
                          )
                        : const Icon(
                            Icons.lock_rounded,
                            color: Colors.black38,
                            size: 20,
                          ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: isUnlocked ? rank.color.withValues(alpha: 0.35) : Colors.black12,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rank.displayName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isUnlocked ? Colors.black87 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCurrent
                        ? 'Şu an buradasın'
                        : rank.requiredStreak == 0
                            ? 'Başlangıç rütbesi'
                            : '${rank.requiredStreak} günlük seride açılır',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent ? AppColors.gold : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUnlocked && !isCurrent)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            ),
        ],
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
