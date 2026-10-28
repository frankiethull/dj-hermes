library(maelstrom)

# Halftime trap 140bpm — 808-style sub slide, rolled hi-hats (fast(2)),
# sparse clap on beat 4, humanized shaker shadows, tom fill.
bpm <- 140
target_seconds <- 15  # defaults.yaml render_policy: target_render_seconds
cps <- bpm / 240      # 1 maelstrom cycle = 1 bar (4/4); bpm/60 here caused 4-second renders
cycles <- max(8, ceiling(target_seconds * bpm / 240))  # bars, >= ~15 s

bd <- s("bd [~ ~ ~ ~] [~ ~ bd] ~") |> gain(1)
sub <- note("[a1 a1 ~ ~][~ g1 ~ f1][a1 ~ bb1 ~][~ ~ g1 ~]") |>
  synth("sub") |> echo(2, 0.25, 0.4) |> gain(0.9)
clap <- s("[~ ~ ~ cp]") |> degrade_by(0.1) |> gain(0.8)
hat <- s("hh*4 hh*8") |> fast(2) |> degrade(0.2) |> gain(0.55) |> pan(0.55)
shk <- s("shaker*8") |> humanize(0.004, 0.15) |> gain(0.3)
tom <- s("[~ ~ ~ ~][~ ~ tom ~]") |> gain(0.5)

pattern <- stack(bd, sub, clap, hat, shk, tom)
samples <- render_stereo(pattern, cycles = cycles, cps = cps)
write_wav("beat_halftime_trap_140bpm.wav", samples)
