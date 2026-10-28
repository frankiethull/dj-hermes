#!/usr/bin/env bash
# dj-hermes example WAV guardrail.
#
# Every skills/dj-hermes/examples/**/*.wav must be a valid RIFF WAVE whose
# duration satisfies render_policy in skills/dj-hermes/defaults.yaml
# (min_render_seconds .. max_render_seconds). A short render is the classic
# cps = bpm / 60 mistake (cycle treated as one beat instead of one bar);
# correct value is cps = bpm / 240, giving duration = cycles * 240 / bpm.
#
# Usage: bash scripts/check_examples.sh
# Exit 0 = pass, non-zero = violation (CI / agents should fail on this).

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULTS="$ROOT/skills/dj-hermes/defaults.yaml"

if [ ! -f "$DEFAULTS" ]; then
  echo "FAIL defaults.yaml not found at $DEFAULTS"
  exit 1
fi

min_s=$(awk '/min_render_seconds:/{print $2; exit}' "$DEFAULTS")
max_s=$(awk '/max_render_seconds:/{print $2; exit}' "$DEFAULTS")

if ! command -v ffprobe >/dev/null 2>&1; then
  echo "FAIL ffprobe not available; cannot verify WAV durations"
  exit 1
fi

if ! ls "$ROOT"/skills/dj-hermes/examples/*/*.wav >/dev/null 2>&1; then
  echo "FAIL no example WAVs found under skills/dj-hermes/examples/"
  exit 1
fi

fail=0
for wav in "$ROOT"/skills/dj-hermes/examples/*/*.wav; do
  rel="${wav#"$ROOT"/}"
  dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$wav" 2>/dev/null)
  if [ -z "$dur" ]; then
    echo "FAIL $rel: unreadable/invalid WAV (ffprobe returned no duration)"
    fail=1
    continue
  fi
  if ! file "$wav" | grep -q "RIFF (little-endian) data, WAVE audio"; then
    echo "FAIL $rel: not RIFF WAVE PCM data"
    fail=1
    continue
  fi
  if ! awk -v d="$dur" -v min="$min_s" -v max="$max_s" \
    'BEGIN { sig=d+0 < min+0 || d+0 > max+0 } END { exit sig }'; then
    echo "FAIL $rel: ${dur}s outside render_policy [${min_s}s, ${max_s}s] (expect cps = bpm / 240, 1 cycle = 1 bar)"
    fail=1
  else
    echo "PASS $rel: ${dur}s"
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "OK all example WAVs satisfy render_policy (>= ${min_s}s, <= ${max_s}s)"
fi
exit "$fail"
