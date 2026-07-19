#!/usr/bin/env bash
set -euo pipefail

episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_root="${episode_root}/frames/source"
png_root="${episode_root}/build/frames/png"
mkdir -p "${png_root}"

# These SVG sources are self-contained: all raster context is embedded as data
# URIs so the episode can be rebuilt without the external scratch tree.
for svg in "${source_root}"/faithful_auto_lp_*.svg; do
  frame="$(basename "${svg%.svg}")"
  rsvg-convert --width 1920 --height 1080 \
    --output "${png_root}/${frame}.png" "${svg}"
  convert "${png_root}/${frame}.png" \
    -background white -alpha remove -alpha off \
    "PNG24:${png_root}/${frame}.png"
done

printf '%s\n' "${png_root}"

