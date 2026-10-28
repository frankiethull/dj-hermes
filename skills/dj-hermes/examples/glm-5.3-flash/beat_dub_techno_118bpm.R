library(maelstrom)

# Dub techno 118bpm — long echoing pad chord, sparse euclid conga/rim
# percussion, dubby sub bass, everything washed in echo.
bpm <- 118
target_seconds <- 15  # defaults.yaml render_policy: target_render_seconds
cps <- bpm / 240      # 1 maelstrom cycle = 1 bar (4/4); bpm/60 here caused 4-second renders
cycles <- max(8, ceiling(target_seconds * bpm / 240))  # bars, >= ~15 s

bd <- s("bd*4") |> gain(0.9) |> drive(1.2)
chord <- note("[c3 eb3 g3]") |> synth("pad") |>
  echo(5, 0.75, 0.6) |> lpf(1400) |> gain(0.6)
rim <- euclid(s("rim"), 2, 8) |> degrade(0.25) |> gain(0.4)
conga <- euclid(s("conga"), 5, 16) |> gain(0.45)
bass <- note("[c1 ~ ~ ~][~ ~ g1 ~]") |> synth("sub") |> gain(0.85)
hiss <- s("shaker") |> every(2, \(p) fast(p, 2)) |> gain(0.3)

pattern <- stack(bd, chord, rim, conga, bass, hiss)
samples <- render_stereo(pattern, cycles = cycles, cps = cps)
write_wav("beat_dub_techno_118bpm.wav", samples)
