import 'package:flutter/material.dart';

/// TopCik marka paleti — modern, canlı ama göz yormayan, Play Store'a
/// hazır bir görünüm için tek kaynak. Tüm ekranlar renklerini buradan alır.
abstract class AppColors {
  // Marka rengi (AppBar, ana gradient)
  static const primary = Color(0xFF5B4FE9); // Elektrik indigo
  static const primaryDark = Color(0xFF3F32C4); // Koyu indigo
  static const accent = Color(0xFF8B5CF6); // Canlı mor (gradient ikinci ucu)

  // Ana çağrı-eylem rengi (Oyna butonu vb.)
  static const cta = Color(0xFF00C2A8); // Canlı camgöbeği

  // Geri bildirim renkleri
  static const success = Color(0xFF13B981); // Zümrüt yeşili
  static const successGlow = Color(0xFF4EF0B8);
  static const error = Color(0xFFF0405C); // Mercan kırmızısı (sert değil)
  static const gold = Color(0xFFFFB020); // Skor / hedef sayı / rekor

  // Seviye kartı renkleri (birbirinden ayrışan, uyumlu ton seti)
  static const levelEasy = Color(0xFF22C3A6); // Camgöbeği-yeşil
  static const levelMedium = Color(0xFF3B9CF2); // Gökyüzü mavisi
  static const levelHard = Color(0xFFFF8A4C); // Turuncu
  static const levelExpert = Color(0xFF9B6BF2); // Mor

  // Grid hücre (idle) renk havuzu
  static const tilePalette = [
    Color(0xFF3B9CF2), // mavi
    Color(0xFFFFB020), // altın
    Color(0xFFFF8A4C), // turuncu
    Color(0xFF22C3A6), // camgöbeği
    Color(0xFF9B6BF2), // mor
  ];

  // Yüzeyler
  static const background = Color(0xFFF4F4FC); // yumuşak lavanta-beyaz
  static const surface = Colors.white;

  // Menü / sonuç ekranı arka plan gradienti
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );
}
