// beat_breakbeat_160bpm — export from maelstrom pattern to Strudel
// verified vs @strudel 1.2.6 API (see references/strudel-vs-maelstrom.md)
setcpm(160/4) // 1 cycle = 1 bar of 4/4; stack = 10 bars = 15 s
stack(
  s("bd [~ bd] bd [~ bd ~ bd]").gain(0.95).drive(1.5),
  s("sd(3,8)").gain(0.85),
  s("hh*16").degradeBy(0.3).gain(0.6).pan(0.35),
  s("ride(3,8)").sometimes(x => x.rev()).gain(0.5),
  note("[c1 ~ c1 ~][~ g1 ~ ab1]").s("sawtooth").gain(0.8).lpf(300)
)
