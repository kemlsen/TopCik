import 'package:flutter/material.dart';

import 'screens/main_menu_screen.dart';
import 'services/audio_service.dart';
import 'services/score_service.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const TopCikApp());
}

class TopCikApp extends StatefulWidget {
  const TopCikApp({super.key});

  @override
  State<TopCikApp> createState() => _TopCikAppState();
}

class _TopCikAppState extends State<TopCikApp> {
  final AudioService _audioService = AudioService();
  final ScoreService _scoreService = ScoreService();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _audioService.init();
    _audioService.playBackgroundMusic();
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TopCik - Sayı Avı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: _ready
          ? MainMenuScreen(
              audioService: _audioService,
              scoreService: _scoreService,
            )
          : const _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
