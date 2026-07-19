#!/usr/bin/env bash
set -euo pipefail

episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
video="${1:-${episode_root}/build/silent-animatic.mp4}"
audio="${episode_root}/narration/narration_master.wav"
output="${2:-${episode_root}/build/narrated-prototype.mp4}"
mkdir -p "$(dirname "${output}")"

# Preserve the approved visual stream; add narration and silent outro padding.
ffmpeg -y -hide_banner -nostats \
  -i "${video}" -i "${audio}" \
  -map 0:v:0 -map 1:a:0 \
  -c:v copy -af "apad=whole_dur=25" -t 25 \
  -c:a aac -b:a 160k -ar 48000 \
  -movflags +faststart "${output}"

printf '%s\n' "${output}"
