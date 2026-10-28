// beat_smoky_dub_76bpm — generated VERBATIM by Rhythmancer 3B GGUF
// (Nanite-Labs/nanites-rhythmancer-3b-generator-gguf, Q4_K_M,
//  temp 0.7, top_p 0.9, repeat_penalty 1.1, seed-free — 2026-10-27)
// llama-cli -m rhythmancer-Q4_K_M.gguf -no-cnv -f prompt.txt -n 400
// NOTE: outputs occasionally carry syntax defects (did for techno:
// unbalanced paren, truncated bank name) — validate before shipping.
stack(
  s("~ ~ bd ~").bank("RolandTR808").gain(0.92),
  s("~ ~ rim ~").orbit(1).room(0.43).sometimes(x => x.rev()),
  s("hh*8").gain(0.57).every(4, x => x.fast(2)),
  note("~ bb2 f2 d2 ab2 a2 d2").sound("triangle").lpf(691)
).cpm(76/4)
