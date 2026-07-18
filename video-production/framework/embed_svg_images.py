#!/usr/bin/env python3
"""Embed relative PNG references in SVG frames for deterministic rendering."""

from __future__ import annotations

import argparse
import base64
import re
from pathlib import Path
from urllib.parse import unquote, urlparse


REFERENCE = re.compile(r'href="([^\"]+\.png)"')


def image_path(reference: str, frame_path: Path) -> Path:
    if reference.startswith("file://"):
        return Path(unquote(urlparse(reference).path))
    return (frame_path.parent / reference).resolve()


def embed_frame(frame_path: Path, output_path: Path) -> None:
    source = frame_path.read_text(encoding="utf-8")

    def replace(match: re.Match[str]) -> str:
        reference = match.group(1)
        path = image_path(reference, frame_path)
        if not path.is_file():
            raise FileNotFoundError(f"Missing frame image: {path}")
        encoded = base64.b64encode(path.read_bytes()).decode("ascii")
        return f'href="data:image/png;base64,{encoded}"'

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(REFERENCE.sub(replace, source), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source_dir", type=Path)
    parser.add_argument("output_dir", type=Path)
    args = parser.parse_args()

    frames = sorted(args.source_dir.glob("*.svg"))
    if not frames:
        raise SystemExit(f"No SVG frames found under {args.source_dir}")
    for frame in frames:
        embed_frame(frame, args.output_dir / frame.name)


if __name__ == "__main__":
    main()
