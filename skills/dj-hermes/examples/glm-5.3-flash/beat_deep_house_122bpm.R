library(maelstrom)

# Deep house 122bpm — swung shaker, echoing arp pluck stabs,
# hats with a slow lpf cutoff sweep, saw bass.
bpm <- 122
target_seconds <- 15  # defaults.yaml render_policy: target_render_seconds
# 1 maelstrom cycle = 1 bar (4/4) -> cps = bpm / 240 (NOT bpm/60; cycle=beat here caused 4-second renders)
cps <- bpm / 240
cycles <- max(8, ceiling(target_seconds * bpm / 240))  # bars, >= ~15 s

bd <- s("bd [~ bd] bd [~ bd]") |> gain(0.95)
sd <- s("[~ cp] [~ cp]") |> gain(0.7)
shake <- s("shaker*16") |> swing(0.35) |> degrade(0.2) |> gain(0.45)
stab <- arp(note("[c4 eb4 g4][~ eb4 g4 bb4][a3 c4 eb4][~ g4 bb4 c5]")) |>
  synth("pluck") |> echo(3, 0.375, 0.55) |> lpf(3000) |> gain(0.75)
bass <- note("[a1 ~ ~ g1]") |> synth("sawtooth") |>
  lpf(slow(n("400 800 1600 400"), 4)) |> gain(0.8)
hat <- s("~ hh*2 ~ hh") |> gain(0.5)

pattern <- stack(bd, sd, shake, stab, bass, hat)
samples <- render_stereo(pattern, cycles = cycles, cps = cps)
write_wav("beat_deep_house_122bpm.wav", samples)
