library(maelstrom)

# Classic four-on-the-floor 126bpm house — rolling sub-bass, supersaw chord
# pad, swung 16th hats, claps on the off-beat.
#
# Path A (maelstrom offline render) — translation of the Strudel-first
# beat_house_strudel_126bpm.strudel.cc (which is the source of truth).
# Mapping: synth("pad")  <-> .s("supersaw").attack(0.15).release(0.5)
#          synth("sub")  <-> .s("sine").lpf(low)
#          drive(1.3)    <-> .drive(1.3)
#          note(...)     <-> .note(...); s("...")<->.s("...")
bpm <- 126
target_seconds <- 15  # defaults.yaml render_policy: target_render_seconds
cps <- bpm / 240      # 1 maelstrom cycle = 1 bar (4/4)
cycles <- max(8, ceiling(target_seconds * bpm / 240))  # bars, >= ~15 s

bd <- s("bd*4") |> gain(0.9) |> drive(1.3)
cp <- s("~ cp ~ cp ~ cp ~ cp") |> gain(0.72)
hh <- s("hh*16") |> swing(0.2) |> gain(0.42)
bass <- note("c2 ~ g2 ~ eb2 ~ bb2 ~") |> synth("sub") |> gain(0.85) |> lpf(180)
pad <- note("[c4 eb4 g4] [eb4 g4 bb4] [f4 ab4 c5] [g4 bb4 d5]") |>
  synth("pad") |> lpf(2400) |> gain(0.45)
oh <- s("~ ~ ~ oh") |> gain(0.4)

pattern <- stack(bd, cp, hh, bass, pad, oh)
samples <- render_stereo(pattern, cycles = cycles, cps = cps)
write_wav("beat_house_strudel_126bpm.wav", samples)
