# ADR 0002 — Engine-independent simulation library

**Status:** accepted · **Date:** 2026-11-07

## Decision
All game rules live in `IronPipeline.Sim`, a .NET class library with **no reference to Godot**. The Godot project is a presentation layer that renders Sim state and submits `Command`s. Every state change is a serializable Command applied to immutable-by-convention state; the sim is deterministic (seeded RNG injected, integer math in rules, no unordered iteration in rule code).

## Why
- Tests run in milliseconds without an engine process, so the agent pipeline's automated gates are trustworthy.
- Replays, undo, golden-file regression tests, AI self-play and future lockstep multiplayer all fall out of Command + determinism.
- Engine can be swapped (Bevy for an RTS, say) without rewriting rules.

## Enforcement
`scripts/check-engine-boundary.sh` and `scripts/check-determinism.sh` run in CI; the `engine-boundary` and `determinism` review agents enforce the spirit.
