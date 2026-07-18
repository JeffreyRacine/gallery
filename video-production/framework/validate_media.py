#!/usr/bin/env python3
"""Validate the Gallery MP4 delivery contract and full decode."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("media", type=Path)
    parser.add_argument("--duration", type=float, required=True)
    parser.add_argument("--silent", action="store_true")
    args = parser.parse_args()

    probe = subprocess.run(
        [
            "ffprobe", "-v", "error", "-show_streams", "-show_format",
            "-of", "json", str(args.media),
        ],
        check=True,
        text=True,
        capture_output=True,
    )
    metadata = json.loads(probe.stdout)
    streams = metadata["streams"]
    video = next(stream for stream in streams if stream["codec_type"] == "video")
    audio = next(
        (stream for stream in streams if stream["codec_type"] == "audio"), None
    )
    duration = float(metadata["format"]["duration"])
    size = args.media.stat().st_size
    payload = args.media.read_bytes()
    atoms = {name: payload.find(name.encode("ascii")) for name in ("ftyp", "moov", "mdat")}

    checks = {
        "duration": abs(duration - args.duration) <= 0.04,
        "video_codec": video["codec_name"] == "h264",
        "dimensions": (video["width"], video["height"]) == (1920, 1080),
        "frame_rate": video["r_frame_rate"] == "30/1",
        "pixel_format": video["pix_fmt"] == "yuv420p",
        "audio_contract": audio is None if args.silent else (
            audio is not None
            and audio["codec_name"] == "aac"
            and audio["sample_rate"] == "48000"
        ),
        "github_safe_size": size < 50 * 1024 * 1024,
        "faststart": 0 <= atoms["ftyp"] < atoms["moov"] < atoms["mdat"],
    }
    subprocess.run(
        ["ffmpeg", "-v", "error", "-i", str(args.media), "-f", "null", "-"],
        check=True,
    )
    result = {
        "path": str(args.media),
        "duration": duration,
        "bytes": size,
        "atoms": atoms,
        "checks": checks,
        "full_decode": True,
    }
    print(json.dumps(result, indent=2))
    if not all(checks.values()):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
