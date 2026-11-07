# Skills and agents

**Skills** (`skills/*/SKILL.md`) hold shared knowledge, written once:

| Skill | Preloaded by |
|---|---|
| `determinism-rules` | coding session, `review-determinism`, `review-save-and-replay-compat`, `spec-determinism-and-replay` |
| `wargame-domain` | coding session, `spec-*`, `review-engine-boundary`, `review-sim-performance`, `review-content-schema` |
| `spec-format` | `/specs`, `spec-*`, `review-content-schema` |
| `godot-presentation` | anyone touching `src/IronPipeline.Game`, `spec-ux-wargame`, `review-engine-boundary` |
| `playtest-checklist` | invoked as `/playtest-checklist NNNN` once per feature PR |

**Agents** (`agents/*.md`) are isolated, read-only reviewers layered on the `dev-team` plugin's generic ones
(architecture, correctness, naming, structure, spec-compliance, test-correctness, test-smells, documentation-drift, domain).

| Prefix | When |
|---|---|
| `spec-*` | On a feature spec, before the human approves it (Gate 1). Not for small tasks. |
| `review-*` | After `scripts/verify.sh` passes on a feature PR. Not for small tasks. |

Why agents and not skills for review: isolation (a cold read, not anchored on the coder's reasoning), parallel
fan-out, and enforced read-only tools. After the Sunday pipeline test, cut any reviewer that produced noise.
