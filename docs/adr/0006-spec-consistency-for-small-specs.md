# ADR 0006 — Spec consistency review for small Specs

**Status:** accepted · **Date:** 2026-11-08 · **Amends:** ADR 0005 decision 2 (task sizes), which said small specs get no spec reviewers.

## Context
Spec 0002 (small) shipped with mechanical gaps a cold read of the Spec and Features would likely have caught: a Given said 3 content files when there were 4 types; two Features invariants (round-trip, determinism) were not implementable from the stated API; schema rules had no AC. The cost was fix commits after the budget was spent (issue #20).

## Decision
1. **Small specs get exactly one reviewer, `spec-consistency`** (haiku; Read/Grep/Glob), plus the author's consistency-gate checklist in the Spec template. It checks only mechanical agreement: Givens vs content, invariants vs stated API, AC↔scenario, schema-rule coverage, Number tolerances.
2. **Planned specs** run `spec-consistency` and the existing `spec-*` fan-out (balance, determinism-and-replay, game-design-fit, ux-wargame).
3. The full `spec-*` fan-out stays planned-only. A Spec with more than six scenarios is not small.

## Consequences
One cheap extra step before human approval on every change. Judgment reviewers stay out of small work. Revisit if `spec-consistency` produces noise or misses gaps in the next few small specs.
