import 'dart:async';

import 'package:flutter/material.dart';

import '../models/daily_goal.dart';
import '../models/game_mode.dart';
import '../services/audio_service.dart';
import '../services/daily_goals_service.dart';
import '../services/score_service.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_symbols_background.dart';
import '../widgets/mascot_widget.dart';
import 'climb_game_screen.dart';
import 'daily_goals_screen.dart';
import 'game_screen.dart';
import 'match_game_screen.dart';
import 'mode_select_screen.dart';
import 'scoreboard_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatelessWidget {
  final AudioService audioService;
  final ScoreService scoreService;
  final DailyGoalsService dailyGoalsService;

  const MainMenuScreen({
    super.key,
    required this.audioService,
    required this.scoreService,
    required this.dailyGoalsService,
  });

  /// "Oyna": Mod Seç ekranında (veya bir önceki oyunda) bırakılan mod +
  /// seviye + işlem türü kombinasyonuyla, ara ekranlar olmadan doğrudan
  /// oyunu başlatır.
  Future<void> _quickPlay(BuildContext context) async {
    final mode = await scoreService.getLastMode();
    if (mode == GameMode.climb) {
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ClimbGameScreen(
            audioService: audioService,
            scoreService: scoreService,
            dailyGoalsService: dailyGoalsService,
          ),
        ),
      );
      return;
    }

    final level = await scoreService.getLastLevel();
    final operations = await scoreService.getLastOperations(level);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => mode == GameMode.hunt
            ? GameScreen(
                level: level,
                operations: operations,
                audioService: audioService,
                scoreService: scoreService,
                dailyGoalsService: dailyGoalsService,
              )
            : MatchGameScreen(
                level: level,
                operations: operations,
                audioService: audioService,
                scoreService: scoreService,
                dailyGoalsService: dailyGoalsService,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: Stack(
          children: [
            const Positioned.fill(child: FloatingSymbolsBackground()),
            SafeArea(
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
                        const _MenuMascot(),
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
                        const SizedBox(height: 20),
                        _StreakBanner(dailyGoalsService: dailyGoalsService),
                        const SizedBox(height: 20),
                        _MenuButton(
                          label: 'Oyna',
                          icon: Icons.play_arrow_rounded,
                          color: AppColors.cta,
                          onTap: () => _quickPlay(context),
                        ),
                        const SizedBox(height: 16),
                        _MenuButton(
                          label: 'Mod Seç',
                          icon: Icons.grid_view_rounded,
                          color: AppColors.levelMedium,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ModeSelectScreen(
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
          ],
        ),
      ),
    );
  }
}

/// Ana Menü'deki seri/rütbe rozeti (bkz. CLAUDE.md Bölüm 17). Dokununca
/// `DailyGoalsScreen`'i açar; oradaki verinin aynısını `FutureBuilder` ile
/// önden gösterir (Skor Tablosu'ndaki seviye kartlarıyla aynı desen).
class _StreakBanner extends StatelessWidget {
  final DailyGoalsService dailyGoalsService;

  const _StreakBanner({required this.dailyGoalsService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DailyGoalsSnapshot>(
      future: dailyGoalsService.getTodaySnapshot(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Material(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    DailyGoalsScreen(dailyGoalsService: dailyGoalsService),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      data == null
                          ? 'Günlük Hedefler'
                          : '${data.streak} gün — ${data.rank.displayName}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

/// Ana Menü'nün maskotu: sürekli hafifçe zıplayan (bkz. [MascotWidget] idle
/// animasyonu) Cik, üstünde arada bir değişen neşeli bir karşılama balonuyla
/// birlikte gösterilir; birkaç saniyede bir kendiliğinden sevinçle zıplar
/// (Bölüm 8 — çocuklara hitap eden hareketli bir karakter).
class _MenuMascot extends StatefulWidget {
  const _MenuMascot();

  @override
  State<_MenuMascot> createState() => _MenuMascotState();
}

class _MenuMascotState extends State<_MenuMascot> {
  MascotMood _mood = MascotMood.idle;
  Timer? _hopTimer;

  @override
  void initState() {
    super.initState();
    _hopTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _mood = MascotMood.happy);
      Future.delayed(const Duration(milliseconds: 750), () {
        if (mounted) setState(() => _mood = MascotMood.idle);
      });
    });
  }

  @override
  void dispose() {
    _hopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MascotWidget(mood: _mood, size: 118);
  }
}
