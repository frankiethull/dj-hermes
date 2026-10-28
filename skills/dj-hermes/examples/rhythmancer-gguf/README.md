# rhythmancer-gguf examples (first real GGUF loop, 2026-10-27)

One beat generated **verbatim** by the actual Rhythmancer 3B GGUF
(`Nanite-Labs/nanites-rhythmancer-3b-generator-gguf`, Q4_K_M, ~1.9 GB,
Qwen2.5-Coder-3B base, Apache-2.0) — run locally on an RTX 4070 with
llama.cpp using only the repo's own generation defaults
(`defaults.yaml rhythmancer`: temp 0.7, top_p 0.9, repeat_penalty 1.1).

Prompt (ChatML, as the model trains): `Generate Strudel live-coding music
code for: smoky dub track with echoing skanks at 76 bpm`

## What this proves

1. The GGUF runs fine headless (`llama-cli -no-cnv -f prompt.txt`), GPU (`-ngl 99`).
2. Outputs are **Strudel-dialect code, tempo already correct** — `.cpm(76/4)`
   (1 cycle = 1 bar) matches our render convention and the
   `references/strudel-vs-maelstrom.md` verified API (verified `sometimes`/
   `every` lambdas, sound/voice params, room/orbit).
3. **Propose, then validate** — the charter's principle is earned: a techno
   request in the same session returned an *unbalanced paren* and a
   truncated `.bank("RolandTR90")`. So the pipeline is:
   `dj-generate` → `dj-validate` (fix/shear) → Path A (translate via the
   table, render ≥15 s WAV) / Path B (ship raw + link).

## Loop used here (dub, success case)

- `.R` — the GGUF stack translated maelstrom-ward with the verified table
  (`sound→synth`, drop `bank/orbit/room`, sometimes/every lambdas kept),
  rendered `>= 15 s` per `render_policy` (25.3 s at 76 bpm).
- `.wav` — `beat_smoky_dub_76bpm.wav`, RIFF-verified.
- `.strudel.cc` — the GGUF output verbatim (Path B raw).
- Playable link mints itself (no browser):
  `python3 plugins/dj-hermes/scripts/strudel_url.py encode beat_smoky_dub_76bpm.strudel.cc`
