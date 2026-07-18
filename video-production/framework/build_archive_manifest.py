#!/usr/bin/env python3
"""Inventory every external campaign artifact without copying it into Git."""

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


def retention(path: str, copied: dict[str, str]) -> tuple[str, str]:
    if path in copied:
        return "canonical-copy-in-gallery", copied[path]
    lower = path.lower()
    if path.startswith("captures/raw/"):
        return "raw-capture-external", "-"
    if "rejected" in lower:
        return "rejected-take-external", "-"
    if path.startswith(("Rlib/", "tarballs/")):
        return "installed-environment-external", "-"
    if path.startswith(("proof/rstudio_", "proof/faster_whisper_models/", "proof/hf_cache/")):
        return "ephemeral-profile-or-model-external", "-"
    if "/embedded/" in path or "/png/" in path or path.endswith(".DS_Store"):
        return "generated-cache-external", "-"
    return "campaign-evidence-external", "-"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("scratch_root", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("copied_map", type=Path)
    args = parser.parse_args()

    with args.copied_map.open(newline="", encoding="utf-8") as stream:
        copied = {
            row["scratch_path"]: row["gallery_destination"]
            for row in csv.DictReader(stream, delimiter="\t")
        }
    paths = sorted(path for path in args.scratch_root.rglob("*") if path.is_file())
    user_component = Path.home().name
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream, delimiter="\t", lineterminator="\n")
        writer.writerow(
            ["scratch_path", "bytes", "sha256", "retention", "gallery_destination"]
        )
        for path in paths:
            relative = path.relative_to(args.scratch_root).as_posix()
            category, destination = retention(relative, copied)
            display_path = relative.replace(user_component, "<user>")
            writer.writerow(
                [display_path, path.stat().st_size, sha256(path), category, destination]
            )


if __name__ == "__main__":
    main()
