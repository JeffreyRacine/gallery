#!/usr/bin/env bash
set -euo pipefail

episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
video="${1:-${episode_root}/build/silent-animatic.mp4}"
audio="${episode_root}/narration/narration_master.wav"
output="${2:-${episode_root}/build/narrated-prototype.mp4}"
duration=29
ratio="$(awk -v target="${duration}" 'BEGIN { printf "%.9f", target / 23.066667 }')"
mkdir -p "$(dirname "${output}")"

# Extend the approved static-frame grammar uniformly to the natural continuous
# Cove delivery. Never time-stretch or splice narration.
ffmpeg -y -hide_banner -nostats \
  -i "${video}" -i "${audio}" \
  -filter_complex \
  "[0:v]setpts=${ratio}*PTS,fps=30,format=yuv420p[v];[1:a]apad=whole_dur=${duration}[a]" \
  -map "[v]" -map "[a]" -t "${duration}" \
  -c:v libx264 -preset medium -crf 24 -pix_fmt yuv420p \
  -c:a aac -b:a 160k -ar 48000 \
  -movflags +faststart "${output}"

printf '%s\n' "${output}"
