import 'package:flutter/material.dart' show IconData, Icons;

/// Günlük hedef havuzu (bkz. CLAUDE.md Bölüm 17). Her gün bu havuzdan 3
/// tanesi tarihe göre sabit (deterministic) bir şekilde seçilir — bkz.
/// `DailyGoalsService`. Hepsi zaten var olan oyun sonucu alanlarından
/// (skor, doğru sayısı, eşleşen çift, ulaşılan bölüm) beslenir, yeni bir
/// oyun mekaniği gerektirmez.
enum DailyGoalKind { playCount, totalScore, huntCorrect, matchPairs, climbRound }

extension DailyGoalKindInfo on DailyGoalKind {
  int get target {
    switch (this) {
      case DailyGoalKind.playCount:
        return 2;
      case DailyGoalKind.totalScore:
        return 150;
      case DailyGoalKind.huntCorrect:
        return 15;
      case DailyGoalKind.matchPairs:
        return 10;
      case DailyGoalKind.climbRound:
        return 10;
    }
  }

  String get description {
    switch (this) {
      case DailyGoalKind.playCount:
        return 'Bugün en az 2 oyun oyna';
      case DailyGoalKind.totalScore:
        return 'Bugün toplam 150 puan topla';
      case DailyGoalKind.huntCorrect:
        return "Sayı Avı'nda 15 doğru cevap ver";
      case DailyGoalKind.matchPairs:
        return "Eşleştirme'de 10 çift bul";
      case DailyGoalKind.climbRound:
        return "Tırmanış'ta 10. bölüme ulaş";
    }
  }

  IconData get icon {
    switch (this) {
      case DailyGoalKind.playCount:
        return Icons.videogame_asset_rounded;
      case DailyGoalKind.totalScore:
        return Icons.star_rounded;
      case DailyGoalKind.huntCorrect:
        return Icons.grid_view_rounded;
      case DailyGoalKind.matchPairs:
        return Icons.join_full_rounded;
      case DailyGoalKind.climbRound:
        return Icons.terrain_rounded;
    }
  }
}

/// Bugünün hedeflerinden biri, ne kadarının tamamlandığıyla birlikte.
class DailyGoalProgress {
  final DailyGoalKind kind;
  final int current;

  const DailyGoalProgress({required this.kind, required this.current});

  int get target => kind.target;
  bool get isCompleted => current >= target;
  double get ratio => (current / target).clamp(0, 1).toDouble();
}

/// Seri (streak) uzunluğuna göre açılan matematik temalı rütbeler (bkz.
/// CLAUDE.md Bölüm 17).
enum DailyRank {
  apprentice,
  additionMaster,
  multiplicationHero,
  divisionWizard,
  mathGenius,
}

extension DailyRankInfo on DailyRank {
  String get displayName {
    switch (this) {
      case DailyRank.apprentice:
        return 'Sayı Çırağı';
      case DailyRank.additionMaster:
        return 'Toplama Ustası';
      case DailyRank.multiplicationHero:
        return 'Çarpım Kahramanı';
      case DailyRank.divisionWizard:
        return 'Bölme Büyücüsü';
      case DailyRank.mathGenius:
        return 'Matematik Dahisi';
    }
  }

  /// Bir sonraki rütbeye geçmek için gereken minimum seri (gün); en üst
  /// rütbedeyken bir sonraki yoktur.
  int? get nextThreshold {
    switch (this) {
      case DailyRank.apprentice:
        return 3;
      case DailyRank.additionMaster:
        return 7;
      case DailyRank.multiplicationHero:
        return 14;
      case DailyRank.divisionWizard:
        return 30;
      case DailyRank.mathGenius:
        return null;
    }
  }
}

/// Seri (gün) -> rütbe eşlemesi.
DailyRank rankForStreak(int streak) {
  if (streak >= 30) return DailyRank.mathGenius;
  if (streak >= 14) return DailyRank.divisionWizard;
  if (streak >= 7) return DailyRank.multiplicationHero;
  if (streak >= 3) return DailyRank.additionMaster;
  return DailyRank.apprentice;
}
