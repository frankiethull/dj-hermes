library(maelstrom)

# Rhythmancer GGUF generated (Path B dialect, temp 0.7) — translated to
# maelstrom per references/strudel-vs-maelstrom.md:
#   s("...")          -> s("...")
#   sound("triangle")  -> synth("triangle")
#   bank/orbit/room    -> dropped (maelstrom has no TR sample banks/orbits)
#   sometimes(x=>x.rev()) -> pipe |> sometimes(rev)
#   every(4, fn)       -> pipe |> every(4, \(p) fast(p, 2))
#   .cpm(76/4)         -> cps = 76 / 240 (1 cycle = 1 bar of 4/4)
bpm <- 76
target_seconds <- 15	 # defaults.yaml render_policy: target_render_seconds
cps <- bpm / 240
cycles <- max(8, ceiling(target_seconds * bpm / 240))	 # bars, >= ~15 s

bd <- s("~ ~ bd ~") |> gain(0.92)
rim <- s("~ ~ rim ~") |> sometimes(rev) |> gain(0.6)
hh <- s("hh*8") |> every(4, \(p) fast(p, 2)) |> gain(0.57)
mel <- note("~ bb2 f2 d2 ab2 a2 d2") |> synth("triangle") |> lpf(691) |> gain(0.77)

pattern <- stack(bd, rim, hh, mel)
samples <- render_stereo(pattern, cycles = cycles, cps = cps)
write_wav("beat_smoky_dub_76bpm.wav", samples)
