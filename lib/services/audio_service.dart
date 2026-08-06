import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Plays sound effects and background music, with persisted on/off
/// preferences (Bölüm 9 — ses açma/kapama butonu).
class AudioService {
  static const _soundEnabledKey = 'audio_sound_enabled';
  static const _musicEnabledKey = 'audio_music_enabled';

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool soundEnabled = true;
  bool musicEnabled = true;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    musicEnabled = prefs.getBool(_musicEnabledKey) ?? true;
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  Future<void> setMusicEnabled(bool value) async {
    musicEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicEnabledKey, value);
    if (value) {
      await playBackgroundMusic();
    } else {
      await _musicPlayer.stop();
    }
  }

  Future<void> playCorrect() => _playSfx('correct.wav');
  Future<void> playWrong() => _playSfx('wrong.wav');
  Future<void> playTick() => _playSfx('tick.wav');
  Future<void> playTimeUp() => _playSfx('time_up.wav');

  Future<void> playBackgroundMusic() async {
    if (!musicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource('sounds/bg_music.wav'));
    } catch (_) {
      // A missing or unsupported audio backend should never break gameplay.
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  Future<void> _playSfx(String fileName) async {
    if (!soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/$fileName'));
    } catch (_) {
      // A missing or unsupported audio backend should never break gameplay.
    }
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
