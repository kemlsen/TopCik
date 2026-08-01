/// Shared constants/enums used by both game controllers (Sayı Avı ve
/// Eşleştirme modu) so the two modes stay consistent.
enum GameStatus { playing, levelComplete, timeUp, outOfLives }

const int gridSize = 16;

/// Bölüm 6 — Can sistemi: oyuncuya 3 deneme hakkı verilir, 4. yanlış
/// cevapta oyun biter. Her iki modda da geçerlidir.
const int maxLives = 3;

const correctAnimationDuration = Duration(milliseconds: 450);
const wrongAnimationDuration = Duration(milliseconds: 500);
