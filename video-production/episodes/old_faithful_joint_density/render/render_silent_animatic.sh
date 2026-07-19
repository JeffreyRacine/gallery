#!/usr/bin/env bash
set -euo pipefail

episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
frames="${episode_root}/build/frames/png"
output="${1:-${episode_root}/build/silent-animatic.mp4}"
mkdir -p "$(dirname "${output}")"

ffmpeg -hide_banner -y \
  -loop 1 -framerate 30 -t 2.85 -i "${frames}/faithful_udens_01_result.png" \
  -loop 1 -framerate 30 -t 2.65 -i "${frames}/faithful_udens_02_rstudio.png" \
  -loop 1 -framerate 30 -t 3.70 -i "${frames}/faithful_udens_03_data.png" \
  -loop 1 -framerate 30 -t 4.60 -i "${frames}/faithful_udens_04_fit.png" \
  -loop 1 -framerate 30 -t 5.10 -i "${frames}/faithful_udens_05_viewer.png" \
  -loop 1 -framerate 30 -t 3.00 -i "${frames}/faithful_udens_06_return.png" \
  -loop 1 -framerate 30 -t 3.60 -i "${frames}/faithful_udens_07_outro.png" \
  -filter_complex_threads 1 \
  -filter_complex \
  "[0:v]format=yuv420p[v0];\
   [1:v]format=yuv420p[v1];\
   [2:v]format=yuv420p[v2];\
   [3:v]format=yuv420p[v3];\
   [4:v]format=yuv420p[v4];\
   [5:v]format=yuv420p[v5];\
   [6:v]format=yuv420p[v6];\
   [v0][v1]xfade=transition=fade:duration=0.35:offset=2.50[x1];\
   [x1][v2]xfade=transition=fade:duration=0.35:offset=4.80[x2];\
   [x2][v3]xfade=transition=fade:duration=0.35:offset=8.15[x3];\
   [x3][v4]xfade=transition=fade:duration=0.35:offset=12.40[x4];\
   [x4][v5]xfade=transition=fade:duration=0.35:offset=17.15[x5];\
   [x5][v6]xfade=transition=fade:duration=0.35:offset=19.80,\
   fps=30,format=yuv420p[vout]" \
  -map "[vout]" -t 23.066667 -an \
  -c:v libx264 -preset medium -crf 24 -pix_fmt yuv420p \
  -movflags +faststart "${output}"

printf '%s\n' "${output}"
