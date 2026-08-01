import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mathgrid/screens/main_menu_screen.dart';
import 'package:mathgrid/services/audio_service.dart';
import 'package:mathgrid/services/score_service.dart';

void main() {
  testWidgets('Main menu shows Oyna, Mod Seç, Skor Tablosu ve Ayarlar', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: MainMenuScreen(
          audioService: AudioService(),
          scoreService: ScoreService(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Oyna'), findsOneWidget);
    expect(find.text('Mod Seç'), findsOneWidget);
    expect(find.text('Skor Tablosu'), findsOneWidget);
    expect(find.text('Ayarlar'), findsOneWidget);
  });
}
