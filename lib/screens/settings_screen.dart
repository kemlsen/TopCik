import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../theme/app_colors.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 28, color: AppColors.levelExpert),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
