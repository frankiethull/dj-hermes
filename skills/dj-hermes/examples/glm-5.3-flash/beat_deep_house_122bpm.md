# beat_deep_house_122bpm

**Style:** deep house **BPM:** 122

## Files
- Pattern: `beat_deep_house_122bpm.R`
- Render: `beat_deep_house_122bpm.wav` (8 bars = 1 cycle/bar of 4/4, cps = 122/240, 15.7 s, stereo, 44100 Hz, 16-bit)
- Strudel live: `beat_deep_house_122bpm.strudel.cc`

## Combinators exercised
- `swing(0.35)` — groove on the 16th-note shaker (man/swing.Rd)
- `arp()` — auto-arpeggiates stacked chord tones man/arp.Rd
- `echo(3, 0.375, 0.55)` — dotted-8th pluck stabs (man/echo.Rd)
- `lpf(slow(n("400 800 1600 400"), 4))` — cutoff sweep *as a pattern* (man/lpf.Rd, man/n.Rd)
- `synth("pluck")` — Karplus-Strong string voice

## Verify (Path A, offline)
```bash
Rscript beat_deep_house_122bpm.R && file beat_deep_house_122bpm.wav
ffprobe -v error -show_entries format=duration -of csv=p=0 beat_deep_house_122bpm.wav
# -> 15.7 s; must be >= min_render_seconds (defaults.yaml render_policy)
```

## Verify (Path B, live)
Paste `beat_deep_house_122bpm.strudel.cc` at strudel.cc.

## References
- maelstrom docs: `man/render.Rd`, `man/stack.Rd`, `man/arp.Rd`, `man/echo.Rd`, `man/lpf.Rd`
- GGUF (dj-generate path): https://huggingface.co/Nanite-Labs/nanites-rhythmancer-3b-generator-gguf
