library(maelstrom)

# Deep house 124bpm — four-on-floor kick with ghost notes, snappy claps,
# swung hats with highpass, walking chord-tone sub-bass, echoing stab chords.
# Hand-authored in maelstrom uzu; Path A (offline render) is the source of truth.
#
# Timing: 1 maelstrom cycle = 1 bar (4/4) -> cps = bpm / 240.
# Using bpm/60 here by mistake yields a 3-4 s WAV (see defaults.yaml render_policy).
bpm <- 124
target_seconds <- 15  # defaults.yaml render_policy: target_render_seconds
cps <- bpm / 240
cycles <- max(8, ceiling(target_seconds * bpm / 240))  # bars, >= ~15 s

# Kick: 4/4 foundation + ghost kicks on the "&" of 2 and 4
bd <- s("bd ~ bd ~ ~ bd ~ bd") |> gain(0.92) |> drive(1.4)

# Clap: backbeat on 2 & 4, full bar
cp <- s("~ cp ~ cp ~ cp ~ cp") |> gain(0.8)

# Closed hats: swung 16ths, lightly crushed for grit (crush = bit depth [1,16])
hh <- s("hh*16") |> swing(0.22) |> crush(8) |> gain(0.45)

# Open hat punctuation on the "&" of beat 4
oh <- s("~ ~ ~ ~ ~ ~ ~ oh") |> gain(0.45) |> echo(3, 0.25, 0.2)

# Walking bassline on chord tones (c minor 7 walk: c2 -> eb2 -> g2 -> f2)
bass <- note("c2 ~ eb2 ~ g2 ~ f2 ~") |> synth("sub") |> lpf(140) |> gain(0.85)

# Stab chords with dotted-delay echo, every bar changes chord
stab <- note("[c4 eb4 g4] [eb4 g4 bb4] [f4 ab4 c5] [g4 bb4 d5]") |>
  synth("sawtooth") |> echo(4, 0.25, 0.35) |> lpf(2200) |> gain(0.6)

pattern <- stack(bd, cp, hh, oh, bass, stab)
samples <- render_stereo(pattern, cycles = cycles, cps = cps)
write_wav("beat_house_maelstrom_124bpm.wav", samples)
