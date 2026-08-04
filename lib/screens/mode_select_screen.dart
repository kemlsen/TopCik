import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_scaffold.dart';
import 'climb_game_screen.dart';
import 'level_select_screen.dart';

const _modeColors = {
  GameMode.hunt: AppColors.levelMedium,
  GameMode.match: AppColors.levelHard,
  GameMode.climb: AppColors.levelEasy,
};

const _modeIcons = {
  GameMode.hunt: Icons.grid_view_rounded,
  GameMode.match: Icons.join_full_rounded,
  GameMode.climb: Icons.terrain_rounded,
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

  /// Tırmanış modu Seviye Seç / İşlem Türü Seç akışını atlar ve doğrudan
  /// oyuna girer, bu yüzden "son oynanan mod" kaydını (diğer modlarda
  /// `LevelSelectScreen._startLevel` içinde yapılan işi) burada kendisi
  /// yapmalı.
  Future<void> _handleModeTap(BuildContext context, GameMode mode) async {
    if (mode == GameMode.climb) {
      await scoreService.setLastMode(mode);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ClimbGameScreen(
            audioService: audioService,
            scoreService: scoreService,
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LevelSelectScreen(
          mode: mode,
          audioService: audioService,
          scoreService: scoreService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Mod Seç',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: GameMode.values
            .map(
              (mode) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ModeCard(
                  mode: mode,
                  onTap: () => _handleModeTap(context, mode),
                ),
              ),
            )
            .toList(),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
      ),
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
