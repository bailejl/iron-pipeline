# Process v4.1 — fix causes, not symptoms

Brief for the coding agent. Read fully before starting. This is a process-only PR on branch `0000-process-v4.1`.
It must run `review-process-drift` in the review. Stage files by name. Do not rewrite history. Leave
`.claude/CLAUDE.md` unstaged until the `chore(repowise)` step in the `pr` skill.

---

## 0. The principle this PR installs

> **We do not fix the problem. We fix the thing that caused the problem, and we put a check in so it cannot
> happen again — whenever a check is possible.**

Two incidents from spec 0002 are the worked examples (§2, §3). Section §1 makes the principle a repeatable
process so the next incident is handled the same way without re-deriving it.

---

## 1. Make the principle repeatable

### 1a. Skill: `.claude/skills/root-cause-fix/SKILL.md`

Frontmatter: `name: root-cause-fix`; description: "The required way to respond to any defect, review
error, broken check, incident or retro finding in Iron Pipeline: find the cause, fix the cause, add a check.
Load before fixing anything that went wrong." Body:

```
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
```

### 1b. `CLAUDE.md` additions

- Under "How to work": **"Anything that went wrong is handled with the `root-cause-fix` skill: symptom →
  cause → cause fix → check. A symptom-only fix is an open item, not a fix."**
- New rule: **"Every rule in this file is backed by a named check in `scripts/` or tagged `judgment:<agent>`
  naming the reviewer that owns it. A rule with neither is a bug — file it."** Add a **Rule → check table** at
  the bottom of `CLAUDE.md` listing every rule-shaped statement in the file with its check script or
  `judgment:<agent>` tag. Fill it in for every existing rule now (engine boundary → `check-engine-boundary.sh`;
  determinism → `check-determinism.sh` + `judgment:review-determinism`; budget → `check-budget.sh`;
  retired terms → `check-stale-refs.sh`; refactor evidence → `judgment:review-*`; etc.). Leave no row blank.

### 1c. Templates

- `.github/ISSUE_TEMPLATE/defect.md` with sections: Symptom (evidence) / Proximate cause / Enabling cause /
  Cause fix / Check (script or `judgment:<agent>`) / Verified (check failed on the symptom, then passed).
- `.github/PULL_REQUEST_TEMPLATE.md`: add a section **"If this fixes something that went wrong"** with the
  same four fields; the `pr` skill refuses to open a PR labelled fix/bug/incident with those fields empty.
- `docs/playtest/TEMPLATE.md` and the retro issue format: "Notes → new specs" becomes "Notes → defects
  (use the Defect template) and new specs".

### 1d. Check on the checks

`review-process-drift` gets two items: (1) any rule-shaped line in `CLAUDE.md` missing from the Rule → check
table, or in the table with neither a script nor a `judgment:` tag, is a finding; (2) any PR whose title or
labels say fix/bug/incident but whose body lacks Cause / Cause fix / Check is a blocker.

ADR 0007 "Fix causes, add checks" records the principle, the skill, the rule→check table and the templates.

---

## 2. Worked example A — a dependency decision made silently

**Symptom.** Spec 0002 shipped a hand-written YAML parser inside `IronPipeline.Sim` (commit range of PR for
0002). Nothing failed; the review passed.

**Proximate cause.** The agent had to choose between adding YamlDotNet to Sim and hand-rolling a parser, and
chose without asking.

**Enabling cause.** No dependency policy exists; nothing classifies "new package / new project / hand-written
parser for a standard format" as a `human` decision; no check inspects project references.

**Cause fix.**
1. `dependencies.allowed` at the repo root — one block per project listing allowed `PackageReference`s and
   `ProjectReference`s. `IronPipeline.Sim`: packages **none**, projects **none**. `IronPipeline.Sim.Tests`:
   xunit, xunit.runner.visualstudio, Microsoft.NET.Test.Sdk, FsCheck.Xunit; project Sim. `IronPipeline.Tools`:
   project Sim. `IronPipeline.Game`: project Sim (Godot SDK is the project SDK, not a package).
   `IronPipeline.Content` (reserved, created by spec 0003): YamlDotNet; project Sim.
   Comment at the top: changing this file requires a `human` row in a Spec that names the package and why.
2. `spec-format`: **"A new package, a new project, a new external file format, or hand-writing a
   parser/serializer for a standard format (YAML, JSON, CSV, TOML, XML) is always a `human` decision. Never
   inferable."**
3. `review-engine-boundary` (owns project structure): re-implementing a standard format is a blocker; the
   finding names the allowlisted library or asks for a Spec decision.
4. `CLAUDE.md` rule 1 extended: Sim references nothing — no Godot, no packages, no projects.

**Check.** `scripts/check-dependencies.sh`, wired into `verify.sh` before the build:
- Parses every `src/**/*.csproj` (grep/sed is fine; no XML library). For each project, every
  `PackageReference Include=` and `ProjectReference Include=` must appear under that project in
  `dependencies.allowed`; anything else fails with the project, the reference and the sentence "add it to
  dependencies.allowed via a human Spec decision".
- `IronPipeline.Sim` must have zero references of either kind.
- Heuristic for the hand-rolled case: any file under `src/IronPipeline.Sim` whose name matches
  `*Parser*`, `*Yaml*`, `*Json*`, `*Csv*`, `*Toml*`, `*Serializer*` fails with "standard-format handling belongs
  in IronPipeline.Content". Exception marker `// dependency: ok <reason>` on line 1, reviewed by
  `review-engine-boundary`.
- **Verify:** temporarily add `<PackageReference Include="YamlDotNet" />` to Sim's csproj → script fails;
  remove → passes. Also create an empty `src/IronPipeline.Sim/Content/YamlParser.cs` → fails; delete → passes.
  Put both in the PR body under Verified.

Spec 0003 (content project) then has as its first AC: "`check-dependencies.sh` passes with Sim's allowlist
empty and Content allowlisting YamlDotNet", so the code fix is proven by the check that prevents recurrence.

---

## 3. Worked example B — an identifier format that lived in a script

**Symptom.** Branch `0002b-content-project` resolved to spec 0002 in `check-budget.sh`; the follow-up spec file
could never be found. Caught only when the agent read the script.

**Proximate cause.** The issue was titled "0002b" and the branch followed it.

**Enabling cause.** The spec identifier was never defined anywhere. It existed implicitly as a regex inside
`check-budget.sh` and a filename convention in the templates. Nothing validates ids, allocates them, or keeps
the two scripts' patterns in sync.

**Cause fix.**
1. Define it once, in `spec-format`: **"Spec id = exactly four digits, allocated as max existing + 1, never
   reused, no suffixes or letters. A follow-up gets the next number and cites its parent in the Spec header
   as `**Follows:** NNNN`."** Add the `**Follows:**` line to `docs/specs/TEMPLATE.md`.
2. One source of truth in code: `scripts/lib/spec-id.sh` exporting `SPEC_ID_RE='[0-9]{4}'`, `spec_id_from_branch`,
   and `next_spec_id` (scans `docs/specs/`). `check-budget.sh` sources it; delete its private regex.
3. `scripts/next-spec-id.sh` prints the next free id. `spec-format` says to run it when naming work.
4. `.github/ISSUE_TEMPLATE/spec.md` with a "Spec id (run `scripts/next-spec-id.sh`)" field, so the number is
   allocated when the work is named, not when a branch appears.

**Check.** `scripts/check-spec-ids.sh`, wired into `verify.sh`:
- Every file in `docs/specs/` (except `TEMPLATE.md`) and `features/` (except `TEMPLATE.feature`) matches
  `^NNNN-[a-z0-9-]+\.(md|feature)$` with `NNNN` from `spec-id.sh`.
- Ids are unique; every Spec has exactly one Features file with the same `NNNN-name` and vice versa.
- Each Spec's `**Features:**` header points at an existing file; each Features file's `# Spec:` line points
  back at its Spec; `**Follows:**`, if present, names an existing Spec.
- If the current branch carries an id, a Spec with that id exists (budget runs after this, so it can rely on it).
- **Verify:** create `docs/specs/0002b-x.md` → fails; rename to `0099-x.md` without a Features file → fails;
  add `features/0099-x.feature` → passes; delete both. Put the results in the PR body under Verified.

---

## 4. Everything else in this PR

- `scripts/verify.sh` order: engine boundary → dependencies → spec ids → determinism → asset manifest →
  stale refs → budget → format → build → test.
- `README.md` and `.claude/CLAUDE.md` command comments updated to match.
- `scripts/retired-terms.txt`: add `re:[0-9]{4}[a-z]\b` so a suffixed id in any process doc is caught.
- `docs/adr/0007-fix-causes-add-checks.md`: records §1 (principle, skill, rule→check table, templates) and
  cites §2 and §3 as the originating incidents.
- `.claude/README.md`: add `root-cause-fix` to the skills table (preloaded by: coding session on any fix;
  `review-process-drift`).
- Close nothing by number here (the 0002b issue stays open until spec 0003 ships); comment on it that it is
  numbered 0003 and that `check-dependencies.sh` is the recurrence check.

---

## 5. Done when

- `scripts/verify.sh` is green and both new checks have a recorded fail-then-pass verification in the PR body.
- The Rule → check table in `CLAUDE.md` has a script or `judgment:<agent>` for every row.
- `/dev-team:code-review` including `review-process-drift` returns no errors; warnings listed under Deferred.
- PR opened with `/pr`; body uses the new "If this fixes something that went wrong" section for both worked
  examples (that is the first use of the template).

---

## Prompt to start the agent

```
Read CLAUDE.md, then load spec-format, test-conventions and wargame-domain. Read the file
docs/process/process-v4.1-brief.md in full (I will add it to the repo) — it is the complete scope.

Create branch 0000-process-v4.1 from main. Process-only PR; must run review-process-drift. Stage files by
name; do not rewrite history; leave .claude/CLAUDE.md unstaged until the pr skill's chore(repowise) step.

Implement the brief in this order: §1 (the root-cause-fix skill, CLAUDE.md rules and Rule → check table,
templates, ADR 0007), then §2, then §3, then §4. For each new check, record the fail-then-pass verification
exactly as §2 and §3 describe, and paste the output into the PR body.

When §1–§4 are done: scripts/verify.sh; /dev-team:code-review including review-process-drift; fix errors
only; warnings under Deferred; open the PR with /pr using the new PR-template section for both worked
examples. Comment on the 0002b issue as §4 says. Report the PR URL.
```
