import '../models/difficulty_level.dart';

/// Round -> grid shape (columns + total cell count). İlk katman kare değil
/// (1x2 — tek hücrede gerçek bir seçim olmayacağı için en az iki hücre
/// olsun diye), sonraki katmanlar kare: 2x2 -> 3x3 -> 4x4, orada sabit
/// kalır (bkz. CLAUDE.md Bölüm 3b).
({int columns, int cellCount}) climbGridShapeForRound(int round) {
  if (round <= 10) return (columns: 2, cellCount: 2); // 1x2
  if (round <= 20) return (columns: 2, cellCount: 4); // 2x2
  if (round <= 40) return (columns: 3, cellCount: 9); // 3x3
  return (columns: 4, cellCount: 16); // 4x4
}

/// Round -> işlem zorluğu, [climbGridShapeForRound] ile aynı eşiklerde
/// ilerler (sayı aralığı/işlem türleri mevcut [DifficultyLevel]
/// tanımlarından otomatik gelir, ayrı bir seçim ekranına gerek kalmaz).
DifficultyLevel climbLevelForRound(int round) {
  if (round <= 10) return DifficultyLevel.easy;
  if (round <= 20) return DifficultyLevel.medium;
  if (round <= 40) return DifficultyLevel.hard;
  return DifficultyLevel.expert;
}
