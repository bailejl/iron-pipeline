---
name: playtest-checklist
description: Write the human playtest checklist for a feature PR from its spec and diff, saved under docs/playtest/. Invoke as /playtest-checklist <spec number> once reviews pass on a feature PR.
---
# /playtest-checklist <NNNN>

Produce `docs/playtest/<NNNN>-<name>-<YYYY-MM-DD>.md` from `docs/playtest/TEMPLATE.md`.

Inputs: the spec `docs/specs/<NNNN>-*.feature`, the PR diff, `docs/gdd.md` pillars.

Write **5–10 checks** a player can do in the exported build in under 15 minutes. Each check names:
1. the exact action (which unit, which hex, which button),
2. the expected **visible** result,
3. the pillar it tests.

Always include:
- one *try to break it* item (illegal action, edge of map, out of fuel/ammo),
- one *judgment* item: "Did this create tension / was it fun / was it clear?" (1–5),
- a line for *notes → new specs*.

Link the checklist in the PR description. Do not change any other file.
