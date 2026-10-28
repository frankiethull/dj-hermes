// beat_dub_techno_118bpm — export from maelstrom pattern to Strudel
// verified vs @strudel 1.2.6 API (see references/strudel-vs-maelstrom.md)
setcpm(118/4) // 1 cycle = 1 bar of 4/4; stack = 8 bars ~ 16.3 s
stack(
  s("bd*4").gain(0.9).drive(1.2),
  note("[c3 eb3 g3]").s("supersaw").attack(0.15).release(0.5)
    .gain(0.6).echo(5, 0.75, 0.6).lpf(1400),
  s("rim(2,8)").degradeBy(0.25).gain(0.4),
  s("conga(5,16)").gain(0.45),
  note("[c1 ~ ~ ~][~ ~ g1 ~]").s("sine").gain(0.85).lpf(120),
  s("shaker").every(2, x => x.fast(2)).gain(0.3)
)
