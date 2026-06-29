# Particle Knowledge

Generated from `particle/` by `scripts/distill_particle_knowledge.py`.

- Generated at: `2026-06-26T09:30:25+00:00`
- Scene count: `49`

## Family Index

- `atmosphere`: `firefly.tscn`, `fountain.tscn`, `leef.tscn`, `rain.tscn`, `smoke2.tscn`, `smoke_fog.tscn`, `snow.tscn`
- `aura`: `glow.tscn`, `light.tscn`, `light2.tscn`, `light_face.tscn`, `radial_glow.tscn`, `ring.tscn`, `ring2.tscn`
- `fire`: `flame.tscn`
- `general`: `colorful.tscn`, `colorful2.tscn`, `dot_group.tscn`
- `impact`: `battle.tscn`, `boom.tscn`, `boom_star.tscn`, `explosion_star.tscn`, `gold_boom.tscn`, `meteor.tscn`, `star_boom.tscn`
- `magic`: `blink.tscn`, `blink2.tscn`, `glaxy.tscn`, `glaxy3.tscn`, `mask.tscn`, `sun_eat.tscn`
- `reward`: `gold.tscn`, `srtar3.tscn`, `star2.tscn`, `star4.tscn`, `star5.tscn`, `upgrade.tscn`
- `tech`: `loading.tscn`, `technology.tscn`
- `trail`: `electro_blade_3d.tscn`, `ray.tscn`, `ribbon.tscn`, `ribbon2.tscn`, `trail.tscn`, `trail2.tscn`
- `water`: `water_flow.tscn`, `water_ripple.tscn`, `wave.tscn`, `whirlpool.tscn`

## Role Index

- `ambient-loop`: `firefly.tscn`, `leef.tscn`, `smoke_fog.tscn`, `snow.tscn`, `whirlpool.tscn`
- `core-glow`: `blink.tscn`, `blink2.tscn`, `electro_blade_3d.tscn`, `flame.tscn`, `glaxy.tscn`, `glaxy3.tscn`, `glow.tscn`, `light.tscn`, `light_face.tscn`, `loading.tscn`, `mask.tscn`, `radial_glow.tscn`, `ring.tscn`, `ring2.tscn`, `sun_eat.tscn`, `technology.tscn`, `upgrade.tscn`, `whirlpool.tscn`
- `directional-trail`: `electro_blade_3d.tscn`, `meteor.tscn`, `ray.tscn`, `ribbon.tscn`, `ribbon2.tscn`, `trail.tscn`, `trail2.tscn`
- `hero-stack`: `electro_blade_3d.tscn`
- `impact-burst`: `battle.tscn`, `boom.tscn`, `boom_star.tscn`, `explosion_star.tscn`, `gold.tscn`, `gold_boom.tscn`, `meteor.tscn`, `ribbon.tscn`, `star5.tscn`, `star_boom.tscn`, `upgrade.tscn`
- `orbiting-accent`: `electro_blade_3d.tscn`, `ring2.tscn`
- `reward-accent`: `gold.tscn`, `srtar3.tscn`, `star2.tscn`, `star4.tscn`, `star5.tscn`, `upgrade.tscn`
- `ring-accent`: `electro_blade_3d.tscn`, `ring.tscn`, `ring2.tscn`, `water_ripple.tscn`, `wave.tscn`
- `soft-residue`: `smoke_fog.tscn`, `snow.tscn`
- `sparkle-breakup`: `boom_star.tscn`, `explosion_star.tscn`, `firefly.tscn`, `gold.tscn`, `gold_boom.tscn`, `srtar3.tscn`, `star2.tscn`, `star4.tscn`, `star5.tscn`, `star_boom.tscn`, `upgrade.tscn`
- `vortex-core`: `battle.tscn`, `blink.tscn`, `blink2.tscn`, `boom.tscn`, `glaxy.tscn`, `glaxy3.tscn`, `ring.tscn`, `sun_eat.tscn`, `whirlpool.tscn`
- `water-accent`: `water_flow.tscn`, `water_ripple.tscn`, `wave.tscn`, `whirlpool.tscn`

## Parameter Pattern Library

- Pattern count: `46`

| Signature | Nodes | Scenes | Recommended uses | Example scenes |
| --- | ---: | ---: | --- | --- |
| add/sparse/short/force-led/unknown/transient | 3 | 3 | weapon trail, projectile streak, slash accent | ray.tscn, ring2.tscn, wave.tscn |
| add/light/short/velocity-led/fast/transient | 2 | 2 | general support | srtar3.tscn, star2.tscn |
| add/light/unknown/gravity-shaped/ballistic/burst | 2 | 2 | impact flash, spark burst, burst accent | explosion_star.tscn, star5.tscn |
| add/medium/short/velocity-led/ballistic/transient | 2 | 2 | weapon trail, projectile streak, slash accent | flame.tscn, trail2.tscn |
| add/sparse/medium/force-led/unknown/transient | 2 | 2 | vortex core, charge-up aura, orbital magic | glaxy3.tscn, technology.tscn |
| add/dense/long/gravity-shaped/ballistic/stream | 1 | 1 | debris spray, violent burst, impact chips | dot_group.tscn |
| add/dense/short/force-led/unknown/transient | 1 | 1 | general support | mask.tscn |
| add/dense/short/velocity-led/fast/transient | 1 | 1 | general support | water_flow.tscn |
| add/light/instant/force-led/unknown/transient | 1 | 1 | general support | rain.tscn |
| add/light/long/neutral/orbit-driven/burst | 1 | 1 | impact flash, spark burst, burst accent | boom.tscn |
| add/light/long/neutral/orbit-driven/settled-loop | 1 | 1 | vortex core, charge-up aura, orbital magic | whirlpool.tscn |
| add/light/medium/force-led/unknown/transient | 1 | 1 | general support | light.tscn |
| add/light/medium/velocity-led/active/transient | 1 | 1 | general support | glow.tscn |
| add/light/medium/velocity-led/ballistic/stream | 1 | 1 | weapon trail, projectile streak, slash accent | meteor.tscn |
| add/light/medium/velocity-led/ballistic/transient | 1 | 1 | weapon trail, projectile streak, slash accent | ribbon2.tscn |
| add/light/short/gravity-dominant/active/transient | 1 | 1 | general support | loading.tscn |
| add/medium/instant/gravity-shaped/ballistic/burst | 1 | 1 | impact flash, spark burst, burst accent | boom_star.tscn |
| add/medium/long/velocity-led/active/stream | 1 | 1 | general support | firefly.tscn |
| add/medium/medium/force-led/unknown/stream | 1 | 1 | general support | colorful.tscn |
| add/medium/medium/gravity-dominant/ballistic/burst | 1 | 1 | impact flash, spark burst, burst accent | upgrade.tscn |

## Parameter Axes

### by_amount_band

- `dense`: `add/dense/long/gravity-shaped/ballistic/stream`, `add/dense/short/force-led/unknown/transient`, `add/dense/short/velocity-led/fast/transient`, `mix/dense/long/gravity-shaped/ballistic/burst`, `mix/dense/long/neutral/orbit-driven/settled-loop`, `mix/dense/medium/gravity-shaped/ballistic/transient`, `mix/dense/medium/gravity-shaped/fast/transient`
- `light`: `add/light/instant/force-led/unknown/transient`, `add/light/long/neutral/orbit-driven/burst`, `add/light/long/neutral/orbit-driven/settled-loop`, `add/light/medium/force-led/unknown/transient`, `add/light/medium/velocity-led/active/transient`, `add/light/medium/velocity-led/ballistic/stream`, `add/light/medium/velocity-led/ballistic/transient`, `add/light/short/gravity-dominant/active/transient`
- `medium`: `add/medium/instant/gravity-shaped/ballistic/burst`, `add/medium/long/velocity-led/active/stream`, `add/medium/medium/force-led/unknown/stream`, `add/medium/medium/gravity-dominant/ballistic/burst`, `add/medium/persistent/velocity-led/active/stream`, `add/medium/short/velocity-led/ballistic/transient`, `add/medium/unknown/velocity-led/fast/transient`, `mix/medium/instant/gravity-shaped/ballistic/burst`
- `sparse`: `add/sparse/long/force-led/unknown/stream`, `add/sparse/long/neutral/orbit-driven/settled-loop`, `add/sparse/medium/force-led/unknown/transient`, `add/sparse/medium/neutral/orbit-driven/settled-loop`, `add/sparse/short/force-led/unknown/transient`, `add/sparse/short/velocity-led/fast/transient`, `add/sparse/unknown/force-led/unknown/transient`, `mix/sparse/long/gravity-shaped/fast/stream`
- `swarm`: `add/swarm/long/gravity-dominant/active/stream`, `add/swarm/long/velocity-led/ballistic/stream`, `add/swarm/medium/neutral/orbit-driven/settled-loop`, `add/swarm/medium/neutral/orbit-driven/transient`, `mix/swarm/long/gravity-dominant/fast/stream`, `mix/swarm/long/gravity-shaped/fast/stream`

### by_lifetime_band

- `instant`: `add/light/instant/force-led/unknown/transient`, `add/medium/instant/gravity-shaped/ballistic/burst`, `mix/medium/instant/gravity-shaped/ballistic/burst`
- `long`: `add/dense/long/gravity-shaped/ballistic/stream`, `add/light/long/neutral/orbit-driven/burst`, `add/light/long/neutral/orbit-driven/settled-loop`, `add/medium/long/velocity-led/active/stream`, `add/sparse/long/force-led/unknown/stream`, `add/sparse/long/neutral/orbit-driven/settled-loop`, `add/swarm/long/gravity-dominant/active/stream`, `add/swarm/long/velocity-led/ballistic/stream`
- `medium`: `add/light/medium/force-led/unknown/transient`, `add/light/medium/velocity-led/active/transient`, `add/light/medium/velocity-led/ballistic/stream`, `add/light/medium/velocity-led/ballistic/transient`, `add/medium/medium/force-led/unknown/stream`, `add/medium/medium/gravity-dominant/ballistic/burst`, `add/sparse/medium/force-led/unknown/transient`, `add/sparse/medium/neutral/orbit-driven/settled-loop`
- `persistent`: `add/medium/persistent/velocity-led/active/stream`
- `short`: `add/dense/short/force-led/unknown/transient`, `add/dense/short/velocity-led/fast/transient`, `add/light/short/gravity-dominant/active/transient`, `add/light/short/velocity-led/fast/transient`, `add/medium/short/velocity-led/ballistic/transient`, `add/sparse/short/force-led/unknown/transient`, `add/sparse/short/velocity-led/fast/transient`, `mixed/light/short/gravity-shaped/drift/transient`
- `unknown`: `add/light/unknown/gravity-shaped/ballistic/burst`, `add/medium/unknown/velocity-led/fast/transient`, `add/sparse/unknown/force-led/unknown/transient`

### by_gravity_style

- `force-led`: `add/dense/short/force-led/unknown/transient`, `add/light/instant/force-led/unknown/transient`, `add/light/medium/force-led/unknown/transient`, `add/medium/medium/force-led/unknown/stream`, `add/sparse/long/force-led/unknown/stream`, `add/sparse/medium/force-led/unknown/transient`, `add/sparse/short/force-led/unknown/transient`, `add/sparse/unknown/force-led/unknown/transient`
- `gravity-dominant`: `add/light/short/gravity-dominant/active/transient`, `add/medium/medium/gravity-dominant/ballistic/burst`, `add/swarm/long/gravity-dominant/active/stream`, `mix/swarm/long/gravity-dominant/fast/stream`, `mixed/medium/medium/gravity-dominant/drift/transient`
- `gravity-shaped`: `add/dense/long/gravity-shaped/ballistic/stream`, `add/light/unknown/gravity-shaped/ballistic/burst`, `add/medium/instant/gravity-shaped/ballistic/burst`, `mix/dense/long/gravity-shaped/ballistic/burst`, `mix/dense/medium/gravity-shaped/ballistic/transient`, `mix/dense/medium/gravity-shaped/fast/transient`, `mix/medium/instant/gravity-shaped/ballistic/burst`, `mix/medium/long/gravity-shaped/ballistic/burst`
- `neutral`: `add/light/long/neutral/orbit-driven/burst`, `add/light/long/neutral/orbit-driven/settled-loop`, `add/sparse/long/neutral/orbit-driven/settled-loop`, `add/sparse/medium/neutral/orbit-driven/settled-loop`, `add/swarm/medium/neutral/orbit-driven/settled-loop`, `add/swarm/medium/neutral/orbit-driven/transient`, `mix/dense/long/neutral/orbit-driven/settled-loop`
- `velocity-led`: `add/dense/short/velocity-led/fast/transient`, `add/light/medium/velocity-led/active/transient`, `add/light/medium/velocity-led/ballistic/stream`, `add/light/medium/velocity-led/ballistic/transient`, `add/light/short/velocity-led/fast/transient`, `add/medium/long/velocity-led/active/stream`, `add/medium/persistent/velocity-led/active/stream`, `add/medium/short/velocity-led/ballistic/transient`

### by_velocity_band

- `active`: `add/light/medium/velocity-led/active/transient`, `add/light/short/gravity-dominant/active/transient`, `add/medium/long/velocity-led/active/stream`, `add/medium/persistent/velocity-led/active/stream`, `add/swarm/long/gravity-dominant/active/stream`, `mix/sparse/medium/gravity-shaped/active/stream`, `mixed/light/short/velocity-led/active/transient`, `mixed/medium/short/gravity-shaped/active/transient`
- `ballistic`: `add/dense/long/gravity-shaped/ballistic/stream`, `add/light/medium/velocity-led/ballistic/stream`, `add/light/medium/velocity-led/ballistic/transient`, `add/light/unknown/gravity-shaped/ballistic/burst`, `add/medium/instant/gravity-shaped/ballistic/burst`, `add/medium/medium/gravity-dominant/ballistic/burst`, `add/medium/short/velocity-led/ballistic/transient`, `add/swarm/long/velocity-led/ballistic/stream`
- `drift`: `mixed/light/short/gravity-shaped/drift/transient`, `mixed/medium/medium/gravity-dominant/drift/transient`
- `fast`: `add/dense/short/velocity-led/fast/transient`, `add/light/short/velocity-led/fast/transient`, `add/medium/unknown/velocity-led/fast/transient`, `add/sparse/short/velocity-led/fast/transient`, `mix/dense/medium/gravity-shaped/fast/transient`, `mix/light/medium/velocity-led/fast/transient`, `mix/sparse/long/gravity-shaped/fast/stream`, `mix/swarm/long/gravity-dominant/fast/stream`
- `orbit-driven`: `add/light/long/neutral/orbit-driven/burst`, `add/light/long/neutral/orbit-driven/settled-loop`, `add/sparse/long/neutral/orbit-driven/settled-loop`, `add/sparse/medium/neutral/orbit-driven/settled-loop`, `add/swarm/medium/neutral/orbit-driven/settled-loop`, `add/swarm/medium/neutral/orbit-driven/transient`, `mix/dense/long/neutral/orbit-driven/settled-loop`
- `unknown`: `add/dense/short/force-led/unknown/transient`, `add/light/instant/force-led/unknown/transient`, `add/light/medium/force-led/unknown/transient`, `add/medium/medium/force-led/unknown/stream`, `add/sparse/long/force-led/unknown/stream`, `add/sparse/medium/force-led/unknown/transient`, `add/sparse/short/force-led/unknown/transient`, `add/sparse/unknown/force-led/unknown/transient`

### by_blend_mode

- `add`: `add/dense/long/gravity-shaped/ballistic/stream`, `add/dense/short/force-led/unknown/transient`, `add/dense/short/velocity-led/fast/transient`, `add/light/instant/force-led/unknown/transient`, `add/light/long/neutral/orbit-driven/burst`, `add/light/long/neutral/orbit-driven/settled-loop`, `add/light/medium/force-led/unknown/transient`, `add/light/medium/velocity-led/active/transient`
- `mix`: `mix/dense/long/gravity-shaped/ballistic/burst`, `mix/dense/long/neutral/orbit-driven/settled-loop`, `mix/dense/medium/gravity-shaped/ballistic/transient`, `mix/dense/medium/gravity-shaped/fast/transient`, `mix/light/medium/velocity-led/fast/transient`, `mix/medium/instant/gravity-shaped/ballistic/burst`, `mix/medium/long/gravity-shaped/ballistic/burst`, `mix/sparse/long/gravity-shaped/fast/stream`
- `mixed`: `mixed/light/short/gravity-shaped/drift/transient`, `mixed/light/short/velocity-led/active/transient`, `mixed/medium/medium/gravity-dominant/drift/transient`, `mixed/medium/short/gravity-shaped/active/transient`

### by_emission_mode

- `burst`: `add/light/long/neutral/orbit-driven/burst`, `add/light/unknown/gravity-shaped/ballistic/burst`, `add/medium/instant/gravity-shaped/ballistic/burst`, `add/medium/medium/gravity-dominant/ballistic/burst`, `mix/dense/long/gravity-shaped/ballistic/burst`, `mix/medium/instant/gravity-shaped/ballistic/burst`, `mix/medium/long/gravity-shaped/ballistic/burst`
- `settled-loop`: `add/light/long/neutral/orbit-driven/settled-loop`, `add/sparse/long/neutral/orbit-driven/settled-loop`, `add/sparse/medium/neutral/orbit-driven/settled-loop`, `add/swarm/medium/neutral/orbit-driven/settled-loop`, `mix/dense/long/neutral/orbit-driven/settled-loop`
- `stream`: `add/dense/long/gravity-shaped/ballistic/stream`, `add/light/medium/velocity-led/ballistic/stream`, `add/medium/long/velocity-led/active/stream`, `add/medium/medium/force-led/unknown/stream`, `add/medium/persistent/velocity-led/active/stream`, `add/sparse/long/force-led/unknown/stream`, `add/swarm/long/gravity-dominant/active/stream`, `add/swarm/long/velocity-led/ballistic/stream`
- `transient`: `add/dense/short/force-led/unknown/transient`, `add/dense/short/velocity-led/fast/transient`, `add/light/instant/force-led/unknown/transient`, `add/light/medium/force-led/unknown/transient`, `add/light/medium/velocity-led/active/transient`, `add/light/medium/velocity-led/ballistic/transient`, `add/light/short/gravity-dominant/active/transient`, `add/light/short/velocity-led/fast/transient`

## Scene Table

| Scene | Family | Tier | Layers | Motion | Roles | Parameter signatures | Suggested companions |
| --- | --- | --- | ---: | --- | --- | --- | --- |
| battle.tscn | impact | advanced | 1 | orbit, prewarmed, radius-orbit, size-over-life | impact-burst, vortex-core | mix/dense/long/neutral/orbit-driven/settled-loop | electro_blade_3d.tscn, smoke_fog.tscn, boom_star.tscn |
| blink.tscn | magic | foundational | 1 | active-travel, directional, gravity-driven, orbit | core-glow, vortex-core | add/sparse/short/velocity-led/fast/transient | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| blink2.tscn | magic | advanced | 1 | orbit, prewarmed, radius-orbit, size-over-life | core-glow, vortex-core | add/sparse/medium/neutral/orbit-driven/settled-loop | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| boom.tscn | impact | advanced | 1 | burst, orbit, radius-orbit, size-over-life | impact-burst, vortex-core | add/light/long/neutral/orbit-driven/burst | electro_blade_3d.tscn, smoke_fog.tscn, boom_star.tscn |
| boom_star.tscn | impact | foundational | 1 | burst, gravity-driven, high-velocity, scale-over-life | impact-burst, sparkle-breakup | add/medium/instant/gravity-shaped/ballistic/burst | electro_blade_3d.tscn, smoke_fog.tscn, explosion_star.tscn |
| colorful.tscn | general | foundational | 1 | directional, gravity-driven, scale-over-life, sustain | - | add/medium/medium/force-led/unknown/stream | - |
| colorful2.tscn | general | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | - | mix/swarm/long/gravity-dominant/fast/stream | - |
| dot_group.tscn | general | foundational | 1 | gravity-driven, high-velocity, scale-over-life, sustain | - | add/dense/long/gravity-shaped/ballistic/stream | - |
| electro_blade_3d.tscn | trail | hero | 4 | active-travel, directional, gravity-driven, orbit | core-glow, directional-trail, hero-stack, orbiting-accent | mixed/light/short/gravity-shaped/drift/transient, mixed/light/short/velocity-led/active/transient | ring.tscn, boom_star.tscn, ring2.tscn |
| explosion_star.tscn | impact | foundational | 1 | burst, directional, gravity-driven, high-velocity | impact-burst, sparkle-breakup | add/light/unknown/gravity-shaped/ballistic/burst | electro_blade_3d.tscn, smoke_fog.tscn, boom_star.tscn |
| firefly.tscn | atmosphere | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | ambient-loop, sparkle-breakup | add/medium/long/velocity-led/active/stream | blink.tscn, smoke_fog.tscn |
| flame.tscn | fire | foundational | 1 | gravity-driven, high-velocity, scale-over-life, swirl | core-glow | add/medium/short/velocity-led/ballistic/transient | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| fountain.tscn | atmosphere | foundational | 1 | directional, gravity-driven, high-velocity, scale-over-life | - | mix/dense/medium/gravity-shaped/ballistic/transient | - |
| glaxy.tscn | magic | advanced | 1 | orbit, prewarmed, radius-orbit, size-over-life | core-glow, vortex-core | add/swarm/medium/neutral/orbit-driven/settled-loop | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| glaxy3.tscn | magic | foundational | 1 | gravity-driven, orbit, scale-over-life, spin | core-glow, vortex-core | add/sparse/medium/force-led/unknown/transient | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| glow.tscn | aura | foundational | 1 | active-travel, gravity-driven, scale-over-life, swirl | core-glow | add/light/medium/velocity-led/active/transient | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| gold.tscn | reward | advanced | 1 | burst, directional, gravity-driven, high-velocity | impact-burst, reward-accent, sparkle-breakup | mix/medium/long/gravity-shaped/ballistic/burst | electro_blade_3d.tscn, smoke_fog.tscn, boom_star.tscn |
| gold_boom.tscn | impact | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | impact-burst, sparkle-breakup | add/swarm/long/velocity-led/ballistic/stream | electro_blade_3d.tscn, smoke_fog.tscn, boom_star.tscn |
| leef.tscn | atmosphere | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | ambient-loop | mix/sparse/long/gravity-shaped/fast/stream | blink.tscn, smoke_fog.tscn |
| light.tscn | aura | foundational | 1 | gravity-driven, scale-over-life | core-glow | add/light/medium/force-led/unknown/transient | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| light2.tscn | aura | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | - | mix/sparse/medium/gravity-shaped/active/stream | - |
| light_face.tscn | aura | foundational | 1 | gravity-driven, scale-over-life | core-glow | add/sparse/unknown/force-led/unknown/transient | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| loading.tscn | tech | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | core-glow | add/light/short/gravity-dominant/active/transient | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| mask.tscn | magic | foundational | 1 | directional, gravity-driven, scale-over-life | core-glow | add/dense/short/force-led/unknown/transient | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| meteor.tscn | impact | foundational | 1 | directional, gravity-driven, high-velocity, scale-over-life | directional-trail, impact-burst | add/light/medium/velocity-led/ballistic/stream | battle.tscn, blink.tscn, smoke_fog.tscn |
| radial_glow.tscn | aura | foundational | 1 | directional, gravity-driven, scale-over-life, sustain | core-glow | add/sparse/long/force-led/unknown/stream | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| rain.tscn | atmosphere | foundational | 1 | directional, gravity-driven, scale-over-life | - | add/light/instant/force-led/unknown/transient | - |
| ray.tscn | trail | foundational | 1 | directional, gravity-driven, scale-over-life | directional-trail | add/sparse/short/force-led/unknown/transient | battle.tscn, blink.tscn, smoke_fog.tscn |
| ribbon.tscn | trail | foundational | 1 | burst, directional, gravity-driven, high-velocity | directional-trail, impact-burst | mix/dense/long/gravity-shaped/ballistic/burst | battle.tscn, blink.tscn, smoke_fog.tscn |
| ribbon2.tscn | trail | foundational | 1 | directional, gravity-driven, high-velocity, scale-over-life | directional-trail | add/light/medium/velocity-led/ballistic/transient | battle.tscn, blink.tscn, smoke_fog.tscn |
| ring.tscn | aura | advanced | 1 | orbit, prewarmed, radius-orbit, size-over-life | core-glow, ring-accent, vortex-core | add/sparse/long/neutral/orbit-driven/settled-loop | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| ring2.tscn | aura | advanced | 1 | gravity-driven, orbit, scale-over-life, spin | core-glow, orbiting-accent, ring-accent | add/sparse/short/force-led/unknown/transient | electro_blade_3d.tscn, boom_star.tscn |
| smoke2.tscn | atmosphere | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | - | mix/dense/medium/gravity-shaped/fast/transient | - |
| smoke_fog.tscn | atmosphere | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | ambient-loop, soft-residue | add/medium/persistent/velocity-led/active/stream | blink.tscn, snow.tscn |
| snow.tscn | atmosphere | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | ambient-loop, soft-residue | add/swarm/long/gravity-dominant/active/stream | blink.tscn, smoke_fog.tscn |
| srtar3.tscn | reward | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | reward-accent, sparkle-breakup | add/light/short/velocity-led/fast/transient | blink.tscn, boom_star.tscn |
| star2.tscn | reward | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | reward-accent, sparkle-breakup | add/light/short/velocity-led/fast/transient | blink.tscn, boom_star.tscn |
| star4.tscn | reward | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | reward-accent, sparkle-breakup | add/medium/unknown/velocity-led/fast/transient | blink.tscn, boom_star.tscn |
| star5.tscn | reward | advanced | 1 | burst, directional, gravity-driven, high-velocity | impact-burst, reward-accent, sparkle-breakup | add/light/unknown/gravity-shaped/ballistic/burst | electro_blade_3d.tscn, smoke_fog.tscn, boom_star.tscn |
| star_boom.tscn | impact | foundational | 1 | burst, gravity-driven, high-velocity, scale-over-life | impact-burst, sparkle-breakup | mix/medium/instant/gravity-shaped/ballistic/burst | electro_blade_3d.tscn, smoke_fog.tscn, boom_star.tscn |
| sun_eat.tscn | magic | advanced | 1 | orbit, prewarmed, radius-orbit, size-over-life | core-glow, vortex-core | add/swarm/medium/neutral/orbit-driven/transient | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| technology.tscn | tech | foundational | 1 | gravity-driven, scale-over-life, spin | core-glow | add/sparse/medium/force-led/unknown/transient | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| trail.tscn | trail | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | directional-trail | mix/swarm/long/gravity-shaped/fast/stream | battle.tscn, blink.tscn, smoke_fog.tscn |
| trail2.tscn | trail | foundational | 1 | directional, gravity-driven, high-velocity, scale-over-life | directional-trail | add/medium/short/velocity-led/ballistic/transient | battle.tscn, blink.tscn, smoke_fog.tscn |
| upgrade.tscn | reward | advanced | 1 | active-travel, burst, directional, gravity-driven | core-glow, impact-burst, reward-accent, sparkle-breakup | add/medium/medium/gravity-dominant/ballistic/burst | electro_blade_3d.tscn, boom_star.tscn, ring2.tscn |
| water_flow.tscn | water | foundational | 1 | active-travel, directional, gravity-driven, scale-over-life | water-accent | add/dense/short/velocity-led/fast/transient | electro_blade_3d.tscn, smoke_fog.tscn |
| water_ripple.tscn | water | foundational | 1 | active-travel, gravity-driven, scale-over-life | ring-accent, water-accent | mix/light/medium/velocity-led/fast/transient | electro_blade_3d.tscn, smoke_fog.tscn |
| wave.tscn | water | foundational | 1 | gravity-driven, scale-over-life | ring-accent, water-accent | add/sparse/short/force-led/unknown/transient | electro_blade_3d.tscn, smoke_fog.tscn |
| whirlpool.tscn | water | advanced | 1 | orbit, prewarmed, radius-orbit, size-over-life | ambient-loop, core-glow, vortex-core, water-accent | add/light/long/neutral/orbit-driven/settled-loop | blink.tscn, smoke_fog.tscn, electro_blade_3d.tscn |

## Scene Profiles

### battle.tscn

- Summary: 2D impact reference with 1 particle layer(s) with custom particle shader; primary motion: orbit, prewarmed, radius-orbit; reusable as impact-burst, vortex-core.
- Textures: `res://particle/battle_0.png`
- Semantic tags: `burst`, `graded-color`, `impact`
- Motion signatures: `orbit`, `prewarmed`, `radius-orbit`, `size-over-life`, `spawn-variance`, `spin`, `sustain`, `vortex`
- Reusable roles: `impact-burst`, `vortex-core`
- Parameter signatures: `mix/dense/long/neutral/orbit-driven/settled-loop`
- Suggested companions: `electro_blade_3d.tscn`, `smoke_fog.tscn`, `boom_star.tscn`
- Node parameter profiles:
  - `Particle2D`: `mix/dense/long/neutral/orbit-driven/settled-loop` | amount `dense` | lifetime `long` | gravity `neutral` | velocity `orbit-driven` | blend `mix`

### blink.tscn

- Summary: 2D magic reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as core-glow, vortex-core.
- Textures: `res://particle/blink_0.png`
- Semantic tags: `additive`, `flash`, `graded-color`, `magic`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `orbit`, `scale-over-life`
- Reusable roles: `core-glow`, `vortex-core`
- Parameter signatures: `add/sparse/short/velocity-led/fast/transient`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/sparse/short/velocity-led/fast/transient` | amount `sparse` | lifetime `short` | gravity `velocity-led` | velocity `fast` | blend `add`

### blink2.tscn

- Summary: 2D magic reference with 1 particle layer(s) with custom particle shader; primary motion: orbit, prewarmed, radius-orbit; reusable as core-glow, vortex-core.
- Textures: `res://particle/blink2_0.png`
- Semantic tags: `additive`, `flash`, `graded-color`, `magic`
- Motion signatures: `orbit`, `prewarmed`, `radius-orbit`, `size-over-life`, `spawn-variance`, `spin`, `sustain`, `vortex`
- Reusable roles: `core-glow`, `vortex-core`
- Parameter signatures: `add/sparse/medium/neutral/orbit-driven/settled-loop`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/sparse/medium/neutral/orbit-driven/settled-loop` | amount `sparse` | lifetime `medium` | gravity `neutral` | velocity `orbit-driven` | blend `add`

### boom.tscn

- Summary: 2D impact reference with 1 particle layer(s) with custom particle shader; primary motion: burst, orbit, radius-orbit; reusable as impact-burst, vortex-core.
- Textures: `res://particle/boom_0.png`
- Semantic tags: `additive`, `burst`, `graded-color`, `impact`
- Motion signatures: `burst`, `orbit`, `radius-orbit`, `size-over-life`, `spawn-variance`, `spin`, `vortex`
- Reusable roles: `impact-burst`, `vortex-core`
- Parameter signatures: `add/light/long/neutral/orbit-driven/burst`
- Suggested companions: `electro_blade_3d.tscn`, `smoke_fog.tscn`, `boom_star.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/light/long/neutral/orbit-driven/burst` | amount `light` | lifetime `long` | gravity `neutral` | velocity `orbit-driven` | blend `add`

### boom_star.tscn

- Summary: 2D impact reference with 1 particle layer(s); primary motion: burst, gravity-driven, high-velocity; reusable as impact-burst, sparkle-breakup.
- Textures: `res://particle/boom_star_0.png`
- Semantic tags: `additive`, `burst`, `graded-color`, `impact`, `reward`, `sparkle`
- Motion signatures: `burst`, `gravity-driven`, `high-velocity`, `scale-over-life`, `spin`
- Reusable roles: `impact-burst`, `sparkle-breakup`
- Parameter signatures: `add/medium/instant/gravity-shaped/ballistic/burst`
- Suggested companions: `electro_blade_3d.tscn`, `smoke_fog.tscn`, `explosion_star.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/medium/instant/gravity-shaped/ballistic/burst` | amount `medium` | lifetime `instant` | gravity `gravity-shaped` | velocity `ballistic` | blend `add`

### colorful.tscn

- Summary: 2D general reference with 1 particle layer(s); primary motion: directional, gravity-driven, scale-over-life; reusable as general support.
- Textures: `res://particle/colorful_0.png`
- Semantic tags: `additive`, `graded-color`
- Motion signatures: `directional`, `gravity-driven`, `scale-over-life`, `sustain`, `swirl`
- Reusable roles: `none`
- Parameter signatures: `add/medium/medium/force-led/unknown/stream`
- Suggested companions: `none`
- Node parameter profiles:
  - `Particle2D`: `add/medium/medium/force-led/unknown/stream` | amount `medium` | lifetime `medium` | gravity `force-led` | velocity `unknown` | blend `add`

### colorful2.tscn

- Summary: 2D general reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as general support.
- Textures: `res://particle/colorful2_0.png`
- Semantic tags: `graded-color`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`, `sustain`, `swirl`
- Reusable roles: `none`
- Parameter signatures: `mix/swarm/long/gravity-dominant/fast/stream`
- Suggested companions: `none`
- Node parameter profiles:
  - `Particle2D`: `mix/swarm/long/gravity-dominant/fast/stream` | amount `swarm` | lifetime `long` | gravity `gravity-dominant` | velocity `fast` | blend `mix`

### dot_group.tscn

- Summary: 2D general reference with 1 particle layer(s); primary motion: gravity-driven, high-velocity, scale-over-life; reusable as general support.
- Textures: `res://particle/dot_group_0.png`
- Semantic tags: `additive`, `graded-color`
- Motion signatures: `gravity-driven`, `high-velocity`, `scale-over-life`, `sustain`, `swirl`
- Reusable roles: `none`
- Parameter signatures: `add/dense/long/gravity-shaped/ballistic/stream`
- Suggested companions: `none`
- Node parameter profiles:
  - `Particle2D`: `add/dense/long/gravity-shaped/ballistic/stream` | amount `dense` | lifetime `long` | gravity `gravity-shaped` | velocity `ballistic` | blend `add`

### electro_blade_3d.tscn

- Summary: 3D trail reference with 4 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as core-glow, directional-trail, hero-stack.
- Textures: `none`
- Semantic tags: `additive`, `directional`, `electric`, `graded-color`, `magic`, `tech`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `orbit`, `prewarmed`, `ring-motion`, `spin`, `swirl`, `trail-support`, `turbulence`
- Reusable roles: `core-glow`, `directional-trail`, `hero-stack`, `orbiting-accent`, `ring-accent`
- Parameter signatures: `mixed/light/short/gravity-shaped/drift/transient`, `mixed/light/short/velocity-led/active/transient`, `mixed/medium/medium/gravity-dominant/drift/transient`, `mixed/medium/short/gravity-shaped/active/transient`
- Suggested companions: `ring.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `BladeArcs`: `mixed/medium/short/gravity-shaped/active/transient` | amount `medium` | lifetime `short` | gravity `gravity-shaped` | velocity `active` | blend `mixed`
  - `BladeSparks`: `mixed/light/short/velocity-led/active/transient` | amount `light` | lifetime `short` | gravity `velocity-led` | velocity `active` | blend `mixed`
  - `TipCorona`: `mixed/light/short/gravity-shaped/drift/transient` | amount `light` | lifetime `short` | gravity `gravity-shaped` | velocity `drift` | blend `mixed`
  - `BladeBloom`: `mixed/medium/medium/gravity-dominant/drift/transient` | amount `medium` | lifetime `medium` | gravity `gravity-dominant` | velocity `drift` | blend `mixed`

### explosion_star.tscn

- Summary: 2D impact reference with 1 particle layer(s); primary motion: burst, directional, gravity-driven; reusable as impact-burst, sparkle-breakup.
- Textures: `res://particle/explosion_star_0.png`
- Semantic tags: `additive`, `burst`, `graded-color`, `impact`, `reward`, `sparkle`
- Motion signatures: `burst`, `directional`, `gravity-driven`, `high-velocity`, `scale-over-life`
- Reusable roles: `impact-burst`, `sparkle-breakup`
- Parameter signatures: `add/light/unknown/gravity-shaped/ballistic/burst`
- Suggested companions: `electro_blade_3d.tscn`, `smoke_fog.tscn`, `boom_star.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/light/unknown/gravity-shaped/ballistic/burst` | amount `light` | lifetime `unknown` | gravity `gravity-shaped` | velocity `ballistic` | blend `add`

### firefly.tscn

- Summary: 2D atmosphere reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as ambient-loop, sparkle-breakup.
- Textures: `res://particle/firefly_0.png`
- Semantic tags: `additive`, `ambient`, `graded-color`, `sparkle`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`, `sustain`
- Reusable roles: `ambient-loop`, `sparkle-breakup`
- Parameter signatures: `add/medium/long/velocity-led/active/stream`
- Suggested companions: `blink.tscn`, `smoke_fog.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/medium/long/velocity-led/active/stream` | amount `medium` | lifetime `long` | gravity `velocity-led` | velocity `active` | blend `add`

### flame.tscn

- Summary: 2D fire reference with 1 particle layer(s); primary motion: gravity-driven, high-velocity, scale-over-life; reusable as core-glow.
- Textures: `res://particle/flame_0.png`
- Semantic tags: `additive`, `energy`, `fire`, `graded-color`
- Motion signatures: `gravity-driven`, `high-velocity`, `scale-over-life`, `swirl`
- Reusable roles: `core-glow`
- Parameter signatures: `add/medium/short/velocity-led/ballistic/transient`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/medium/short/velocity-led/ballistic/transient` | amount `medium` | lifetime `short` | gravity `velocity-led` | velocity `ballistic` | blend `add`

### fountain.tscn

- Summary: 2D atmosphere reference with 1 particle layer(s); primary motion: directional, gravity-driven, high-velocity; reusable as general support.
- Textures: `res://particle/fountain_0.png`
- Semantic tags: `ambient`, `graded-color`, `water`
- Motion signatures: `directional`, `gravity-driven`, `high-velocity`, `scale-over-life`, `swirl`
- Reusable roles: `none`
- Parameter signatures: `mix/dense/medium/gravity-shaped/ballistic/transient`
- Suggested companions: `none`
- Node parameter profiles:
  - `Particle2D`: `mix/dense/medium/gravity-shaped/ballistic/transient` | amount `dense` | lifetime `medium` | gravity `gravity-shaped` | velocity `ballistic` | blend `mix`

### glaxy.tscn

- Summary: 2D magic reference with 1 particle layer(s) with custom particle shader; primary motion: orbit, prewarmed, radius-orbit; reusable as core-glow, vortex-core.
- Textures: `res://particle/glaxy_0.png`
- Semantic tags: `additive`, `graded-color`, `magic`, `orbit`
- Motion signatures: `orbit`, `prewarmed`, `radius-orbit`, `size-over-life`, `spawn-variance`, `spin`, `sustain`, `vortex`
- Reusable roles: `core-glow`, `vortex-core`
- Parameter signatures: `add/swarm/medium/neutral/orbit-driven/settled-loop`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/swarm/medium/neutral/orbit-driven/settled-loop` | amount `swarm` | lifetime `medium` | gravity `neutral` | velocity `orbit-driven` | blend `add`

### glaxy3.tscn

- Summary: 2D magic reference with 1 particle layer(s); primary motion: gravity-driven, orbit, scale-over-life; reusable as core-glow, vortex-core.
- Textures: `res://particle/glaxy3_0.png`
- Semantic tags: `additive`, `graded-color`, `magic`, `orbit`
- Motion signatures: `gravity-driven`, `orbit`, `scale-over-life`, `spin`
- Reusable roles: `core-glow`, `vortex-core`
- Parameter signatures: `add/sparse/medium/force-led/unknown/transient`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/sparse/medium/force-led/unknown/transient` | amount `sparse` | lifetime `medium` | gravity `force-led` | velocity `unknown` | blend `add`

### glow.tscn

- Summary: 2D aura reference with 1 particle layer(s); primary motion: active-travel, gravity-driven, scale-over-life; reusable as core-glow.
- Textures: `res://particle/glow_0.png`
- Semantic tags: `additive`, `energy`, `graded-color`, `light`
- Motion signatures: `active-travel`, `gravity-driven`, `scale-over-life`, `swirl`
- Reusable roles: `core-glow`
- Parameter signatures: `add/light/medium/velocity-led/active/transient`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/light/medium/velocity-led/active/transient` | amount `light` | lifetime `medium` | gravity `velocity-led` | velocity `active` | blend `add`

### gold.tscn

- Summary: 2D reward reference with 1 particle layer(s); primary motion: burst, directional, gravity-driven; reusable as impact-burst, reward-accent, sparkle-breakup.
- Textures: `res://particle/gold_0.png`
- Semantic tags: `graded-color`, `reward`, `sparkle`
- Motion signatures: `burst`, `directional`, `gravity-driven`, `high-velocity`, `scale-over-life`, `spin`
- Reusable roles: `impact-burst`, `reward-accent`, `sparkle-breakup`
- Parameter signatures: `mix/medium/long/gravity-shaped/ballistic/burst`
- Suggested companions: `electro_blade_3d.tscn`, `smoke_fog.tscn`, `boom_star.tscn`
- Node parameter profiles:
  - `Particle2D`: `mix/medium/long/gravity-shaped/ballistic/burst` | amount `medium` | lifetime `long` | gravity `gravity-shaped` | velocity `ballistic` | blend `mix`

### gold_boom.tscn

- Summary: 2D impact reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as impact-burst, sparkle-breakup.
- Textures: `res://particle/gold_boom_0.png`
- Semantic tags: `additive`, `burst`, `graded-color`, `impact`, `reward`, `sparkle`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`, `spin`, `sustain`
- Reusable roles: `impact-burst`, `sparkle-breakup`
- Parameter signatures: `add/swarm/long/velocity-led/ballistic/stream`
- Suggested companions: `electro_blade_3d.tscn`, `smoke_fog.tscn`, `boom_star.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/swarm/long/velocity-led/ballistic/stream` | amount `swarm` | lifetime `long` | gravity `velocity-led` | velocity `ballistic` | blend `add`

### leef.tscn

- Summary: 2D atmosphere reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as ambient-loop.
- Textures: `res://particle/leef_0.png`
- Semantic tags: `ambient`, `graded-color`, `nature`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`, `spin`, `sustain`, `swirl`
- Reusable roles: `ambient-loop`
- Parameter signatures: `mix/sparse/long/gravity-shaped/fast/stream`
- Suggested companions: `blink.tscn`, `smoke_fog.tscn`
- Node parameter profiles:
  - `Particle2D`: `mix/sparse/long/gravity-shaped/fast/stream` | amount `sparse` | lifetime `long` | gravity `gravity-shaped` | velocity `fast` | blend `mix`

### light.tscn

- Summary: 2D aura reference with 1 particle layer(s); primary motion: gravity-driven, scale-over-life; reusable as core-glow.
- Textures: `res://particle/light_0.png`
- Semantic tags: `additive`, `energy`, `graded-color`, `light`
- Motion signatures: `gravity-driven`, `scale-over-life`
- Reusable roles: `core-glow`
- Parameter signatures: `add/light/medium/force-led/unknown/transient`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/light/medium/force-led/unknown/transient` | amount `light` | lifetime `medium` | gravity `force-led` | velocity `unknown` | blend `add`

### light2.tscn

- Summary: 2D aura reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as general support.
- Textures: `res://particle/light2_0.png`
- Semantic tags: `energy`, `graded-color`, `light`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`, `sustain`
- Reusable roles: `none`
- Parameter signatures: `mix/sparse/medium/gravity-shaped/active/stream`
- Suggested companions: `none`
- Node parameter profiles:
  - `Particle2D`: `mix/sparse/medium/gravity-shaped/active/stream` | amount `sparse` | lifetime `medium` | gravity `gravity-shaped` | velocity `active` | blend `mix`

### light_face.tscn

- Summary: 2D aura reference with 1 particle layer(s); primary motion: gravity-driven, scale-over-life; reusable as core-glow.
- Textures: `res://particle/light_face_0.png`
- Semantic tags: `additive`, `energy`, `graded-color`, `light`
- Motion signatures: `gravity-driven`, `scale-over-life`
- Reusable roles: `core-glow`
- Parameter signatures: `add/sparse/unknown/force-led/unknown/transient`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/sparse/unknown/force-led/unknown/transient` | amount `sparse` | lifetime `unknown` | gravity `force-led` | velocity `unknown` | blend `add`

### loading.tscn

- Summary: 2D tech reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as core-glow.
- Textures: `res://particle/loading_0.png`
- Semantic tags: `additive`, `graded-color`, `magic`, `tech`, `ui`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`
- Reusable roles: `core-glow`
- Parameter signatures: `add/light/short/gravity-dominant/active/transient`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/light/short/gravity-dominant/active/transient` | amount `light` | lifetime `short` | gravity `gravity-dominant` | velocity `active` | blend `add`

### mask.tscn

- Summary: 2D magic reference with 1 particle layer(s); primary motion: directional, gravity-driven, scale-over-life; reusable as core-glow.
- Textures: `res://particle/mask_0.png`
- Semantic tags: `additive`, `graded-color`, `magic`, `organic`
- Motion signatures: `directional`, `gravity-driven`, `scale-over-life`
- Reusable roles: `core-glow`
- Parameter signatures: `add/dense/short/force-led/unknown/transient`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/dense/short/force-led/unknown/transient` | amount `dense` | lifetime `short` | gravity `force-led` | velocity `unknown` | blend `add`

### meteor.tscn

- Summary: 2D impact reference with 1 particle layer(s); primary motion: directional, gravity-driven, high-velocity; reusable as directional-trail, impact-burst.
- Textures: `res://particle/meteor_0.png`
- Semantic tags: `additive`, `directional`, `graded-color`, `impact`
- Motion signatures: `directional`, `gravity-driven`, `high-velocity`, `scale-over-life`, `sustain`
- Reusable roles: `directional-trail`, `impact-burst`
- Parameter signatures: `add/light/medium/velocity-led/ballistic/stream`
- Suggested companions: `battle.tscn`, `blink.tscn`, `smoke_fog.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/light/medium/velocity-led/ballistic/stream` | amount `light` | lifetime `medium` | gravity `velocity-led` | velocity `ballistic` | blend `add`

### radial_glow.tscn

- Summary: 2D aura reference with 1 particle layer(s); primary motion: directional, gravity-driven, scale-over-life; reusable as core-glow.
- Textures: `res://particle/radial_glow_0.png`
- Semantic tags: `additive`, `energy`, `graded-color`, `light`, `pulse`
- Motion signatures: `directional`, `gravity-driven`, `scale-over-life`, `sustain`
- Reusable roles: `core-glow`
- Parameter signatures: `add/sparse/long/force-led/unknown/stream`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/sparse/long/force-led/unknown/stream` | amount `sparse` | lifetime `long` | gravity `force-led` | velocity `unknown` | blend `add`

### rain.tscn

- Summary: 2D atmosphere reference with 1 particle layer(s); primary motion: directional, gravity-driven, scale-over-life; reusable as general support.
- Textures: `res://particle/rain_0.png`
- Semantic tags: `additive`, `ambient`, `graded-color`, `water`
- Motion signatures: `directional`, `gravity-driven`, `scale-over-life`
- Reusable roles: `none`
- Parameter signatures: `add/light/instant/force-led/unknown/transient`
- Suggested companions: `none`
- Node parameter profiles:
  - `Particle2D`: `add/light/instant/force-led/unknown/transient` | amount `light` | lifetime `instant` | gravity `force-led` | velocity `unknown` | blend `add`

### ray.tscn

- Summary: 2D trail reference with 1 particle layer(s); primary motion: directional, gravity-driven, scale-over-life; reusable as directional-trail.
- Textures: `res://particle/ray_0.png`
- Semantic tags: `additive`, `beam`, `directional`, `graded-color`
- Motion signatures: `directional`, `gravity-driven`, `scale-over-life`
- Reusable roles: `directional-trail`
- Parameter signatures: `add/sparse/short/force-led/unknown/transient`
- Suggested companions: `battle.tscn`, `blink.tscn`, `smoke_fog.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/sparse/short/force-led/unknown/transient` | amount `sparse` | lifetime `short` | gravity `force-led` | velocity `unknown` | blend `add`

### ribbon.tscn

- Summary: 2D trail reference with 1 particle layer(s); primary motion: burst, directional, gravity-driven; reusable as directional-trail, impact-burst.
- Textures: `res://particle/ribbon_0.png`
- Semantic tags: `arc`, `directional`, `graded-color`
- Motion signatures: `burst`, `directional`, `gravity-driven`, `high-velocity`, `scale-over-life`, `spin`, `swirl`
- Reusable roles: `directional-trail`, `impact-burst`
- Parameter signatures: `mix/dense/long/gravity-shaped/ballistic/burst`
- Suggested companions: `battle.tscn`, `blink.tscn`, `smoke_fog.tscn`
- Node parameter profiles:
  - `Particle2D`: `mix/dense/long/gravity-shaped/ballistic/burst` | amount `dense` | lifetime `long` | gravity `gravity-shaped` | velocity `ballistic` | blend `mix`

### ribbon2.tscn

- Summary: 2D trail reference with 1 particle layer(s); primary motion: directional, gravity-driven, high-velocity; reusable as directional-trail.
- Textures: `res://particle/ribbon2_0.png`
- Semantic tags: `additive`, `arc`, `directional`, `graded-color`
- Motion signatures: `directional`, `gravity-driven`, `high-velocity`, `scale-over-life`, `spin`, `swirl`
- Reusable roles: `directional-trail`
- Parameter signatures: `add/light/medium/velocity-led/ballistic/transient`
- Suggested companions: `battle.tscn`, `blink.tscn`, `smoke_fog.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/light/medium/velocity-led/ballistic/transient` | amount `light` | lifetime `medium` | gravity `velocity-led` | velocity `ballistic` | blend `add`

### ring.tscn

- Summary: 2D aura reference with 1 particle layer(s) with custom particle shader; primary motion: orbit, prewarmed, radius-orbit; reusable as core-glow, ring-accent, vortex-core.
- Textures: `res://particle/ring_0.png`
- Semantic tags: `additive`, `energy`, `graded-color`, `ring`
- Motion signatures: `orbit`, `prewarmed`, `radius-orbit`, `size-over-life`, `spawn-variance`, `spin`, `sustain`, `vortex`
- Reusable roles: `core-glow`, `ring-accent`, `vortex-core`
- Parameter signatures: `add/sparse/long/neutral/orbit-driven/settled-loop`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/sparse/long/neutral/orbit-driven/settled-loop` | amount `sparse` | lifetime `long` | gravity `neutral` | velocity `orbit-driven` | blend `add`

### ring2.tscn

- Summary: 2D aura reference with 1 particle layer(s); primary motion: gravity-driven, orbit, scale-over-life; reusable as core-glow, orbiting-accent, ring-accent.
- Textures: `res://particle/ring2_0.png`
- Semantic tags: `additive`, `energy`, `graded-color`, `ring`
- Motion signatures: `gravity-driven`, `orbit`, `scale-over-life`, `spin`
- Reusable roles: `core-glow`, `orbiting-accent`, `ring-accent`
- Parameter signatures: `add/sparse/short/force-led/unknown/transient`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/sparse/short/force-led/unknown/transient` | amount `sparse` | lifetime `short` | gravity `force-led` | velocity `unknown` | blend `add`

### smoke2.tscn

- Summary: 2D atmosphere reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as general support.
- Textures: `res://particle/smoke2_0.png`
- Semantic tags: `graded-color`, `smoke`, `soft`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`
- Reusable roles: `none`
- Parameter signatures: `mix/dense/medium/gravity-shaped/fast/transient`
- Suggested companions: `none`
- Node parameter profiles:
  - `Particle2D`: `mix/dense/medium/gravity-shaped/fast/transient` | amount `dense` | lifetime `medium` | gravity `gravity-shaped` | velocity `fast` | blend `mix`

### smoke_fog.tscn

- Summary: 2D atmosphere reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as ambient-loop, soft-residue.
- Textures: `res://particle/smoke_fog_0.png`
- Semantic tags: `additive`, `graded-color`, `smoke`, `soft`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`, `sustain`
- Reusable roles: `ambient-loop`, `soft-residue`
- Parameter signatures: `add/medium/persistent/velocity-led/active/stream`
- Suggested companions: `blink.tscn`, `snow.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/medium/persistent/velocity-led/active/stream` | amount `medium` | lifetime `persistent` | gravity `velocity-led` | velocity `active` | blend `add`

### snow.tscn

- Summary: 2D atmosphere reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as ambient-loop, soft-residue.
- Textures: `res://particle/snow_0.png`
- Semantic tags: `additive`, `ambient`, `graded-color`, `soft`, `water`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`, `sustain`
- Reusable roles: `ambient-loop`, `soft-residue`
- Parameter signatures: `add/swarm/long/gravity-dominant/active/stream`
- Suggested companions: `blink.tscn`, `smoke_fog.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/swarm/long/gravity-dominant/active/stream` | amount `swarm` | lifetime `long` | gravity `gravity-dominant` | velocity `active` | blend `add`

### srtar3.tscn

- Summary: 2D reward reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as reward-accent, sparkle-breakup.
- Textures: `res://particle/srtar3_0.png`
- Semantic tags: `additive`, `graded-color`, `reward`, `sparkle`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`
- Reusable roles: `reward-accent`, `sparkle-breakup`
- Parameter signatures: `add/light/short/velocity-led/fast/transient`
- Suggested companions: `blink.tscn`, `boom_star.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/light/short/velocity-led/fast/transient` | amount `light` | lifetime `short` | gravity `velocity-led` | velocity `fast` | blend `add`

### star2.tscn

- Summary: 2D reward reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as reward-accent, sparkle-breakup.
- Textures: `res://particle/star2_0.png`
- Semantic tags: `additive`, `graded-color`, `reward`, `sparkle`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`, `spin`
- Reusable roles: `reward-accent`, `sparkle-breakup`
- Parameter signatures: `add/light/short/velocity-led/fast/transient`
- Suggested companions: `blink.tscn`, `boom_star.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/light/short/velocity-led/fast/transient` | amount `light` | lifetime `short` | gravity `velocity-led` | velocity `fast` | blend `add`

### star4.tscn

- Summary: 2D reward reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as reward-accent, sparkle-breakup.
- Textures: `res://particle/star4_0.png`
- Semantic tags: `additive`, `graded-color`, `reward`, `sparkle`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`
- Reusable roles: `reward-accent`, `sparkle-breakup`
- Parameter signatures: `add/medium/unknown/velocity-led/fast/transient`
- Suggested companions: `blink.tscn`, `boom_star.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/medium/unknown/velocity-led/fast/transient` | amount `medium` | lifetime `unknown` | gravity `velocity-led` | velocity `fast` | blend `add`

### star5.tscn

- Summary: 2D reward reference with 1 particle layer(s); primary motion: burst, directional, gravity-driven; reusable as impact-burst, reward-accent, sparkle-breakup.
- Textures: `res://particle/star5_0.png`
- Semantic tags: `additive`, `graded-color`, `reward`, `sparkle`
- Motion signatures: `burst`, `directional`, `gravity-driven`, `high-velocity`, `scale-over-life`, `spin`
- Reusable roles: `impact-burst`, `reward-accent`, `sparkle-breakup`
- Parameter signatures: `add/light/unknown/gravity-shaped/ballistic/burst`
- Suggested companions: `electro_blade_3d.tscn`, `smoke_fog.tscn`, `boom_star.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/light/unknown/gravity-shaped/ballistic/burst` | amount `light` | lifetime `unknown` | gravity `gravity-shaped` | velocity `ballistic` | blend `add`

### star_boom.tscn

- Summary: 2D impact reference with 1 particle layer(s); primary motion: burst, gravity-driven, high-velocity; reusable as impact-burst, sparkle-breakup.
- Textures: `res://particle/star_boom_0.png`
- Semantic tags: `burst`, `graded-color`, `impact`, `reward`, `sparkle`
- Motion signatures: `burst`, `gravity-driven`, `high-velocity`, `scale-over-life`, `spin`
- Reusable roles: `impact-burst`, `sparkle-breakup`
- Parameter signatures: `mix/medium/instant/gravity-shaped/ballistic/burst`
- Suggested companions: `electro_blade_3d.tscn`, `smoke_fog.tscn`, `boom_star.tscn`
- Node parameter profiles:
  - `Particle2D`: `mix/medium/instant/gravity-shaped/ballistic/burst` | amount `medium` | lifetime `instant` | gravity `gravity-shaped` | velocity `ballistic` | blend `mix`

### sun_eat.tscn

- Summary: 2D magic reference with 1 particle layer(s) with custom particle shader; primary motion: orbit, prewarmed, radius-orbit; reusable as core-glow, vortex-core.
- Textures: `res://particle/sun_eat_0.png`
- Semantic tags: `additive`, `energy`, `graded-color`, `light`, `magic`
- Motion signatures: `orbit`, `prewarmed`, `radius-orbit`, `size-over-life`, `spawn-variance`, `spin`, `vortex`
- Reusable roles: `core-glow`, `vortex-core`
- Parameter signatures: `add/swarm/medium/neutral/orbit-driven/transient`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/swarm/medium/neutral/orbit-driven/transient` | amount `swarm` | lifetime `medium` | gravity `neutral` | velocity `orbit-driven` | blend `add`

### technology.tscn

- Summary: 2D tech reference with 1 particle layer(s); primary motion: gravity-driven, scale-over-life, spin; reusable as core-glow.
- Textures: `res://particle/technology_0.png`
- Semantic tags: `additive`, `graded-color`, `magic`, `tech`
- Motion signatures: `gravity-driven`, `scale-over-life`, `spin`
- Reusable roles: `core-glow`
- Parameter signatures: `add/sparse/medium/force-led/unknown/transient`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/sparse/medium/force-led/unknown/transient` | amount `sparse` | lifetime `medium` | gravity `force-led` | velocity `unknown` | blend `add`

### trail.tscn

- Summary: 2D trail reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as directional-trail.
- Textures: `res://particle/trail_0.png`
- Semantic tags: `directional`, `graded-color`, `slash`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`, `sustain`, `swirl`
- Reusable roles: `directional-trail`
- Parameter signatures: `mix/swarm/long/gravity-shaped/fast/stream`
- Suggested companions: `battle.tscn`, `blink.tscn`, `smoke_fog.tscn`
- Node parameter profiles:
  - `Particle2D`: `mix/swarm/long/gravity-shaped/fast/stream` | amount `swarm` | lifetime `long` | gravity `gravity-shaped` | velocity `fast` | blend `mix`

### trail2.tscn

- Summary: 2D trail reference with 1 particle layer(s); primary motion: directional, gravity-driven, high-velocity; reusable as directional-trail.
- Textures: `res://particle/trail2_0.png`
- Semantic tags: `additive`, `directional`, `graded-color`, `slash`
- Motion signatures: `directional`, `gravity-driven`, `high-velocity`, `scale-over-life`, `spin`, `swirl`
- Reusable roles: `directional-trail`
- Parameter signatures: `add/medium/short/velocity-led/ballistic/transient`
- Suggested companions: `battle.tscn`, `blink.tscn`, `smoke_fog.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/medium/short/velocity-led/ballistic/transient` | amount `medium` | lifetime `short` | gravity `velocity-led` | velocity `ballistic` | blend `add`

### upgrade.tscn

- Summary: 2D reward reference with 1 particle layer(s); primary motion: active-travel, burst, directional; reusable as core-glow, impact-burst, reward-accent.
- Textures: `res://particle/upgrade_0.png`
- Semantic tags: `additive`, `energy`, `graded-color`, `reward`, `sparkle`
- Motion signatures: `active-travel`, `burst`, `directional`, `gravity-driven`, `scale-over-life`, `spin`
- Reusable roles: `core-glow`, `impact-burst`, `reward-accent`, `sparkle-breakup`
- Parameter signatures: `add/medium/medium/gravity-dominant/ballistic/burst`
- Suggested companions: `electro_blade_3d.tscn`, `boom_star.tscn`, `ring2.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/medium/medium/gravity-dominant/ballistic/burst` | amount `medium` | lifetime `medium` | gravity `gravity-dominant` | velocity `ballistic` | blend `add`

### water_flow.tscn

- Summary: 2D water reference with 1 particle layer(s); primary motion: active-travel, directional, gravity-driven; reusable as water-accent.
- Textures: `res://particle/water_flow_0.png`
- Semantic tags: `additive`, `graded-color`, `water`
- Motion signatures: `active-travel`, `directional`, `gravity-driven`, `scale-over-life`, `spin`
- Reusable roles: `water-accent`
- Parameter signatures: `add/dense/short/velocity-led/fast/transient`
- Suggested companions: `electro_blade_3d.tscn`, `smoke_fog.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/dense/short/velocity-led/fast/transient` | amount `dense` | lifetime `short` | gravity `velocity-led` | velocity `fast` | blend `add`

### water_ripple.tscn

- Summary: 2D water reference with 1 particle layer(s); primary motion: active-travel, gravity-driven, scale-over-life; reusable as ring-accent, water-accent.
- Textures: `res://particle/water_ripple_0.png`
- Semantic tags: `graded-color`, `ring`, `water`
- Motion signatures: `active-travel`, `gravity-driven`, `scale-over-life`
- Reusable roles: `ring-accent`, `water-accent`
- Parameter signatures: `mix/light/medium/velocity-led/fast/transient`
- Suggested companions: `electro_blade_3d.tscn`, `smoke_fog.tscn`
- Node parameter profiles:
  - `Particle2D`: `mix/light/medium/velocity-led/fast/transient` | amount `light` | lifetime `medium` | gravity `velocity-led` | velocity `fast` | blend `mix`

### wave.tscn

- Summary: 2D water reference with 1 particle layer(s); primary motion: gravity-driven, scale-over-life; reusable as ring-accent, water-accent.
- Textures: `res://particle/wave_0.png`
- Semantic tags: `additive`, `graded-color`, `pulse`, `ring`, `water`
- Motion signatures: `gravity-driven`, `scale-over-life`
- Reusable roles: `ring-accent`, `water-accent`
- Parameter signatures: `add/sparse/short/force-led/unknown/transient`
- Suggested companions: `electro_blade_3d.tscn`, `smoke_fog.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/sparse/short/force-led/unknown/transient` | amount `sparse` | lifetime `short` | gravity `force-led` | velocity `unknown` | blend `add`

### whirlpool.tscn

- Summary: 2D water reference with 1 particle layer(s) with custom particle shader; primary motion: orbit, prewarmed, radius-orbit; reusable as ambient-loop, core-glow, vortex-core.
- Textures: `res://particle/whirlpool_0.png`
- Semantic tags: `additive`, `graded-color`, `magic`, `vortex`, `water`
- Motion signatures: `orbit`, `prewarmed`, `radius-orbit`, `size-over-life`, `spawn-variance`, `spin`, `sustain`, `vortex`
- Reusable roles: `ambient-loop`, `core-glow`, `vortex-core`, `water-accent`
- Parameter signatures: `add/light/long/neutral/orbit-driven/settled-loop`
- Suggested companions: `blink.tscn`, `smoke_fog.tscn`, `electro_blade_3d.tscn`
- Node parameter profiles:
  - `Particle2D`: `add/light/long/neutral/orbit-driven/settled-loop` | amount `light` | lifetime `long` | gravity `neutral` | velocity `orbit-driven` | blend `add`
