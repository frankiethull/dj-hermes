# beat_house_strudel_126bpm

**Style:** classic four-on-the-floor house **BPM:** 126

## Method
**Strudel** (Path B) — authored first in native Strudel syntax using only methods
verified against `@strudel/parser@1.2.6` (see `references/strudel-vs-maelstrom.md`).
The `.R` is the offline-render translation to maelstrom, rendered to the WAV with
`render_stereo`/`write_wav`.

## Files
- Live pattern: `beat_house_strudel_126bpm.strudel.cc` (primary, Strudel-first)
- Offline render: `beat_house_strudel_126bpm.R` (maelstrom translation)
- Audio: `beat_house_strudel_126bpm.wav` (8 bars = 8 cycles, cps = 126/240,
  15.24 s, stereo, 44100 Hz, 16-bit PCM)

## Combinators exercised
- `stack(...)` — layer kick / claps / hats / bass / pad / oh  (verified)
- `s("bd*4")`, `s("hh*16")`, `s("~ cp ~ cp ...")` — drum patterns (verified)
- `.gain()`, `.swing(0.2)` — levels & groove (verified)
- `.drive(1.3)` — kick saturation (verified)
- `.lpf(180)`, `.lpf(2400)` — lowpass filters (verified)
- `.s("sine")` — sub-bass oscillator voice (verified)
- `.s("supersaw").attack(0.15).release(0.5)` — supersaw pad voice + ADSR
  (verified: `synth("pad")` ↔ `.s("supersaw").attack(0.15).release(0.5)`)
- `.echo(4, 0.25, 0.3)` — dotted delay on the pad (verified)
- `.note(...)` with `[...]` chord voicings + `~` rests for the walking bass
  (verified)

## Verify (Path A, offline)
```bash
Rscript beat_house_strudel_126bpm.R && file beat_house_strudel_126bpm.wav
# -> RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, stereo 44100 Hz
ffprobe -v error -show_entries format=duration -of csv=p=0 beat_house_strudel_126bpm.wav
# -> 15.24 s; must be >= min_render_seconds (defaults.yaml render_policy) [15, 30]
bash ../../../../plugins/dj-hermes/scripts/check_examples.sh
```

## Verify (Path B, live)
```bash
URL=$(python3 ../../../../plugins/dj-hermes/scripts/strudel_url.py encode \
        beat_house_strudel_126bpm.strudel.cc)
echo "$URL" | xclip -sel clip   # paste into strudel.cc, press Play
python3 ../../../../plugins/dj-hermes/scripts/strudel_url.py decode "$URL"  # round-trip
```

## References
- Strudel mapping: `references/strudel-vs-maelstrom.md`
- maelstrom synth voices: `man/synth.Rd`; audio DSP `R/synth2.R` (SYNTHS list)
