---
name: determinism-rules
description: The determinism rules for IronPipeline.Sim — what is forbidden in rule code, the approved patterns (injected IRandom, integer/fixed-point math, deterministic ordering), and how to write the "determinism: ok" exception. Load before writing or reviewing any Sim code.
---
# Determinism rules for `IronPipeline.Sim`

The sim must produce the identical state hash from the same seed and command log on every machine. These rules are enforced by `scripts/check-determinism.sh` (greppable subset) and the `review-determinism` agent (the rest).

## Forbidden in rule code
| Hazard | Why | Use instead |
|---|---|---|
| `new Random()`, `Random.Shared`, `Guid.NewGuid()` | unseeded | the injected `IRandom` (seeded, part of state) |
| `DateTime.*`, `Stopwatch`, `Environment.TickCount` | wall clock | turn/tick counters in `GameState` |
| `float`, `double`, `decimal` | platform/rounding drift | `int`, `long`, or fixed-point (`Fixed32`, when it exists) |
| iterating `Dictionary`, `HashSet`, `ConcurrentX` to make a decision | unordered | iterate a `List`/array, or `.OrderBy(x => x.Id, Comparer)` first |
| `GroupBy`/`Distinct`/`ToHashSet` feeding a decision without a subsequent `OrderBy` | unordered | add deterministic `OrderBy` on a stable key |
| string ordering without a comparer | culture-dependent | `StringComparer.Ordinal` |
| `GetHashCode()` for ordering or ids | not stable across runtimes | explicit integer ids |
| `Parallel.*`, `Task.Run`, `async` inside `Rules.Apply` | nondeterministic interleaving | sequential rule code; parallelism only in Tools (self-play) around whole games |

## Dependencies
`IronPipeline.Sim` takes no third-party packages — BCL only. Content parsing (YAML) belongs in a separate `IronPipeline.Content` project where YamlDotNet is allowed; Sim receives parsed data. Third-party code in rule code is unaudited for determinism.

## Approved patterns
- **Randomness:** `IRandom` lives on `GameState`; every call advances it; `Rules.Apply` receives state and returns state, never reaching for a global.
- **Ordering:** units, hexes and commands are processed in **id order** unless the spec says otherwise. Ids are dense integers assigned at creation.
- **Ties:** every tie-break is explicit and documented in the spec (e.g. "lowest unit id attacks first").
- **Hashing:** `GameState.Hash()` covers every field that affects future behavior. Adding state = adding it to the hash **and** bumping `SaveFormat.Version`.
- **Presentation math** (pixel layout, animation, camera) may use floats — it lives in `IronPipeline.Game`, never in Sim.

## Exceptions
A line that trips the grep but is provably outside rule code (e.g. a debug formatter) may carry `// determinism: ok <reason>`. The reviewer checks the reason; "needed" is not a reason.
