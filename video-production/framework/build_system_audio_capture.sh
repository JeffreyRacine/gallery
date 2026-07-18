#!/usr/bin/env bash
set -euo pipefail

framework_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "${framework_root}/build"

/usr/bin/swiftc \
  -parse-as-library \
  "${framework_root}/capture_system_audio.swift" \
  -o "${framework_root}/build/capture_system_audio" \
  -framework ScreenCaptureKit \
  -framework AVFoundation \
  -framework CoreMedia

printf '%s\n' "${framework_root}/build/capture_system_audio"
