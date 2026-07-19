#!/usr/bin/env bash
set -euo pipefail

mode="${1:---check}"
episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
gallery_root="$(cd "${episode_root}/../../.." && pwd)"
public_root="${gallery_root}/www/videos/italy_conditional_density"

sources=(
  "${episode_root}/analysis.R"
  "${episode_root}/captions/captions.en.vtt"
  "${episode_root}/review/narrated-prototype.mp4"
  "${episode_root}/assets/poster.png"
  "${episode_root}/transcript.txt"
)
destinations=(
  "${public_root}/italy_conditional_density.R"
  "${public_root}/italy_conditional_density.en.vtt"
  "${public_root}/italy_conditional_density.mp4"
  "${public_root}/italy_conditional_density_poster.png"
  "${public_root}/italy_conditional_density_transcript.txt"
)

case "${mode}" in
  --check)
    for i in "${!sources[@]}"; do cmp "${sources[$i]}" "${destinations[$i]}"; done
    echo "PUBLIC_BUNDLE_MATCH"
    ;;
  --write)
    mkdir -p "${public_root}"
    for i in "${!sources[@]}"; do cp "${sources[$i]}" "${destinations[$i]}"; done
    echo "PUBLIC_BUNDLE_WRITTEN"
    ;;
  *)
    echo "usage: $0 [--check|--write]" >&2
    exit 64
    ;;
esac
