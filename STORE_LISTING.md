# Godot Asset Store Listing Draft

## Title

Particle2DX Importer

## Short Description

Convert Cocos2d-x ParticleDesigner plist effects into Godot GPUParticles2D scenes.

## Description

Particle2DX Importer helps Godot 4 projects reuse legacy Cocos2d-x ParticleDesigner effects. It imports `.plist` particle files one by one or in batches from a folder, decodes embedded or adjacent textures, and saves reusable `GPUParticles2D` scenes inside the current project.

The importer supports gravity and radius emitter modes, common blend modes, particle lifetime, finite emitter duration, source variance, acceleration, rotation, scale curves, and color ramps. It can be used from the editor through `Project > Tools > Convert Particle2D Plist...` or from headless Godot for batch conversion.

Some Cocos particle behaviors do not map one-to-one to Godot particle properties. The importer approximates those cases and reports warnings when a conversion cannot be represented exactly.

## Metadata

- Version: 1.0.0
- Godot version: 4.x
- Tested version: 4.7
- License: MIT
- Category suggestion: Tools
- Tags: particles, importer, cocos2d-x, plist, gpuparticles2d, 2d, editor

## Media Checklist

- 16:9 thumbnail, at least 1280x720.
- One screenshot of the editor menu or generated scene.
- One screenshot or short GIF showing a converted particle effect.

## External Links

- Documentation: repository README
- Issue tracker: repository issues
