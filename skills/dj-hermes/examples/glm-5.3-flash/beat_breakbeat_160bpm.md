# beat_breakbeat_160bpm

**Style:** breakbeat **BPM:** 160

## Files
- Pattern: `beat_breakbeat_160bpm.R`
- Render: `beat_breakbeat_160bpm.wav` (10 bars = 1 cycle/bar of 4/4, cps = 160/240, 15.0 s, stereo, 44100 Hz, 16-bit)
- Strudel live: `beat_breakbeat_160bpm.strudel.cc`

## Combinators exercised
- `drive(1.5)` — soft saturation on the kick (man/drive.Rd)
- `euclid` inline suffix `sd(3,8)` and functional `euclid(s("ride"), 3, 8)` (man/euclid.Rd, man/mini_parse_euclid.Rd)
- `sometimes(rev)` — hat roller flips on ~half the cycles (man/sometimes.Rd, man/rev.Rd)
- `degrade(0.3)` — ghost-hat dropout (man/degrade.Rd)
- `synth("sub")` voice on `note()` for the bassline (man/synth.Rd)

## Verify (Path A, offline)
```bash
Rscript beat_breakbeat_160bpm.R && file beat_breakbeat_160bpm.wav
# -> RIFF ... WAVE audio, ... stereo 44100 Hz
ffprobe -v error -show_entries format=duration -of csv=p=0 beat_breakbeat_160bpm.wav
# -> 15.0 s; must be >= min_render_seconds (defaults.yaml render_policy)
```

## Verify (Path B, live)
Paste the contents of `beat_breakbeat_160bpm.strudel.cc` at strudel.cc; presses Play.

## References
- maelstrom docs: `man/render.Rd`, `man/stack.Rd`, `man/synth.Rd`, `man/degrade.Rd`
- GGUF (dj-generate path): https://huggingface.co/Nanite-Labs/nanites-rhythmancer-3b-generator-gguf
