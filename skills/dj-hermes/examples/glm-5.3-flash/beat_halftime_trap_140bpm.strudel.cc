// beat_halftime_trap_140bpm — export from maelstrom pattern to Strudel
// verified vs @strudel 1.2.6 API (see references/strudel-vs-maelstrom.md)
setcpm(140/4) // 1 cycle = 1 bar of 4/4; stack = 9 bars ~ 15.4 s
stack(
  s("bd [~ ~ ~ ~] [~ ~ bd] ~").gain(1),
  note("[a1 a1 ~ ~][~ g1 ~ f1][a1 ~ bb1 ~][~ ~ g1 ~]")
    .s("sine").gain(0.9).echo(2, 0.25, 0.4).lpf(120),
  s("[~ ~ ~ cp]").gain(0.8),
  s("hh*4 hh*8").fast(2).degradeBy(0.2).gain(0.55).pan(0.55),
  s("shaker*8").sometimes(x => x.early(0.012)).gain(0.3),
  s("[~ ~ ~ ~][~ ~ tom ~]").gain(0.5)
)
