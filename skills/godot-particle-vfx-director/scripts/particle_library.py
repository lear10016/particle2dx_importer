#!/usr/bin/env python3
"""
Inspect the local particle reference library for this repository.

Usage:
  python skills/godot-particle-vfx-director/scripts/particle_library.py inventory
  python skills/godot-particle-vfx-director/scripts/particle_library.py inspect particle/flame.tscn
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path


PARTICLE_TYPES = {
    "GPUParticles2D",
    "GPUParticles3D",
    "CPUParticles2D",
    "CPUParticles3D",
}

SCENE_HEADER_RE = re.compile(r"^\[(.+?)\]\s*$", re.M)
NODE_HEADER_RE = re.compile(r'node name="(?P<name>[^"]+)" type="(?P<type>[^"]+)"')
SUBRESOURCE_TYPE_RE = re.compile(r'type="([^"]+)"')
TEXTURE_RE = re.compile(r'\[ext_resource type="Texture2D".*? path="([^"]+)"')

PRIMARY_KEYS = [
    "amount",
    "lifetime",
    "one_shot",
    "explosiveness",
    "randomness",
    "preprocess",
    "fixed_fps",
    "texture",
    "process_material",
    "material",
]


def default_particle_root() -> Path:
    return Path(__file__).resolve().parents[3] / "particle"


def iter_sections(text: str) -> list[tuple[str, str]]:
    matches = list(SCENE_HEADER_RE.finditer(text))
    sections: list[tuple[str, str]] = []
    for index, match in enumerate(matches):
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        header = match.group(1).strip()
        body = text[start:end].strip()
        sections.append((header, body))
    return sections


def parse_properties(body: str) -> dict[str, str]:
    props: dict[str, str] = {}
    for raw_line in body.splitlines():
        line = raw_line.strip()
        if not line or " = " not in line:
            continue
        key, value = line.split(" = ", 1)
        props[key.strip()] = value.strip()
    return props


def parse_scene(path: Path) -> dict[str, object]:
    text = path.read_text(encoding="utf-8")
    sections = iter_sections(text)

    node_sections: list[dict[str, object]] = []
    subresources: Counter[str] = Counter()

    for header, body in sections:
        if header.startswith("node "):
            node_match = NODE_HEADER_RE.search(header)
            if not node_match:
                continue
            node_sections.append(
                {
                    "name": node_match.group("name"),
                    "type": node_match.group("type"),
                    "properties": parse_properties(body),
                }
            )
        elif header.startswith("sub_resource "):
            sub_match = SUBRESOURCE_TYPE_RE.search(header)
            if sub_match:
                subresources[sub_match.group(1)] += 1

    particle_nodes = [node for node in node_sections if node["type"] in PARTICLE_TYPES]
    root_node = node_sections[0] if node_sections else None
    primary_particle = particle_nodes[0] if particle_nodes else None
    textures = sorted(set(TEXTURE_RE.findall(text)))
    primary_props = dict(primary_particle["properties"]) if primary_particle else {}

    return {
        "scene": path.as_posix(),
        "root_name": root_node["name"] if root_node else "",
        "root_type": root_node["type"] if root_node else "",
        "particle_node_count": len(particle_nodes),
        "particle_nodes": [
            {"name": node["name"], "type": node["type"]} for node in particle_nodes
        ],
        "primary_particle_type": primary_particle["type"] if primary_particle else "",
        "uses_particle_shader": "shader_type particles;" in text,
        "uses_canvas_material": "CanvasItemMaterial" in text,
        "has_additive_blend": "blend_mode = 1" in text,
        "textures": textures,
        "subresources": dict(subresources),
        "primary_properties": {
            key: primary_props[key] for key in PRIMARY_KEYS if key in primary_props
        },
    }


def inspect_scene(path: Path) -> int:
    if not path.exists():
        print(f"[error] Scene not found: {path}", file=sys.stderr)
        return 1

    record = parse_scene(path)
    print(f"Scene: {record['scene']}")
    print(f"Root: {record['root_name']} ({record['root_type']})")
    print(
        "Particle nodes: "
        + ", ".join(
            f"{node['name']} ({node['type']})" for node in record["particle_nodes"]
        )
    )
    print(f"Uses custom particles shader: {record['uses_particle_shader']}")
    print(f"Uses CanvasItemMaterial: {record['uses_canvas_material']}")
    print(f"Has additive blend somewhere: {record['has_additive_blend']}")
    print("Textures:")
    for texture in record["textures"]:
        print(f"  - {texture}")
    if not record["textures"]:
        print("  - none")

    print("Sub-resources:")
    for name, count in sorted(record["subresources"].items()):
        print(f"  - {name}: {count}")

    print("Primary particle properties:")
    for key, value in record["primary_properties"].items():
        print(f"  - {key}: {value}")
    if not record["primary_properties"]:
        print("  - none")
    return 0


def inventory(root: Path, as_json: bool) -> int:
    if not root.exists():
        print(f"[error] Particle library folder not found: {root}", file=sys.stderr)
        return 1

    records = [parse_scene(path) for path in sorted(root.glob("*.tscn"))]
    if as_json:
        print(json.dumps(records, indent=2))
        return 0

    print("| Scene | Primary particle | Layers | Shader | Additive | Texture hints |")
    print("| --- | --- | ---: | --- | --- | --- |")
    for record in records:
        textures = [Path(texture).name for texture in record["textures"][:2]]
        texture_hint = ", ".join(textures) if textures else "-"
        print(
            "| {scene} | {ptype} | {layers} | {shader} | {additive} | {textures} |".format(
                scene=Path(str(record["scene"])).name,
                ptype=record["primary_particle_type"] or record["root_type"],
                layers=record["particle_node_count"],
                shader="yes" if record["uses_particle_shader"] else "no",
                additive="yes" if record["has_additive_blend"] else "no",
                textures=texture_hint,
            )
        )
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Inspect local particle reference scenes.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    inventory_parser = subparsers.add_parser("inventory", help="List particle scenes.")
    inventory_parser.add_argument(
        "--root",
        type=Path,
        default=default_particle_root(),
        help="Folder containing .tscn particle scenes.",
    )
    inventory_parser.add_argument(
        "--json",
        action="store_true",
        help="Emit JSON instead of a markdown table.",
    )

    inspect_parser = subparsers.add_parser(
        "inspect", help="Show details for one particle scene."
    )
    inspect_parser.add_argument("scene", type=Path, help="Path to a .tscn file.")

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if args.command == "inventory":
        return inventory(args.root, args.json)
    if args.command == "inspect":
        return inspect_scene(args.scene)

    parser.print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
