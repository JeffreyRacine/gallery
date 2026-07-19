#!/usr/bin/env bash
set -euo pipefail

episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
frames="${episode_root}/build/frames/png"
output="${1:-${episode_root}/build/silent-animatic.mp4}"
mkdir -p "$(dirname "${output}")"

ffmpeg -hide_banner -y \
  -loop 1 -framerate 30 -t 3.05 -i "${frames}/faithful_auto_lp_01_result.png" \
  -loop 1 -framerate 30 -t 3.05 -i "${frames}/faithful_auto_lp_02_rstudio.png" \
  -loop 1 -framerate 30 -t 4.10 -i "${frames}/faithful_auto_lp_03_contrast.png" \
  -loop 1 -framerate 30 -t 4.85 -i "${frames}/faithful_auto_lp_04_selection.png" \
  -loop 1 -framerate 30 -t 4.80 -i "${frames}/faithful_auto_lp_05_derivatives.png" \
  -loop 1 -framerate 30 -t 5.15 -i "${frames}/faithful_auto_lp_06_bands.png" \
  -loop 1 -framerate 30 -t 3.10 -i "${frames}/faithful_auto_lp_07_return.png" \
  -loop 1 -framerate 30 -t 3.25 -i "${frames}/faithful_auto_lp_08_outro.png" \
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
   [v0][v1]xfade=transition=fade:duration=0.35:offset=2.70[x1];\
   [x1][v2]xfade=transition=fade:duration=0.35:offset=5.40[x2];\
   [x2][v3]xfade=transition=fade:duration=0.35:offset=9.15[x3];\
   [x3][v4]xfade=transition=fade:duration=0.35:offset=13.65[x4];\
   [x4][v5]xfade=transition=fade:duration=0.35:offset=18.10[x5];\
   [x5][v6]xfade=transition=fade:duration=0.35:offset=22.90[x6];\
   [x6][v7]xfade=transition=fade:duration=0.35:offset=25.65,\
   fps=30,format=yuv420p[vout]" \
  -map "[vout]" -t 28.566667 -an \
  -c:v libx264 -preset medium -crf 24 -pix_fmt yuv420p \
  -movflags +faststart "${output}"

printf '%s\n' "${output}"

