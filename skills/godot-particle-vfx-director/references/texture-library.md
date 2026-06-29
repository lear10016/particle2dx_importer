# Texture Library

Use this file when the built-in `particle/*.png` textures are not enough and Codex should mine the dedicated `texture/` library before sourcing external art or generating new bitmap textures.

## Search order

1. `particle/*_0.png` for textures already proven inside local Godot sample scenes
2. `texture/` for broader particle-specific sprite shapes, masks, and authored flipbooks
3. External sourcing or bitmap generation only when the local texture bank still lacks the right silhouette

## Folder map

### `texture/alpha/`

Use for tintable grayscale or alpha-driven particle shapes.

Best for:

- additive energy
- slash trails
- sparks
- smoke masks
- light glows
- magic wisps
- scorch marks

Common families:

- `circle_*_a`: round glows, shields, soft cores
- `effect_*_a`: generic breakup, magical splashes
- `fire_*_a`, `flame_*_a`: fire tongues, combustion cores
- `light_*_a`, `flare_*_a`, `spotlight_*_a`: highlights, beam blooms, focused light cones
- `magic_*_a`, `symbol_*_a`, `twirl_*_a`, `window_*_a`: arcane marks, ritual energy, UI-like magical motifs
- `slash_*_a`, `trace_*_a`, `scratch_*_a`: weapon arcs, speed cuts, streak accents
- `smoke_*_a`, `dirt_*_a`, `scorch_*_a`: residue, dust, soot, ground burn
- `spark_*_a`, `star_*_a`: hot spark breakup, collectible pop, sharp accents
- `muzzle_*_a`: muzzle flashes, forward bursts, projectile ignition

Rule of thumb:

- Start here when you want to recolor the effect inside Godot.
- Prefer these over pre-colored sprites when hue control matters.

### `texture/opague/`

This folder name is spelled `opague` in the repo; keep using the real path as-is.

Use for pre-colored or baked-look textures when you want the authored color information rather than a neutral alpha mask.

Best for:

- effects whose painted color breakup already looks good
- softer smoke and dirt where grayscale tinting loses richness
- quick prototyping when the baked color is already close to the brief

Rule of thumb:

- Use these when the painted color language is the asset's main value.
- Avoid heavy runtime recoloring; it usually muddies the source art.

### `texture/predrawn/`

Use for authored atlas-style impact or magic textures with strong silhouette.

Notable assets:

- `electric_ring_6x5.png`: electric ritual ring, electric barrier, shock halo
- `charge_7x6.png`: charge-up core, channel buildup, spawn charge
- `impact_white_6x4.png`: neutral hit flash, white burst timing layer
- `lightstreaks_6x5.png`: directional magical streaks, burst ribbons
- `vortex_6x5.png`: suction core, portal, storm center
- `wavy_blue_6x5.png`, `wavy_purple_6x5.png`: flowing magical bands, water/electric currents
- `big_hit_6x5.png`, `star_explosion_6x5.png`, `explosion_6x5.png`: impact peaks and hero bursts
- `fire_ring_6x5.png`, `fire_point_6x5.png`, `dithered_fire_6x5.png`: stylized fire and ignition beats

Rule of thumb:

- Use these when a single particle texture needs to carry a lot of shape identity.
- Good source for manual atlas animation, shader-driven flipbook playback, or one-shot burst cards.

### `texture/flipbooks/`

Use for authored animated flipbooks stored as `.tga` atlases.

Typical contents:

- `explosion_*`
- `explosion_smoke_*`
- `cloud_*`
- `wispy_smoke_*`
- `fire_*`
- `flame_*`

Rule of thumb:

- Use when the effect needs real frame evolution rather than static sprite scaling.
- Best for fire, cloud, explosion, and smoke beats that look fake when driven by one still texture.
- Treat these as a stronger option than external sourcing when the brief matches the family already present here.

## Recommended routing by effect intent

- Ninja / slash / weapon trail:
  `texture/alpha/slash_*_a`, `trace_*_a`, `scratch_*_a`, `spark_*_a`
- Electric / lightning / arcane storm:
  `texture/predrawn/electric_ring_6x5.png`, `wavy_blue_6x5.png`, `texture/alpha/spark_*_a`, `light_*_a`, `magic_*_a`
- Fire / combustion:
  `texture/alpha/fire_*_a`, `flame_*_a`, `texture/flipbooks/fire_*`, `flame_*`
- Smoke / dust / aftermath:
  `texture/alpha/smoke_*_a`, `dirt_*_a`, `scorch_*_a`, `texture/flipbooks/wispy_smoke_*`, `cloud_*`
- Impact / burst / hit flash:
  `texture/predrawn/impact_white_6x4.png`, `big_hit_6x5.png`, `star_explosion_6x5.png`, `texture/alpha/spark_*_a`
- Ritual / magic / portal:
  `texture/alpha/magic_*_a`, `symbol_*_a`, `twirl_*_a`, `window_*_a`, `texture/predrawn/vortex_6x5.png`

## Selection rules

- Choose by silhouette first, color second.
- For particle systems that need recoloring, prefer `alpha/`.
- For particle systems that need baked painterly breakup, prefer `opague/`.
- For short hero beats with strong authored identity, prefer `predrawn/`.
- For animated smoke, fire, or explosion, prefer `flipbooks/`.
- If none of these categories fit the requested shape language, then source external art or generate a new texture.
