import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _assetsAvailable = false;
  bool _musicPlaying = false;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Load persisted settings
    try {
      final prefs = await SharedPreferences.getInstance();
      _musicEnabled = prefs.getBool('audio_music') ?? true;
      _sfxEnabled = prefs.getBool('audio_sfx') ?? true;
    } catch (_) {}

    // Detect if real audio files exist (check file size > 0)
    try {
      final data = await rootBundle.load('assets/audio/select.wav');
      _assetsAvailable = data.lengthInBytes > 0;
    } catch (_) {
      _assetsAvailable = false;
    }

    if (_assetsAvailable) {
      try {
        await FlameAudio.bgm.initialize();
      } catch (_) {}
    }
  }

  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('audio_music', _musicEnabled);
    } catch (_) {}

    if (!_musicEnabled) {
      try {
        FlameAudio.bgm.stop();
        _musicPlaying = false;
      } catch (_) {}
    } else if (!_musicPlaying) {
      startMusic();
    }
  }

  Future<void> toggleSfx() async {
    _sfxEnabled = !_sfxEnabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('audio_sfx', _sfxEnabled);
    } catch (_) {}
  }

  void _playSfx(String filename, {double volume = 0.5}) {
    if (!_sfxEnabled || !_assetsAvailable) return;
    try {
      FlameAudio.play(filename, volume: volume).catchError((_) {});
    } catch (_) {}
  }

  void playSelect() => _playSfx('select.wav');
  void playMove() => _playSfx('move.wav', volume: 0.45);
  void playConfirm() => _playSfx('confirm.wav');
  void playGameOver() => _playSfx('game_over.wav', volume: 0.65);
  void playTick() => _playSfx('tick.wav', volume: 0.3);
  void playCapture() => _playSfx('capture.wav', volume: 0.65);
  void playHay() => _playSfx('hay.wav', volume: 0.55);
  void playHerdPlace() => _playSfx('confirm.wav', volume: 0.5);

  void startMusic() {
    if (!_musicEnabled || !_assetsAvailable || _musicPlaying) return;
    try {
      _musicPlaying = true;
      FlameAudio.bgm.play('bg_music.wav', volume: 0.38).catchError((_) {
        _musicPlaying = false;
      });
    } catch (_) {
      _musicPlaying = false;
    }
  }

  void stopMusic() {
    try {
      _musicPlaying = false;
      FlameAudio.bgm.stop().catchError((_) {});
    } catch (_) {}
  }

  void pauseMusic() {
    try {
      FlameAudio.bgm.pause().catchError((_) {});
    } catch (_) {}
  }

  void resumeMusic() {
    if (!_musicEnabled || !_assetsAvailable) return;
    try {
      FlameAudio.bgm.resume().catchError((_) {});
    } catch (_) {}
  }

  void dispose() {
    try {
      _musicPlaying = false;
      FlameAudio.bgm.stop().catchError((_) {});
      FlameAudio.bgm.dispose();
    } catch (_) {}
  }
}
