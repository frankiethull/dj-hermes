# beat_halftime_trap_140bpm

**Style:** halftime trap **BPM:** 140

## Files
- Pattern: `beat_halftime_trap_140bpm.R`
- Render: `beat_halftime_trap_140bpm.wav` (9 bars = 1 cycle/bar of 4/4, cps = 140/240, 15.4 s, stereo, 44100 Hz)
- Strudel live: `beat_halftime_trap_140bpm.strudel.cc`

## Combinators exercised
- `fast(2)` hat rolls inside mini-notation `"hh*4 hh*8"` mixed with functional `fast(2)`
- `humanize(0.004, 0.15)` — deterministic timing/velocity jitter (man/humanize.Rd)
- `echo(2, 0.25, 0.4)` — 808 sub slide tails (man/echo.Rd)
- `degrade_by(0.1)` — occasional clap dropout (man/degrade_by.Rd)
- `synth("sub")` — 808-style sub voice (man/synth.Rd)

## Verify (Path A, offline)
```bash
Rscript beat_halftime_trap_140bpm.R && file beat_halftime_trap_140bpm.wav
ffprobe -v error -show_entries format=duration -of csv=p=0 beat_halftime_trap_140bpm.wav
# -> 15.4 s; must be >= min_render_seconds (defaults.yaml render_policy)
```

## Verify (Path B, live)
Paste `beat_halftime_trap_140bpm.strudel.cc` at strudel.cc.

## References
- maelstrom docs: `man/render.Rd`, `man/stack.Rd`, `man/humanize.Rd`, `man/synth.Rd`
- GGUF (dj-generate path): https://huggingface.co/Nanite-Labs/nanites-rhythmancer-3b-generator-gguf
