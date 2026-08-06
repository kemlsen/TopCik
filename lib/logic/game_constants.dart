/// Shared constants/enums used by all three game controllers so the modes
/// stay consistent.
enum GameStatus { playing, timeUp, outOfLives }

/// Bölüm 6 — Can sistemi: oyuncuya 3 deneme hakkı verilir, 4. yanlış
/// cevapta oyun biter. Üç modda da geçerlidir.
const int maxLives = 3;

const correctAnimationDuration = Duration(milliseconds: 450);
const wrongAnimationDuration = Duration(milliseconds: 500);
