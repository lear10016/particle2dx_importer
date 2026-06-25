# Release Checklist

## Repository

- `addons/particle2dx_importer/plugin.cfg` has the release version.
- `README.md`, `CHANGELOG.md`, and `LICENSE` are present at the repository root.
- `addons/particle2dx_importer/README.md` and `addons/particle2dx_importer/LICENSE` are present inside the installable addon.
- `.godot/` and other generated files are not tracked.

## Validation

- Open the project in the target Godot version.
- Enable `Particle2DX Importer` under `Project > Project Settings > Plugins`.
- Convert at least one embedded-texture plist from `plist/`.
- Convert at least one external-texture plist, if available.
- Run the CLI once in headless mode.

## Package

- Commit the release tree.
- Build the upload zip with:

```bash
git archive --format=zip --output particle2dx_importer-1.0.0.zip HEAD
```

- Inspect the zip before upload. It should contain `addons/particle2dx_importer/` plus the top-level README, CHANGELOG, and LICENSE.

## Store Page

- Use the text from `STORE_LISTING.md`.
- Select MIT as the license.
- Upload 16:9 media.
- Link the source repository and issue tracker.
