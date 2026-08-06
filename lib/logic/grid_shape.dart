import '../models/difficulty_level.dart';

/// Difficulty level -> grid shape (columns + total cell count). Kolay
/// katmanı kare değil (1x2 — tek hücrede gerçek bir seçim olmayacağı için
/// en az iki hücre olsun diye), sonraki katmanlar kare: 2x2 -> 3x3 -> 4x4.
/// Tırmanış modunun bölüm eşiklerinde kullandığı aynı eşleme (bkz.
/// [climbGridShapeForRound] / CLAUDE.md Bölüm 3b); Sayı Avı da seçilen
/// seviyeye göre sabit grid boyutu için bunu kullanır (bkz. Bölüm 2).
({int columns, int cellCount}) gridShapeForLevel(DifficultyLevel level) {
  switch (level) {
    case DifficultyLevel.easy:
      return (columns: 2, cellCount: 2); // 1x2
    case DifficultyLevel.medium:
      return (columns: 2, cellCount: 4); // 2x2
    case DifficultyLevel.hard:
      return (columns: 3, cellCount: 9); // 3x3
    case DifficultyLevel.expert:
      return (columns: 4, cellCount: 16); // 4x4
  }
}

/// Difficulty level -> grid shape for Eşleştirme modu (columns + pair
/// count; cell count is always `pairCount * 2`). Aynı büyüme mantığını
/// izler (kolaydan zora artan sütun sayısı — bkz. [gridShapeForLevel]) ama
/// çift sayısına göre ölçeklenir: her seviyede en az 2 çift olur (1 çiftte
/// gerçek bir seçim olmaz, kalan tek çift otomatik doğru olur). Uzman
/// seviyesi, mevcut en iyi skorların anlamlı kalması için oyunun özgün
/// sabit boyutunu (4x6, 12 çift) korur.
({int columns, int pairCount}) matchGridShapeForLevel(DifficultyLevel level) {
  switch (level) {
    case DifficultyLevel.easy:
      return (columns: 2, pairCount: 2); // 2x2
    case DifficultyLevel.medium:
      return (columns: 2, pairCount: 4); // 2x4
    case DifficultyLevel.hard:
      return (columns: 3, pairCount: 6); // 3x4
    case DifficultyLevel.expert:
      return (columns: 4, pairCount: 12); // 4x6
  }
}
