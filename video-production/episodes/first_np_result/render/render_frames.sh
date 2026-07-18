#!/usr/bin/env bash
set -euo pipefail

episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
production_root="$(cd "${episode_root}/../.." && pwd)"
embedded="${episode_root}/build/frames/embedded"
png_root="${episode_root}/build/frames/png"
mkdir -p "${embedded}" "${png_root}"

python3 "${production_root}/framework/embed_svg_images.py" \
  "${episode_root}/frames/source" "${embedded}"

for frame in \
  candidate_A_01_result \
  candidate_A_02_install \
  candidate_A_03_load_data \
  candidate_A_04_fit \
  candidate_A_05_summary \
  candidate_A_06_plot \
  candidate_A_07_outro \
  candidate_A_08_actual_rstudio_context \
  candidate_A_09_actual_rstudio_return
do
  rsvg-convert --width 1920 --height 1080 \
    --output "${png_root}/${frame}.png" "${embedded}/${frame}.svg"
done

printf '%s\n' "${png_root}"
