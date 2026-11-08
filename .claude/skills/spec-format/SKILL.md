---
name: spec-format
description: The three change artifacts for Iron Pipeline and their exact formats — Spec (docs/specs/*.md with decisions, ambiguity log, numbers, ACs, size, budget), Features (features/*.feature, Gherkin only) and Plan (plans/*.md for planned-size work) — plus the scenario→test mapping. Load before writing, reviewing or implementing any change.
---
# Spec, Features, Plan

Three artifacts, three names, never mixed. The words "spec", "features" and "plan" mean only these.

| Artifact | File | Holds | Who owns it |
|---|---|---|---|
| **Spec** | `docs/specs/NNNN-<name>.md` | intent, scope, **Numbers** (with tolerances), **Decisions & Ambiguity Log**, ACs, commands/state, presentation, consistency gate, **Size**, **Budget** | human approves (Gate 1) |
| **Features** | `features/NNNN-<name>.feature` | Gherkin scenarios only; each becomes one test | human approves with the Spec |
| **Plan** | `plans/NNNN-<name>.md` | slices, steps (IMPLEMENT/TEST/REFACTOR/Files/Commit), waves, Build Progress | produced by `/dev-team:plan`, human approves; **planned** size only; slices copy the Features scenarios (same S-IDs and steps, plus `# Still passes if:` comments; Features wins on any difference) |

Templates: `docs/specs/TEMPLATE.md`, `features/TEMPLATE.feature`. Worked example: 0001.

## Rules
- **Every change has a Spec and a Features file**, even a bug fix (a Spec can be ten lines; "no decisions" is a valid log).
- **Numbers live in the Spec, with a tolerance or `exact`.** A value with no tolerance is not approvable. Values then go to `content/`, never into C#.
- **Ambiguity Log:** before writing ACs, list every open question. Try to infer; if one plausible alternative exists that the repo does not rule out, it is `human`, and the human answers it before approval. "Inferable" is not a convenient default.
- **Size** decides the machinery (CLAUDE.md): `small` → single agent + deterministic gates; `planned` → `/dev-team:plan`, spec reviewers, review fan-out, playtest.
- **Budget** (commits, review rounds) is enforced by `scripts/check-budget.sh`. Exceeding it means stop, defer, escalate — never keep polishing.
- **Scenario IDs** `S01…` are stable; add at the end, never renumber. Each scenario ⇒ exactly one xUnit test `S<NN>_<ScenarioInPascalCase>` in `<Name>AcceptanceTests`. Invariants are FsCheck property tests listed in the Features trailing comment, not scenarios.
- **Reviewers may not raise the bar above the Spec.** A stricter bar is a `spec-change` finding for the human, never a fix request.
- The Gherkin keyword `Feature:` is syntax; do not use "feature" for a task size (sizes are `small` and `planned`).

## Review checklist (what `spec-*` agents look for)
Pillar named · Size honest · Budget set · every Number has a tolerance and a range · every `human` decision actually answered · every AC has a scenario and vice versa · nothing in Scope-Out referenced · every scenario expressible as a Command · no time or floats · presentation stated for anything player-facing · consistency gate PASS.
