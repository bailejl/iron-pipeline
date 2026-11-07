# ADR 0001 — Godot 4.7 (.NET) with C#

**Status:** accepted · **Date:** 2026-11-07

## Context
Solo developer, strong general software background, no game-dev experience, open-source preference, Windows + Linux (Bazzite) targets, AI-agent-driven development process.

## Decision
Godot 4.7 .NET build; all simulation and game code in C#. GDScript only where an addon forces it.

## Consequences
- Static typing gives agents deterministic compiler feedback; the .NET test/analyzer toolchain is mature and supported by the `dev-team` plugin.
- The sim can be a plain .NET library (ADR 0002).
- Editor on Bazzite needs a distrobox with the .NET SDK.
- Alternatives rejected: Bevy/Rust (no editor, breaking changes, too many new things at once), Unity (proprietary, Linux editor second-tier), MonoGame (build everything yourself), Unreal (3D-first, royalty).
