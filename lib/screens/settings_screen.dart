import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  final AudioService audioService;

  const SettingsScreen({super.key, required this.audioService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  late bool _musicEnabled;

  @override
  void initState() {
    super.initState();
    _soundEnabled = widget.audioService.soundEnabled;
    _musicEnabled = widget.audioService.musicEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Ayarlar',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          _SettingSwitch(
            label: 'Ses Efektleri',
            icon: Icons.volume_up_rounded,
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              widget.audioService.setSoundEnabled(value);
            },
          ),
          const SizedBox(height: 16),
          _SettingSwitch(
            label: 'Arka Plan Müziği',
            icon: Icons.music_note_rounded,
            value: _musicEnabled,
            onChanged: (value) {
              setState(() => _musicEnabled = value);
              widget.audioService.setMusicEnabled(value);
            },
          ),
        ],
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 3,
      shadowColor: AppColors.levelExpert.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.levelExpert.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 24, color: AppColors.levelExpert),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.cta,
            ),
          ],
        ),
      ),
    );
  }
}
