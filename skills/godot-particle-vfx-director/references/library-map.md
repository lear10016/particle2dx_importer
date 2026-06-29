# Library Map

Use this file to choose references quickly. Use `scripts/particle_library.py` for exact current inventory details.

## High-value scene groups

| Group | Scenes | Best reused for |
| --- | --- | --- |
| Impacts and bursts | `boom`, `boom_star`, `explosion_star`, `gold_boom`, `star_boom`, `battle` | hit flashes, burst timing, spark breakup, short hero impacts |
| Trails and slashes | `trail`, `trail2`, `ribbon`, `ribbon2`, `ray`, `electro_blade_3d` | weapon arcs, projectile streaks, beam accents, directional motion |
| Glows, rings, and auras | `glow`, `radial_glow`, `ring`, `ring2`, `light`, `light2`, `mask`, `wave`, `water_ripple` | soft cores, pulse rings, charge-up halos, contact decals |
| Atmosphere and environment | `smoke2`, `smoke_fog`, `rain`, `snow`, `firefly`, `fountain`, `water_flow` | lingering tails, background loops, ambient motion, moisture and mist |
| Magic and orbit motion | `glaxy`, `glaxy3`, `technology`, `whirlpool`, `sun_eat`, `blink`, `blink2` | orbiting magic, suction, implosion, rune-like motion, sci-fi spell beats |
| Utility and reward shapes | `upgrade`, `gold`, `light_face`, `star2`, `star4`, `star5`, `radial_glow`, `loading` | pickups, UI pings, collectible pops, sparkle motifs |

## Notable shader-based 2D scenes

These scenes contain `shader_type particles;` and are the best local references for non-standard radius or orbit behavior:

- `battle`
- `blink2`
- `boom`
- `glaxy`
- `ring`
- `sun_eat`
- `whirlpool`

Use them when the motion idea matters more than the exact sprite.

## Texture motif shortcuts

| Texture | Typical role |
| --- | --- |
| `particle/radial_glow_0.png` | soft energy core, bloom-like halo, charge center |
| `particle/glow_0.png` | compact glow, magical seed, bright additive center |
| `particle/ray_0.png` | streaks, sparks, directionality, speed lines |
| `particle/ribbon_0.png` and `particle/ribbon2_0.png` | arcs, slashes, curved motion accents |
| `particle/trail_0.png` and `particle/trail2_0.png` | elongated projectile trails, fast slash afterimages |
| `particle/smoke_fog_0.png` and `particle/smoke2_0.png` | soft breakup, lingering tails, soot or dust |
| `particle/star5_0.png`, `particle/star4_0.png`, `particle/star_boom_0.png` | sparkle bursts, impact chips, pickup pops |
| `particle/water_ripple_0.png` and `particle/wave_0.png` | rings, ripples, shock discs, ground contact accents |
| `particle/light_face_0.png` and `particle/mask_0.png` | stylized organic masks, magical overlays, noisy breakup |

## Best starting points by effect intent

- Fire burst: `flame`, `boom_star`, `gold_boom`, `smoke_fog`
- Energy slash: `electro_blade_3d`, `trail`, `trail2`, `ray`, `ribbon`
- Magic impact: `boom`, `ring`, `radial_glow`, `glaxy`, `star_boom`
- Vortex or charge-up: `whirlpool`, `sun_eat`, `ring2`, `light`, `blink2`
- Reward or pickup: `upgrade`, `gold`, `light_face`, `star5`, `radial_glow`
- Ambient weather: `rain`, `snow`, `firefly`, `smoke_fog`, `water_flow`

## Usage notes

- The converted scenes are best used as ingredients, not as final hero effects.
- Reuse shape language and timing curves first, then reuse textures.
- If you only borrow one scene, you will usually inherit its weaknesses too. Combine at least two references for anything important.
