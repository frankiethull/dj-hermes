---
name: dj-listen
description: Quick playback helper for generated WAV files.
version: 0.1.0
author: Frankie Hull (frankiethull), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [music, playback, audio, listen, preview]
    related_skills: [dj-hermes, dj-render]
---

# dj-listen Skill

Provides quick playback of generated WAV files. Simple helper for previewing beats without leaving the terminal or opening a full player.

## When to Use

- User wants to hear a generated beat immediately
- Agent needs to play audio as part of a workflow
- Quick preview before exporting or sharing

Don't use for:
- Full-featured audio player (use system player)
- Editing audio (use DAW)
- Batch playback (use a playlist tool)

## Prerequisites

- One of: `ffplay` (ffmpeg), `aplay` (ALSA), `paplay` (PulseAudio), `afplay` (macOS), `start` (Windows)
- WAV file path from dj-render

## How to Run

```bash
# Via skill in conversation
# "dj-listen: ./beat_20240101_120000.wav"

# Direct command (auto-detects player)
dj-listen ./beat.wav
```

## Quick Reference

| Parameter | Description | Default |
|---|---|---|
| `file` | WAV file path | required |
| `player` | Force specific player (`ffplay`, `aplay`, `paplay`, `afplay`) | auto-detect |
| `volume` | Playback volume 0.0-1.0 | 1.0 |
| `loop` | Loop playback | false |

## Procedure

1. **Receive WAV path** — from user or dj-render output
2. **Verify file exists** — check path, ensure it's a valid WAV
3. **Detect player** — check available players in priority order:
   - `ffplay` (best: shows waveform, supports volume, seek)
   - `aplay` (Linux/ALSA)
   - `paplay` (Linux/PulseAudio)
   - `afplay` (macOS native)
   - `start` (Windows default association)
4. **Execute playback** — run player with file and options
5. **Return** — player PID or confirmation (non-blocking for ffplay)

### Player Commands

```bash
# ffplay (preferred)
ffplay -nodisp -autoexit -volume 100 "./beat.wav"

# aplay
aplay "./beat.wav"

# paplay
paplay --volume=65536 "./beat.wav"

# afplay (macOS)
afplay "./beat.wav"

# Windows
start "" "./beat.wav"
```

## Pitfalls

- Player availability varies by platform; auto-detect handles most cases
- ffplay `-nodisp` hides video window; `-autoexit` closes on end
- Volume scaling differs: ffplay 0-100, paplay 0-65536
- Windows `start` is non-blocking and uses default association
- Blocking vs non-blocking: ffplay/block by default, others vary
- No player found → return actionable error with install hints

## Verification

- Audio plays audibly for the file duration
- Correct player selected for platform
- Volume control works (where supported)
- Non-blocking returns control to user
- Missing file → clear error message