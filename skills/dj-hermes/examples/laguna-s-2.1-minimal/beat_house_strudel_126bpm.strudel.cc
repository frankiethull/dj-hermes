// beat_house_strudel_126bpm — authored in Strudel (Path B, source of truth)
// Classic four-on-the-floor with a rolling sub-bass and supersaw chord pad.
// Path A (.R) is the offline-render translation via maelstrom write_wav.
// Verified vs @strudel 1.2.6; see references/strudel-vs-maelstrom.md.
setcpm(126/4) // 1 cycle = 1 bar of 4/4; 8 bars ~ 15.1 s
stack(
  s("bd*4").gain(0.9).drive(1.3),
  s("~ cp ~ cp ~ cp ~ cp").gain(0.72),
  s("hh*16").swing(0.2).gain(0.42),
  note("c2 ~ g2 ~ eb2 ~ bb2 ~").s("sine").gain(0.85).lpf(180),
  note("[c4 eb4 g4] [eb4 g4 bb4] [f4 ab4 c5] [g4 bb4 d5]")
    .s("supersaw").attack(0.15).release(0.5).gain(0.45).lpf(2400),
  s("~ ~ ~ oh").gain(0.4)
)
