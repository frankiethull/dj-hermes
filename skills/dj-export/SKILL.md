---
name: dj-export
description: Export validated uzu pattern to Strudel-ready code or live session URL.
version: 0.1.0
author: Frankie Hull (frankiethull), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [music, export, strudel, live-coding, uzu]
    related_skills: [dj-hermes, dj-generate, dj-validate, dj-render]
---

# dj-export Skill

Exports validated uzu pattern code to Strudel-compatible format for live coding in the browser. Optionally generates a shareable Strudel session URL.

## When to Use

- User wants to take a generated pattern into Strudel for live editing
- Agent needs to provide a Strudel-playable version of a pattern
- Sharing beats with others via Strudel session links

Don't use for:
- Offline rendering to WAV (use dj-render)
- Validating patterns (use dj-validate)
- Generating patterns from prompts (use dj-generate)

## Prerequisites

- Pattern must be validated (dj-validate) for Strudel compatibility
- Optional: Strudel session sharing requires network access

## How to Run

```bash
# Via skill in conversation
# "dj-export: s('bd sd', 'hh*2')"

# Direct usage
# Returns Strudel code and optional session URL
```

## Quick Reference

| Parameter | Description | Default |
|---|---|---|
| `pattern` | Validated uzu pattern string | required |
| `include_tempo` | Include `setcpm(bpm/4)` call | true |
| `include_swing` | Include swing setting | true |
| `wrap_in_stack` | Wrap in `stack()` for multi-track | true |
| `create_session` | Generate shareable Strudel URL | false |

## Procedure

1. **Receive validated pattern** — uzu pattern that passed dj-validate with Strudel check
2. **Read the translation table first** — maelstrom and Strudel are NOT API-identical; consult `skills/dj-hermes/references/strudel-vs-maelstrom.md` (verified against `@strudel` 1.2.6, the code strudel.cc ships) before writing any export. Known paste-errors from real sessions: `.degrade(1)` ("expects 0 inputs"), `.synth` ("not a function"), `.sometimes(x => x.rev)` (uncalled lambda)
3. **Convert uzu -> Strudel** — use the verified mapping table (that reference), e.g. `synth("x")` -> `.s("x")`, `degrade(p)` -> `.degradeBy(p)`, `arp(chords)` -> `arp("<0 1 2>", chords)`
4. **Apply settings** — `setcpm(bpm / 4)` (1 cycle = 1 bar of 4/4; idiom per strudel.cc/understand/cycles. NOT `setcps(bpm/60)`, NOT `setcps(bpm)`)
5. **Wrap if needed** — `stack(...)`; apply swing as a pattern method (`.swing(0.15)`) instead of a global
6. **Generate share link** — the long URL format is base64(code) percent-encoded into the URL fragment, so agents mint links WITHOUT a browser:
   ```bash
   python3 scripts/strudel_url.py encode path/to/beat.strudel.cc
   # -> https://strudel.cc/#<base64url-encoded-code>   (clickable, self-contained)
   ```
   The Share button's short link (`?HASH`) needs the Supabase share DB (agents can't mint, and links depend on that DB). Always ship the long URL.
7. **Return export** — raw code + the clickable `https://strudel.cc/#...` URL

### Uzu to Strudel Mapping

Do NOT trust method-name assumptions — the authoritative table lives in
`skills/dj-hermes/references/strudel-vs-maelstrom.md`. Examples of verified
diffs: `.degrade()` (0 args) vs `.degradeBy(p)`, `.s(voice)` vs nonexistent
`.synth`, `echo(n, time, feedback)` identical order, `arp(indices, chords)`
2-arg in Strudel.

### Output Format

```javascript
// Strudel code (verified API)
setcpm(124/4) // 1 cycle = 1 bar of 4/4
stack(
  s("bd sd"),
  s("hh*2").gain(0.8)
).swing(0.1)
```

## Pitfalls

- **Methods are not shared with maelstrom** — arity and names differ; the
  reference table is verified against the actual shipped package (`@strudel`
  1.2.6); re-verify if strudel.cc ships a new major
- Strudel session API (short `?HASH` links) runs on Supabase and "is not
  guaranteed to live forever" (official docs wording); only the long
  `#base64` URL is self-contained
- Large patterns may exceed URL length limits (keep exports compact)
- Always validate with dj-validate check_strudel=true first
- Envelope/voice nuances (_pluck_, _pad_, _sub_ sounds) don't exist in
  Strudel — use the substitutes from the reference table

## Verification

- Exported code parses (bracket balance; optional `@strudel/mini` parse in node)
- Every method used is in the verified table of `references/strudel-vs-maelstrom.md`
- Tempo line is `setcpm(bpm/4)` (cycle = bar) so Strudel loop length matches the maelstrom WAV
- Share URL round-trips: `strudel_url.py decode '<url>'` returns the code
- Round-trip: export → strudel.cc → edit → export preserves intent