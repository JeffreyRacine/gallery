#!/usr/bin/env python3
"""Write sizes and SHA-256 values for version-controlled production sources."""

from __future__ import annotations

import argparse
import csv
import hashlib
from pathlib import Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source_root", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    output = args.output.resolve()
    paths = sorted(
        path
        for path in args.source_root.rglob("*")
        if path.is_file()
        and "build" not in path.relative_to(args.source_root).parts
        and path.resolve() != output
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream, delimiter="\t", lineterminator="\n")
        writer.writerow(["path", "bytes", "sha256"])
        for path in paths:
            writer.writerow(
                [
                    path.relative_to(args.source_root).as_posix(),
                    path.stat().st_size,
                    sha256(path),
                ]
            )


if __name__ == "__main__":
    main()
