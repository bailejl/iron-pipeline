---
name: asset-pipeline
description: Rules for binary assets in Iron Pipeline — Git LFS tracking, the assets-src/manifest.yaml provenance entry (fields, allowed values), licensing, Godot import formats, and the no-real-world-IP rule. Load before adding or changing anything under assets/ or assets-src/, or when reviewing such a change.
---
# Asset pipeline rules

Every binary under `assets/` is shipped content and a legal record. The manifest doubles as the Steam AI-generated-content disclosure, so a missing or wrong entry is a release blocker, not a nit.

## Layout
| Path | Holds |
|---|---|
| `assets/` | shipped binaries only. `assets/LICENSE` (all rights reserved; not MIT) covers everything here. |
| `assets-src/manifest.yaml` | one provenance entry per file under `assets/` |
| `assets-src/prompts/` | prompt files referenced by `prompt_file` |
| `assets-src/out/` | raw generation scratch; gitignored, never committed |

## Git LFS
`.gitattributes` routes these through LFS: `*.png *.jpg *.webp *.ogg *.wav *.mp3 *.ttf *.otf`.
- Verify a file: `git check-attr filter <file>` must print `filter: lfs`.
- A binary type not in that list (e.g. `.exr`, `.glb`, `.flac`) needs a `.gitattributes` line in the same PR. Otherwise it lands in plain git history.

## Manifest entry
`path` is relative to `assets/` and must match the file exactly. Field set and allowed values (from the manifest header):

| Field | Required | Values |
|---|---|---|
| `path` | always | e.g. `units/mbt-ridgeback.png` |
| `kind` | always | `sprite`, `tile`, `icon`, `music`, `sfx`, `voice`, `font` |
| `source` | always | `generated`, `purchased`, `handmade`, `public-domain` |
| `tool` | if `generated` | e.g. `ComfyUI` |
| `model` | if `generated` | e.g. `z-image-turbo-fp8` |
| `prompt_file` | if `generated` | path under `assets-src/`; the file must exist and be committed |
| `seed` | if `generated` | integer |
| `post` | if post-processed | what was done after generation (bg removal, resize, palette) |
| `license` | always | `all-rights-reserved`, `CC0`, or the tool/vendor license |
| `commercial_ok` | always | `true`/`false`; `false` cannot ship |
| `approved_by` | always | initials of the human who approved it |
| `approved_on` | always | `YYYY-MM-DD` |

`scripts/check-asset-manifest.sh` (run by `scripts/verify.sh`) only checks that a `path:` entry exists. Field completeness, valid values, `prompt_file` existence and license are checked by review, not the script.

## Formats for Godot import
- Sprites, tiles, icons: PNG with alpha.
- Music, sfx, voice: OGG.
- Fonts: TTF or OTF.
- Pointy-top hex tiles must fit the layout in the `godot-presentation` skill.

## No real-world IP
Original names and designs only, matching `assets-src/prompts/factions.md`:
- No real nations, alliances, armed forces, or thinly-veiled copies.
- No real trademarks, logos, insignia, flags or symbols.
- No named real vehicles or weapons.

This applies to prompts, filenames, manifest text and the image itself.
