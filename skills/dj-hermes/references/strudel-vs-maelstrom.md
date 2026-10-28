# Strudel vs maelstrom — Verified API Surface

Both engines speak uzu mini-notation, but **the method APIs are NOT siblings**.
Verified 2026-10-27 against the exact code strudel.cc ships (`@strudel/core`
1.2.6 / `@strudel/webaudio` 1.3.0, extracted from the published dists), plus
agent paste-errors from strudel.cc itself (marked **[observed]**). Check
`versions` again if strudel.cc bumps majors: `node_modules/@strudel/core/dist/index.mjs`
throws `.<name>() expects N inputs but got M` from a central registry — that
registry line enumerates true arities.

## Tempo / duration (do this exactly)

| | |
|---|---|
| maelstrom | `render_stereo(pattern, cycles = N, cps = bpm / 240)` — 1 cycle = 1 bar of 4/4 |
| Strudel | `setcpm(bpm / 4)` — official docs idiom (strudel.cc/understand/cycles). `setcps(bpm / 240)` is equivalent but `setcpm(x/4)` is what docs/examples use |

One cycle = one bar (4/4) in **both** engines under these values, so pattern
length and loop content map 1:1. Expected audible length is
`cycles * 240 / bpm` s; never ship Strudel exports shorter than
`defaults.yaml render_policy.min_render_seconds`.

## Method translation table (all verified against @strudel 1.2.6)

| maelstrom | Strudel | Trap / difference |
|---|---|---|
| `degrade(0.2)` | `.degradeBy(0.2)` | **[observed]** `.degrade() is 0-input` — it means "drop 50%"; only `degradeBy(p)` takes a probability |
| `synth("sawtooth")` on `note()` | `.s("sawtooth")` | **[observed]** `.synth` doesn't exist (`note(...).synth is not a function`). Voice = `s` (`= sound`) param |
| `synth("sub")` | `.s("sine").lpf(low)` | no `sub` sound; 808-ish sub in Strudel = clean sine, lowpassed |
| `synth("pluck")` | `.s("sawtooth")` (`+ .attack(0).release(0.08)`) | no pluck preset |
| `synth("pad")` | `.s("supersaw").attack(0.15).release(0.5)` | supersaw is the nearest spirit (soft unison, slow env) |
| `humanize(a, b)` | omit, or `.sometimes(x => x.early(0.012))` | no `humanize` method in Strudel |
| `kit("...")` | omit, or `.bank("RolandTR909")` on drums | different sample-bank model (maelstrom kit naming not portable) |
| `echo(n, time, feedback)` | `.echo(n, time, feedback)` | same order (count, delay-in-cycles, feedback) — 3 inputs. A 2-arg call is an error or nonsense |
| `arp(chords)` | `arp("<0 1 2>", chordPattern).s(voice)` | `arp` takes **2 inputs**: an index pattern over the collected chord tones, then the note pattern. Maelstrom's 1-arg auto-arp does not exist |
| `swing(x)` | `.swing(x)` | 1 input; identical semantics (swingBy 1/3). Prefer `.swing(x)` on a layer/stack over a global |
| `every(n, fn)` | `.every(2, x => x.fast(2))` | fn must be a real unary lambda **whose chain is called** — `.sometimes(x => x.rev)` is broken (`rev` never invoked); write `x => x.rev()` |
| `sometimes/by/often/rarely(fn)` | `.sometimes(x => x.rev())` | 1 input = the function; no probability arg in either engine |
| `fast(n)` / `slow(n)` | `.fast(n)` / `.slow(n)` | identical |
| `lpf(3000)` | `.lpf(3000)` | pattern-valued cutoff works: `.lpf("<400 800 1600 400>/4")` — replace maelstrom `slow(n("400 800"), 4)` style with mini-notation `/N` |
| `pan(0.35)` | `.pan(0.35)` | in maelstrom pan is scalar-only; in Strudel it also accepts patterns, but scalar keeps parity |
| `drive(1.5)` | `.drive(1.5)` | exists as param in both (Strudel also has `.distort`) |
| `note("ab1")` | `.note("ab1")` | Strudel's note parser is more forgiving than maelstrom (maelstrom renders `aa1`-style garbage as NA); keep single-letter + `#`/`b` anyway for portability |
| `stack(...)` | `stack(...)` | identical; also `.cpm(bpm/4)` can set per-pattern tempo |

## Known-absent in Strudel (grep-verified, use substitutes)

`synth` (as method), `pluck`, `pad`, `sub`, `humanize` sounds, maelstrom
`kit()` banks, `add_reverb` (use `.room(n)`), `render/write_wav`
(Strudel is live-only).

## Strudel voice inventory (verified to ship, webaudio package)

- Oscillator synths: `sine`, `triangle` (`tri`), `square` (`sqr`), `sawtooth`
  (`saw`/`sqr`), `noise`, `supersaw` (ADSR params: `attack/decay/sustain/release`),
  `pulse`, `sbd`, `bytebeat`
- Everything else (drums `bd hh sd cp tom oh shaker ride rim conga`, `gm_*`
  samples) is loaded per-site on strudel.cc — fine for Path B exports, don't
  assume them in headless `@strudel/*` node runs

## Share links (agent flow: generate → link back, NO browser needed)

The long share URL is simply **base64 of the code, percent-encoded** (verified
byte-for-byte against the official embed docs and the site's own
`shareCode()` implementation):

```
https://strudel.cc/#<urllib.quote(base64(code).decode('ascii'), safe='')>
```

Agent procedure for "give me a playable link":

1. Generate/fix the Strudel code (this file's table + Path B template).
2. Sanity-parse if you can (node + `@strudel/mini` or at least bracket/nesting balance).
3. Encode: `python3 scripts/strudel_url.py encode '<file-or-code>'`
   → returns a `https://strudel.cc/#...` URL.
4. Hand the user BOTH the raw code and the clickable URL.
5. The Share button's short link (`https://strudel.cc/?HASH`) needs the
   Supabase share DB — agents cannot mint those; always ship the long URL
   (it is self-contained and survives DB loss).
6. Decode round-trip check when unsure: `strudel_url.py decode '<url>'`.

## Bisecting Strudel errors (Play button shows one error at a time)

1. Comment out all but one layer of the `stack(` (or split into several REPLs).
2. Fix layer-by-layer using the table above; arity errors name their method (`.x() expects N inputs`).
3. Re-add layers; the last surviving error names the broken layer.
