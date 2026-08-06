import '../models/difficulty_level.dart';
import 'grid_shape.dart';

/// Round -> grid shape (columns + total cell count), orada sabit kalır.
/// Eşikler bilerek geniş tutulur: ilkokulda matematiğe yeni başlayan
/// çocuklar ilk katmanlarda uzun süre zorlanmadan ilerleyip daha ileri
/// bölümlere ulaşabilsin (bkz. CLAUDE.md Bölüm 3b). Katman -> şekil
/// eşlemesinin kendisi [gridShapeForLevel]'de yaşar, Sayı Avı'nın seçilen
/// seviyeye göre sabit grid boyutuyla aynı kaynaktan gelsin diye (bkz.
/// Bölüm 2).
({int columns, int cellCount}) climbGridShapeForRound(int round) =>
    gridShapeForLevel(climbLevelForRound(round));

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
