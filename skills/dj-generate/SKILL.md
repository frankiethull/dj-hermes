---
name: dj-generate
description: Generate uzu pattern code via Rhythmancer 3B GGUF (offline/local inference).
version: 0.2.0
author: Frankie Hull (frankiethull), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [music, rhythmancer, gguf, uzu, generation, offline]
    related_skills: [dj-hermes, dj-render, dj-export]
---

# dj-generate (GGUF Redesign)

Uses `Nanite-Labs/nanites-rhythmancer-3b-generator-gguf` for local/offline inference via `llama.cpp`/GGUF loader. Prompt -> GGUF proposes pattern.

## Verified reality (2026-10-27 — actually run, see `skills/dj-hermes/examples/rhythmancer-gguf/`)

- **The GGUF outputs Strudel-dialect code**, not uzu/maelstrom: a
  `stack(...)` with `.cpm(BPM/4)` already baked in (1 cycle = 1 bar —
  matches our `render_policy`), `.sound/.bank/.lpf/.room/.orbit` params,
  verified-style `sometimes/every` lambdas. So dj-generate output feeds
  **Path B directly**; for Path A translate it to maelstrom with the table
  in `references/strudel-vs-maelstrom.md` (`sound`->`synth`, drop
  `bank/orbit/room`, keep the mini-notation).
- **Prompt format: Qwen ChatML** (im_start/im_end; embedded template).
  The GGUF repo card's "Alpaca-style" note is stale — the model card and
  its metadata are ChatML:
  ```
  <|im_start|>user
  Generate Strudel live-coding music code for: <mood genre at N bpm>
  <|im_start|>assistant
  ```
- Tested llama.cpp invocation (GPU, `-ngl 99`; drop that flag for CPU):
  ```bash
  llama-cli -m rhythmancer-Q4_K_M.gguf -ngl 99 -no-cnv -f prompt.txt \
    -n 400 -c 2048 --temp 0.7 --top-p 0.9 --repeat-penalty 1.1
  ```
  those values are `defaults.yaml rhythmancer:`.
- In the sampled session: dub and breakbeat requests came back clean and
  parseable; a techno request carried an unbalanced paren and a truncated
  `.bank("RolandTR90")`. Regenerate / fix via dj-validate before shipping —
  never paste GGUF output unvalidated.
- Twelve trained genres: techno, house, jungle, ambient, acid, dub,
  boom-bap, footwork, trance, downtempo, electro, breakbeat.

## Multi-Path
- Load GGUF (local, reproducible seed)
- Generate -> validate against maelstrom (`man/mini_parse_*.Rd`) — and
  against `references/strudel-vs-maelstrom.md` for Path B
- Emit to dj-render (maelstrom `render_stereo`/`render_wav`) OR dj-export (Strudel + share link via `plugins/dj-hermes/scripts/strudel_url.py`)

## References
- GGUF repo: https://huggingface.co/Nanite-Labs/nanites-rhythmancer-3b-generator-gguf
- Base/adapter repo: https://huggingface.co/Nanite-Labs/nanites-rhythmancer-3b-generator (ChatML prompt format, genre list, provenance REPORT.md)
- maelstrom man: `man/render.Rd`, `man/stack.Rd`, `man/synth.Rd`, `man/degrade.Rd`
- The bridge: `skills/dj-hermes/references/strudel-vs-maelstrom.md`
- Showcase: `skills/dj-hermes/examples/rhythmancer-gguf/`
