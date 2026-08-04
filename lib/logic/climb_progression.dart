import '../models/difficulty_level.dart';

/// Round -> grid shape (columns + total cell count). İlk katman kare değil
/// (1x2 — tek hücrede gerçek bir seçim olmayacağı için en az iki hücre
/// olsun diye), sonraki katmanlar kare: 2x2 -> 3x3 -> 4x4, orada sabit
/// kalır. Eşikler bilerek geniş tutulur: ilkokulda matematiğe yeni başlayan
/// çocuklar ilk katmanlarda uzun süre zorlanmadan ilerleyip daha ileri
/// bölümlere ulaşabilsin (bkz. CLAUDE.md Bölüm 3b).
({int columns, int cellCount}) climbGridShapeForRound(int round) {
  if (round <= 20) return (columns: 2, cellCount: 2); // 1x2
  if (round <= 50) return (columns: 2, cellCount: 4); // 2x2
  if (round <= 100) return (columns: 3, cellCount: 9); // 3x3
  return (columns: 4, cellCount: 16); // 4x4
}

/// Round -> sayı aralığı zorluğu (mevcut [DifficultyLevel.maxNumber]),
/// [climbGridShapeForRound] ile aynı geniş eşiklerde ilerler.
DifficultyLevel climbLevelForRound(int round) {
  if (round <= 20) return DifficultyLevel.easy;
  if (round <= 50) return DifficultyLevel.medium;
  if (round <= 100) return DifficultyLevel.hard;
  return DifficultyLevel.expert;
}

/// Round -> işlem türü havuzu. [DifficultyLevel.operations]'tan bilerek
/// bağımsız: çarpma ve bölme yalnızca Zor katmanından itibaren açılır;
/// Kolay ve Orta katmanları (matematiğe yeni başlayanlar için) sadece
/// toplama/çıkarma içerir.
Set<Operation> climbOperationsForRound(int round) {
  final level = climbLevelForRound(round);
  if (level == DifficultyLevel.easy || level == DifficultyLevel.medium) {
    return {Operation.addition, Operation.subtraction};
  }
  return {
    Operation.addition,
    Operation.subtraction,
    Operation.multiplication,
    Operation.division,
  };
}
