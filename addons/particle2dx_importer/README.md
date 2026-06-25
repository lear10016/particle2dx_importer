# Particle2DX Importer

Particle2DX Importer converts Cocos2d-x ParticleDesigner `.plist` particle effects into Godot 4 `GPUParticles2D` scenes.

## Requirements

- Godot 4.x
- A Cocos2d-x ParticleDesigner plist file
- Embedded texture data or an adjacent PNG, JPEG, or WebP texture referenced by `textureFileName`

## Installation

1. Copy `addons/particle2dx_importer` into your Godot project.
2. Open `Project > Project Settings > Plugins`.
3. Enable `Particle2DX Importer`.

## Editor Usage

1. Choose `Project > Tools > Convert Particle2D Plist...`.
2. Select a source `.plist` file.
3. Choose a `res://` `.tscn` output path.

The generated scene is saved as a `GPUParticles2D` root node. If the plist contains embedded texture data, the decoded texture is written next to the generated scene and imported by Godot.

## Batch Editor Usage

1. Choose `Project > Tools > Convert Particle2D Plist Folder...`.
2. Select a filesystem folder that contains `.plist` files.
3. Select a `res://` output folder for the converted scenes.

The plugin converts every `.plist` file in the selected folder, writes each scene into the chosen `res://` directory, and shows a summary of successes, warnings, and failures when the batch completes.

## Command Line Usage

```bash
godot --headless \
  --path /path/to/project \
  --script res://addons/particle2dx_importer/cli_convert.gd \
  -- /path/to/particle.plist res://converted_particles/particle.tscn
```

Named arguments:

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
- `sourcePositionx/y` is ignored by default so the converted effect can be instanced at the scene origin. Use `--preserve-source-position` to keep it.
- Finite Cocos `duration` is treated as the active emission window, not particle lifetime.
- Radius mode uses a custom particles shader to approximate `maxRadius`, `minRadius`, `rotatePerSecond`, and related variances.
- Gravity mode maps `startColor` and `finishColor` to a lifetime `color_ramp`. Color and size variance are approximated where Godot exposes different randomization controls.
- Embedded PNG textures are rewritten from decoded pixels and stripped of ancillary metadata chunks.

## License

MIT License. See `LICENSE`.
