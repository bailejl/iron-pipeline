# ADR 0005 — Process v3: Spec / Features / Plan, sizes, budgets, drift

**Status:** accepted (decisions 2 and 3 amended by ADR 0006) · **Date:** 2026-11-08 · **Amends:** ADR 0003 decision 1 ("Gherkin scenarios are written and human-approved before coding" becomes "a Spec and a Features file are approved before coding") and decision 5 (sizes "Small" / "Feature" become `small` / `planned`). ADR 0003 decisions 2–4 (code-first small batches, mandatory refactor with frozen tests, one coding agent) are unchanged.

## Context
An analysis of https://github.com/bdfinst/vsm-workshop — the dev-team plugin used end to end on one 18-slice piece of work in October 2026 — is checked in at `docs/research/vsm-process-analysis.md`. It showed the highest-leverage
artifact was a Spec with an explicit Ambiguity Log, and showed two things we want to avoid: a 21-commit follow-up PR (#42) spent on sub-pixel label-width matching that no
scenario had asked for — we read that as polish-creep from a missing tolerance, which is an inference, not something the
repo states — and process drift (Cucumber removed, local skills still describing it, which the repo does show). Our own vocabulary collided: "spec" meant the Gherkin file, dev-team's
`/specs` writes a different Spec document, and "feature" was both a task size and the Gherkin keyword.

## Decision
0. We do not use `/dev-team:specs`; the Spec template replaces it (its default output path would collide with
   `docs/specs/`). `/dev-team:plan` is always run with `--output plans/NNNN-<name>.md`, takes the approved Features file as input and copies its scenarios into the slices with the same S-IDs and the same Given/When/Then steps (the plan may add `# Still passes if:` comment lines, which the plugin requires); a new or changed scenario is a spec-change for the human, and the Features file wins on any difference. Before running it, pre-seed `plans/NNNN-<name>.md` with the line `**Gherkin persistence**: plan-file-only` (otherwise the plugin auto-detects `features/` and exports a second Gherkin set there). `/dev-team:build` is used as is.
1. Three artifacts with fixed names: **Spec** `docs/specs/NNNN-<name>.md` (intent, Numbers with tolerances,
   Decisions & Ambiguity Log, ACs, Size, Budget, consistency gate); **Features** `features/NNNN-<name>.feature`
   (Gherkin only); **Plan** `plans/NNNN-<name>.md` (`/dev-team:plan`, planned-size only).
2. Task sizes are **small** and **planned** (replacing ADR 0003's "Small / Feature"). Every change,
   including a bug fix, has a Spec and a Features file.
   **Budgets are per branch.** Planned work uses one branch and one PR per slice, so a slice budget and a branch
   budget are the same thing; `check-budget.sh` counts the branch.
3. **Budgets.** The Spec header sets commits and review rounds (small: scenarios + 3 per ADR 0006, formerly 6/1; planned slice 15/2).
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
