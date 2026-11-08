# Spec NNNN — <name>

**Status:** draft | approved | implemented
**Size:** small | planned        <!-- small = single agent + gates; planned = plans/NNNN-<name>.md + full pipeline -->
**Budget:** 6 commits, 1 review round   <!-- defaults: small 6/1, planned slice 15/2. Exceeding = stop, defer, escalate -->
**Pillar(s):** logistics tension | big maps | readable tactics | distinct factions
**Features:** features/NNNN-<name>.feature
**Plan:** plans/NNNN-<name>.md (planned only)

## Intent
One to three paragraphs: who, what is wrong today, what this changes, which pillar it serves.

## Scope
- In:
- Out (explicitly):
- Unchanged:

## Numbers
Single source of truth for this spec's constants. Every row has a tolerance or `exact`.
These values then live in `content/`, never in C#.

| name | value | unit | tolerance | range |
|---|---|---|---|---|

## Decisions & Ambiguity Log
Every open question that came up, how it was resolved, and why. `human` rows were answered by the human; `inferable` rows carry the rationale a developer with only this repo would reach.

| # | Decision | Resolved by (human / inferable) | Answer / rationale |
|---|---|---|---|

## Acceptance criteria
Numbered, measurable, each mapped to one or more scenarios in the Features file.

| AC | Statement | Scenarios |
|---|---|---|

## Commands and state
Commands this introduces or changes (fields), state added to `GameState` (hash + save-version impact), events emitted.

## Presentation (if player-facing)
How the player sees and acts on it; clicks to perform the action; feedback on illegal action.

## Consistency gate
- [ ] Every AC has at least one scenario; every scenario maps to an AC
- [ ] Every number in Numbers has a tolerance and a home in `content/`
- [ ] Every `human` decision was actually answered by the human
- [ ] Nothing in Scope-Out is referenced by a scenario
- [ ] Budget and Size set
**Verdict:** PASS | FAIL   (FAIL blocks approval)
