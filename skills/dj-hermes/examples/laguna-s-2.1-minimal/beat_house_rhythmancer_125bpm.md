# beat_house_rhythmancer_125bpm

**Style:** deep house (rolling bassline, chord stabs) **BPM:** 125

## Method
**Rhythmancer** (Path C) — an LLM-generated house beat. Prompted the Nanite-Labs
`nanites-rhythmancer-3b-generator-gguf` (a Qwen2-3B fine-tune that emits Strudel
`stack()` code) with `llama-cli`, captured its verbatim Strudel output as the
`.strudel.cc`, then hand-translated to maelstrom's uzu DSL for the offline render.

This is the "bonus" method — the model's output uses Strudel-only methods
(`.bank`, `.hpf`, `.scramble`, `.chord().voicing()`, `.room`, `.degradeBy`) with
no maelstrom analogue. See "Translation" below for every dropped/differing
combinator.

## Files
- Live pattern (LLM verbatim): `beat_house_rhythmancer_125bpm.strudel.cc` (Path C,
  Rhythmancer Q4_K_M output — chat_template qwen2/ChatML, temp 0.8, top_p 0.95)
- Offline render: `beat_house_rhythmancer_125bpm.R` (maelstrom translation,
  hand-mapped from the LLM output)
- Audio: `beat_house_rhythmancer_125bpm.wav` (8 bars = 8 cycles, cps = 125/240,
  15.36 s, stereo, 44100 Hz, 16-bit PCM)

## LLM provenance (Path C)
- Model: `Nanite-Labs/nanites-rhythmancer-3b-generator-gguf` — snapshot
  `20066060bc25dbc09c6dd69e234a36e930e3b82a`, file `rhythmancer-Q4_K_M.gguf`
- Arch / params: Qwen2, 3.09 B params, 36 layers, hidden 2048, FFN 11008 (GQA)
- Quant: Q4_K_M (Q4_K Medium), 4.99 BPW, 1.79 GiB file size, 434 tensors
- Engine: llama-cli build 6981 (gcc 14.3.0), CPU-only — no GPU support compiled in
- KV cache: q8_0, 38.25 MiB (ctx 2048); threads = 8
- Sampling: `--temp 0.8 --top-p 0.95 --n-predict 400`
- Inference time: 27.5 s total (47-token prompt eval @ 4.8 t/s, 155-token gen @ 8.8 t/s)
- Prompt: `Generate Strudel live-coding music code for: deep house track with a
  rolling bassline and supersaw chord stabs at 125 bpm` (wrapped in ChatML
  `<|im_start|>user ... <|im_start|>assistant` per the qwen2 template)

## Translation (strudel -> maelstrom)
Per `references/strudel-vs-maelstrom.md`:

| Strudel (LLM output) | maelstrom | Notes |
|---|---|---|
| `s("bd*4")` | `s("bd*4")` | 1:1 |
| `s("~ cp ~ cp")` | `s("~ cp ~ cp")` | `bank("RolandTR808")` omitted (kit names not portable) |
| `.degradeBy(0.08)` | `degrade(0.08)` | combinator exists; verified |
| `.room(0.22)` / `.room(0.4)` | `add_reverb(0.4)` (post-render) | add_reverb takes rendered audio, applied once to full mix |
| `s("~ hh hh ~")` | `s("~ hh hh ~")` | `.hpf(8163)` omitted (maelstrom has no hpf) |
| `.sound("triangle")` | `synth("triangle")` | verified oscillator voice |
| `.gain(0.99)` | `gain(0.9)` | level tamed slightly |
| `.scramble(2)` | omitted | no maelstrom equivalent |
| `chord("<Cm7 Gbm9>").voicing()` | `note("[c4 eb4 g4 bb4] [gb4 bb4 db5 f5]")` | explicit voicings: bar1=real Cm7, bar2=Gbm7 (Gbm9 simplified); `synth("sawtooth")` + `lpf(2400)` |
| `.cpm(125/4)` | cps = 125/240 | 1 cycle = 1 bar in both engines |

## Combinators exercised
- `s("bd*4")` / `s("~ cp ~ cp")` / `s("~ oh ~ oh")` / `s("~ hh hh ~")` — drum
  patterns (4/4 kick, 2&4 claps, 2&4 open hats, sparse closed hats)
- `degrade(0.08)` — light probability-based event drop on claps (NEW: not in the
  glm-5.3-flash or strudel-126bpm beat sets)
- `note("~ a2 a2 a2 a2 a2 a2")` — 8th-note triangle-oscillator walking bassline
- `note("[c4 eb4 g4 bb4] [gb4 bb4 db5 f5]")` — 2-bar chord voicings (poly)
- `synth("triangle")`, `synth("sawtooth")` — oscillator voices
- `lpf(2400)`, `gain(...)`, `stack(...)`, `add_reverb(0.4)` — filters, level,
  layering, reverb

## Verify (Path C generative + Path A offline)
Generative check (regenerate the Strudel output from the GGUF):
```bash
cat /tmp/rhythmancer_prompt.txt | xargs -0 printf '%s' | \
  llama-cli -m <gguf> -f /tmp/rhythmancer_prompt.txt -n 400 \
    --temp 0.8 --top-p 0.95 -c 2048 \
    --cache-type-k q8_0 --cache-type-v q8_0
# -> emits the stack() block in beat_house_rhythmancer_125bpm.strudel.cc
```
Path A render:
```bash
Rscript beat_house_rhythmancer_125bpm.R && file beat_house_rhythmancer_125bpm.wav
# -> RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, stereo 44100 Hz
ffprobe -v error -show_entries format=duration -of csv=p=0 beat_house_rhythmancer_125bpm.wav
# -> 15.36 s; must be >= min_render_seconds (defaults.yaml render_policy) [15, 30]
bash ../../../../plugins/dj-hermes/scripts/check_examples.sh  # if present
```

## Verify (Path B, live via strudel.cc)
Encode the LLM output into a self-contained share link (base64 + percent-encode,
no Supabase DB dependency).

**Live link:** https://strudel.cc/#Ly8gYmVhdF9ob3VzZV9yaHl0aG1hbmNlcl8xMjVicG0g4oCUIExMTS1nZW5lcmF0ZWQgYnkgUmh5dGhtYW5jZXIKLy8gUGF0aCBDOiBOYW5pdGUtTGFicy9uYW5pdGVzLXJoeXRobWFuY2VyLTNiLWdlbmVyYXRvci1nZ3VmIChRNF9LX00sIDMuMDlCLCAxLjhHQikKLy8gUHJvbXB0OiAiZGVlcCBob3VzZSB0cmFjayB3aXRoIGEgcm9sbGluZyBiYXNzbGluZSBhbmQgc3VwZXJzYXcgY2hvcmQgc3RhYnMgYXQgMTI1IGJwbSIKLy8gRW5naW5lOiBsbGFtYS1jbGkgKGdjYyA2OTgxLCBDUFUtb25seSBidWlsZCwgbm8gR1BVIHN1cHBvcnQpCi8vIFNhbXBsaW5nOiAtLXRlbXAgMC44IC0tdG9wLXAgMC45NSAtLW4tcHJlZGljdCA0MDAsIGNoYXRfdGVtcGxhdGUgcXdlbjIgKENoYXRNTCkKLy8gT3V0cHV0IGlzIHZlcmJhdGltIFN0cnVkZWwgMS4yLjYgc3ludGF4IChwZXIgbW9kZWwgUkVBRE1FOiAyNC8yNCBhZGFwdGVyIGV2YWwgcGFyc2VzKS4KLy8KLy8gTk9URSAodW50cmFuc2xhdGVkIHRvIG1hZWxzdHJvbSBQYXRoIEEpOiAuYmFuaygpLCAucm9vbSgpLCAuZGVncmFkZUJ5KCksCi8vICAgLnNjcmFtYmxlKCksIC5jaG9yZCgpLnZvaWNpbmcoKSBoYXZlIG5vIG1hZWxzdHJvbSBjb21iaW5hdG9yIGVxdWl2YWxlbnQuCi8vICAgU2VlIGJlYXRfaG91c2Vfcmh5dGhtYW5jZXJfMTI1YnBtLlIgZm9yIHRoZSBvZmZsaW5lLXJlbmRlciB0cmFuc2xhdGlvbi4Kc2V0Y3BtKDEyNS80KQpzdGFjaygKICBzKCJiZCo0IikuZ2FpbigwLjgzKSwKICBzKCJ%2BIGNwIH4gY3AiKS5iYW5rKCJSb2xhbmRUUjgwOCIpLnJvb20oMC4yMikuZGVncmFkZUJ5KDAuMDgpLAogIHMoIn4gb2ggfiBvaCIpLmJhbmsoIlJvbGFuZFRSODA4IikuZ2FpbigwLjg2KSwKICBzKCJ%2BIGhoIGhoIH4iKS5ocGYoODE2MykuZ2FpbigwLjUyKSwKICBub3RlKCJ%2BIGEyIGEyIGEyIGEyIGEyIGEyIikuc291bmQoInRyaWFuZ2xlIikuZ2FpbigwLjk5KS5zY3JhbWJsZSgyKSwKICBjaG9yZCgiPENtNyBHYm05PiIpLnZvaWNpbmcoKS5yb29tKDAuNCkKKQo%3D
```bash
python3 ../../../../plugins/dj-hermes/scripts/strudel_url.py encode \
        beat_house_rhythmancer_125bpm.strudel.cc
python3 ../../../../plugins/dj-hermes/scripts/strudel_url.py decode "<url>"  # round-trip
```

## References
- Rhythmancer GGUF: https://huggingface.co/Nanite-Labs/nanites-rhythmancer-3b-generator-gguf
- maelstrom synth voices: `man/synth.Rd`; `R/synth2.R` (SYNTHS list: sine sawtooth square triangle noise pluck pad sub lead)
- `add_reverb` (post-render audio effect): `man/add_reverb.Rd`
- `degrade`, `lpf`, `gain`, `stack`, `render_stereo`, `write_wav`
- Strudel mapping: `references/strudel-vs-maelstrom.md`