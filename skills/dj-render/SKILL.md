---
name: dj-render
description: Render uzu pattern to WAV via maelstrom offline synthesis.
version: 0.1.0
author: Frankie Hull (frankiethull), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [music, render, maelstrom, audio, synthesis]
    related_skills: [dj-hermes, dj-generate, dj-validate, dj-listen]
---

# dj-render Skill

Renders validated uzu pattern code to WAV audio using maelstrom (R-based offline synthesis). This is the deterministic rendering engine of the dj-hermes pipeline.

## When to Use

- User has a uzu pattern (from dj-generate or manual) and wants audio
- Agent needs to produce playable WAV from pattern code
- Re-rendering after pattern edits

Don't use for:
- Generating patterns from prompts (use dj-generate)
- Validating syntax (use dj-validate)
- Live coding (use Strudel export via dj-export)

## Prerequisites

- maelstrom installed (R package from `frankiethull/maelstrom`)
- R runtime (>= 4.0)
- Required R packages: `tuneR`, `seewave`, `stringr`, `magrittr`
- Pattern must be validated first (dj-validate)

## How to Run

```bash
# Via skill in conversation
# "dj-render: s('bd sd', 'hh*2')"

# Or direct Rscript
Rscript -e 'maelstrom::render("s(\"bd sd\", \"hh*2\")", "output.wav", bpm=124)'
```

## Quick Reference

| Parameter | Description | Default |
|---|---|---|
| `pattern` | Valid uzu pattern string | required |
| `output` | Output WAV path | `./beat_<timestamp>.wav` |
| `bpm` | Tempo in BPM | 120 |
| `bars` | Number of bars to render | 8 |
| `sample_rate` | Output sample rate | 44100 |
| `bit_depth` | Output bit depth | 16 |
| `normalize` | Normalize audio | true |
| `fade_out_bars` | Fade out over N bars | 1 |

## Procedure

1. **Validate input** — ensure pattern passed dj-validate (or validate inline)
2. **Load defaults** — read `defaults.yaml` for maelstrom settings
3. **Prepare maelstrom call** — construct Rscript command with pattern and parameters
4. **Execute render** — run maelstrom::render() via Rscript
5. **Verify output** — check WAV file exists, has expected duration
6. **Return WAV path** — absolute path to generated audio file

### Maelstrom R Function Signature

```r
maelstrom::render(
  pattern,           # uzu pattern string
  output_file,       # path to WAV
  bpm = 120,         # tempo
  bars = 8,          # length
  sample_rate = 44100,
  bit_depth = 16,
  normalize = TRUE,
  fade_out_bars = 1
)
```

## Pitfalls

- maelstrom requires R; not a pure Python dependency
- Invalid patterns cause R errors — always validate first
- **Render-length trap (verified 2026-10-26):** maelstrom's `render_stereo()` takes `cps` in *cycles (bars) per second* — for 4/4, `cps = bpm / 240`. Never use `cps = bpm / 60`: that silently treats one cycle as one beat and produced 3-4 second WAVs in past sessions. Rule: `cycles = max(8, ceiling(15 * bpm / 240))`; expected duration is `cycles * 240 / bpm` seconds. Always ffprobe the output and compare against `render_policy` in `defaults.yaml` before shipping.
- Long renders (many bars) consume memory; cap at `max_render_bars` (default 64, see `defaults.yaml render_policy`)
- Windows: Rscript path may need full path or PATH entry
- Sample rate conversion not supported; output fixed at 44.1kHz

## Verification

- WAV file exists at output path
- File duration matches expected: `bars * 60 / bpm * 4` seconds (4/4 time)
- Duration satisfies `render_policy` in `defaults.yaml`: `bash plugins/dj-hermes/scripts/check_examples.sh` (or the same ffprobe check per file) — a WAV under `min_render_seconds` (15s) is a fail, not a style choice
- Audio plays without corruption (check with `file` or `ffprobe`)
- Sample rate and bit depth match settings