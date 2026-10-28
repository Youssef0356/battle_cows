"""
Battle Cows SFX Generator
Generates all required game sound effects using pure Python (no external libs needed).
Run from the project root:  python scripts/generate_sfx.py
"""

import wave
import struct
import math
import os
import array

SAMPLE_RATE = 44100
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')


# ─────────────────────────────────────────────────────────────────────────────
# Core helpers
# ─────────────────────────────────────────────────────────────────────────────

def write_wav(filename: str, samples: list[float]):
    """Write normalised float samples to a 16-bit mono WAV file."""
    peak = max(abs(s) for s in samples) if samples else 1.0
    if peak < 1e-6:
        peak = 1.0
    scaled = [int(s / peak * 32700) for s in samples]
    packed = array.array('h', scaled)

    path = os.path.join(OUTPUT_DIR, filename)
    with wave.open(path, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SAMPLE_RATE)
        f.writeframes(packed.tobytes())
    print(f'  [OK] {filename}  ({len(samples)/SAMPLE_RATE*1000:.0f} ms)')


def sine(t: float, freq: float) -> float:
    return math.sin(2 * math.pi * freq * t)


def saw(t: float, freq: float) -> float:
    return 2 * ((t * freq) % 1.0) - 1.0


def square(t: float, freq: float, duty: float = 0.5) -> float:
    return 1.0 if (t * freq) % 1.0 < duty else -1.0


def noise() -> float:
    import random
    return random.uniform(-1.0, 1.0)


def envelope(t: float, duration: float, attack: float, decay: float,
             sustain: float, release: float) -> float:
    """ADSR envelope, all times in seconds."""
    s_start = attack + decay
    r_start = duration - release
    if t < attack:
        return t / attack if attack > 0 else 1.0
    elif t < s_start:
        return 1.0 - (t - attack) / decay * (1.0 - sustain) if decay > 0 else sustain
    elif t < r_start:
        return sustain
    else:
        return sustain * max(0.0, 1.0 - (t - r_start) / release) if release > 0 else 0.0


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def ease_out(t: float) -> float:
    return 1.0 - (1.0 - t) ** 3


# ─────────────────────────────────────────────────────────────────────────────
# Sound generators
# ─────────────────────────────────────────────────────────────────────────────

def gen_select():
    """Quick UI pop click — two-layer: a high sine pop + a subtle low thump."""
    dur = 0.10
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        p = t / dur  # normalised 0→1

        # High pop
        freq = lerp(1100, 850, ease_out(p))
        amp = math.exp(-p * 28)
        hi = sine(t, freq) * amp

        # Low body
        freq2 = lerp(300, 160, ease_out(p))
        amp2 = math.exp(-p * 40)
        lo = sine(t, freq2) * amp2 * 0.5

        samples.append(hi + lo)
    write_wav('select.wav', samples)


def gen_move():
    """Gentle whoosh — frequency sweep + breathy noise trail."""
    dur = 0.22
    n = int(SAMPLE_RATE * dur)
    samples = []
    import random
    rng = random.Random(42)
    for i in range(n):
        t = i / SAMPLE_RATE
        p = t / dur

        # Pitch sweep high→low
        freq = lerp(900, 200, ease_out(p))
        sweep = sine(t, freq)

        # Noise breeze
        breeze = rng.uniform(-1, 1) * 0.35

        # Amplitude: quick rise then fade
        amp = math.sin(math.pi * p) * math.exp(-p * 3.5)

        samples.append((sweep * 0.65 + breeze * 0.35) * amp)
    write_wav('move.wav', samples)


def gen_confirm():
    """Happy two-tone ascending ding — C5 then E5 chord resolving upward."""
    dur = 0.42
    n = int(SAMPLE_RATE * dur)
    samples = []

    notes = [
        (0.00, 523.25),   # C5
        (0.10, 659.25),   # E5
        (0.20, 783.99),   # G5
    ]

    for i in range(n):
        t = i / SAMPLE_RATE
        p = t / dur
        val = 0.0
        for (note_t, freq) in notes:
            nt = t - note_t
            if nt < 0:
                continue
            np_ = nt / (dur - note_t)
            amp = math.exp(-np_ * 7) * max(0.0, 1.0 - np_)
            val += (sine(t, freq) * 0.7 + sine(t, freq * 2) * 0.3) * amp * 0.5
        samples.append(val)
    write_wav('confirm.wav', samples)


def gen_capture():
    """Territory capture — punchy bass impact + short crunch + reverb tail."""
    dur = 0.45
    n = int(SAMPLE_RATE * dur)
    samples = []
    import random
    rng = random.Random(7)

    for i in range(n):
        t = i / SAMPLE_RATE
        p = t / dur

        # Bass thud: exponential pitch drop
        freq = 180 * math.exp(-p * 18)
        thud = sine(t, max(freq, 30)) * math.exp(-p * 14) * 0.85

        # Short crunch burst
        crunch_amp = math.exp(-p * 60) * 0.55
        crunch = rng.uniform(-1, 1) * crunch_amp

        # Punch layer (saw wave body)
        punch_freq = lerp(240, 80, ease_out(min(p * 4, 1.0)))
        punch = saw(t, max(punch_freq, 20)) * math.exp(-p * 22) * 0.45

        # Short overtone ring
        ring = sine(t, 1200) * math.exp(-p * 45) * 0.12

        samples.append(thud + crunch + punch + ring)
    write_wav('capture.wav', samples)


def gen_hay():
    """Hay bale / golden bonus — sparkle arpeggio collect sound."""
    dur = 0.32
    n = int(SAMPLE_RATE * dur)
    samples = []

    # Rising pentatonic arpeggio
    notes = [
        (0.00, 880),    # A5
        (0.06, 1109),   # C#6
        (0.12, 1318),   # E6
        (0.18, 1760),   # A6
        (0.22, 2217),   # C#7
    ]

    for i in range(n):
        t = i / SAMPLE_RATE
        val = 0.0
        for (nt, freq) in notes:
            dt = t - nt
            if dt < 0:
                continue
            amp = math.exp(-dt * 20)
            val += sine(t, freq) * amp * 0.25
            val += sine(t, freq * 2) * amp * 0.08   # shimmer overtone

        samples.append(val * math.exp(-t / dur * 3))
    write_wav('hay.wav', samples)


def gen_tick():
    """Countdown tick — very short percussive click."""
    dur = 0.055
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        p = t / dur
        freq = lerp(1400, 900, p)
        amp = math.exp(-p * 55)
        samples.append(sine(t, freq) * amp)
    write_wav('tick.wav', samples)


def gen_game_over():
    """Western comical 'wah-wah-wah' descending trombone fanfare."""
    dur = 1.60
    n = int(SAMPLE_RATE * dur)
    samples = []

    # Three descending 'wah' notes
    wahs = [
        (0.0,  0.40, 349.23, 293.66),   # F4 → D4
        (0.45, 0.40, 293.66, 246.94),   # D4 → B3
        (0.90, 0.55, 246.94, 174.61),   # B3 → F3
    ]

    for i in range(n):
        t = i / SAMPLE_RATE
        val = 0.0
        for (start, length, f1, f2) in wahs:
            lt = t - start
            if lt < 0 or lt > length:
                continue
            lp = lt / length
            freq = lerp(f1, f2, ease_out(lp))
            # Trombone-ish: mix of sine + saw + slight vibrato
            vib = 1 + 0.025 * math.sin(2 * math.pi * 6 * lt)
            tone = (sine(t, freq * vib) * 0.6
                    + saw(t, freq * vib) * 0.25
                    + sine(t, freq * 2 * vib) * 0.15)
            env = envelope(lt, length,
                           attack=0.04, decay=0.1,
                           sustain=0.7, release=0.12)
            val += tone * env * 0.8
        samples.append(val)
    write_wav('game_over.wav', samples)


def gen_bg_music():
    """
    Simple looping western-flavoured banjo + bass loop (~8 bar, 120 BPM).
    Uses additive synthesis for a pleasant farm feel.
    """
    BPM = 116
    BEAT = 60.0 / BPM
    dur = BEAT * 16  # 16 beats (~8.3 s loop)
    n = int(SAMPLE_RATE * dur)
    samples = []

    # Note helpers
    def note_freq(semitones_from_A4: int) -> float:
        return 440.0 * (2 ** (semitones_from_A4 / 12))

    # Pentatonic-ish melody in A major: A B C# E F#
    A4, B4, Cs5, E5, Fs5 = (
        note_freq(0), note_freq(2), note_freq(4),
        note_freq(7), note_freq(9)
    )
    A3, E3, D3 = note_freq(-12), note_freq(-5), note_freq(-7)

    # Banjo melody pattern (beat_start, freq, beat_length)
    melody = [
        (0.0,  E5,  0.5),
        (0.5,  Cs5, 0.5),
        (1.0,  A4,  0.5),
        (1.5,  B4,  0.5),
        (2.0,  Cs5, 1.0),
        (3.0,  E5,  0.5),
        (3.5,  Fs5, 0.5),
        (4.0,  E5,  0.5),
        (4.5,  Cs5, 0.5),
        (5.0,  A4,  1.0),
        (6.0,  B4,  0.5),
        (6.5,  A4,  0.5),
        (7.0,  E5,  1.0),
        (8.0,  Fs5, 0.5),
        (8.5,  E5,  0.5),
        (9.0,  Cs5, 0.5),
        (9.5,  B4,  0.5),
        (10.0, A4,  2.0),
        (12.0, B4,  0.5),
        (12.5, Cs5, 0.5),
        (13.0, E5,  0.5),
        (13.5, Cs5, 0.5),
        (14.0, A4,  1.0),
        (15.0, E5,  1.0),
    ]

    # Bass line (on beats)
    bass = [
        (0.0,  A3,  0.8),
        (2.0,  E3,  0.8),
        (4.0,  A3,  0.8),
        (6.0,  D3,  0.8),
        (8.0,  A3,  0.8),
        (10.0, E3,  0.8),
        (12.0, D3,  0.8),
        (14.0, A3,  0.8),
    ]

    # Strum chord hits (banjo strum)
    chord_freqs = [A4, Cs5, E5]
    strums = [0.5, 1.5, 2.5, 4.5, 5.5, 6.5, 8.5, 9.5, 10.5, 12.5, 13.5, 14.5]

    import random
    rng = random.Random(99)

    for i in range(n):
        t = i / SAMPLE_RATE
        beat = t / BEAT
        val = 0.0

        # --- Melody (banjo pluck: sine + slightly metallic overtone) ---
        for (bs, freq, bl) in melody:
            dt = t - bs * BEAT
            if dt < 0 or dt > bl * BEAT:
                continue
            lp = dt / (bl * BEAT)
            amp = math.exp(-lp * 8) * 0.55
            # Banjo pluck: bright attack
            val += (sine(t, freq) * 0.7
                    + sine(t, freq * 2) * 0.2
                    + sine(t, freq * 3) * 0.1) * amp

        # --- Bass (warm low sine + slight saw body) ---
        for (bs, freq, bl) in bass:
            dt = t - bs * BEAT
            if dt < 0 or dt > bl * BEAT:
                continue
            lp = dt / (bl * BEAT)
            amp = math.exp(-lp * 5) * 0.4
            val += (sine(t, freq) * 0.75 + saw(t, freq) * 0.25) * amp

        # --- Strum hits (background chord shimmer) ---
        for sb in strums:
            dt = t - sb * BEAT
            if 0 <= dt < 0.18:
                lp = dt / 0.18
                amp = math.exp(-lp * 18) * 0.12
                for sf in chord_freqs:
                    jitter = rng.uniform(0, 0.012)
                    val += sine(t + jitter, sf) * amp

        # Gentle high-pass feel: dampen very low freq contribution
        samples.append(val * 0.72)

    # Smooth loop crossfade (last 0.25s blends into first 0.25s)
    xfade = int(SAMPLE_RATE * 0.25)
    for i in range(xfade):
        alpha = i / xfade
        samples[i] = samples[i] * alpha + samples[n - xfade + i] * (1 - alpha)

    write_wav('bg_music_raw.wav', samples)
    print('  [INFO] bg_music_raw.wav written')
    # Also save as .wav directly for testing
    import shutil
    src = os.path.join(OUTPUT_DIR, 'bg_music_raw.wav')
    dst = os.path.join(OUTPUT_DIR, 'bg_music.wav')
    shutil.copy(src, dst)
    print(f'  [OK] bg_music.wav  ({dur*1000:.0f} ms loop)')

    # Also copy all generated files to assets/sounds/
    sounds_dir = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sounds')
    if os.path.exists(sounds_dir):
        for fname in os.listdir(OUTPUT_DIR):
            if fname.endswith('.wav'):
                shutil.copy(os.path.join(OUTPUT_DIR, fname), os.path.join(sounds_dir, fname))


# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

if __name__ == '__main__':
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print('\n[Battle Cows SFX Generator]')
    print('=' * 40)
    gen_select()
    gen_move()
    gen_confirm()
    gen_capture()
    gen_hay()
    gen_tick()
    gen_game_over()
    gen_bg_music()
    print('\nAll sounds successfully written to assets/audio/ and assets/sounds/')

