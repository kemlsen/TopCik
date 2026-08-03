/// Shared constants/enums used by both game controllers (Sayı Avı ve
/// Eşleştirme modu) so the two modes stay consistent.
enum GameStatus { playing, levelComplete, timeUp, outOfLives }

/// 4 sütun x 6 satır = 24 hücre. Ekranı daha iyi doldurmak için standart
/// 4x4'ten büyütüldü; [GridWidget] hücre boyutunu buna göre otomatik
/// hesaplar (bkz. grid_widget.dart).
const int gridSize = 24;
const int gridColumns = 4;

/// Bölüm 6 — Can sistemi: oyuncuya 3 deneme hakkı verilir, 4. yanlış
/// cevapta oyun biter. Her iki modda da geçerlidir.
const int maxLives = 3;

const correctAnimationDuration = Duration(milliseconds: 450);
const wrongAnimationDuration = Duration(milliseconds: 500);
