# Spec 0002 — Map and terrain

**Status:** implemented
**Size:** small
**Budget:** 6 commits, 1 review round
**Pillar(s):** big maps, readable tactics
**Features:** features/0002-map-and-terrain.feature
**Plan:** —

## Intent
Nothing in the Sim knows what a hex is *made of*. This adds a rectangular hex map of W×H cells stored as a flat array, terrain types loaded from `content/terrain/*.yaml` (movement cost in MP, defense modifier), a terrain-at-hex query and a bounds check. Pathfinding (0003) and units (0004) build on it. Serves big maps (flat array, O(1) lookup) and readable tactics (terrain is what makes positions matter).

## Scope
- In: `HexMap` (width, height, flat `terrain` array); `TerrainType` + loader from `content/terrain/*.yaml`, **one file per terrain type** (`plains.yaml`, `forest.yaml`, …), with schema in `content/schemas/`; `InBounds(HexCoord)`; `TerrainAt(HexCoord)`; hex↔index mapping; initial terrain content files.
- Out (explicitly): pathfinding (0003), units and stacks (0004), rendering, scenario files and map authoring format, procedural generation, elevation/line of sight, roads/rivers as hex edges.
- Unchanged: `HexCoord` (0001).

## Numbers
Values live in `content/terrain/*.yaml`. Movement cost is integer MP; defense modifier is integer percent (no floats, determinism).

| name | value | unit | tolerance | range |
|---|---|---|---|---|
| map width W | per map | hexes | exact | 1–512 |
| map height H | per map | hexes | exact | 1–512 |
| cells in map | W×H | cells | exact | 1–262144 |
| plains movement cost | 1 | MP | exact | 1–9 |
| forest movement cost | 2 | MP | exact | 1–9 |
| hills movement cost | 3 | MP | exact | 1–9 |
| plains defense modifier | 0 | % | exact | −50–+100 |
| forest defense modifier | 25 | % | exact | −50–+100 |
| hills defense modifier | 40 | % | exact | −50–+100 |
| water | impassable | — | exact | passable: false |

## Decisions & Ambiguity Log
| # | Decision | Resolved by (human / inferable) | Answer / rationale |
|---|---|---|---|
| 1 | Axial storage with flat array (not 2D array) | inferable | Task statement + 0001 decision 1 (axial); flat array is the stated storage |
| 2 | Defense modifier as integer percent, movement cost as integer MP | inferable | Determinism rules forbid floats in Sim; glossary says cost is in MP |
| 3 | Numbers/types in `content/terrain/*.yaml`, not C# | inferable | CLAUDE.md rule 5 |
| 4 | Sim is orientation-agnostic | inferable | CLAUDE.md rule 6, ADR 0004 |
| 5 | Out-of-bounds query behavior | inferable | Error case: `TerrainAt` throws `ArgumentOutOfRangeException`; callers use `InBounds` first (matches 0001 `Ring` style) |
| 6 | How impassable terrain (e.g. water) is represented | human | Explicit passable: false in YAML (default true); movement_cost is required only when passable. TerrainType.IsPassable plus MovementCost that throws if queried on impassable terrain. No sentinel numbers. |
| 7 | What "rectangular W×H" means in axial coords: offset layout (odd-r / even-r) or raw `q∈[0,W)`, `r∈[0,H)` parallelogram? Pointy-top rendering (ADR 0004) suggests odd-r so the map looks rectangular | human | Rectangular in odd-r offset coordinates (rows), the natural rectangle for pointy-top. Public API takes HexCoord (axial); odd-r↔axial conversion lives in HexMap. This is a map-shape decision, not rendering, so it belongs in the Sim. |
| 8 | Initial terrain set and the cost/defense values in Numbers (plains/forest/hills/water) | human | Four types for now: plains 1 MP / 0 %, forest 2 / +25, hills 3 / +40, water impassable / 0. Cities and roads come with their own spec. |
| 9 | Terrain identity in the map array: string id from YAML vs. compact integer index into a loaded terrain table | human | Map array stores a compact byte index into the loaded terrain table; YAML ids are strings. 256 terrain types is plenty and keeps a 512×512 map at 256 KB. |
| 10 | Index order of the flat array: row-major by r (index = r·W + col) vs column-major | human | Row-major: `index = row * W + col` in offset coords. |
| 11 | Which cell is origin: top-left (0,0), or centered | human | Origin is the top-left cell: offset (col 0, row 0) = axial (0,0); rows increase southward, matching the layout `y = 1.5 r`. |
| 12 | Behavior when a map references an unknown terrain id, or YAML violates schema | human | Any unknown id, missing field, duplicate id or schema violation fails the whole load with an error naming file and field. No partial loads. (S08 already covers this; add “unknown id referenced by a map” when scenarios exist.) |
| 13 | Does the map constructor require every cell be set (no default fill), or fill with a default terrain | human | No default fill. `HexMap.Filled(w, h, terrain)` is the only constructor for now; the scenario loader (later) sets cells explicitly. |

## Acceptance criteria
| AC | Statement | Scenarios |
|---|---|---|
| 1 | A map of W×H has exactly W·H cells; W or H < 1 is rejected | S01, S02 |
| 2 | `InBounds` is true for exactly the map's cells and false outside | S03, S04 |
| 3 | `TerrainAt` returns the terrain stored for an in-bounds hex; out-of-bounds throws | S05, S06 |
| 4 | Terrain types load from `content/terrain/*.yaml` with MP cost and defense modifier matching the file | S07 |
| 5 | Invalid terrain content (missing field / duplicate id) is rejected with an error naming the file | S08, S09 |

## Commands and state
No Commands. Adds `HexMap` and `TerrainType` (immutable). Not yet part of `GameState` (introduced in 0004), so no hash or save-version impact; 0004 will fold the map into the state hash.

## Presentation
Not player-facing.

## Consistency gate
- [x] Every AC has at least one scenario; every scenario maps to an AC
- [x] Every number in Numbers has a tolerance and a home in `content/`
- [x] Every `human` decision was actually answered by the human
- [x] Nothing in Scope-Out is referenced by a scenario
- [x] Budget and Size set
**Verdict:** PASS
