# ADR 0007 — IronPipeline.Sim takes no third-party packages

**Status:** accepted · **Date:** 2026-11-08 · **Extends:** ADR 0002 (engine-independent Sim)

## Context
ADR 0002 keeps Godot out of Sim. Spec 0002 then shipped a hand-rolled YAML parser inside Sim because parsing content needs a library and Sim has none. Third-party code in rule code is unaudited for determinism (unordered collections, culture-dependent formatting, floats), and it widens what Sim's replay guarantee depends on.

## Decision
1. `IronPipeline.Sim` references nothing outside the BCL. Content parsing (YAML) lives in a separate `IronPipeline.Content` project, where YamlDotNet is allowed; Sim receives parsed data.
2. Test projects and Tools may use packages (xUnit, FsCheck, etc.); the rule covers Sim only.
3. Existing parser code in Sim is a known gap, moved by a follow-up spec (#21), not in the PR that adopts this rule.

## Consequences
One more project in the headless solution once #21 lands. `scripts/check-engine-boundary.sh` checks only Godot references; a PackageReference check for Sim is not yet automated (candidate for a later `verify.sh` step).
