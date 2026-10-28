// beat_deep_house_122bpm — export from maelstrom pattern to Strudel
// verified vs @strudel 1.2.6 API (see references/strudel-vs-maelstrom.md)
setcpm(122/4) // 1 cycle = 1 bar of 4/4; stack = 8 bars ~ 15.7 s
stack(
  s("bd [~ bd] bd [~ bd]").gain(0.95),
  s("[~ cp] [~ cp]").gain(0.7),
  s("shaker*16").swing(0.35).degradeBy(0.2).gain(0.45),
  arp("<0 1 2>", note("[c4 eb4 g4][~ eb4 g4 bb4][a3 c4 eb4][~ g4 bb4 c5]"))
    .s("sawtooth").gain(0.75).echo(3, 0.375, 0.55).lpf(3000),
  note("[a1 ~ ~ g1]").s("sine").gain(0.8).lpf("<400 800 1600 400>/4"),
  s("~ hh*2 ~ hh").gain(0.5)
)
