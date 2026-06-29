#!/usr/bin/env python3
"""
Generate a structured particle knowledge base from local particle scenes.

Usage:
  python skills/godot-particle-vfx-director/scripts/distill_particle_knowledge.py
  python skills/godot-particle-vfx-director/scripts/distill_particle_knowledge.py --root particle --output-dir skills/godot-particle-vfx-director/references
"""

from __future__ import annotations

import argparse
import json
import math
import re
from collections import Counter, defaultdict
from datetime import UTC, datetime
from pathlib import Path

from particle_library import PARTICLE_TYPES, default_particle_root, iter_sections, parse_properties


SECTION_ID_RE = re.compile(r'id="([^"]+)"')
SECTION_TYPE_RE = re.compile(r'type="([^"]+)"')
NODE_NAME_RE = re.compile(r'name="([^"]+)"')
TEXTURE_RE = re.compile(r'\[ext_resource type="Texture2D".*? path="([^"]+)"')
SUBRESOURCE_REF_RE = re.compile(r'SubResource\("([^"]+)"\)')
NUMBER_RE = re.compile(r"-?\d+(?:\.\d+)?")

OUTPUT_JSON = "particle-knowledge.json"
OUTPUT_MD = "particle-knowledge.md"

EMISSION_SHAPES = {
    0: "point",
    1: "sphere",
    2: "sphere_surface",
    3: "box",
    4: "points",
    5: "directed_points",
    6: "ring",
}

TOKEN_NORMALIZATION = {
    "glaxy": "galaxy",
    "srtar": "star",
    "leef": "leaf",
}

PRIMARY_FAMILY_RULES = [
    ("trail", {"trail", "ribbon", "ray", "blade"}),
    ("impact", {"boom", "battle", "explosion", "meteor"}),
    ("water", {"water", "wave", "ripple", "whirlpool"}),
    ("atmosphere", {"smoke", "fog", "rain", "snow", "firefly", "fountain", "leaf"}),
    ("reward", {"gold", "upgrade", "star"}),
    ("tech", {"technology", "electro", "loading"}),
    ("fire", {"flame", "fire"}),
    ("magic", {"galaxy", "blink", "sun", "mask"}),
    ("aura", {"glow", "light", "radial", "ring"}),
]

TOKEN_TAGS = {
    "trail": {"directional", "slash"},
    "ribbon": {"directional", "arc"},
    "ray": {"directional", "beam"},
    "blade": {"directional", "electric"},
    "boom": {"impact", "burst"},
    "battle": {"impact", "burst"},
    "explosion": {"impact", "burst"},
    "meteor": {"impact", "directional"},
    "glow": {"energy", "light"},
    "light": {"energy", "light"},
    "radial": {"energy", "pulse"},
    "ring": {"energy", "ring"},
    "wave": {"ring", "pulse"},
    "ripple": {"ring", "water"},
    "water": {"water"},
    "whirlpool": {"water", "vortex", "magic"},
    "smoke": {"smoke", "soft"},
    "fog": {"smoke", "soft"},
    "rain": {"water", "ambient"},
    "snow": {"ambient", "soft"},
    "firefly": {"ambient", "sparkle"},
    "fountain": {"ambient", "water"},
    "gold": {"reward", "sparkle"},
    "upgrade": {"reward", "energy"},
    "star": {"reward", "sparkle"},
    "technology": {"tech", "magic"},
    "electro": {"electric", "tech"},
    "loading": {"tech", "ui"},
    "galaxy": {"magic", "orbit"},
    "blink": {"magic", "flash"},
    "sun": {"magic", "energy"},
    "mask": {"magic", "organic"},
    "flame": {"fire", "energy"},
    "leaf": {"nature", "ambient"},
}

ROLE_COMPLEMENTS = {
    "directional-trail": ["impact-burst", "core-glow", "soft-residue"],
    "impact-burst": ["ring-accent", "soft-residue", "sparkle-breakup"],
    "core-glow": ["ring-accent", "sparkle-breakup", "orbiting-accent"],
    "vortex-core": ["orbiting-accent", "core-glow", "ring-accent"],
    "ambient-loop": ["core-glow", "soft-residue"],
    "reward-accent": ["core-glow", "sparkle-breakup"],
    "water-accent": ["ring-accent", "soft-residue"],
}


def normalize_token(token: str) -> str:
    return TOKEN_NORMALIZATION.get(token, token)


def extract_tokens(*parts: str) -> list[str]:
    tokens: list[str] = []
    for part in parts:
        stem = Path(part).stem.lower()
        for token in re.findall(r"[a-z]+", stem):
            token = normalize_token(token)
            if token and token not in tokens:
                tokens.append(token)
    return tokens


def parse_bool(value: str | None) -> bool | None:
    if value is None:
        return None
    if value == "true":
        return True
    if value == "false":
        return False
    return None


def parse_scalar(value: str | None) -> float | int | bool | None:
    if value is None:
        return None
    bool_value = parse_bool(value)
    if bool_value is not None:
        return bool_value
    if re.fullmatch(r"-?\d+", value):
        return int(value)
    if re.fullmatch(r"-?\d+(?:\.\d+)?", value):
        return float(value)
    return None


def parse_number_list(value: str | None) -> list[float]:
    if value is None:
        return []
    return [float(match) for match in NUMBER_RE.findall(value)]


def parse_vector(value: str | None) -> list[float] | None:
    if value is None or not value.startswith(("Vector2(", "Vector3(", "Vector4(")):
        return None
    numbers = parse_number_list(value)
    return numbers if numbers else None


def subresource_ref(value: str | None) -> str | None:
    if value is None:
        return None
    match = SUBRESOURCE_REF_RE.search(value)
    return match.group(1) if match else None


def vector_magnitude(vector: list[float] | None) -> float:
    if not vector:
        return 0.0
    return math.sqrt(sum(component * component for component in vector))


def max_abs(values: list[float]) -> float:
    return max((abs(v) for v in values), default=0.0)


def dominant_axis(vector: list[float] | None) -> str | None:
    if not vector:
        return None
    axes = ["x", "y", "z", "w"]
    best_index = max(range(len(vector)), key=lambda index: abs(vector[index]))
    best_value = vector[best_index]
    if abs(best_value) < 0.1:
        return None
    return axes[best_index]


def classify_amount_band(amount: float | int | bool | None) -> str:
    if not isinstance(amount, (int, float)) or isinstance(amount, bool):
        return "unknown"
    if amount <= 16:
        return "sparse"
    if amount <= 48:
        return "light"
    if amount <= 120:
        return "medium"
    if amount <= 300:
        return "dense"
    return "swarm"


def classify_lifetime_band(lifetime: float | int | bool | None) -> str:
    if not isinstance(lifetime, (int, float)) or isinstance(lifetime, bool):
        return "unknown"
    if lifetime <= 0.15:
        return "instant"
    if lifetime <= 0.75:
        return "short"
    if lifetime <= 2.0:
        return "medium"
    if lifetime <= 6.0:
        return "long"
    return "persistent"


def classify_velocity_band(peak_velocity: float | None, motion: set[str]) -> str:
    if "radius-orbit" in motion:
        return "orbit-driven"
    if peak_velocity is None:
        return "unknown"
    if peak_velocity < 0.1:
        return "static"
    if peak_velocity < 5.0:
        return "drift"
    if peak_velocity < 60.0:
        return "active"
    if peak_velocity < 180.0:
        return "fast"
    return "ballistic"


def classify_gravity_profile(
    gravity_vector: list[float] | None, velocity_peak: float | None
) -> dict[str, object]:
    magnitude = round(vector_magnitude(gravity_vector), 4) if gravity_vector else 0.0
    axis = dominant_axis(gravity_vector)
    if magnitude < 0.1:
        return {
            "magnitude": magnitude,
            "band": "none",
            "direction": "neutral",
            "style": "neutral",
        }

    if magnitude < 20.0:
        band = "gentle"
    elif magnitude < 150.0:
        band = "moderate"
    elif magnitude < 500.0:
        band = "strong"
    else:
        band = "extreme"

    if axis == "y":
        direction = "downward" if gravity_vector and gravity_vector[1] > 0 else "upward"
    elif axis == "x":
        direction = "lateral"
    elif axis == "z":
        direction = "depth"
    else:
        direction = "angled"

    if velocity_peak is None or velocity_peak < 0.1:
        style = "force-led"
    else:
        ratio = magnitude / max(velocity_peak, 0.001)
        if ratio >= 2.0:
            style = "gravity-dominant"
        elif ratio >= 0.35:
            style = "gravity-shaped"
        else:
            style = "velocity-led"

    return {
        "magnitude": magnitude,
        "band": band,
        "direction": direction,
        "style": style,
    }


def blend_mode_name(blend_modes: list[str]) -> str:
    if not blend_modes:
        return "unknown"
    unique_modes = sorted(set(blend_modes))
    if len(unique_modes) == 1:
        return unique_modes[0]
    return "mixed"


def classify_emission_mode(
    one_shot: bool, explosiveness: float, sustain: bool, prewarmed: bool
) -> str:
    if one_shot or explosiveness >= 0.8:
        return "burst"
    if prewarmed and sustain:
        return "settled-loop"
    if explosiveness >= 0.2:
        return "pulse"
    if sustain:
        return "stream"
    return "transient"


def parameter_signature(profile: dict[str, object]) -> str:
    return "/".join(
        [
            str(profile["blend_mode"]),
            str(profile["amount_band"]),
            str(profile["lifetime_band"]),
            str(profile["gravity_style"]),
            str(profile["velocity_band"]),
            str(profile["emission_mode"]),
        ]
    )


def parameter_keywords(profile: dict[str, object], motion: set[str], roles: set[str]) -> list[str]:
    keywords: set[str] = {
        str(profile["blend_mode"]),
        str(profile["amount_band"]),
        str(profile["lifetime_band"]),
        str(profile["velocity_band"]),
        str(profile["emission_mode"]),
    }
    gravity_direction = str(profile["gravity_direction"])
    gravity_style = str(profile["gravity_style"])
    if gravity_direction != "neutral":
        keywords.add(gravity_direction)
    if gravity_style != "neutral":
        keywords.add(gravity_style)
    if "trail-support" in motion:
        keywords.add("trail")
    if "radius-orbit" in motion or "vortex-core" in roles:
        keywords.add("orbit")
    if "sustain" in motion:
        keywords.add("loop")
    if "burst" in motion:
        keywords.add("burst")
    return sorted(keywords)


def design_implications_for_profile(
    profile: dict[str, object], motion: set[str], semantic: set[str], roles: set[str]
) -> list[str]:
    implications: list[str] = []
    blend_mode = str(profile["blend_mode"])
    amount_band = str(profile["amount_band"])
    lifetime_band = str(profile["lifetime_band"])
    velocity_band = str(profile["velocity_band"])
    gravity_style = str(profile["gravity_style"])
    gravity_direction = str(profile["gravity_direction"])
    emission_mode = str(profile["emission_mode"])

    if blend_mode == "add" and lifetime_band in {"instant", "short"} and velocity_band in {"fast", "ballistic"}:
        implications.append("Strong fit for hit flashes, spark bursts, and sharp impact accents.")
    if blend_mode == "add" and ("radius-orbit" in motion or "vortex-core" in roles):
        implications.append("Reads well as a magical core, vortex, charge-up halo, or orbital accent.")
    if blend_mode in {"mix", "mixed"} and lifetime_band in {"long", "persistent"}:
        implications.append("Good base for smoke, fog, soft aftermath, or environmental drift.")
    if blend_mode == "add" and "directional-trail" in roles and velocity_band in {"active", "fast"}:
        implications.append("Useful for weapon trails, projectile streaks, and energy ribbons.")
    if amount_band in {"dense", "swarm"} and lifetime_band in {"long", "persistent"} and gravity_direction == "downward":
        implications.append("Good candidate for weather sheets, showers, or dense ambient fields.")
    if emission_mode == "burst" and gravity_style in {"gravity-shaped", "gravity-dominant"}:
        implications.append("Supports explosive beats that arc, scatter, or fall off after the peak.")
    if emission_mode == "settled-loop" and lifetime_band in {"medium", "long", "persistent"}:
        implications.append("Works well for already-running auras, engines, shrines, or persistent magic beds.")
    if "soft" in semantic and lifetime_band in {"long", "persistent"}:
        implications.append("Best used as a support layer behind a brighter focal effect, not as the only read.")
    if not implications:
        implications.append("General-purpose support pattern; pair it with a stronger focal layer for hero effects.")
    return implications


def aggregate_pattern_uses(
    dimensions: dict[str, object], motion_counts: Counter[str], role_counts: Counter[str]
) -> list[str]:
    uses: list[str] = []
    blend_mode = str(dimensions["blend_mode"])
    lifetime_band = str(dimensions["lifetime_band"])
    velocity_band = str(dimensions["velocity_band"])
    emission_mode = str(dimensions["emission_mode"])
    gravity_direction = str(dimensions["gravity_direction"])

    if blend_mode == "add" and emission_mode == "burst":
        uses.extend(["impact flash", "spark burst", "burst accent"])
    if blend_mode == "add" and "directional-trail" in role_counts:
        uses.extend(["weapon trail", "projectile streak", "slash accent"])
    if "vortex-core" in role_counts or motion_counts.get("radius-orbit", 0) > 0:
        uses.extend(["vortex core", "charge-up aura", "orbital magic"])
    if lifetime_band in {"long", "persistent"} and blend_mode in {"mix", "mixed"}:
        uses.extend(["smoke tail", "ambient drift", "aftermath haze"])
    if gravity_direction == "downward" and lifetime_band in {"long", "persistent"}:
        uses.extend(["weather sheet", "rain field", "falling ambience"])
    if velocity_band == "ballistic":
        uses.extend(["debris spray", "violent burst", "impact chips"])
    deduped: list[str] = []
    for use in uses:
        if use not in deduped:
            deduped.append(use)
    return deduped or ["general support"]


def parse_scene_sections(path: Path) -> dict[str, object]:
    text = path.read_text(encoding="utf-8")
    sections = iter_sections(text)

    subresources: dict[str, dict[str, object]] = {}
    nodes: list[dict[str, object]] = []

    for header, body in sections:
        if header.startswith("sub_resource "):
            type_match = SECTION_TYPE_RE.search(header)
            id_match = SECTION_ID_RE.search(header)
            if not type_match or not id_match:
                continue
            subresources[id_match.group(1)] = {
                "id": id_match.group(1),
                "type": type_match.group(1),
                "properties": parse_properties(body),
                "raw_body": body,
            }
        elif header.startswith("node "):
            type_match = SECTION_TYPE_RE.search(header)
            name_match = NODE_NAME_RE.search(header)
            if not type_match or not name_match:
                continue
            nodes.append(
                {
                    "name": name_match.group(1),
                    "type": type_match.group(1),
                    "properties": parse_properties(body),
                }
            )

    return {
        "text": text,
        "textures": sorted(set(TEXTURE_RE.findall(text))),
        "subresources": subresources,
        "nodes": nodes,
    }


def emission_shape_name(process_props: dict[str, str]) -> str | None:
    raw = process_props.get("emission_shape")
    scalar = parse_scalar(raw)
    if isinstance(scalar, int):
        return EMISSION_SHAPES.get(scalar, f"enum:{scalar}")
    return None


def material_profiles_for_node(
    node_props: dict[str, str], subresources: dict[str, dict[str, object]]
) -> list[dict[str, object]]:
    profiles: list[dict[str, object]] = []
    direct_material_ref = subresource_ref(node_props.get("material"))
    if direct_material_ref and direct_material_ref in subresources:
        profiles.append(subresources[direct_material_ref])

    for key, value in node_props.items():
        if not key.startswith("draw_pass_"):
            continue
        draw_ref = subresource_ref(value)
        if not draw_ref:
            continue
        draw_resource = subresources.get(draw_ref)
        if not draw_resource:
            continue
        profiles.append(draw_resource)
        draw_material_ref = subresource_ref(draw_resource["properties"].get("material"))
        if draw_material_ref and draw_material_ref in subresources:
            profiles.append(subresources[draw_material_ref])
    return profiles


def classify_family(tokens: set[str], uses_shader: bool, roles: set[str], motion: set[str]) -> str:
    for family, family_tokens in PRIMARY_FAMILY_RULES:
        if tokens & family_tokens:
            return family
    if "vortex-core" in roles or "radius-orbit" in motion:
        return "magic"
    if uses_shader:
        return "magic"
    return "general"


def infer_roles(
    tokens: set[str],
    family: str,
    motion: set[str],
    semantic: set[str],
    additive: bool,
    sustain: bool,
    layer_count: int,
) -> list[str]:
    roles: set[str] = set()
    directional_tokens = {"trail", "ribbon", "ray", "blade", "meteor"}
    ring_tokens = {"ring", "wave", "ripple"}
    if additive and (semantic & {"energy", "light", "magic", "electric", "fire"} or family in {"aura", "magic", "fire"}):
        roles.add("core-glow")
    if "burst" in motion or family == "impact":
        roles.add("impact-burst")
    if family == "trail" or tokens & directional_tokens or "trail-support" in motion:
        roles.add("directional-trail")
    if "ring-motion" in motion or tokens & ring_tokens:
        roles.add("ring-accent")
    if semantic & {"smoke", "soft"} and sustain:
        roles.add("soft-residue")
    if "vortex" in motion or family == "magic" and "orbit" in motion:
        roles.add("vortex-core")
    if "orbit" in motion and "vortex-core" not in roles:
        roles.add("orbiting-accent")
    if semantic & {"sparkle", "reward"}:
        roles.add("sparkle-breakup")
    if family in {"atmosphere", "water"} and sustain:
        roles.add("ambient-loop")
    if family == "water":
        roles.add("water-accent")
    if family == "reward":
        roles.add("reward-accent")
    if layer_count >= 4:
        roles.add("hero-stack")
    return sorted(roles)


def analyze_particle_node(
    scene_name: str,
    node: dict[str, object],
    tokens: set[str],
    subresources: dict[str, dict[str, object]],
) -> dict[str, object]:
    props: dict[str, str] = node["properties"]  # type: ignore[assignment]

    metrics = {
        "amount": parse_scalar(props.get("amount")),
        "lifetime": parse_scalar(props.get("lifetime")),
        "one_shot": parse_bool(props.get("one_shot")),
        "explosiveness": parse_scalar(props.get("explosiveness")),
        "randomness": parse_scalar(props.get("randomness")),
        "preprocess": parse_scalar(props.get("preprocess")),
        "fixed_fps": parse_scalar(props.get("fixed_fps")),
    }

    motion: set[str] = set()
    semantic: set[str] = set()
    render: set[str] = set()
    velocity_peak: float | None = None
    gravity_vector: list[float] | None = None

    one_shot = bool(metrics["one_shot"])
    explosiveness = float(metrics["explosiveness"] or 0.0)
    lifetime = float(metrics["lifetime"] or 0.0)
    preprocess = float(metrics["preprocess"] or 0.0)

    if one_shot or explosiveness >= 0.5:
        motion.add("burst")
    if lifetime >= 1.8 and not one_shot:
        motion.add("sustain")
    if preprocess and lifetime and preprocess >= lifetime * 0.8:
        motion.add("prewarmed")

    process_ref = subresource_ref(props.get("process_material"))
    process_type = None
    process_props: dict[str, str] = {}
    if process_ref and process_ref in subresources:
        process_resource = subresources[process_ref]
        process_type = str(process_resource["type"])
        process_props = process_resource["properties"]  # type: ignore[assignment]

    if process_type == "ParticleProcessMaterial":
        shape = emission_shape_name(process_props)
        if shape:
            render.add(f"shape:{shape}")
        if shape == "ring":
            motion.update({"ring-motion", "orbit"})
        if shape in {"box", "directed_points"} and tokens & {"trail", "ribbon", "ray", "blade"}:
            motion.add("directional")

        gravity_vector = parse_vector(process_props.get("gravity"))
        if vector_magnitude(gravity_vector) > 0.1:
            motion.add("gravity-driven")
        direction = parse_vector(process_props.get("direction"))
        if vector_magnitude(direction) > 0.1:
            motion.add("directional")

        angular_values = parse_number_list(process_props.get("angular_velocity_max"))
        angular_values += parse_number_list(process_props.get("angular_velocity_min"))
        if max_abs(angular_values) >= 30.0:
            motion.add("spin")

        radial_values = parse_number_list(process_props.get("radial_accel_max"))
        radial_values += parse_number_list(process_props.get("radial_accel_min"))
        tangential_values = parse_number_list(process_props.get("tangential_accel_max"))
        tangential_values += parse_number_list(process_props.get("tangential_accel_min"))
        if max_abs(radial_values + tangential_values) > 0.1:
            motion.add("swirl")

        if parse_bool(process_props.get("turbulence_enabled")):
            motion.add("turbulence")
        if "scale_curve" in process_props:
            motion.add("scale-over-life")
        if "color_ramp" in process_props or "color_initial_ramp" in process_props:
            semantic.add("graded-color")

        velocity_values = parse_number_list(process_props.get("initial_velocity_max"))
        velocity_values += parse_number_list(process_props.get("initial_velocity_min"))
        velocity_peak = max_abs(velocity_values) if velocity_values else None
        if (velocity_peak or 0.0) >= 300.0:
            motion.add("high-velocity")
        elif (velocity_peak or 0.0) >= 5.0:
            motion.add("active-travel")

    elif process_type == "ShaderMaterial":
        parameter_names = {
            key.split("/", 1)[1]
            for key in process_props
            if key.startswith("shader_parameter/")
        }
        if {"max_radius", "min_radius"} & parameter_names:
            motion.update({"radius-orbit", "vortex", "orbit"})
        if "rotate_per_second_deg" in parameter_names:
            motion.add("spin")
        if {"start_size", "end_size"} <= parameter_names:
            motion.add("size-over-life")
        if {"start_color", "end_color"} <= parameter_names:
            semantic.add("graded-color")
        if "source_position_variance" in parameter_names:
            motion.add("spawn-variance")

    materials = material_profiles_for_node(props, subresources)
    blend_modes: list[str] = []
    uses_particle_trails = False
    uses_unshaded = False
    for material in materials:
        material_type = str(material["type"])
        material_props: dict[str, str] = material["properties"]  # type: ignore[assignment]
        blend_mode = parse_scalar(material_props.get("blend_mode"))
        if blend_mode == 1:
            blend_modes.append("add")
        elif blend_mode == 2:
            blend_modes.append("sub")
        elif blend_mode == 3:
            blend_modes.append("mul")
        else:
            blend_modes.append("mix")
        if material_type == "CanvasItemMaterial":
            render.add("canvas-item")
        if material_type == "StandardMaterial3D":
            if parse_bool(material_props.get("use_particle_trails")):
                uses_particle_trails = True
            shading_mode = parse_scalar(material_props.get("shading_mode"))
            if shading_mode == 0:
                uses_unshaded = True
            if parse_scalar(material_props.get("billboard_mode")) == 3:
                render.add("billboard-particles")

    blend_mode = blend_mode_name(blend_modes)
    additive = blend_mode in {"add", "mixed"}
    if additive:
        semantic.add("additive")
    if uses_particle_trails:
        motion.add("trail-support")
    if uses_unshaded:
        render.add("unshaded")

    if tokens & {"smoke", "fog"}:
        semantic.update({"smoke", "soft"})
    if tokens & {"water", "wave", "ripple", "whirlpool", "rain", "snow", "fountain"}:
        semantic.add("water")
    if tokens & {"gold", "upgrade", "star"}:
        semantic.update({"reward", "sparkle"})
    if tokens & {"technology", "electro", "loading"}:
        semantic.update({"tech", "magic"})
    if tokens & {"trail", "ribbon", "ray", "blade"}:
        motion.add("directional")
    if tokens & {"galaxy", "ring", "blink", "whirlpool"}:
        motion.add("orbit")
    if tokens & {"flame"}:
        semantic.update({"fire", "energy"})
    if tokens & {"glow", "light", "radial", "sun"}:
        semantic.update({"energy", "light"})
    for token in tokens:
        semantic.update(TOKEN_TAGS.get(token, set()))

    sustain = "sustain" in motion
    prewarmed = "prewarmed" in motion
    gravity_profile = classify_gravity_profile(gravity_vector, velocity_peak)
    profile = {
        "amount_band": classify_amount_band(metrics["amount"]),
        "lifetime_band": classify_lifetime_band(metrics["lifetime"]),
        "gravity_band": gravity_profile["band"],
        "gravity_direction": gravity_profile["direction"],
        "gravity_style": gravity_profile["style"],
        "velocity_band": classify_velocity_band(velocity_peak, motion),
        "blend_mode": blend_mode,
        "emission_mode": classify_emission_mode(one_shot, explosiveness, sustain, prewarmed),
    }
    profile["signature"] = parameter_signature(profile)
    provisional_roles = infer_roles(
        tokens,
        "general",
        motion,
        semantic,
        additive,
        sustain,
        1,
    )

    return {
        "name": node["name"],
        "type": node["type"],
        "main_metrics": metrics,
        "process_material_type": process_type,
        "parameter_profile": {
            **profile,
            "gravity_magnitude": gravity_profile["magnitude"],
            "velocity_peak": round(velocity_peak, 4) if velocity_peak is not None else None,
            "keywords": parameter_keywords(profile, motion, set(provisional_roles)),
        },
        "design_implications": design_implications_for_profile(
            profile, motion, semantic, set(provisional_roles)
        ),
        "motion_signatures": sorted(motion),
        "semantic_tags": sorted(semantic),
        "render_flags": sorted(render),
        "uses_additive": additive,
    }


def scene_summary(record: dict[str, object]) -> str:
    family = record["primary_family"]
    layer_count = record["particle_layer_count"]
    dimensionality = record["dimensionality"]
    motion = ", ".join(record["motion_signatures"][:3]) or "neutral motion"
    roles = ", ".join(record["reusable_roles"][:3]) or "general support"
    shader_note = " with custom particle shader" if record["render_profile"]["uses_custom_particles_shader"] else ""
    return (
        f"{dimensionality.upper()} {family} reference with {layer_count} particle layer(s){shader_note}; "
        f"primary motion: {motion}; reusable as {roles}."
    )


def build_indexes(
    scenes: list[dict[str, object]]
) -> tuple[dict[str, list[str]], dict[str, list[str]], dict[str, list[str]]]:
    family_index: dict[str, list[str]] = defaultdict(list)
    role_index: dict[str, list[str]] = defaultdict(list)
    motion_index: dict[str, list[str]] = defaultdict(list)

    for scene in scenes:
        scene_name = str(scene["scene_file"])
        family_index[str(scene["primary_family"])].append(scene_name)
        for role in scene["reusable_roles"]:
            role_index[str(role)].append(scene_name)
        for motion in scene["motion_signatures"]:
            motion_index[str(motion)].append(scene_name)

    return (
        {key: sorted(values) for key, values in sorted(family_index.items())},
        {key: sorted(values) for key, values in sorted(role_index.items())},
        {key: sorted(values) for key, values in sorted(motion_index.items())},
    )


def build_parameter_pattern_library(scenes: list[dict[str, object]]) -> dict[str, object]:
    pattern_entries: dict[str, dict[str, object]] = {}
    index_amount: dict[str, list[str]] = defaultdict(list)
    index_lifetime: dict[str, list[str]] = defaultdict(list)
    index_gravity: dict[str, list[str]] = defaultdict(list)
    index_velocity: dict[str, list[str]] = defaultdict(list)
    index_blend: dict[str, list[str]] = defaultdict(list)
    index_emission: dict[str, list[str]] = defaultdict(list)

    for scene in scenes:
        for node in scene["particle_nodes"]:
            profile: dict[str, object] = node["parameter_profile"]
            signature = str(profile["signature"])
            node_ref = {
                "scene_file": scene["scene_file"],
                "scene_family": scene["primary_family"],
                "node_name": node["name"],
                "node_type": node["type"],
                "roles": scene["reusable_roles"],
                "motion_signatures": node["motion_signatures"],
                "semantic_tags": node["semantic_tags"],
                "main_metrics": node["main_metrics"],
            }

            if signature not in pattern_entries:
                pattern_entries[signature] = {
                    "signature": signature,
                    "dimensions": {
                        "blend_mode": profile["blend_mode"],
                        "amount_band": profile["amount_band"],
                        "lifetime_band": profile["lifetime_band"],
                        "gravity_band": profile["gravity_band"],
                        "gravity_direction": profile["gravity_direction"],
                        "gravity_style": profile["gravity_style"],
                        "velocity_band": profile["velocity_band"],
                        "emission_mode": profile["emission_mode"],
                    },
                    "keywords": Counter(),
                    "families": Counter(),
                    "roles": Counter(),
                    "motion_signatures": Counter(),
                    "examples": [],
                    "design_implications": Counter(),
                }

            entry = pattern_entries[signature]
            entry["examples"].append(node_ref)
            entry["families"][scene["primary_family"]] += 1
            for role in scene["reusable_roles"]:
                entry["roles"][role] += 1
            for motion in node["motion_signatures"]:
                entry["motion_signatures"][motion] += 1
            for keyword in profile["keywords"]:
                entry["keywords"][keyword] += 1
            for implication in node["design_implications"]:
                entry["design_implications"][implication] += 1

            index_amount[str(profile["amount_band"])].append(signature)
            index_lifetime[str(profile["lifetime_band"])].append(signature)
            index_gravity[str(profile["gravity_style"])].append(signature)
            index_velocity[str(profile["velocity_band"])].append(signature)
            index_blend[str(profile["blend_mode"])].append(signature)
            index_emission[str(profile["emission_mode"])].append(signature)

    patterns: list[dict[str, object]] = []
    for signature, entry in sorted(
        pattern_entries.items(),
        key=lambda item: (-len(item[1]["examples"]), item[0]),
    ):
        scene_files = sorted({example["scene_file"] for example in entry["examples"]})
        dimensions: dict[str, object] = entry["dimensions"]
        pattern = {
            "signature": signature,
            "dimensions": dimensions,
            "node_count": len(entry["examples"]),
            "scene_count": len(scene_files),
            "scene_files": scene_files,
            "top_families": [
                {"family": family, "count": count}
                for family, count in entry["families"].most_common(4)
            ],
            "top_roles": [
                {"role": role, "count": count}
                for role, count in entry["roles"].most_common(4)
            ],
            "top_motion_signatures": [
                {"motion": motion, "count": count}
                for motion, count in entry["motion_signatures"].most_common(5)
            ],
            "keywords": [keyword for keyword, _ in entry["keywords"].most_common(8)],
            "design_implications": [
                text for text, _ in entry["design_implications"].most_common(3)
            ],
            "recommended_uses": aggregate_pattern_uses(
                dimensions, entry["motion_signatures"], entry["roles"]
            ),
            "example_nodes": entry["examples"][:6],
        }
        patterns.append(pattern)

    def unique_sorted(index: dict[str, list[str]]) -> dict[str, list[str]]:
        return {
            key: sorted(set(signatures))
            for key, signatures in sorted(index.items())
        }

    return {
        "axes": {
            "amount_band": ["sparse", "light", "medium", "dense", "swarm"],
            "lifetime_band": ["instant", "short", "medium", "long", "persistent"],
            "gravity_style": ["neutral", "velocity-led", "gravity-shaped", "gravity-dominant", "force-led"],
            "velocity_band": ["static", "drift", "active", "fast", "ballistic", "orbit-driven", "unknown"],
            "blend_mode": ["mix", "add", "sub", "mul", "mixed", "unknown"],
            "emission_mode": ["burst", "pulse", "stream", "settled-loop", "transient"],
        },
        "pattern_count": len(patterns),
        "patterns": patterns,
        "query_index": {
            "by_amount_band": unique_sorted(index_amount),
            "by_lifetime_band": unique_sorted(index_lifetime),
            "by_gravity_style": unique_sorted(index_gravity),
            "by_velocity_band": unique_sorted(index_velocity),
            "by_blend_mode": unique_sorted(index_blend),
            "by_emission_mode": unique_sorted(index_emission),
        },
    }


def recommend_companions(
    scene: dict[str, object], role_index: dict[str, list[str]]
) -> list[str]:
    suggestions: list[str] = []
    scene_name = str(scene["scene_file"])
    desired_roles: list[str] = []
    for role in scene["reusable_roles"]:
        desired_roles.extend(ROLE_COMPLEMENTS.get(str(role), []))

    for role in desired_roles:
        for candidate in role_index.get(role, []):
            if candidate == scene_name or candidate in suggestions:
                continue
            suggestions.append(candidate)
            break
        if len(suggestions) >= 3:
            break
    return suggestions


def analyze_scene(path: Path) -> dict[str, object]:
    parsed = parse_scene_sections(path)
    textures: list[str] = parsed["textures"]  # type: ignore[assignment]
    subresources: dict[str, dict[str, object]] = parsed["subresources"]  # type: ignore[assignment]
    nodes: list[dict[str, object]] = parsed["nodes"]  # type: ignore[assignment]

    scene_tokens = set(extract_tokens(path.name, *textures))
    particle_nodes = [node for node in nodes if node["type"] in PARTICLE_TYPES]
    node_profiles = [
        analyze_particle_node(path.stem, node, scene_tokens, subresources)
        for node in particle_nodes
    ]

    motion = sorted({tag for profile in node_profiles for tag in profile["motion_signatures"]})
    semantic = sorted({tag for profile in node_profiles for tag in profile["semantic_tags"]})
    additive_layers = sum(1 for profile in node_profiles if profile["uses_additive"])
    uses_shader = any(profile["process_material_type"] == "ShaderMaterial" for profile in node_profiles)
    uses_canvas = any("canvas-item" in profile["render_flags"] for profile in node_profiles)
    uses_unshaded = any("unshaded" in profile["render_flags"] for profile in node_profiles)
    uses_trails = any("trail-support" in profile["motion_signatures"] for profile in node_profiles)

    family = classify_family(scene_tokens, uses_shader, set(), set(motion))
    sustain = "sustain" in motion
    roles = infer_roles(
        scene_tokens,
        family,
        set(motion),
        set(semantic),
        additive_layers > 0,
        sustain,
        len(particle_nodes),
    )
    if uses_shader and "radius-orbit" in motion and "vortex-core" not in roles:
        roles.append("vortex-core")
        roles = sorted(set(roles))

    dimensionality = "3d" if any(node["type"].endswith("3D") for node in particle_nodes) else "2d"
    complexity = "hero" if len(particle_nodes) >= 4 else "advanced" if uses_shader or len(roles) >= 3 else "foundational"

    lifetime_values = [
        profile["main_metrics"]["lifetime"]
        for profile in node_profiles
        if isinstance(profile["main_metrics"]["lifetime"], (int, float))
    ]
    one_shot_layers = sum(1 for profile in node_profiles if profile["main_metrics"]["one_shot"])

    scene_record = {
        "scene_file": path.name,
        "scene_path": path.as_posix(),
        "scene_stem": path.stem,
        "dimensionality": dimensionality,
        "root_type": nodes[0]["type"] if nodes else "",
        "particle_layer_count": len(particle_nodes),
        "particle_nodes": node_profiles,
        "textures": textures,
        "tokens": sorted(scene_tokens),
        "primary_family": family,
        "semantic_tags": semantic,
        "motion_signatures": motion,
        "reusable_roles": roles,
        "complexity_tier": complexity,
        "render_profile": {
            "uses_custom_particles_shader": uses_shader,
            "uses_canvas_item_material": uses_canvas,
            "uses_unshaded_draw_material": uses_unshaded,
            "uses_particle_trails": uses_trails,
            "additive_layer_count": additive_layers,
        },
        "timing_profile": {
            "one_shot_layer_count": one_shot_layers,
            "lifetime_min": min(lifetime_values) if lifetime_values else None,
            "lifetime_max": max(lifetime_values) if lifetime_values else None,
        },
    }
    scene_record["summary"] = scene_summary(scene_record)
    unique_signatures = sorted(
        {
            node["parameter_profile"]["signature"]
            for node in node_profiles
        }
    )
    scene_record["parameter_recipe_summary"] = {
        "signature_count": len(unique_signatures),
        "signatures": unique_signatures,
        "blend_modes": sorted(
            {
                node["parameter_profile"]["blend_mode"]
                for node in node_profiles
            }
        ),
        "lifetime_bands": sorted(
            {
                node["parameter_profile"]["lifetime_band"]
                for node in node_profiles
            }
        ),
    }
    return scene_record


def render_markdown(knowledge: dict[str, object]) -> str:
    lines: list[str] = []
    lines.append("# Particle Knowledge")
    lines.append("")
    lines.append(
        "Generated from `particle/` by `scripts/distill_particle_knowledge.py`."
    )
    lines.append("")
    lines.append(f"- Generated at: `{knowledge['generated_at_utc']}`")
    lines.append(f"- Scene count: `{knowledge['scene_count']}`")
    lines.append("")

    lines.append("## Family Index")
    lines.append("")
    for family, scenes in knowledge["family_index"].items():
        lines.append(f"- `{family}`: {', '.join(f'`{scene}`' for scene in scenes)}")
    lines.append("")

    lines.append("## Role Index")
    lines.append("")
    for role, scenes in knowledge["role_index"].items():
        lines.append(f"- `{role}`: {', '.join(f'`{scene}`' for scene in scenes)}")
    lines.append("")

    lines.append("## Parameter Pattern Library")
    lines.append("")
    pattern_library = knowledge["parameter_pattern_library"]
    lines.append(f"- Pattern count: `{pattern_library['pattern_count']}`")
    lines.append("")
    lines.append("| Signature | Nodes | Scenes | Recommended uses | Example scenes |")
    lines.append("| --- | ---: | ---: | --- | --- |")
    for pattern in pattern_library["patterns"][:20]:
        lines.append(
            "| {signature} | {node_count} | {scene_count} | {uses} | {scenes} |".format(
                signature=pattern["signature"],
                node_count=pattern["node_count"],
                scene_count=pattern["scene_count"],
                uses=", ".join(pattern["recommended_uses"][:3]) or "-",
                scenes=", ".join(pattern["scene_files"][:3]) or "-",
            )
        )
    lines.append("")

    lines.append("## Parameter Axes")
    lines.append("")
    for axis_name, values in pattern_library["query_index"].items():
        lines.append(f"### {axis_name}")
        lines.append("")
        for value, signatures in values.items():
            lines.append(
                f"- `{value}`: {', '.join(f'`{signature}`' for signature in signatures[:8])}"
            )
        lines.append("")

    lines.append("## Scene Table")
    lines.append("")
    lines.append("| Scene | Family | Tier | Layers | Motion | Roles | Parameter signatures | Suggested companions |")
    lines.append("| --- | --- | --- | ---: | --- | --- | --- | --- |")
    for scene in knowledge["scenes"]:
        lines.append(
            "| {scene_file} | {primary_family} | {complexity_tier} | {particle_layer_count} | {motion} | {roles} | {signatures} | {companions} |".format(
                scene_file=scene["scene_file"],
                primary_family=scene["primary_family"],
                complexity_tier=scene["complexity_tier"],
                particle_layer_count=scene["particle_layer_count"],
                motion=", ".join(scene["motion_signatures"][:4]) or "-",
                roles=", ".join(scene["reusable_roles"][:4]) or "-",
                signatures=", ".join(scene["parameter_recipe_summary"]["signatures"][:2]) or "-",
                companions=", ".join(scene["recommended_companions"]) or "-",
            )
        )
    lines.append("")

    lines.append("## Scene Profiles")
    lines.append("")
    for scene in knowledge["scenes"]:
        lines.append(f"### {scene['scene_file']}")
        lines.append("")
        lines.append(f"- Summary: {scene['summary']}")
        lines.append(f"- Textures: {', '.join(f'`{texture}`' for texture in scene['textures']) or '`none`'}")
        lines.append(f"- Semantic tags: {', '.join(f'`{tag}`' for tag in scene['semantic_tags']) or '`none`'}")
        lines.append(f"- Motion signatures: {', '.join(f'`{tag}`' for tag in scene['motion_signatures']) or '`none`'}")
        lines.append(f"- Reusable roles: {', '.join(f'`{tag}`' for tag in scene['reusable_roles']) or '`none`'}")
        lines.append(f"- Parameter signatures: {', '.join(f'`{signature}`' for signature in scene['parameter_recipe_summary']['signatures']) or '`none`'}")
        lines.append(f"- Suggested companions: {', '.join(f'`{scene_name}`' for scene_name in scene['recommended_companions']) or '`none`'}")
        lines.append("- Node parameter profiles:")
        for node in scene["particle_nodes"]:
            profile = node["parameter_profile"]
            lines.append(
                "  - `{name}`: `{signature}` | amount `{amount}` | lifetime `{lifetime}` | gravity `{gravity}` | velocity `{velocity}` | blend `{blend}`".format(
                    name=node["name"],
                    signature=profile["signature"],
                    amount=profile["amount_band"],
                    lifetime=profile["lifetime_band"],
                    gravity=profile["gravity_style"],
                    velocity=profile["velocity_band"],
                    blend=profile["blend_mode"],
                )
            )
        lines.append("")

    return "\n".join(lines)


def build_knowledge(root: Path) -> dict[str, object]:
    scenes = [analyze_scene(path) for path in sorted(root.glob("*.tscn"))]
    family_index, role_index, motion_index = build_indexes(scenes)

    for scene in scenes:
        scene["recommended_companions"] = recommend_companions(scene, role_index)

    parameter_pattern_library = build_parameter_pattern_library(scenes)

    return {
        "schema_version": 2,
        "generated_at_utc": datetime.now(UTC).replace(microsecond=0).isoformat(),
        "source_root": root.as_posix(),
        "scene_count": len(scenes),
        "family_index": family_index,
        "role_index": role_index,
        "motion_index": motion_index,
        "parameter_pattern_library": parameter_pattern_library,
        "scenes": scenes,
    }


def write_outputs(knowledge: dict[str, object], output_dir: Path) -> tuple[Path, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    json_path = output_dir / OUTPUT_JSON
    md_path = output_dir / OUTPUT_MD
    json_path.write_text(json.dumps(knowledge, indent=2), encoding="utf-8")
    md_path.write_text(render_markdown(knowledge), encoding="utf-8")
    return json_path, md_path


def default_output_dir() -> Path:
    return Path(__file__).resolve().parents[1] / "references"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Distill the local particle library into a structured knowledge base."
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=default_particle_root(),
        help="Folder containing particle .tscn scenes.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=default_output_dir(),
        help="Directory that receives the generated JSON and Markdown knowledge files.",
    )
    parser.add_argument(
        "--stdout-json",
        action="store_true",
        help="Print the generated JSON to stdout after writing files.",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if not args.root.exists():
        parser.error(f"Particle root not found: {args.root}")

    knowledge = build_knowledge(args.root)
    json_path, md_path = write_outputs(knowledge, args.output_dir)
    print(f"[ok] wrote {json_path}")
    print(f"[ok] wrote {md_path}")
    if args.stdout_json:
        print(json.dumps(knowledge, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
