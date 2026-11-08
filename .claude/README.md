# Skills and agents

**Skills** (`skills/*/SKILL.md`) hold shared knowledge, written once:

| Skill | Preloaded by |
|---|---|
| `determinism-rules` | coding session, `review-determinism`, `review-save-and-replay-compat`, `spec-determinism-and-replay` |
| `wargame-domain` | coding session, `spec-*`, `review-engine-boundary`, `review-sim-performance`, `review-content-schema` |
| `spec-format` | `/specs`, `spec-*`, `review-content-schema`, `review-process-drift` |
| `test-conventions` | coding session, `review-determinism`, `review-save-and-replay-compat` |
| `godot-presentation` | anyone touching `src/IronPipeline.Game`, `spec-ux-wargame`, `review-engine-boundary` |
| `playtest-checklist` | invoked as `/playtest-checklist NNNN` once per planned-size, player-facing PR |

**Agents** (`agents/*.md`) are isolated, read-only reviewers layered on the `dev-team` plugin's generic ones
(architecture, correctness, naming, structure, spec-compliance, test-correctness, test-smells, documentation-drift, domain).

| Prefix | When |
|---|---|
| `spec-*` | On a planned-size Spec + Features, before the human approves them (Gate 1). Not for small tasks. |
| `review-*` | After `scripts/verify.sh` passes on a planned-size PR. Not for small tasks. `review-process-drift` runs on any PR touching process files. |

Why agents and not skills for review: isolation (a cold read, not anchored on the coder's reasoning), parallel
fan-out, and enforced read-only tools. After the Sunday pipeline test, cut any reviewer that produced noise.

**Models are pinned per agent** (not `inherit`), so changing your session model doesn't change the review fan-out:
opus for the two design-judgment spec reviewers; sonnet for reviewers that must read intent (determinism, replay compat,
performance, UX, determinism spec); haiku for rule checks (engine boundary, content schema, asset pipeline).
Skills have no model — they run on whoever loaded them.
