# DJ-Hermes Workflow Reference

## Signals embedded from session
- User corrected style/verbosity: must be direct, no over-explaining before asking/acting.
- User corrected workflow: build in `/home/frankiethull/Documents/dj-hermes` (not `~/.hermes/`); self-documented; package + plugin.
- User corrected technique: use maelstrom `man/` + `examples/` (not python synth); use GGUF (`llama.cpp`); generate different patterns per style.
- User corrected output: produce real `.wav` (`render_stereo()` + `write_wav()`), `.strudel.cc` from `.md` prompts, `.R` files unique per style.

## Skill Class Structure
- `skills/dj-hermes/SKILL.md` — umbrella (class-level)
- `skills/dj-generate/` — GGUF generation
- `skills/dj-render/` — maelstrom render
- `skills/dj-validate/` — syntax check
- `skills/dj-export/` — Strudel
- `skills/dj-listen/` — playback

## Verification Pattern
Every artifact verified: `file` for `.wav` (RIFF WAVE), `.strudel.cc` loads, `.R` runs, `.md` links source/docs.

## maelstrom Parser/Render Pitfalls (verified 2026-10-24, glm-5.3-flash session)
These were hit empirically against the installed maelstrom; always assume them:
1. **`pan()` is scalar-only.** `pan(n("0.3 0.7"))` fails at render (`mixdown →
   num_or: cannot coerce type 'closure' to type 'double'`). Use one fixed value
   per layer; get variation by panning different layers differently.
2. **`.` is NOT a rest token — it silently hangs the parser** (Rscript never
   returns). Valid rests: `~` or `-`. Watch for this from GGUF output.
3. **Inline `|` layering is invalid** — polymeter is only `{a b, x y z}`.
   Use `stack()` for layering.
4. **`every(pat, n, fn)` needs a real unary function**, not a partial call:
   `every(2, \(p) fast(p, 2))` — not `every(2, fast(2))`.
5. **`sometimes(pat, fn)` / `often` / `rarely` take (pat, fn)**; no probability
   argument except `sometimes_by(pat, p, fn)`.
6. **Pitch spelling**: only single-letter naturals + `#`/`b` (`ab1`, `bb1`).
   `aa1` → NA midi → `peak > 1` missing-value render error.
7. **Bisecting hang/render errors**: render one voice at a time, at low
   `cycles`, before stacking. Renderer combining bugs localize quickly.
8. **Render-length trap (2026-10-26)**: a parse-clean render can still be a
   wrong *delivery*. First glm-5.3-flash session shipped 2-4 s WAVs because
   `render_stereo()` got `cps = bpm / 60` (one cycle = one beat) while the
   patterns were composed as one cycle = one bar. Canonical maelstrom/uzu
   semantics: **1 cycle = 1 bar (4/4) → `cps = bpm / 240`**. Size length from
   `defaults.yaml render_policy`:
   `cycles = max(8, ceiling(target_render_seconds * bpm / 240))`,
   expected seconds = `cycles * 240 / bpm`. The identical bug existed in
   every Strudel export (`setcps(bpm/60)`) and in
   `dashboard/plugin_api.py::convert_to_strudel` — the fix applies to all
   three surfaces. Ship-verifiable: `ffprobe` duration + `file` RIFF check,
   automated by `plugins/dj-hermes/scripts/check_examples.sh`. Also fixed in
   the same session: inkling `.R` files wrote WAVs into the parent
   `examples/` dir instead of their own (always write relative to the
   script's directory).

## Examples Feedback Loop
- `skills/dj-hermes/examples/glm-5.3-flash/` — v0.3 iteration with per-example `.md`,
  `.strudel.cc`, verified `.wav`. New combinator coverage documented in
  `examples/glm-5.3-flash/README.md`. Prefer copying a voice from these when a user asks
  for a new groove, then vary.
