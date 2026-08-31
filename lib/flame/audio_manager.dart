import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await FlameAudio.bgm.initialize();
    } catch (_) {
      // Audio initialization can fail on some platforms
    }
  }

  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (!_musicEnabled) {
      FlameAudio.bgm.stop();
    }
  }

  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
  }

  void playSelect() {
    if (!_sfxEnabled) return;
    try {
      FlameAudio.play('select.wav', volume: 0.5);
    } catch (_) {}
  }

  void playMove() {
    if (!_sfxEnabled) return;
    try {
      FlameAudio.play('move.wav', volume: 0.5);
    } catch (_) {}
  }

  void playConfirm() {
    if (!_sfxEnabled) return;
    try {
      FlameAudio.play('confirm.wav', volume: 0.5);
    } catch (_) {}
  }

  void playGameOver() {
    if (!_sfxEnabled) return;
    try {
      FlameAudio.play('game_over.wav', volume: 0.6);
    } catch (_) {}
  }

  void playTick() {
    if (!_sfxEnabled) return;
    try {
      FlameAudio.play('tick.wav', volume: 0.3);
    } catch (_) {}
  }

  void startMusic() {
    if (!_musicEnabled) return;
    try {
      FlameAudio.bgm.play('bg_music.mp3', volume: 0.4);
    } catch (_) {}
  }

  void stopMusic() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  void dispose() {
    FlameAudio.bgm.stop();
    FlameAudio.bgm.dispose();
  }
}
