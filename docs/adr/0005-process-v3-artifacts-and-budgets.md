# ADR 0005 — Process v3: Spec / Features / Plan, sizes, budgets, drift

**Status:** accepted · **Date:** 2026-11-08 · **Amends:** ADR 0003, decision 5 — its two sizes "Small" and "Feature" become `small` and `planned`, and its "Gherkin scenarios written and approved before coding" becomes "a Spec and a Features file approved before coding". ADR 0003's workflow (code-first small batches, mandatory refactor, one coding agent) is unchanged.

## Context
An analysis of https://github.com/bdfinst/vsm-workshop — the dev-team plugin used end to end on one 18-slice piece of work in October 2026 — is checked in at `docs/research/vsm-process-analysis.md`. It showed the highest-leverage
artifact was a Spec with an explicit Ambiguity Log, and showed two failure modes we want to avoid: polish-creep
when no scenario states a tolerance (21 commits chasing sub-pixel label widths) and process drift when a tool was
dropped but local docs kept describing it. Our own vocabulary collided: "spec" meant the Gherkin file, dev-team's
`/specs` writes a different Spec document, and "feature" was both a task size and the Gherkin keyword.

## Decision
1. Three artifacts with fixed names: **Spec** `docs/specs/NNNN-<name>.md` (intent, Numbers with tolerances,
   Decisions & Ambiguity Log, ACs, Size, Budget, consistency gate); **Features** `features/NNNN-<name>.feature`
   (Gherkin only); **Plan** `plans/NNNN-<name>.md` (`/dev-team:plan`, planned-size only).
2. Task sizes are **small** and **planned** (replacing ADR 0003's "Small / Feature"). Every change,
   including a bug fix, has a Spec and a Features file.
3. **Budgets.** The Spec header sets commits and review rounds (small 6/1; planned slice 15/2).
   `scripts/check-budget.sh` fails `verify.sh` past the commit limit; the only allowed response is stop → defer to
   issues → escalate. Reviewers may not demand a bar the Spec does not set; a stricter bar is a `spec-change`
   finding for the human.
4. **Drift.** `scripts/retired-terms.txt` + `scripts/check-stale-refs.sh` (deterministic) and the
   `review-process-drift` agent on any PR touching process files. Retiring anything is not done until its term
   is on the list.
5. Deferred work becomes GitHub issues (agents may open them); PR bodies follow `.github/PULL_REQUEST_TEMPLATE.md`;
   in-progress planned work keeps a `docs/handoff/` file.

## Consequences
Two files per change instead of one; a plan only for planned-size work. Process PRs run `/dev-team:code-review`
with `review-process-drift`. No further process changes until after the first full pipeline run on a planned spec.
