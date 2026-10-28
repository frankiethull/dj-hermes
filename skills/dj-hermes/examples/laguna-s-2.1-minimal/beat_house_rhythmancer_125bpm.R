library(maelstrom)

# Deep house 125bpm — translated from Rhythmancer LLM-generated Strudel.
# Source: beat_house_rhythmancer_125bpm.strudel.cc (Path C, LLM-authored)
# LLM: Nanite-Labs nanites-rhythmancer-3b-generator-gguf (Q4_K_M, 1.79 GiB)
# Engine: llama-cli (gcc 6981, CPU-only — no GPU support), chat template = qwen2/ChatML
# Sampling: --temp 0.8 --top-p 0.95 --n-predict 400
#
# Translation table (see references/strudel-vs-maelstrom.md):
#   .sound("triangle")  -> synth("triangle")   (verified oscillator voice)
#   .bank("RolandTR808") -> omitted (maelstrom kit names not portable)
#   .hpf(8163)          -> omitted (maelstrom has no hpf combinator)
#   .scramble(2)        -> omitted (no maelstrom equivalent)
#   .degradeBy(0.08)    -> degrade(0.08)       (pattern combinator, verified)
#   .room(0.22) / .room(0.4) -> add_reverb(0.4)
#     add_reverb takes rendered audio (not a pattern); applied to full mix.
#   chord("<Cm7 Gbm9>").voicing() -> explicit note() chord voicings, synth("sawtooth")
#
# Timing: 1 maelstrom cycle = 1 bar (4/4) -> cps = bpm / 240.
# Expected duration: 8 * 240 / 125 = 15.36s.
bpm <- 125
target_seconds <- 15  # defaults.yaml render_policy: target_render_seconds
cps <- bpm / 240
cycles <- max(8, ceiling(target_seconds * bpm / 240))  # bars, >= ~15 s

# Four-on-the-floor kick
bd <- s("bd*4") |> gain(0.83)

# Clap on 2 & 4, lightly degraded (degradeBy) + a touch of room (room -> add_reverb)
cp <- s("~ cp ~ cp") |> degrade(0.08) |> gain(0.8)

# Open hat on 2 & 4
oh <- s("~ oh ~ oh") |> gain(0.86)

# Closed hats on 2 & 3 (hpf dropped — maelstrom has no hpf; brightness left to sample)
hh <- s("~ hh hh ~") |> gain(0.52)

# Walking bassline: triangle oscillator on a2, 8th-note rhythm (scramble dropped)
bass <- note("~ a2 a2 a2 a2 a2 a2") |> synth("triangle") |> gain(0.9)

# Chord stabs: bar1 = Cm7, bar2 = Gbm7 (simplified from Gbm9), supersaw-ish sawtooth
chords <- note("[c4 eb4 g4 bb4] [gb4 bb4 db5 f5]") |>
  synth("sawtooth") |> lpf(2400) |> gain(0.6)

pattern <- stack(bd, cp, oh, hh, bass, chords)
samples <- render_stereo(pattern, cycles = cycles, cps = cps)
# add_reverb takes rendered audio; consolidated per-layer .room() into one pass
samples <- add_reverb(samples, 0.4)
write_wav("beat_house_rhythmancer_125bpm.wav", samples)
