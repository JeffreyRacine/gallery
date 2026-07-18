#!/usr/bin/env bash
set -euo pipefail

episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
frames="${episode_root}/build/frames/png"
audio="${episode_root}/narration/narration_master.wav"
output="${1:-${episode_root}/build/first_np_result.mp4}"
mkdir -p "$(dirname "${output}")"

ffmpeg -hide_banner -y \
  -loop 1 -framerate 30 -t 2.5 -i "${frames}/candidate_A_01_result.png" \
  -loop 1 -framerate 30 -t 2.3 -i "${frames}/candidate_A_08_actual_rstudio_context.png" \
  -loop 1 -framerate 30 -t 2.0 -i "${frames}/candidate_A_02_install.png" \
  -loop 1 -framerate 30 -t 3.1 -i "${frames}/candidate_A_03_load_data.png" \
  -loop 1 -framerate 30 -t 4.7 -i "${frames}/candidate_A_04_fit.png" \
  -loop 1 -framerate 30 -t 3.0 -i "${frames}/candidate_A_05_summary.png" \
  -loop 1 -framerate 30 -t 1.8 -i "${frames}/candidate_A_06_plot.png" \
  -loop 1 -framerate 30 -t 3.4 -i "${frames}/candidate_A_09_actual_rstudio_return.png" \
  -loop 1 -framerate 30 -t 3.95 -i "${frames}/candidate_A_07_outro.png" \
  -i "${audio}" \
  -filter_complex_threads 1 \
  -filter_complex \
  "[0:v]format=yuv420p[v0];\
   [1:v]format=yuv420p[v1];\
   [2:v]format=yuv420p[v2];\
   [3:v]format=yuv420p[v3];\
   [4:v]format=yuv420p[v4];\
   [5:v]format=yuv420p[v5];\
   [6:v]format=yuv420p[v6];\
   [7:v]format=yuv420p[v7];\
   [8:v]format=yuv420p[v8];\
   [v0][v1]xfade=transition=fade:duration=0.35:offset=2.15[x1];\
   [x1][v2]xfade=transition=fade:duration=0.35:offset=4.10[x2];\
   [x2][v3]xfade=transition=fade:duration=0.35:offset=5.75[x3];\
   [x3][v4]xfade=transition=fade:duration=0.35:offset=8.50[x4];\
   [x4][v5]xfade=transition=fade:duration=0.35:offset=12.85[x5];\
   [x5][v6]xfade=transition=fade:duration=0.35:offset=15.50[x6];\
   [x6][v7]xfade=transition=fade:duration=0.35:offset=16.95[x7];\
   [x7][v8]xfade=transition=fade:duration=0.35:offset=20.00,\
   fps=30,format=yuv420p[vout];\
   [9:a]atrim=start=0:end=23.95,asetpts=PTS-STARTPTS[aout]" \
  -map "[vout]" -map "[aout]" -t 23.95 \
  -c:v libx264 -preset slow -crf 18 -profile:v high -level:v 4.1 \
  -pix_fmt yuv420p -r 30 \
  -c:a aac -b:a 160k -ar 48000 \
  -movflags +faststart "${output}"

printf '%s\n' "${output}"
