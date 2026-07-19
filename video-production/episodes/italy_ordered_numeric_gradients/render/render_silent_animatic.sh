#!/usr/bin/env bash
set -euo pipefail

episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
frames="${episode_root}/build/frames/png"
output="${1:-${episode_root}/build/silent-animatic.mp4}"
mkdir -p "$(dirname "${output}")"

ffmpeg -hide_banner -y \
  -loop 1 -framerate 30 -t 2.90 -i "${frames}/italy_gradient_01_result.png" \
  -loop 1 -framerate 30 -t 3.10 -i "${frames}/italy_gradient_02_rstudio.png" \
  -loop 1 -framerate 30 -t 4.10 -i "${frames}/italy_gradient_03_classes.png" \
  -loop 1 -framerate 30 -t 5.05 -i "${frames}/italy_gradient_04_propagation.png" \
  -loop 1 -framerate 30 -t 3.00 -i "${frames}/italy_gradient_05_fits.png" \
  -loop 1 -framerate 30 -t 3.50 -i "${frames}/italy_gradient_06_gradients.png" \
  -loop 1 -framerate 30 -t 2.75 -i "${frames}/italy_gradient_07_return.png" \
  -loop 1 -framerate 30 -t 3.25 -i "${frames}/italy_gradient_08_outro.png" \
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
   [v0][v1]xfade=transition=fade:duration=0.35:offset=2.55[x1];\
   [x1][v2]xfade=transition=fade:duration=0.35:offset=5.30[x2];\
   [x2][v3]xfade=transition=fade:duration=0.35:offset=9.05[x3];\
   [x3][v4]xfade=transition=fade:duration=0.35:offset=13.75[x4];\
   [x4][v5]xfade=transition=fade:duration=0.35:offset=16.40[x5];\
   [x5][v6]xfade=transition=fade:duration=0.35:offset=19.55[x6];\
   [x6][v7]xfade=transition=fade:duration=0.35:offset=21.95,\
   fps=30,format=yuv420p[vout]" \
  -map "[vout]" -t 25.20 -an \
  -c:v libx264 -preset medium -crf 24 -pix_fmt yuv420p \
  -movflags +faststart "${output}"

printf '%s\n' "${output}"
