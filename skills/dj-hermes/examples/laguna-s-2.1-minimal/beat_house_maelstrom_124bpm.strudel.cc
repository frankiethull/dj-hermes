// beat_house_maelstrom_124bpm — exported from maelstrom pattern to Strudel (Path B)
// Path A (maelstrom offline render) was the source of truth for this authoring pass;
// this live-coding version follows the strudel-vs-maelstrom mapping table
// (references/strudel-vs-maelstrom.md). Verified against @strudel 1.2.6.
setcpm(124/4) // 1 cycle = 1 bar of 4/4; stack = 8 bars ~ 15.5 s
stack(
  // Kick: 4/4 foundation + ghost kicks on the "&" of 2 and 4
  s("bd ~ bd ~ ~ bd ~ bd").gain(0.92).drive(1.4),
  // Clap: backbeat on 2 & 4
  s("~ cp ~ cp ~ cp ~ cp").gain(0.8),
  // Closed hats: swung 16ths, lightly crushed for grit
  s("hh*16").swing(0.22).crush(8).gain(0.45),
  // Open hat punctuation on the "&" of beat 4
  s("~ ~ ~ ~ ~ ~ ~ oh").gain(0.45).echo(3, 0.25, 0.2),
  // Walking bassline on chord tones (sub = clean low sine, lowpassed)
  note("c2 ~ eb2 ~ g2 ~ f2 ~").s("sine").gain(0.85).lpf(140),
  // Stab chords with dotted-delay echo, every bar changes chord
  note("[c4 eb4 g4] [eb4 g4 bb4] [f4 ab4 c5] [g4 bb4 d5]")
    .s("sawtooth").echo(4, 0.25, 0.35).lpf(2200).gain(0.6)
)
