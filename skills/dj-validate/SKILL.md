---
name: dj-validate
description: Validate uzu pattern syntax against maelstrom and Strudel parsers.
version: 0.1.0
author: Frankie Hull (frankiethull), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [music, validation, syntax, uzu, maelstrom, strudel]
    related_skills: [dj-hermes, dj-generate, dj-render, dj-export]
---

# dj-validate Skill

Validates uzu pattern code against both the maelstrom parser (offline R) and the Strudel parser (browser-based). Ensures patterns are playable before rendering or exporting.

## When to Use

- After dj-generate to verify Rhythmancer output before rendering
- Before dj-render to catch syntax errors early
- Before dj-export to ensure Strudel compatibility
- User manually editing patterns and wants to check validity

Don't use for:
- Generating patterns (use dj-generate)
- Rendering audio (use dj-render)
- Live coding (use Strudel directly)

## Prerequisites

- maelstrom R package for uzu parser validation
- Optional: Node.js + Strudel parser for Strudel validation (can use `@strudel/parser` npm package)
- Pattern string to validate

## How to Run

```bash
# Via skill in conversation
# "dj-validate: s('bd sd', 'hh*2')"

# Direct R validation
Rscript -e 'maelstrom::parse_pattern("s(\"bd sd\", \"hh*2\")")'

# Direct Strudel validation (Node)
node -e "const { parse } = require('@strudel/parser'); console.log(parse('s(\"bd sd\", \"hh*2\")'))"
```

## Quick Reference

| Parameter | Description | Default |
|---|---|---|
| `pattern` | uzu pattern string to validate | required |
| `check_strudel` | Also validate against Strudel parser | true |
| `strict` | Fail on warnings, not just errors | false |

## Procedure

1. **Receive pattern** — uzu pattern string from user or dj-generate
2. **Validate with maelstrom** — call `maelstrom::parse_pattern()` in R
   - On parse error: return error with position and message
   - On success: continue
3. **Optional: Validate with Strudel** — if `check_strudel=true`
   - Call Strudel parser via Node.js
   - Strudel may accept different syntax; report differences
4. **Return validation result** —
   - `valid: true` + any warnings
   - `valid: false` + error details (engine, position, message)

### Maelstrom Validation

```r
result <- maelstrom::parse_pattern(pattern)
# Returns parsed AST or throws error with position
```

### Strudel Validation

```javascript
const { parse } = require('@strudel/parser');
try {
  const ast = parse(pattern);
  return { valid: true, ast };
} catch (e) {
  return { valid: false, error: e.message, position: e.index };
}
```

## Pitfalls

- maelstrom and Strudel have slightly different syntax support
- Strudel supports more mini-notation features; maelstrom is stricter on uzu core
- Some valid uzu patterns won't parse in Strudel (and vice versa)
- Always validate against the target engine (maelstrom for render, Strudel for export)
- R/Node.js must be available; gracefully handle missing runtimes
- Verified on the installed maelstrom (2026-10-24, see `skills/dj-hermes/references/workflow-lessons.md`):
  - `.` (or any unknown token) **hangs** the parser instead of erroring — treat a silent CLH as "unknown token"; valid rests are `~` / `-`
  - Inline `|` layering is invalid (polymeter only via `{a b, x y}`)
  - `pan()` / other fx accept scalar values only (pattern-valued fx cause `num_or` closure errors at render)
  - a parser-bisect style check (`render_stereo` each voice at `cycles=1`) catches engine-specific failures `parse_pattern` misses because some defects only surface at render time
- **Parse-valid + rendered ≠ correct.** Also validate the *render length*: every shipped WAV must satisfy `render_policy` in `skills/dj-hermes/defaults.yaml` (`>= min_render_seconds`, 15s). A 3-4 second WAV means `cps` was set to `bpm / 60` (cycle treated as one beat); correct is `cps = bpm / 240` (one cycle = one bar of 4/4), i.e. `cycles = max(8, ceiling(15 * bpm / 240))`. Enforce with `bash plugins/dj-hermes/scripts/check_examples.sh`

## Verification

- Known valid patterns return `valid: true`
- Known invalid patterns return `valid: false` with actionable error
- Position information helps user locate error in pattern
- Both engines checked when requested
- Validation completes in <2s for typical patterns