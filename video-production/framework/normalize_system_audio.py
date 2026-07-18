#!/usr/bin/env python3
"""Trim and two-pass EBU R128-normalize a system-audio capture."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path


def run(command: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, check=True, text=True, capture_output=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--trim-start", type=float, required=True)
    parser.add_argument("--trim-end", type=float, required=True)
    parser.add_argument("--proof-prefix", type=Path)
    args = parser.parse_args()

    prefix = (
        f"atrim=start={args.trim_start}:end={args.trim_end},"
        "asetpts=PTS-STARTPTS,pan=mono|c0=0.5*c0+0.5*c1"
    )
    first_filter = (
        f"{prefix},loudnorm=I=-16:TP=-1.5:LRA=7:print_format=json"
    )
    first = run(
        [
            "ffmpeg", "-hide_banner", "-nostats", "-i", str(args.input),
            "-af", first_filter, "-f", "null", "-",
        ]
    )
    match = re.search(r"\{\s*\"input_i\".*?\}", first.stderr, re.DOTALL)
    if not match:
        raise SystemExit("Unable to parse loudnorm first-pass measurements")
    measured = json.loads(match.group(0))

    second_filter = (
        f"{prefix},loudnorm=I=-16:TP=-1.5:LRA=7:"
        f"measured_I={measured['input_i']}:"
        f"measured_TP={measured['input_tp']}:"
        f"measured_LRA={measured['input_lra']}:"
        f"measured_thresh={measured['input_thresh']}:"
        f"offset={measured['target_offset']}:linear=true:print_format=summary"
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    second = run(
        [
            "ffmpeg", "-y", "-hide_banner", "-nostats", "-i", str(args.input),
            "-af", second_filter, "-ar", "48000", "-ac", "1", "-c:a",
            "pcm_s16le", str(args.output),
        ]
    )

    if args.proof_prefix:
        args.proof_prefix.parent.mkdir(parents=True, exist_ok=True)
        args.proof_prefix.with_suffix(".pass1.log").write_text(
            first.stderr, encoding="utf-8"
        )
        args.proof_prefix.with_suffix(".pass2.log").write_text(
            second.stderr, encoding="utf-8"
        )
    print(args.output)


if __name__ == "__main__":
    main()
