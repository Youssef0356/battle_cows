# 🎵 Battle Cows — Audio Assets

All files in `assets/audio/` are currently **empty placeholders**.
Drop real audio files here to enable full sound.

---

## Required Files

| File | Role | Suggested Style |
|------|------|----------------|
| `bg_music.mp3` | Looping background music | Upbeat farm/western banjo or country-pop, ~60–90 BPM |
| `select.wav` | Button press / herd select | Short punchy click or "moo" chirp |
| `move.wav` | Herd slides across board | Soft whoosh or hoofbeat clip |
| `confirm.wav` | Tile/pasture placement confirmed | Happy "ding" or cartoon pop |
| `capture.wav` | Territory captured / herd absorbed | Impact thud + crowd cheer stab |
| `hay.wav` | Hay bale or golden pasture bonus | Coin-collect sparkle or crunch |
| `tick.wav` | Timer countdown (plays at ≤5 s) | Metronome tick, very short |
| `game_over.wav` | Match ends | Western fanfare or comedic trombone |

---

## 🔗 Best Free Sources (Royalty-Free, No Attribution Needed)

### 1. Kenney.nl ⭐ (Best for game SFX packs)
- https://kenney.nl/assets/impact-sounds  → **capture.wav**, **move.wav**
- https://kenney.nl/assets/interface-sounds → **select.wav**, **confirm.wav**, **tick.wav**
- https://kenney.nl/assets/casino-audio → fun sounds for bonus
- All Kenney assets are CC0 (public domain)

### 2. Mixkit.co (Free, no signup, direct download)
- https://mixkit.co/free-sound-effects/game/   → great for all SFX
- https://mixkit.co/free-stock-music/          → farm/western background music

### 3. Freesound.org (Large library, check licenses)
- Search: "cow moo cartoon", "western banjo loop", "hoofbeats", "cartoon whoosh"
- Filter by CC0 or CC BY licenses

### 4. Pixabay Music (Royalty-free, no attribution)
- https://pixabay.com/music/search/western/    → great bg_music options
- https://pixabay.com/sound-effects/           → all SFX

### 5. OpenGameArt.org
- https://opengameart.org/art-search?keys=farm
- https://opengameart.org/art-search?keys=western

---

## 📋 Format Requirements

- **bg_music.mp3**: MP3, 44100 Hz, stereo OK, ~1–3 min loopable
- **SFX .wav files**: WAV or MP3, 44100 Hz, mono preferred, under 2 seconds each

## 🛠 Quick Fix (Procedural Tones)

If you want instant placeholder sounds while sourcing real files,
you can generate simple tones with Audacity (free) or online tools:
- https://onlinetonegenerator.com/
- https://www.audacityteam.org/

## 📝 Notes

- Both `assets/audio/` and `assets/sounds/` are registered in pubspec.yaml.
  Place files in **`assets/audio/`** — that's what AudioManager reads from.
- The AudioManager silently skips all sound if `select.wav` is missing/empty.
  Once you add a real `select.wav`, all other sounds activate automatically.
