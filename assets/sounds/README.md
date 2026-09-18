# Audio Assets

Place the following files in this directory (use .mp3 or .wav):

- `select.wav` - UI selection click sound
- `move.wav` - Cow movement sound
- `confirm.wav` - Action confirmation sound
- `game_over.wav` - Game over fanfare
- `tick.wav` - Timer countdown tick
- `capture.wav` - Territory capture impact
- `hay.wav` - Hay bale bonus sound
- `bg_music.mp3` - Background music loop

## Recommended Sources

- **Kenney**: https://kenney.nl/assets/impact-sounds
- **Freesound**: https://freesound.org
- **Mixkit**: https://mixkit.co/free-sound-effects/game/

## Notes

- Audio files are optional — the app generates tone fallbacks when files are missing
- For best results, use 44100 Hz sample rate, mono channel
- File formats: .mp3 or .wav both supported
- Place files in `assets/sounds/` directory
- All files are declared in `pubspec.yaml` under `flutter.assets`
