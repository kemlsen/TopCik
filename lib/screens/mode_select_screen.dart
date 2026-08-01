import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../theme/app_colors.dart';
import 'level_select_screen.dart';

const _modeColors = {
  GameMode.hunt: AppColors.levelMedium,
  GameMode.match: AppColors.levelHard,
};

const _modeIcons = {
  GameMode.hunt: Icons.grid_view_rounded,
  GameMode.match: Icons.join_full_rounded,
};

/// Ana menüdeki eski "Seviye Seç" ve "Eşleştirme Modu" butonlarının
/// birleştiği tek giriş noktası: oyuncu önce oyun modunu seçer, ardından
/// ortak Seviye Seç / İşlem Türü Seç akışına devam eder.
class ModeSelectScreen extends StatelessWidget {
  final AudioService audioService;
  final ScoreService scoreService;

  const ModeSelectScreen({
    super.key,
    required this.audioService,
    required this.scoreService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mod Seç',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: GameMode.values
              .map(
                (mode) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ModeCard(
                    mode: mode,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LevelSelectScreen(
                          mode: mode,
                          audioService: audioService,
                          scoreService: scoreService,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final GameMode mode;
  final VoidCallback onTap;

  const _ModeCard({required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _modeColors[mode]!;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(_modeIcons[mode]!, size: 40, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.tagline,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 36,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
