---
name: dj-hermes
description: Uzu-language beat plugin for Hermes: Rhythmancer GGUF generation, maelstrom render (man/examples), Strudel bridge, and multi-path skillpack.
version: 0.3.0
author: Frank Hull (frankiethull), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [music, beat-making, uzu, rhythmancer, gguf, maelstrom, strudel, plugin]
    related_skills: [dj-generate, dj-render, dj-validate, dj-export, dj-listen]
---

# dj-hermes Class Skill

Umbrella for the dj-hermes plugin + skillpack. Governs ALL beat-generation work for this repo.

## Hard Lessons (embedded, not memory-only)
- User explicitly corrected: "you are being lazy". Previous runs produced identical-feeling python-synth WAVs instead of real maelstrom patterns (`examples/techno.R`, `jungle.R`, `ambient.R`, `house.R`). Fix: always reference actual maelstrom `man/` docs (`render.Rd`, `stack.Rd`, `synth.Rd`, `degrade.Rd`, `lpf.Rd`) and `examples/` patterns before generating.
- User corrected: "use rhythmancer GGUF" (`https://huggingface.co/Nanite-Labs/nanites-rhythmancer-3b-generator-gguf`) — not HF `transformers`. Embed: `dj-generate` uses GGUF + `llama.cpp` loader.
- User corrected: "all of these beats sound the same and a bit boring". Fix: use varied maelstrom combinators (`degrade()`, `lpf()`, `slowcat`, `fast`, `note()/synth()`), not a single python loop.
- User corrected: "needs to be self-documented" and "built here" (`/home/frankiethull/Documents/dj-hermes`). Fix: every `.R` has `.md` linking source, `man/` docs, examples, GGUF URL, and both paths (maelstrom WAV / Strudel live).
- User corrected: build as package + plugin here. Structure: skills/ (class-level + sub-skills) + root plugin (plugin.yaml + __init__.py + dashboard/ + desktop/) + references/templates/ + examples/.
- Session 2026-10-24 (glm-5.3-flash examples): verified parser/render pitfalls on the installed maelstrom — `pan()` scalar-only (pattern arg fails at render), `.` is NOT a rest token and silently hangs the parser, inline `|` layering invalid (polymeter is `{a b, x y}` only), `every()` needs a real unary function (`\(p) fast(p, 2)`), `sometimes(pat, fn)` has no probability arg, `aa1` pitch spelling renders NA. Full list + bisect procedure: `references/workflow-lessons.md`. Examples: `examples/glm-5.3-flash/` (all WAVs rendered + `file`-verified).
- Session 2026-10-26 (render-length trap): every `examples/` WAV was 2-4 s long — patterns composed in cycles-as-bars but rendered with `cps = bpm / 60` (cycle-as-beat), so "8 cycles" was 8 beats, not 8 bars. Rule: **1 maelstrom cycle = 1 bar of 4/4, `cps = bpm / 240`**, `cycles = max(8, ceiling(15 * bpm / 240))`, expected duration `cycles * 240 / bpm` seconds. Same bug existed in Strudel exports (`setcps(bpm/60)`) and `dashboard/plugin_api.py::convert_to_strudel`. Policy: `defaults.yaml render_policy` (`min_render_seconds: 15`). Enforce before shipping: `bash scripts/check_examples.sh`.
- Session 2026-10-27 (Strudel paste-errors, user-observed): pasting our exports into strudel.cc failed — `.degrade(1)` = "expects 0 inputs but got 1", `note(...).synth` = "not a function", plus lambda-without-call (`sometimes(x => x.rev)`) and wrong arity vs maelstrom (`arp` 1-arg). Root cause: **maelstrom and Strudel are cousins, not twins** — method names/arities differ. Verified full translation table against the shipped `@strudel` 1.2.6 dist (incl. voice inventory and absent sounds): `references/strudel-vs-maelstrom.md`. All `.strudel.cc` exports rewritten to the verified API (`setcpm(bpm/4)`, `.degradeBy`, `.s("voice")`, 3-arg `.echo`, 2-arg `arp`).
- Session 2026-10-27 (share links without a browser): the long strudel.cc share URL is literally base64(code) percent-encoded in the URL fragment (verified against strudel.cc's `shareCode()` and official embed docs). Agents can mint playable `https://strudel.cc/#...` links themselves via `scripts/strudel_url.py` — user flow is "click the link". The Share button's short `?HASH` link needs the Supabase share DB, so agents must always ship the long URL instead.
- Session 2026-10-27 (Rhythmancer GGUF actually tested): until now the model was referenced everywhere but never executed (`run_rhythmancer` was a stub). Ran the Q4_K_M GGUF locally with llama.cpp — see `examples/rhythmancer-gguf/`. Facts: it emits **Strudel-dialect** code with `.cpm(BPM/4)` correct; ChatML prompt format (the "Alpaca-style" note in the GGUF card is stale); occasionally samples broken code (unbalanced paren, truncated bank name) — so "proposes, engine validates" is real policy, and `references/strudel-vs-maelstrom.md` is the bridge both directions (GGUF -> maelstrom `.R` for offline WAV, GGUF -> strudel.cc link for lives). `plugin_api.py::run_rhythmancer` now does real inference when `RHYTHMANCER_GGUF` is set, and tags responses with `source`.

## Multi-Path Architecture
- Path A (offline, deterministic): GGUF prompt → `dj-generate` → `mae-storm` validate (`man/`) → `render_stereo()` / `render_wav()` / `write_wav()` → real WAV.
- Path B (online, optional): same GGUF → `dj-export` → `strudel.cc` (live/edit/share link). APIs are NOT identical to maelstrom — read `references/strudel-vs-maelstrom.md` first; mint playable links without a browser via `scripts/strudel_url.py`.
- Path C (direct): user writes `.R` using maelstrom docs/examples → `maelstrom render` CLI.

## Verification (checkable per path)
- A: `.R` runs; `write_wav()` produces valid RIFF WAVE (`file` confirms); duration satisfies `defaults.yaml render_policy` (`>= min_render_seconds`; run `bash scripts/check_examples.sh`).
- B: Strudel code loads at `strudel.cc` without parse errors; tempo line uses `setcps(bpm/240)` (cycle = bar).
- C: Direct `.R` runs independently; file names match their own directory (no stale paths like writing into a parent `examples/`).

## References
- `references/tabular-structure.md` — repo layout contract (skills/plugins/references/templates/examples)
- `references/strudel-vs-maelstrom.md` — verified Strudel API table (arities, voice names, absent sounds, share-link format) — read before any Strudel export
- `defaults.yaml` — tempo/genre/render policy (never hardcoded); `render_policy` defines render length + the `cps = bpm/240` rule; `strudel:` block pins `setcpm(bpm/4)`
- `plugin.yaml` — plugin manifest
- `dashboard/plugin_api.py` — backend (generate/render/validate/export/listen)
- `desktop/plugin.js` — desktop UI pane + palette command
- `scripts/check_examples.sh` — WAV duration/validity guardrail (run before shipping examples)
- `scripts/strudel_url.py` — strudel.cc share-link encode/decode (agent flow: hand back a playable URL)
- `skills/dj-hermes/examples/*.R` + `*.md` — reproducible patterns with full doc links
