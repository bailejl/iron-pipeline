# Iron Pipeline — Game Design Document (living)

> Human-owned. Agents may propose edits via PR; the pillars change only by your decision.

## One-liner
A turn-based hex wargame about modern-era combined arms where **logistics is the game**: you win by keeping your spearheads fed and starving the enemy's.

## Pillars (every feature must serve at least one)
1. **Logistics tension** — fuel, ammunition and supply lines are visible, scarce, and attackable. Running dry is the most common way to lose.
2. **Big maps** — operations, not skirmishes. Depth matters; flanks are real.
3. **Readable tactics** — the player can always see why something happened. No hidden dice, no opaque modifiers; replays are first-class.
4. **Distinct factions** — fictional factions whose culture drives how their AI plays (see `content/factions/` and the faction prompt in `assets-src/prompts/factions.md`).

## Anti-goals (for now)
- Real-time (RTS comes after the turn-based game proves the sim).
- Multiplayer (not for the first couple of games; the sim stays deterministic so it stays possible).
- Grand strategy / diplomacy / tech trees.

## Core loop (prototype)
Select unit → see reachable hexes and supply state → move / attack → end turn → enemy acts → supply is consumed and delivered → repeat.

## Systems (status)
| System | Status | Spec |
|---|---|---|
| Hex coordinates | done | `docs/specs/0001-hex-coordinates.feature` |
| Map & terrain costs | planned | 0002 |
| Pathfinding | planned | 0003 |
| Units, movement points, fuel, ammo | planned | 0004 |
| Turn / phase state machine | planned | 0005 |
| Combat v0 | planned | 0006 |
| Supply v0 (depots, trucks, consumption) | planned | 0007 |
| Replay & state hash | planned | 0008 |
| Zones of control | planned — **Sunday pipeline test** | 0009 |

## Presentation
2D, pointy-top hexes, programmatic NATO-style counters first, illustrated units later.

## Open design questions
- Supply model: per-unit stockpile vs. traced supply lines vs. both? (v0: per-unit stockpile + trucks; lines in a later spec.)
- Stacking limit per hex.
- Fog of war: full, partial, or none in v1.
