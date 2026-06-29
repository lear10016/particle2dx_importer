---
name: godot-particle-vfx-director
description: "Design, art-direct, and implement high-production-value Godot particle VFX in this particle2dx_importer workspace by mining the local `particle/` and `plist/` libraries for reusable textures, motion motifs, and layered scene references, then building or remixing `GPUParticles2D` and `GPUParticles3D` effects through `godot_ai` tools or direct scene edits. Use when Codex needs to create or polish a particle effect, trail, explosion, aura, hit effect, spell effect, slash, environmental loop, or 3A/AAA-like VFX quality, including Chinese requests such as `粒子特效`, `拖尾`, `爆炸`, `光效`, `技能特效`, or `3A级特效`."
---

# Godot Particle Vfx Director

## Overview

Create layered, reference-driven Godot VFX that read clearly in gameplay and feel intentionally art-directed rather than like single-emitter placeholders. Treat the local `particle/` scenes, the dedicated `texture/` library, and any extracted textures as a motif library that can be recombined into stronger hero effects.

## Workflow

1. Inventory the local library before inventing new shapes.
Run `python skills/godot-particle-vfx-director/scripts/particle_library.py inventory` from the repo root. Use `inspect` on promising scenes before editing them.

Also inventory the dedicated texture bank when the effect needs a stronger sprite than the sample scenes expose:
`python skills/godot-particle-vfx-director/scripts/texture_library.py inventory`

2. Write a short effect brief before touching values.
Capture gameplay role, camera distance, color family, timing arc, scale, and whether the effect must feel heavy, magical, technical, organic, or UI-like.

3. Build the effect in layers, not as one node.
Separate the effect into roles such as core energy, burst, directional streak, secondary breakup, ring or contact accent, and lingering aftermath. For hero moments, aim for at least 3 coordinated layers and often 5 or more.

4. Reuse local textures and scene motifs deliberately.
Borrow ingredients instead of cloning entire effects. Steal a glow shape from one scene, a ring motion from another, and a breakup texture from a third.

5. Fill texture gaps before forcing bad local art.
If the local library does not contain a suitable slash, bolt, spark, smoke, coin, rune, or breakup texture, source a fitting external effect texture or generate a new bitmap texture first. Do not keep tuning particle parameters around an obviously wrong sprite.

6. Prefer live iteration through the Godot editor when available.
Use `godot_ai` tools such as `scene_open`, `scene_save`, `particle_manage`, `material_manage`, `node_set_property`, and `editor_screenshot` so you can iterate visually instead of guessing file edits blind.

7. Review the effect in three frames.
Check anticipation, peak, and tail. If the peak looks good but the tail is muddy or static, fix timing, alpha falloff, and spacing before adding more particles.

## Reference Routing

- Read `references/library-map.md` first when choosing local samples, textures, and scene motifs.
- Read `references/texture-library.md` when the dedicated `texture/` bank is likely to be a better source than `particle/*_0.png`.
- Read `references/effect-recipes.md` when the user wants a concrete effect type such as a slash, impact, aura, projectile, or pickup.
- Read `references/quality-bar.md` when polishing or critiquing whether an effect feels AAA-like.
- If local textures are not enough, source external texture references or generate new bitmap assets before final assembly.
- Run `python skills/godot-particle-vfx-director/scripts/distill_particle_knowledge.py` to regenerate `references/particle-knowledge.json` and `references/particle-knowledge.md` from the current `particle/` library.
- Read `references/particle-knowledge.md` for the latest distilled scene summaries and `references/particle-knowledge.json` when you want machine-readable tags, roles, motion signatures, and companion suggestions.
- Run `python skills/godot-particle-vfx-director/scripts/particle_library.py inspect particle/<scene>.tscn` when you need exact structural details from a candidate reference.
- Run `python skills/godot-particle-vfx-director/scripts/texture_library.py inspect texture/<path>` when you need a quick classification of one dedicated effect texture.

## Repo-Specific Rules

- Favor local textures from `particle/*_0.png` before inventing new textures.
- Treat `texture/alpha/`, `texture/opague/`, `texture/predrawn/`, and `texture/flipbooks/` as the next local source after `particle/*_0.png`.
- When local textures are unsuitable, prefer either sourcing a fitting external effect texture with a clean silhouette and transparent background, or generating a purpose-built bitmap texture and saving it into the project for reuse.
- Favor motif recombination over one-to-one duplication. A shipped-looking effect should usually combine 2 to 4 local references.
- Use shader-based 2D scenes such as `battle`, `blink2`, `boom`, `glaxy`, `ring`, `sun_eat`, and `whirlpool` when you need orbiting, imploding, or radius-style motion.
- Use `electro_blade_3d.tscn` as the main local example of a layered multi-emitter 3D hero effect.
- If a reference scene is already close, open it, save a variant to a new path, and tune from there. Do not destroy the original sample library.
- Keep new custom effects outside the reference folder unless the user explicitly asks to overwrite the library. Good defaults are `res://generated_particles/`, `res://particle_custom/`, or a feature-specific folder.

## Implementation Heuristics

- Use additive blend for energy, lightning, sparks, and magic cores. Use regular alpha or mix for smoke, fog, dust, and broad soft shapes.
- Separate lifetimes by role. Fast bright layers should die early; slower soft layers should carry the tail.
- Push contrast between dominant shape and breakup. Readability beats raw particle count.
- In 2D, vary scale, angular velocity, gradients, and explosiveness before increasing `amount`.
- In 3D, preserve `vertex_color_use_as_albedo`, particle billboarding, unshaded shading, and transparency on draw materials unless you have a strong reason not to.
- Prefer asymmetry, staggered timing, and mixed scales. Uniform loops look cheap fast.
- Treat texture quality as a first-order decision. Wrong texture, wrong effect.
- When the editor is unavailable, still prepare a layered build plan and inspect local references before writing scene files directly.

## Deliverables

When creating or revising an effect, always return:

- the actual scene or resource edits
- the short effect brief you used
- the local references you borrowed from and why
- any known gaps if the workspace lacks distortion, lighting, animation, or post-processing support
