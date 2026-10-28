# beat_dub_techno_118bpm

**Style:** dub techno **BPM:** 118

## Files
- Pattern: `beat_dub_techno_118bpm.R`
- Render: `beat_dub_techno_118bpm.wav` (8 bars = 1 cycle/bar of 4/4, cps = 118/240, 16.3 s, stereo, 44100 Hz)
- Strudel live: `beat_dub_techno_118bpm.strudel.cc`

## Combinators exercised
- `synth("pad")` + `echo(5, 0.75, 0.6) + lpf(1400)` — the classic dub chord wash (man/synth.Rd, man/echo.Rd, man/lpf.Rd)
- `euclid(s("rim"), 2, 8)` / `euclid(s("conga"), 5, 16)` — off-grid Euclidean percussion (man/euclid.Rd)
- `every(2, \(p) fast(p, 2))` — shaker doubles every other cycle (man/every.Rd)
- `drive(1.2)` — saturated four-on-floor kick (man/drive.Rd)
- `synth("sub")` — dubby sub-octave bass

## Verify (Path A, offline)
```bash
Rscript beat_dub_techno_118bpm.R && file beat_dub_techno_118bpm.wav
ffprobe -v error -show_entries format=duration -of csv=p=0 beat_dub_techno_118bpm.wav
# -> 16.3 s; must be >= min_render_seconds (defaults.yaml render_policy)
```

## Verify (Path B, live)
Paste `beat_dub_techno_118bpm.strudel.cc` at strudel.cc.

## References
- maelstrom docs: `man/render.Rd`, `man/stack.Rd`, `man/euclid.Rd`, `man/every.Rd`, `man/echo.Rd`
- GGUF (dj-generate path): https://huggingface.co/Nanite-Labs/nanites-rhythmancer-3b-generator-gguf
