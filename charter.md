# dj-hermes

**Hermes plugin for uzu-lang beat making**

**Tagline:** Drop a beat with uzu patterns.

## 1. Identity

| | |
|---|---|
| **Name** | dj-hermes |
| **Type** | Hermes community plugin (skill pack) |
| **Mission** | Give Hermes (and its agents) a fast, reliable path from a groove description or raw pattern to audible, editable, live-codable beats using the uzu family — powered by the Rhythmancer generator, maelstrom offline synthesis, and optional Strudel export. |

## 2. Relationship to Existing Work

- **hermes-tabular** remains the tabular-intelligence sibling. dj-hermes is a completely separate creative/music route.
- Deterministic core pieces:
- **Strudel** ([strudel.cc](https://strudel.cc)) — primary live-coding / browser target
- **maelstrom** ([frankiethull/maelstrom](https://github.com/frankiethull/maelstrom)) — R-based uzu pattern language + offline WAV synthesis
- **Rhythmancer 3B** ([Nanite-Labs/nanites-rhythmancer-3b-generator](https://huggingface.co/Nanite-Labs/nanites-rhythmancer-3b-generator)) — the generative front-end
- The plugin may deviate and grow its own devices (extra mini-notation sugar, agent workflows, live bridges, etc.) while staying uzu-native.

## 3. Core Principles

1. **Uzu-native** — Patterns are first-class. Prefer mini-notation, combinators, and `stack()` semantics over inventing a new language.
2. **Deterministic core, generative skin** — Rhythmancer proposes; maelstrom (or Strudel) validates and renders. The agent always gets real, playable code or audio.
3. **Offline-first, live-optional** — Base rendering needs no browser. Export or bridge to Strudel when the user wants the stage.
4. **Agent-friendly & narrow** — One primary entry point (like hermes-tabular’s `tabular`). Small decision space, clear defaults, no kitchen-sink DAW.
5. **Honest & open** — Clean provenance (synthetic training data for the model). Apache/MIT-style licensing. No scraped live-coding corpus claims.
6. **Hermes-native** — Installs cleanly via the plugin catalog, auto-registers skills under the `dj-hermes:` namespace.
7. **Audible, not token-sized** — A "render" nobody can listen to is a defect. One maelstrom cycle = one bar (4/4), so `cps = bpm / 240` — never `bpm / 60`. Example/deliverable WAVs must satisfy `render_policy` in `skills/dj-hermes/defaults.yaml` (`>= 15 s`), verified mechanically with `scripts/check_examples.sh`. The same rule holds for Strudel exports (`setcps(bpm/240)`).

## 4. Primary Use Cases (v0–v1)

- Natural-language prompt → uzu/Strudel/maelstrom code → WAV or live session
- Direct pattern editing → re-validate → re-render
- Genre / tempo / mood presets that still emit real uzu code
- CLI + lightweight playground surface
- Agent tools so Hermes can “drop a beat” inside larger workflows

## 5. Non-Goals (initial scope)

- Full multi-track arrangement or DAW replacement
- Real-time collaborative editing (leave that to StrudelHub / flok)
- Training or fine-tuning on scraped public Strudel code
- Tight coupling to Hermes core internals (stays a pure plugin)

## 6. Success Metrics (early)

- Generated stacks parse and produce sound in real Strudel and/or maelstrom
- Round-trip latency (describe → code → render → edit → re-render) feels fast for an agent
- Single primary skill is sufficient for the common case; sub-skills stay optional
- Docs short enough that both a human Strudel user and an agent can use them

## 7. High-Level Architecture

```
User / Agent
↓
dj-hermes primary skill (orchestrator)
↓
├── Rhythmancer 3B → proposes pattern code
├── maelstrom (R) → validates + offline render → WAV
└── Strudel export / bridge → live browser session (optional)
```

Optional later surfaces: MCP tools, Shiny playground wrapper, OSC/live bridge.

## 8. Skill Layout

Mirrors the hermes-tabular pattern.

- **Primary entry point:** `dj-hermes:dj`
- Possible sub-skills (only if needed):
- `dj-generate` — prompt → pattern code
- `dj-render` — pattern → WAV
- `dj-validate` — syntax / engine check
- `dj-export` — Strudel-ready output or session push
- `dj-listen` — short playback helper

Policy defaults live in a small YAML (tempo ranges, genre list, render length, etc.) so the prose skill stays stable.

## 9. Roadmap Sketch

| Version | Focus |
|---------|--------|
| **v0** | Orchestrator that calls Rhythmancer → validates against maelstrom or Strudel parser → renders WAV. Single primary skill. |
| **v1** | Better genre coverage, reliable Strudel export, basic agent tools, short docs. |
| **v2** | Optional live bridge, modest maelstrom extensions, or tighter Hermes desktop integration if demand appears. |

## 10. Licensing & Provenance

- Plugin & orchestration code: MIT (LICENSE file at repo root, matches hermes-tabular)
- maelstrom: keep its existing license
- Rhythmancer 3B: Apache-2.0 (as published)
- Training data remains 100% synthetic / template-generated

---

*This charter is the living source of truth for scope and principles. Implementation details live in the skill files and defaults.*