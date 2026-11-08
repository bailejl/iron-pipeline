---
name: pr
description: Open a pull request for the current branch after scripts/verify.sh is green. Use when the user says "open a PR", "/pr", or a spec's work is ready to ship.
---

# /pr — open a pull request for Iron Pipeline

Trunk (`main`) is always green. Agents open PRs; they never merge, tag, or publish (ADR 0003, Agentic CD constraint 7).

## Steps

1. **Branch check.** Refuse if on `main`; work happens on a spec branch (`NNNN-<name>`) or worktree.
2. **Verify locally** — the same command CI runs:
   ```bash
   scripts/verify.sh
   ```
   It runs `dotnet format --verify-no-changes`, `dotnet build -c Release` (warnings as errors), `dotnet test`, the engine-boundary, determinism, asset-manifest and stale-reference checks, and `scripts/check-budget.sh`. If it fails, fix and re-run; do not open the PR red.
3. **Reviewers (planned-size PRs only).** For multi-file rule or UI changes, run the project review agents on the diff before opening: `review-determinism`, `review-engine-boundary`, plus `review-content-schema` / `review-save-and-replay-compat` / `review-sim-performance` / `review-asset-pipeline` as the diff warrants. Small-size specs skip this (root `CLAUDE.md`, "Size the task"). Any PR touching CLAUDE.md, ADRs, skills, agents or templates also runs `review-process-drift`.
4. **Playtest checklist** for planned-size, player-facing PRs: `/playtest-checklist NNNN` once reviews pass.
5. **Push and open:**
   ```bash
   git push -u origin HEAD
   gh pr create --fill --base main
   ```
   PR body: follow `.github/PULL_REQUEST_TEMPLATE.md` — link the Spec (`docs/specs/NNNN-*.md`) and Features (`features/NNNN-*.feature`), list the scenarios covered (`S<NN>_...` tests), budget used, Decisions made at the build gate, Deferred (as issue links) and Not covered; note any save/replay version bump. End the body with the attribution line required by the session.
6. Report the PR URL. Do not merge.
