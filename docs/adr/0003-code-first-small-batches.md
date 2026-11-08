# ADR 0003 — Code-first small batches, single coding agent, mandatory refactor

**Status:** accepted · **Date:** 2026-11-07 · **Amended by:** ADR 0005 — decision 1 ("Gherkin scenarios … before coding" becomes "a Spec and a Features file approved before coding") and decision 5 (sizes `small` / `planned`); adds budgets; ADR 0006 — decision 5 (small specs get a `spec-consistency` reviewer)

## Context
The `dev-team` experiments (bdfinst/agentic-dev-team, docs/experiments 01–05) found: test-first ordering alone buys nothing; refactor-after-green is the mechanism; code-first small batches with one agent won on quality-per-dollar; split coder/tester agents cost ~3× for no gain; no workflow recovers what a spec never stated; coverage/mutation are blind to workflow quality; pipeline overhead shrinks as tasks grow.

## Decision
1. Gherkin scenarios are written and human-approved **before** coding (spec clarity).
2. The coding agent then works **code-first in small batches**: for each behavior — code → its test → green → refactor → commit.
3. Refactor is mandatory on every batch; **tests are frozen during refactor**.
4. One coding agent. No separate tester agent.
5. Task sizing: small tasks get a single agent + deterministic gates only; multi-file features get the full spec-review / review-fan-out pipeline.

## Consequences
Mutation score is a weekly health metric, not a gate. The review-agent lens plus golden replays are the quality signals.
