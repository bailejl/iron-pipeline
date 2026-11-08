# Spec 0001 — Hex coordinates

**Status:** implemented
**Size:** small
**Budget:** 6 commits, 1 review round
**Pillar(s):** big maps, readable tactics
**Features:** features/0001-hex-coordinates.feature
**Plan:** —

## Intent
Every other system reasons about the map through hex coordinates. This provides axial/cube coordinates with neighbors, distance, rings and lines, deterministic and integer-only, with no dependency on orientation.

## Scope
- In: `HexCoord` value type; neighbors, distance, ring, line.
- Out: pixel layout (presentation, ADR 0004), offset coordinates (add when map storage needs them), pathfinding (0003).
- Unchanged: —

## Numbers
| name | value | unit | tolerance | range |
|---|---|---|---|---|
| neighbor count | 6 | hexes | exact | — |
| ring(r) size | 6r | hexes | exact | r ≥ 1 |

## Decisions & Ambiguity Log
| # | Decision | Resolved by | Answer / rationale |
|---|---|---|---|
| 1 | Axial vs offset storage | inferable | Axial: cube math is simplest and orientation-agnostic (Red Blob Games) |
| 2 | Orientation | human | Pointy-top in presentation only (ADR 0004); Sim never knows |
| 3 | Line rounding ties | inferable | Integer-only cube rounding with a fixed +q/+r bias so lines are deterministic |
| 4 | Direction order | inferable | Fixed array order starting at +q, counter-clockwise; ordering is part of determinism |

## Acceptance criteria
| AC | Statement | Scenarios |
|---|---|---|
| 1 | Six distinct neighbors at distance 1 | S01, S06 |
| 2 | Distance equals the cube metric | S02 |
| 3 | Ring of radius r has 6r hexes at distance r; radius 0 is the center | S03, S04 |
| 4 | Line is inclusive, distance+1 long, adjacent steps, deterministic | S05 |

## Commands and state
None. Pure value type.

## Presentation
Not player-facing.

## Consistency gate
- [x] Every AC has a scenario; every scenario maps to an AC
- [x] Numbers have tolerances (all exact)
- [x] Human decisions answered (ADR 0004)
- [x] Scope-Out not referenced
- [x] Budget and Size set
**Verdict:** PASS
