# glm-5.3-flash examples (v0.3 iteration)

Four beats built by Hermes Agent on 2026-10-24, each exercising combinators the
previous `inkling/` set did not touch. Every WAV was actually rendered with the
local maelstrom install (`Rscript`, cycles = bars of 4/4 via `cps = bpm/240`,
stereo, 44100 Hz, 16-bit PCM) and verified with `file()` + `ffprobe`
(`plugins/dj-hermes/scripts/check_examples.sh`) — not python-synth fakes, and
not the 3-4 second stubs the first pass shipped (see bug list, item 6).

| File | Style | BPM | Bars | Duration | New combinator coverage |
|---|---|---|---|---|---|
| `beat_breakbeat_160bpm` | breakbeat | 160 | 10 | 15.0 s | `drive()`, inline + functional `euclid`, `sometimes(rev)` |
| `beat_deep_house_122bpm` | deep house | 122 | 8 | 15.7 s | `swing()`, `arp()`, `echo()`, pattern-valued `lpf()` via `slow(n(...))` |
| `beat_dub_techno_118bpm` | dub techno | 118 | 8 | 16.3 s | `synth("pad")` chord wash, `every(2, \(p) fast(p, 2))`, `drive()` |
| `beat_halftime_trap_140bpm` | halftime trap | 140 | 9 | 15.4 s | `fast()` rolls, `humanize()`, `degrade_by()`, `synth("sub")` |

## Per-example files
Each beat has three files:
- `.R` — maelstrom pattern (Path A: `Rscript` → `render_stereo` → `write_wav`)
- `.wav` — rendered audio (Path A artifact, verified valid RIFF)
- `.strudel.cc` — paste-ready Strudel code (Path B: strudel.cc), written against the verified `@strudel` API — see `references/strudel-vs-maelstrom.md` for what does NOT map 1:1 (`.synth`, `degrade(x)`, `arp`, …)
- `.md` — self-documented provenance: combinators, man/ docs, GGUF link, both paths

Path B link → user (no browser needed): `python3 plugins/dj-hermes/scripts/strudel_url.py encode <beat>.strudel.cc` → clickable `https://strudel.cc/#...` URL (the same format the Share button's long link produces).

## Bugs found while building these (feedback into skills)
1. **`pan()` is scalar-only in this maelstrom build** — `pan(n("0.3 0.7"))`
   fails at render with `cannot coerce type 'closure' to type 'double'`
   (`mixdown → num_or`). Use a fixed pan value per layer, or vary pan across
   *layers* instead of within one.
2. **`.` is not a rest token** — `s("bd . ~ bd")` (and any unknown token like
   `.`) silently *hangs* the parser; valid rests are `~` or `-`.
3. **Inline `|` polymeter layers are syntax errors** — polymeter is
   `{a b, x y z}` only; use `stack()` for layering.
4. **`every(pat, n, fn)` needs a real unary function** — `every(2, fast(2))`
   fails (`could not find function "pat"`); use `every(2, \(p) fast(p, 2))`.
5. **Pitch spelling**: `aa1` is invalid and renders `NA` midi warnings → peak
   `missing value` error; flats/ sharps only on single letters (`ab1`, `bb1`).
6. **Render-length trap**: the first pass here rendered with `cps = bpm/60`
   (one cycle = one beat), producing 3-4 s WAVs from 8 "cycles". Canon:
   one maelstrom cycle = one bar of 4/4 → `cps = bpm / 240`; size length via
   `defaults.yaml render_policy` (`cycles = max(8, ceiling(15 * bpm / 240))`),
   then verify duration with `ffprobe` (`check_examples.sh` enforces >= 15 s).

## References
- `references/tabular-structure.md` — repo layout contract
- maelstrom `man/` pages referenced per-example
- GGUF model (dj-generate): https://huggingface.co/Nanite-Labs/nanites-rhythmancer-3b-generator-gguf
