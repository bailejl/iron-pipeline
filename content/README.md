# Content

All balance data lives here as YAML, validated against `schemas/` by `IronPipeline.Tools validate-content`
(to be implemented). Nothing in `src/` hard-codes a balance number.

- `units/`     unit types (movement points, fuel capacity, ammo, attack, defense, supply class)
- `terrain/`   terrain types (movement cost, defense modifier)
- `factions/`  generated with `assets-src/prompts/factions.md`; the `ai_profile` block drives the AI
- `scenarios/` maps, start positions, victory conditions

Licensing: all rights reserved (see LICENSE in this directory).
