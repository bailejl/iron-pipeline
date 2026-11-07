---
name: spec-format
description: How to write and read a feature spec for Iron Pipeline — the .feature file layout, scenario IDs, the Numbers table, size tag, and the mapping to xUnit acceptance tests. Load before writing, reviewing, or implementing a spec.
---
# Spec format

Specs are human-owned intent in `docs/specs/NNNN-<kebab-name>.feature`, written in Gherkin because concrete examples are what a human can approve in minutes. Template: `docs/specs/TEMPLATE.feature`. Example: `docs/specs/0001-hex-coordinates.feature`.

## Header comments (required)
```
# Spec NNNN — <name>
# Status: draft | approved | implemented
# Pillar(s): one or more of the four
# Size: small | feature      ← decides whether the review pipeline runs (CLAUDE.md "Size the task")
```

## Body rules
- **Scenario IDs** `S01…` are stable and unique within the spec. Renumbering is forbidden; add new ones at the end.
- **Numbers table** in a comment block holds every constant the scenarios imply, with unit and allowed range. Those numbers then live in `content/`, never in C#.
- Scenarios are **observable**: Given state, When a Command, Then a result the presentation layer could show. No "internally" or "the code should".
- Keep a spec to **one behavior cluster**; if it needs more than ~8 scenarios, split it.
- End with `# Out of scope` and `# Open questions for the human` — the spec reviewers fill these in; the human resolves them before approval.

## Mapping to tests
Each scenario ⇒ exactly one xUnit test in `IronPipeline.Sim.Tests`, named `S<NN>_<ScenarioInPascalCase>`, in a class `<Feature>AcceptanceTests`. Invariants that hold for all inputs are **not** scenarios; they are FsCheck property tests in `<Feature>PropertyTests` and are listed in the spec's trailing comment for traceability.

## Review checklist (what `spec-*` agents look for)
Pillar named · size tag honest · every number in the table with a range · every scenario expressible as a Command · nothing depends on time or floats · UI visibility stated for anything player-facing · out-of-scope list present.
