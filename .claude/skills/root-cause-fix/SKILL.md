---
name: root-cause-fix
description: The required way to respond to any defect, review error, broken check, incident or retro finding in Iron Pipeline: find the cause, fix the cause, add a check. Load before fixing anything that went wrong.
---

# Root-cause fix

Every defect, review error, failing check, incident or retro finding is handled in four steps, in order.
Fixing only the symptom is not done; it is an open item.

1. Symptom — what was observed, in one sentence, with evidence (file, commit, log line).
2. Cause — the missing rule, missing check, ambiguous document or wrong default that allowed the symptom.
   Ask "what would have had to exist for this not to happen?" If the answer is "the agent should have known",
   the cause is an unwritten rule: write it.
   Distinguish: the proximate cause (what went wrong) from the enabling cause (why nothing stopped it).
   Both get fixed.
3. Cause fix — the change to the rule, document, template, default or structure. Never only the code path
   that failed.
4. Check — a deterministic check (script in scripts/, wired into verify.sh) that fails if the cause recurs.
   If no deterministic check is possible, name the reviewer agent that owns it and add the item to that
   agent's checks, and tag the rule `judgment:<agent>`.
   Then verify the check: show it failing on the original symptom (reproduce or simulate), then passing.

Record all four in the issue or PR using the Defect template (.github/ISSUE_TEMPLATE/defect.md). A fix PR
whose body lacks Cause / Cause fix / Check is incomplete; the pr skill refuses to open it.

Scope rule: if the cause fix is a process change, it ships in its own process PR before the code fix, so the
code fix can cite the check that proves it.
