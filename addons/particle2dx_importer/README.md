# Particle2DX Importer

Particle2DX Importer is a Godot 4 editor plugin and command-line converter for Cocos2d-x ParticleDesigner `.plist` particle effects. It creates Godot `GPUParticles2D` scenes and writes recovered textures next to the generated scene.

## Features

- Converts ParticleDesigner plist files to `GPUParticles2D` scenes.
- Decodes embedded `textureImageData` stored as raw, gzip, or deflate base64 image bytes.
- Supports external plist textures referenced by `textureFileName`.
- Maps gravity mode, radius mode, particle lifetime, emission shape, color ramps, scale curves, rotation, acceleration, source variance, and common blend modes.
- Provides an editor menu item for one-off conversion and a headless CLI script for batch conversion.
- Names embedded textures from the generated scene, such as `fire_0.png`, so multiple plist files do not overwrite each other.

## Requirements

- Godot 4.x. The plugin is tested in Godot 4.7.
- A Cocos2d-x ParticleDesigner plist file.
- Embedded or adjacent PNG, JPEG, or WebP texture data.

## Installation

1. Copy `addons/particle2dx_importer` into your Godot project.
2. Open `Project > Project Settings > Plugins`.
3. Enable `Particle2DX Importer`.

## Editor Usage

1. Choose `Project > Tools > Convert Particle2D Plist...`.
2. Pick a `.plist` file from disk.
3. Choose a `res://` `.tscn` output path.

The plugin writes decoded textures next to the scene, requests texture import, refreshes the filesystem, and opens the generated scene.

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

## CLI Options

| Option | Description |
| --- | --- |
| `-i`, `--input <path>` | Source Cocos2d-x particle plist. |
| `-o`, `--output <path>` | Output `.tscn`. Must be `res://`, project-relative, or an absolute path inside the project. |
| `--texture-output <path>` | Output texture path. Defaults next to the scene. |
| `--root-name <name>` | Root `GPUParticles2D` node name. |
| `--preserve-source-position` | Keep `sourcePositionx/y` on the root node. |
| `--no-overwrite` | Fail if the output scene already exists. |
| `-h`, `--help` | Show CLI help. |

## Conversion Notes

- Cocos uses a y-up particle angle/gravity convention, so y values are flipped for Godot 2D.
- `sourcePositionx/y` is ignored by default so the effect can be instanced at the scene origin. Use `--preserve-source-position` to keep it.
- Finite Cocos `duration` is treated as the emitter's active emission window, not particle lifetime.
- Radius mode uses a custom particles shader so `maxRadius`, `minRadius`, `rotatePerSecond`, and related variances follow Cocos' per-particle orbit behavior more closely.
- Gravity mode maps `startColor`/`finishColor` to a lifetime `color_ramp`; color and size variance are approximated where Godot exposes different randomization controls.
- Exported PNG textures are rewritten from decoded pixels, stripped of ancillary metadata chunks, and tagged with an `Author=AI` PNG text chunk.

## License

This addon is available under the MIT License. See `LICENSE` for details.
