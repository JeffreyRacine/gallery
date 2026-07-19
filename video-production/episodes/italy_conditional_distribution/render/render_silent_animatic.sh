#!/usr/bin/env bash
set -euo pipefail

episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
frames="${episode_root}/build/frames/png"
output="${1:-${episode_root}/build/silent-animatic.mp4}"
mkdir -p "$(dirname "${output}")"

ffmpeg -hide_banner -y \
  -loop 1 -framerate 30 -t 2.85 -i "${frames}/italy_cdist_01_result.png" \
  -loop 1 -framerate 30 -t 2.35 -i "${frames}/italy_cdist_02_rstudio_context.png" \
  -loop 1 -framerate 30 -t 3.85 -i "${frames}/italy_cdist_03_ordered_year.png" \
  -loop 1 -framerate 30 -t 4.35 -i "${frames}/italy_cdist_04_fit.png" \
  -loop 1 -framerate 30 -t 3.35 -i "${frames}/italy_cdist_05_summary.png" \
  -loop 1 -framerate 30 -t 4.55 -i "${frames}/italy_cdist_06_plot.png" \
  -loop 1 -framerate 30 -t 2.65 -i "${frames}/italy_cdist_07_rstudio_return.png" \
  -loop 1 -framerate 30 -t 3.50 -i "${frames}/italy_cdist_08_outro.png" \
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
   [v0][v1]xfade=transition=fade:duration=0.35:offset=2.50[x1];\
   [x1][v2]xfade=transition=fade:duration=0.35:offset=4.50[x2];\
   [x2][v3]xfade=transition=fade:duration=0.35:offset=8.00[x3];\
   [x3][v4]xfade=transition=fade:duration=0.35:offset=12.00[x4];\
   [x4][v5]xfade=transition=fade:duration=0.35:offset=15.00[x5];\
   [x5][v6]xfade=transition=fade:duration=0.35:offset=19.20[x6];\
   [x6][v7]xfade=transition=fade:duration=0.35:offset=21.50,\
   fps=30,format=yuv420p[vout]" \
  -map "[vout]" -t 25 -an \
  -c:v libx264 -preset medium -crf 24 -pix_fmt yuv420p \
  -movflags +faststart "${output}"

printf '%s\n' "${output}"
