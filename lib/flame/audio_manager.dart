import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _assetsAvailable = false;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await rootBundle.load('assets/sounds/select.wav');
      _assetsAvailable = true;
    } catch (_) {
      _assetsAvailable = false;
    }

    try {
      await FlameAudio.bgm.initialize();
    } catch (_) {}
  }

  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (!_musicEnabled) {
      try { FlameAudio.bgm.stop(); } catch (_) {}
    }
  }

  void toggleSfx() => _sfxEnabled = !_sfxEnabled;

  void _playSfx(String filename, {double volume = 0.5}) {
    if (!_sfxEnabled) return;
    try {
      if (_assetsAvailable) {
        FlameAudio.play(filename, volume: volume);
      }
    } catch (_) {}
  }

  void playSelect() => _playSfx('select.wav');
  void playMove() => _playSfx('move.wav');
  void playConfirm() => _playSfx('confirm.wav');
  void playGameOver() => _playSfx('game_over.wav', volume: 0.6);
  void playTick() => _playSfx('tick.wav', volume: 0.3);
  void playCapture() => _playSfx('capture.wav', volume: 0.6);
  void playHay() => _playSfx('hay.wav', volume: 0.55);

  void startMusic() {
    if (!_musicEnabled || !_assetsAvailable) return;
    try {
      FlameAudio.bgm.play('bg_music.mp3', volume: 0.4);
    } catch (_) {}
  }

  void stopMusic() {
    try { FlameAudio.bgm.stop(); } catch (_) {}
  }

  void dispose() {
    try {
      FlameAudio.bgm.stop();
      FlameAudio.bgm.dispose();
    } catch (_) {}
  }
}
