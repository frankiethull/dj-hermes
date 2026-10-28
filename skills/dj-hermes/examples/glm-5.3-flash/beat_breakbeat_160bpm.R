library(maelstrom)

# Breakbeat 160bpm — chopped feel: euclid ride, degraded ghost hats,
# rev() flips the hat roller on about half the cycles (sometimes), sub bass.
# earlier glm-5.3-flash render used bpm/60 here, treating one cycle as one beat (4-second WAVs)
bpm <- 160
target_seconds <- 15  # defaults.yaml render_policy: target_render_seconds
cps <- bpm / 240      # 1 maelstrom cycle = 1 bar (4/4)
cycles <- max(8, ceiling(target_seconds * bpm / 240))  # bars, >= ~15 s

bd <- s("bd [~ bd] bd [~ bd ~ bd]") |> drive(1.5) |> gain(0.95)
sd <- s("sd(3,8)") |> gain(0.85) |> kit("acoustic")
hh <- s("hh*16") |> degrade(0.3) |> gain(0.6) |> pan(0.35)
ride <- euclid(s("ride"), 3, 8) |> sometimes(rev) |> gain(0.5)
sub <- note("[c1 ~ c1 ~][~ g1 ~ ab1]") |> synth("sub") |> gain(0.8)

pattern <- stack(bd, sd, hh, ride, sub)
samples <- render_stereo(pattern, cycles = cycles, cps = cps)
write_wav("beat_breakbeat_160bpm.wav", samples)
