#!/usr/bin/env python3
"""
Inspect the dedicated particle texture library for this repository.

Usage:
  python skills/godot-particle-vfx-director/scripts/texture_library.py inventory
  python skills/godot-particle-vfx-director/scripts/texture_library.py inspect texture/alpha/slash_01_a.png
"""

from __future__ import annotations

import argparse
import json
from collections import Counter, defaultdict
from pathlib import Path


IMAGE_EXTENSIONS = {".png", ".tga", ".webp", ".jpg", ".jpeg"}


def default_texture_root() -> Path:
    return Path(__file__).resolve().parents[3] / "texture"


def iter_texture_files(root: Path) -> list[Path]:
    return sorted(
        path for path in root.rglob("*")
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    )


def token_family(path: Path) -> str:
    stem = path.stem.lower()
    for family in [
        "slash", "trace", "scratch", "spark", "smoke", "dirt", "scorch",
        "fire", "flame", "light", "flare", "magic", "symbol", "twirl",
        "window", "circle", "effect", "muzzle", "star", "cloud", "explosion",
        "charge", "vortex", "electric", "wavy", "impact", "blood",
    ]:
        if family in stem:
            return family
    return "misc"


def classify_role(path: Path) -> str:
    stem = path.stem.lower()
    parent = path.parent.name.lower()
    if "flipbooks" in parent:
        return "flipbook"
    if any(token in stem for token in ["slash", "trace", "scratch"]):
        return "directional"
    if any(token in stem for token in ["spark", "star", "muzzle", "impact"]):
        return "burst"
    if any(token in stem for token in ["smoke", "cloud", "dirt", "scorch"]):
        return "residue"
    if any(token in stem for token in ["circle", "light", "flare", "magic", "symbol", "twirl", "window", "electric", "charge", "vortex", "wavy"]):
        return "core-or-accent"
    if any(token in stem for token in ["fire", "flame", "explosion"]):
        return "elemental"
    return "general"


def record_for(path: Path, root: Path) -> dict[str, object]:
    rel = path.relative_to(root).as_posix()
    return {
        "path": rel,
        "folder": path.parent.name,
        "family": token_family(path),
        "role": classify_role(path),
        "extension": path.suffix.lower(),
        "size_bytes": path.stat().st_size,
    }


def inventory(root: Path, as_json: bool) -> int:
    files = iter_texture_files(root)
    records = [record_for(path, root) for path in files]
    if as_json:
        print(json.dumps(records, indent=2))
        return 0

    by_folder: dict[str, list[dict[str, object]]] = defaultdict(list)
    for record in records:
        by_folder[str(record["folder"])].append(record)

    print("| Folder | Count | Top families | Notes |")
    print("| --- | ---: | --- | --- |")
    for folder, folder_records in sorted(by_folder.items()):
        family_counts = Counter(str(record["family"]) for record in folder_records)
        families = ", ".join(name for name, _ in family_counts.most_common(6))
        note = {
            "alpha": "tintable alpha masks",
            "opague": "pre-colored sprites",
            "predrawn": "authored atlases and beats",
            "flipbooks": "animated texture sheets",
        }.get(folder, "-")
        print(f"| {folder} | {len(folder_records)} | {families or '-'} | {note} |")
    return 0


def inspect(path: Path, root: Path) -> int:
    if not path.is_absolute():
        path = (Path.cwd() / path).resolve()
    root = root.resolve()

    if not path.exists():
        print(f"[error] Texture not found: {path}")
        return 1

    record = record_for(path, root)
    print(f"Path: {record['path']}")
    print(f"Folder: {record['folder']}")
    print(f"Family: {record['family']}")
    print(f"Role: {record['role']}")
    print(f"Extension: {record['extension']}")
    print(f"Size: {record['size_bytes']} bytes")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Inspect the particle texture library.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    inventory_parser = subparsers.add_parser("inventory", help="List texture library summary.")
    inventory_parser.add_argument("--root", type=Path, default=default_texture_root())
    inventory_parser.add_argument("--json", action="store_true")

    inspect_parser = subparsers.add_parser("inspect", help="Inspect one texture.")
    inspect_parser.add_argument("texture", type=Path)
    inspect_parser.add_argument("--root", type=Path, default=default_texture_root())

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if args.command == "inventory":
        return inventory(args.root, args.json)
    if args.command == "inspect":
        return inspect(args.texture, args.root)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
