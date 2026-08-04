/// The three playable game modes (bkz. CLAUDE.md Bölüm 3, 3a ve 3b).
enum GameMode { hunt, match, climb }

extension GameModeInfo on GameMode {
  String get displayName {
    switch (this) {
      case GameMode.hunt:
        return 'Sayı Avı';
      case GameMode.match:
        return 'Eşleştirme';
      case GameMode.climb:
        return 'Tırmanış';
    }
  }

  String get tagline {
    switch (this) {
      case GameMode.hunt:
        return 'Hedef sayıyı bul, doğru işlemi yakala!';
      case GameMode.match:
        return 'Sonucu aynı olan iki işlemi eşleştir!';
      case GameMode.climb:
        return 'Kolaydan başla, bölüm bölüm zirveye tırman!';
    }
  }
}
