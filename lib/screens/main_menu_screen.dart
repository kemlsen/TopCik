import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../theme/app_colors.dart';
import 'level_select_screen.dart';
import 'scoreboard_screen.dart';
import 'settings_screen.dart';
import 'operation_select_screen.dart';

class MainMenuScreen extends StatelessWidget {
  final AudioService audioService;
  final ScoreService scoreService;

  const MainMenuScreen({
    super.key,
    required this.audioService,
    required this.scoreService,
  });

  Future<void> _quickPlay(BuildContext context) async {
    final level = await scoreService.getLastLevel();
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OperationSelectScreen(
          level: level,
          mode: GameMode.hunt,
          audioService: audioService,
          scoreService: scoreService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🦉', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 6),
                    const Text(
                      'TopCik',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Sayı Avı',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _MenuButton(
                      label: 'Oyna',
                      icon: Icons.play_arrow_rounded,
                      color: AppColors.cta,
                      onTap: () => _quickPlay(context),
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      label: 'Seviye Seç',
                      icon: Icons.grid_view_rounded,
                      color: AppColors.levelMedium,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LevelSelectScreen(
                            mode: GameMode.hunt,
                            audioService: audioService,
                            scoreService: scoreService,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      label: 'Eşleştirme Modu',
                      icon: Icons.join_full_rounded,
                      color: AppColors.levelHard,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LevelSelectScreen(
                            mode: GameMode.match,
                            audioService: audioService,
                            scoreService: scoreService,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      label: 'Skor Tablosu',
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.gold,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ScoreboardScreen(scoreService: scoreService),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      label: 'Ayarlar',
                      icon: Icons.settings_rounded,
                      color: AppColors.levelExpert,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              SettingsScreen(audioService: audioService),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 28, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 6,
          shadowColor: color.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
