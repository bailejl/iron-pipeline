# ADR 0008 — Fix causes, add checks

**Status:** accepted · **Date:** 2026-11-08 · **Extends:** ADR 0005 (process v3), ADR 0007 (no packages in Sim)

## Context
Two incidents from spec 0002 shared one shape: a rule existed only in someone's head or inside a script, so nothing stopped the mistake and the fix touched only the symptom.
- **A, dependency decision made silently.** Spec 0002 shipped a hand-written YAML parser in `IronPipeline.Sim`. The agent chose between adding YamlDotNet and hand-rolling without asking; no dependency policy classified that as a `human` decision, and no check inspected project references.
- **B, identifier format in a script.** Branch `0002b-content-project` resolved to spec 0002 in `check-budget.sh`. The spec id was never defined; it existed only as a regex in a script and a filename convention in templates.

## Decision
> We do not fix the problem. We fix the thing that caused the problem, and we put a check in so it cannot happen again, whenever a check is possible.

1. **Skill `root-cause-fix`**: symptom → cause (proximate and enabling) → cause fix → check, with the check shown failing then passing.
2. **Rule → check table** at the bottom of `CLAUDE.md`: every rule-shaped statement names a script in `scripts/` or is tagged `judgment:<agent>`. A rule with neither is a bug.
3. **Templates**: `.github/ISSUE_TEMPLATE/defect.md`, the "If this fixes something that went wrong" section of the PR template, and playtest/retro notes routed to defects.
4. **`review-process-drift`** checks the table and fix-PR bodies.
5. Incident A is fixed by `dependencies.allowed` + `scripts/check-dependencies.sh` + a `human` rule in `spec-format`. Incident B by one spec-id definition in `spec-format`, `scripts/lib/spec-id.sh`, `scripts/next-spec-id.sh`, `scripts/check-spec-ids.sh` and the Spec issue template.

## Consequences
Two more `verify.sh` steps. Process changes that fix a cause ship in their own PR before the code fix. Branch id `0000` is reserved for process-only work (no Spec). This supersedes the "candidate for a later check" note in ADR 0007: `check-dependencies.sh` is that check.
