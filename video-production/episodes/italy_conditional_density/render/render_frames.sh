#!/usr/bin/env bash
set -euo pipefail

episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
production_root="$(cd "${episode_root}/../.." && pwd)"
embedded="${episode_root}/build/frames/embedded"
png_root="${episode_root}/build/frames/png"
mkdir -p "${embedded}" "${png_root}"

python3 "${production_root}/framework/embed_svg_images.py" \
  "${episode_root}/frames/source" "${embedded}"

for svg in "${embedded}"/italy_cdens_*.svg; do
  frame="$(basename "${svg%.svg}")"
  rsvg-convert --width 1920 --height 1080 \
    --output "${png_root}/${frame}.png" "${svg}"
  convert "${png_root}/${frame}.png" \
    -background white -alpha remove -alpha off \
    "PNG24:${png_root}/${frame}.png"
done

printf '%s\n' "${png_root}"
