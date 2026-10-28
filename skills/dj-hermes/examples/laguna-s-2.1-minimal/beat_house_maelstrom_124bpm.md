# beat_house_maelstrom_124bpm

**Style:** deep house **BPM:** 124

## Method
**maelstrom** (Path A) — hand-authored in maelstrom uzu R DSL, rendered offline. Path A
is the source of truth; the `.strudel.cc` is the derived Path B export.

## Files
- Pattern: `beat_house_maelstrom_124bpm.R` — maelstrom uzu (Path A, offline)
- Render: `beat_house_maelstrom_124bpm.wav` (8 bars = 8 cycles, cps = 124/240, 15.5 s, stereo, 44100 Hz, 16-bit PCM)
- Strudel live: `beat_house_maelstrom_124bpm.strudel.cc` (Path B, verified vs @strudel 1.2.6)

## Combinators exercised
- `drive(1.4)` — soft saturation on the kick (man/drive.Rd)
- `crush(8)` — bit-depth reduction (8-bit) on the closed hats (NEW: not in the glm-5.3-flash set)
- `swing(0.22)` — laid-back 16th-note hat groove (man/swing.Rd)
- `echo(3, 0.25, 0.2)` and `echo(4, 0.25, 0.35)` — dotted/triplet delays on OH and stabs (man/echo.Rd)
- `lpf(140)` / `lpf(2200)` — lowpass on the sub-bass and stabs (man/lpf.Rd)
- `synth("sub")` — walking chord-tone bass (man/synth.Rd); Strudel maps to `.s("sine").lpf(low)`
- `synth("sawtooth")` — stab chord voice with echo

## Verify (Path A, offline)
```bash
Rscript beat_house_maelstrom_124bpm.R && file beat_house_maelstrom_124bpm.wav
# -> RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, stereo 44100 Hz
ffprobe -v error -show_entries format=duration -of csv=p=0 beat_house_maelstrom_124bpm.wav
# -> 15.48 s; must be >= min_render_seconds (defaults.yaml render_policy) [15, 30]
bash ../../../../scripts/check_examples.sh
```

## Verify (Path B, live)
Encode a shareable link (no browser needed; the URL is base64 of the code,
percent-encoded — a self-contained fragment, no Supabase short-link DB):

```bash
URL=$(python3 ../../../../scripts/strudel_url.py encode \
        beat_house_maelstrom_124bpm.strudel.cc)
echo "$URL" | xclip -sel clip   # paste into strudel.cc, press Play
python3 ../../../../scripts/strudel_url.py decode "$URL"  # round-trip
```

## References
- maelstrom docs: `man/render.Rd`, `man/render_stereo.Rd`, `man/stack.Rd`, `man/synth.Rd`, `man/lpf.Rd`, `man/echo.Rd`, `man/crush.Rd`, `man/drive.Rd`, `man/swing.Rd`
- Strudel mapping: `references/strudel-vs-maelstrom.md`
- GGUF (dj-generate path): https://huggingface.co/Nanite-Labs/nanites-rhythmancer-3b-generator-gguf
