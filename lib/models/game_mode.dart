/// The two playable game modes (bkz. CLAUDE.md Bölüm 3 ve Bölüm 3a).
enum GameMode { hunt, match }

extension GameModeInfo on GameMode {
  String get displayName {
    switch (this) {
      case GameMode.hunt:
        return 'Sayı Avı';
      case GameMode.match:
        return 'Eşleştirme';
    }
  }

  String get tagline {
    switch (this) {
      case GameMode.hunt:
        return 'Hedef sayıyı bul, doğru işlemi yakala!';
      case GameMode.match:
        return 'Sonucu aynı olan iki işlemi eşleştir!';
    }
  }
}
