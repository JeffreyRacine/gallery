#!/usr/bin/env bash
set -euo pipefail

episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
video="${1:-${episode_root}/build/silent-animatic.mp4}"
audio="${episode_root}/narration/narration_master.wav"
output="${2:-${episode_root}/build/narrated-prototype.mp4}"
mkdir -p "$(dirname "${output}")"

# Extend the approved static-frame grammar uniformly from 25 to 26.5 seconds.
# Cove's corrected continuous narration is neither spliced nor time-stretched.
ffmpeg -y -hide_banner -nostats \
  -i "${video}" -i "${audio}" \
  -filter_complex "[0:v]setpts=1.06*PTS,fps=30,format=yuv420p[vout]" \
  -map "[vout]" -map 1:a:0 \
  -c:v libx264 -preset medium -crf 24 \
  -c:a aac -b:a 160k -ar 48000 \
  -t 26.5 -movflags +faststart "${output}"

printf '%s\n' "${output}"
