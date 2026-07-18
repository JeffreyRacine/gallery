#!/usr/bin/env bash
set -euo pipefail

mode="${1:---check}"
episode_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
gallery_root="$(cd "${episode_root}/../../.." && pwd)"
public_root="${gallery_root}/www/videos/first_np_result"

sources=(
  "${episode_root}/analysis.R"
  "${episode_root}/captions/captions.en.vtt"
  "${episode_root}/build/first_np_result.mp4"
  "${episode_root}/assets/poster.png"
  "${episode_root}/transcript.txt"
)
destinations=(
  "${public_root}/first_np_result.R"
  "${public_root}/first_np_result.en.vtt"
  "${public_root}/first_np_result.mp4"
  "${public_root}/first_np_result_poster.png"
  "${public_root}/first_np_result_transcript.txt"
)

case "${mode}" in
  --check)
    for i in "${!sources[@]}"; do
      cmp "${sources[$i]}" "${destinations[$i]}"
    done
    echo "PUBLIC_BUNDLE_MATCH"
    ;;
  --write)
    mkdir -p "${public_root}"
    for i in "${!sources[@]}"; do
      cp "${sources[$i]}" "${destinations[$i]}"
    done
    echo "PUBLIC_BUNDLE_WRITTEN"
    ;;
  *)
    echo "usage: $0 [--check|--write]" >&2
    exit 64
    ;;
esac
