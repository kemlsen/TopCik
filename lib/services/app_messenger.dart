import 'package:flutter/material.dart';

/// Ekranlar arası basit bildirimler (örn. Mod Seç akışı tamamlanıp Ana
/// Menü'ye dönüldüğünde gösterilen "Oyna'ya hazır!" bildirimi) için
/// [MaterialApp.scaffoldMessengerKey]'e bağlanan paylaşılan anahtar.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
