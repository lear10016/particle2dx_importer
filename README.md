# Particle2DX Importer

Particle2DX Importer is a Godot 4 editor plugin and command-line converter for Cocos2d-x ParticleDesigner `.plist` particle effects. It creates `GPUParticles2D` scenes and recovers embedded or adjacent particle textures.

## Features

- Converts ParticleDesigner plist files to reusable Godot `.tscn` scenes.
- Decodes embedded `textureImageData` from raw, gzip, or deflate base64 image bytes.
- Supports external `textureFileName` images in PNG, JPEG, and WebP formats.
- Maps gravity mode, radius mode, color ramps, size curves, rotation, acceleration, source variance, finite duration, and common blend modes.
- Provides both an editor menu command and a headless CLI script for batch conversion.

## Compatibility

- Godot 4.x
- Tested with Godot 4.7

## Installation

1. Copy `addons/particle2dx_importer` into your Godot project.
2. Open `Project > Project Settings > Plugins`.
3. Enable `Particle2DX Importer`.

## Editor Usage

1. Choose `Project > Tools > Convert Particle2D Plist...`.
2. Pick a `.plist` file from disk.
3. Choose a `res://` `.tscn` output path.

The plugin writes decoded textures next to the generated scene, refreshes the filesystem, and opens the generated scene.

For batch conversion, use `Project > Tools > Convert Particle2D Plist Folder...`, choose a source folder on disk, then choose a `res://` output folder. Every `.plist` in that folder is converted in one pass and summarized at the end.

## Command Line Usage

```bash
godot --headless \
  --path /path/to/project \
  --script res://addons/particle2dx_importer/cli_convert.gd \
  -- /path/to/particle.plist res://converted_particles/particle.tscn
```

Named arguments are also supported:

```bash
godot --headless \
  --path /path/to/project \
  --script res://addons/particle2dx_importer/cli_convert.gd \
  -- --input /path/to/particle.plist --output res://converted_particles/particle.tscn
```

## Development Repository

This repository includes a small Godot demo project plus sample plist files under `plist/` and generated sample scenes under `particle/`. The Asset Store release archive is kept clean with `.gitattributes` so generated GitHub archives export only the installable addon and top-level documentation.

## AI Particle Practice

This repository also contains an in-project AI particle workflow practice for Godot 2D particle VFX. See:

- [AI_PARTICLE_PIPELINE.md](AI_PARTICLE_PIPELINE.md)
- [skills/godot-particle-vfx-director/SKILL.md](skills/godot-particle-vfx-director/SKILL.md)

To build a release archive from a committed tree:

```bash
git archive --format=zip --output particle2dx_importer-1.0.0.zip HEAD
```

## License

MIT License. See `LICENSE` and `addons/particle2dx_importer/LICENSE`.
