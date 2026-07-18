# Reusable production framework

The framework is intentionally small and dependency-light:

- `capture_system_audio.swift` records macOS system audio with
  ScreenCaptureKit. It excludes its own process audio and does not record the
  microphone.
- `build_system_audio_capture.sh` compiles that recorder into ignored
  `framework/build/`.
- `list_visible_windows.swift` supports narrow window-inventory diagnostics.
- `embed_svg_images.py` converts relative PNG references in SVG frame sources
  into self-contained SVGs before rasterization.
- `normalize_system_audio.py` trims and two-pass normalizes a retained raw take.
- `validate_media.py` verifies codecs, dimensions, rate, pixel format, duration,
  GitHub-safe size, fast-start atom order, and complete decoding.
- `build_archive_manifest.py` inventories the external scratch campaign without
  copying raw or ephemeral state into Git.

Episode render scripts resolve all paths from their own location. Generated
frames and media go under ignored `build/`; no script contains a private
absolute path.
