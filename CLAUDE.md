# Iron Pipeline — agent operating manual

Turn-based hex wargame (modern-era combined arms, logistics-centric). Godot 4.7 .NET + C#.
Full plan: project doc "Tech Stack and SDLC Plan". Design: `docs/gdd.md`. Decisions: `docs/adr/`.

> If the `dev-team` plugin's `/setup` has appended its own section below, both apply; where they conflict, this section wins.

## Architecture rules (non-negotiable)
1. **`src/IronPipeline.Sim` never references Godot, packages or projects.** No `using Godot`, no Godot types, no NuGet package, no `ProjectReference`. All game rules live here. `scripts/check-engine-boundary.sh` and `scripts/check-dependencies.sh` enforce it.
2. **The Godot project (`src/IronPipeline.Game`) contains no rules.** It renders Sim state and submits `Command`s.
3. **Determinism in Sim.** Full rules in the `determinism-rules` skill — load it before writing Sim code. `scripts/check-determinism.sh` enforces the greppable parts.
4. **Every state change is a serializable `Command`.** `Apply(state, command)` is the only mutation path. Replays must reproduce the same state hash.
5. **Sim takes no third-party packages** (ADR 0007). `IronPipeline.Sim` references nothing outside the BCL (`dependencies.allowed`, checked by `scripts/check-dependencies.sh`; the hand-rolled YAML parser from spec 0002 is the only known gap, tracked in a follow-up issue). A new package, project, file format, or hand-written parser/serializer for a standard format is always a `human` decision in a Spec. Content parsing (YAML etc.) belongs in a separate `IronPipeline.Content` project where YamlDotNet is allowed; Sim receives parsed data. (Existing parser code moves in a follow-up spec, not before.)
6. **Content is data.** Units, terrain, factions, scenarios live in `content/**/*.yaml` with a schema in `content/schemas/`. Balance numbers never hard-coded in C#.
7. **Hexes are pointy-top in presentation; Sim is orientation-agnostic** (axial/cube coordinates, `HexCoord`). Layout math and Game-layer conventions: `godot-presentation` skill.
8. **Domain language** (hex, unit, stack, ZOC, supply line, depot, truck, MP, fuel, ammo) and the Command/GameState model: `wargame-domain` skill. Spec layout and scenario→test mapping: `spec-format` skill.

## Vocabulary (exact; see `spec-format` skill)
- **Spec** = `docs/specs/NNNN-<name>.md` — intent, Numbers (with tolerances), Decisions & Ambiguity Log, ACs, Size, Budget.
- **Features** = `features/NNNN-<name>.feature` — Gherkin only.
- **Plan** = `plans/NNNN-<name>.md` — from `/dev-team:plan`, **planned**-size work only.
- Sizes are **small** and **planned**. The word "feature" is never a size.
- We do **not** use `/dev-team:specs` (its output would collide with `docs/specs/`); write the Spec from `docs/specs/TEMPLATE.md`. `/dev-team:plan` always takes `--output plans/NNNN-<name>.md`, copies the approved Features scenarios (same S-IDs and steps, plus `# Still passes if:` comments; no new ones; Features wins on any difference), and the plan file is pre-seeded with `**Gherkin persistence**: plan-file-only`.

## How to work (ADR 0003, ADR 0005, ADR 0008)
- **Anything that went wrong is handled with the `root-cause-fix` skill: symptom → cause → cause fix → check. A symptom-only fix is an open item, not a fix.**
- **Every rule in this file is backed by a named check in `scripts/` or tagged `judgment:<agent>` naming the reviewer that owns it. A rule with neither is a bug — file it.** The Rule → check table at the bottom lists them.
- **Spec id** = exactly four digits from `scripts/next-spec-id.sh`; no suffixes (`spec-format` skill). Branch id `0000` is reserved for process-only work.
- **Spec + Features first, then code-first.** Every change — including a bug fix — has an approved Spec and Features file before any code. On "approved", re-read the Spec and Features files from disk before acting on them; the human may have edited them. Then implement **code-first in small batches**: one behavior → its test → green → **refactor** → commit. Repeat.
- **Refactor every batch.** Run the structure/complexity lens on what you just wrote. Every batch leaves refactor evidence: a `refactor:` commit, or a `no refactor: <reason>` line in the commit body. **Tests are frozen during refactor**: if a refactor needs a test change, stop, revert the refactor, and treat it as a behavior change in the next batch.
- **One coding agent.** Do not spawn a separate tester agent.
- **Size the task (set in the Spec header; a Spec with more than six scenarios is not small):**
  - **small** (bug fix, one-file change, content/balance tweak, single-slice rule): Spec + Features → author's consistency-gate checklist → `spec-consistency` reviewer (ADR 0006) → human approval → implement directly → `scripts/verify.sh` → `/dev-team:code-review` → PR. No other spec reviewers, no review fan-out.
  - **planned** (multi-slice, new system, UI): Spec + Features → `spec-consistency` + the other spec reviewers (`.claude/agents/spec-*`) → human approval → `/dev-team:plan --output plans/NNNN-<name>.md` → human approves plan → `/dev-team:build` per slice (one branch `NNNN-<name>-sN`, one PR per slice) → `scripts/verify.sh` → code reviewers (`.claude/agents/review-*`) → `/playtest-checklist NNNN` → PR per slice.
- **Code review timing.** Run `/dev-team:code-review` once all scenarios are green, before cleanup commits — not after the budget is spent. Review fixes go in their own commit; amend only unpushed commits.
- **Status.** The agent sets `Status: implemented` in both the Spec and the Features file in the PR's final commit.
- **Never rewrite history** (filter-branch, rebase, force-push, amending pushed commits) unless the human asks for it in the session.
- **Stage named paths only** (`git add <path>`); a PreToolUse hook denies `git add -A/--all/.` and `git commit -a`.
- **Repowise block.** Its block in `.claude/CLAUDE.md` stays in the repo and is kept current, like a lockfile: leave it unstaged during the work; `/pr` commits it alone as `chore(repowise): refresh index`, which `check-budget.sh` does not count, and `check-stale-refs.sh` / `review-process-drift` skip only that generated block, not the rest of `.claude/CLAUDE.md`.
- **Budget.** The Spec header sets `Budget: N commits, M review rounds`. Default for small = number of scenarios + 3 commits, 1 review round (review fixes included); planned slice default stays 15/2. Budgets are **per branch**; planned work uses one branch and one PR per slice, so slice budget = branch budget. `scripts/check-budget.sh` fails `verify.sh` when exceeded. At that point the only allowed move is: stop, write remaining work into the PR's "Deferred" section, open issues, escalate to the human. Never keep polishing past budget.
- **Reviewers may not raise the bar above the Spec.** A stricter bar is a `spec-change` finding for the human, never a fix request. Numbers in the Spec carry tolerances for exactly this reason.
- **Deferred work becomes a GitHub issue** (`gh issue create`), never "later slice N" in prose. Agents may open issues. One standing issue, "needs a person", collects playtests and visual checks.
- **Handoff.** For any in-progress planned work, keep `docs/handoff/HANDOFF-NNNN-<name>.md` (template there) current: decisions in force, next steps. Delete it on merge.
- **Retiring anything** (a tool, a path, a convention, a name) is not done until the term is in `scripts/retired-terms.txt` and `scripts/check-stale-refs.sh` passes. The `review-process-drift` agent runs on any PR touching CLAUDE.md, ADRs, skills, agents or templates.
- **Small commits** on a spec branch (`NNNN-<name>`) or worktree; trunk (`main`) is always green and shippable.
- **Red pipeline = only fixes.** If `main` is red, no new features until it's green (Agentic CD constraint 8).
- **Retro.** After a small spec or planned slice merges, open a retro issue from `.github/ISSUE_TEMPLATE/retro.md`; every defect it finds becomes its own Defect issue (`.github/ISSUE_TEMPLATE/defect.md`, `root-cause-fix` skill).
- **Done-when.** A PR body carries a "Done-when criteria from the brief/Spec" checklist (`.github/PULL_REQUEST_TEMPLATE.md`); `/pr` refuses to open with an unchecked item unless the title starts with `[incomplete]` and the body says why and asks the human.
- **Never promote.** Agents never tag releases or publish builds; they open PRs (Agentic CD constraint 7).

## Tests (full rules: `test-conventions` skill — load it before writing tests)
- One xUnit test per scenario, named `S<NN>_<Scenario>` in `IronPipeline.Sim.Tests`, mirroring the Features file's IDs.
- Property tests (FsCheck) for invariants. Golden replays under `tests/replays/` once spec 0008 lands. Seed state with builders; never command through setup; no sleeps; never assert on engine internals.
- No coverage targets. Do not add tests to raise coverage. Mutation testing runs weekly as a health metric only.

## One command
`scripts/verify.sh` — engine-boundary, dependencies, spec-id, determinism, asset-manifest, stale-reference and budget checks, then format check, build (warnings as errors) and tests. CI runs the same script. Run it before every PR.

Process-only PRs (no `src/` changes): `/dev-team:code-review` **must** include `review-process-drift`; a process PR without that agent's result is not reviewed. dev-team's pre-PR hook requires the gate file that `/code-review` writes; its bypass (`PR_GATE_BYPASS_REASON="<why>"` in the environment when running `/pr`) is allowed only when the review short-circuited as docs-only, and the reason must say so.

## Conventions
- C#: file-scoped namespaces, `readonly record struct` for value types, `sealed` by default, no `var` for built-in types. `dotnet format` is the arbiter.
- Namespaces mirror folders: `IronPipeline.Sim.Hex`, `IronPipeline.Sim.Supply`, …
- Public Sim API is small and intention-revealing: `GameState`, `Command`s, `Rules.Apply`, queries. Domain language: hex, unit, stack, ZOC, supply line, depot, truck, MP (movement points), fuel, ammo.
- Numbers: in the Spec's Numbers table with a tolerance, then in `content/`, never inline in code.
- Assets: any binary in `assets/` must have an entry in `assets-src/manifest.yaml` (license, commercial_ok, approval; plus tool, model, prompt_file, seed when generated — see the `asset-pipeline` skill). No entry → CI fails.

## Repo map
```
src/IronPipeline.Sim        rules (no Godot)        src/IronPipeline.Sim.Tests  xUnit + FsCheck
src/IronPipeline.Tools      replay/validate/selfplay CLI
src/IronPipeline.Game       Godot 4.7 project (opens with Godot .NET; Godot generates its own .sln here)
docs/gdd.md  docs/adr/  docs/specs/ (Spec .md)  features/ (Gherkin)  plans/  docs/playtest/  docs/handoff/
content/  assets/  assets-src/  scripts/  .github/workflows/
.claude/skills/   shared knowledge: determinism-rules, wargame-domain, spec-format, test-conventions, godot-presentation, asset-pipeline, playtest-checklist, pr, root-cause-fix
.claude/agents/   isolated read-only reviewers that preload those skills
```

## Skills vs agents
Knowledge lives once, in `.claude/skills/`, and is preloaded by the coding session and by the reviewer agents, so coder and reviewer are held to the same text. Reviewers stay separate agents for isolation (a cold read of the diff), parallel fan-out, and enforced read-only tools. Keep agent files to judgment and output format; put facts in skills.
The root `IronPipeline.sln` is the headless solution (Sim, Tests, Tools) — build and test it without Godot.

## Rule → check table
Every rule-shaped statement above, with what enforces it. `judgment:<agent>` = no deterministic check is possible; that reviewer owns it. `review-process-drift` fails the PR if a rule is missing here or has neither.

| Rule | Check |
|---|---|
| 1. Sim never references Godot | `scripts/check-engine-boundary.sh` |
| 1/5. Sim references no packages or projects; Sim does no I/O and no text-format parsing (content check; `// dependency: ok <reason>` marker) | `scripts/check-dependencies.sh` + `judgment:review-engine-boundary` |
| 2. Game project contains no rules | `judgment:review-engine-boundary` |
| 3. Determinism in Sim | `scripts/check-determinism.sh` + `judgment:review-determinism` |
| 4. Every state change is a Command; replays reproduce the hash | `judgment:review-save-and-replay-compat` (golden replays via `verify.sh` once they exist) |
| 5. Third-party code only in `IronPipeline.Content`; new dependency is a `human` decision | `scripts/check-dependencies.sh` + `judgment:review-engine-boundary` |
| 6. Content is data; no balance numbers in C# | `judgment:review-content-schema` |
| 7. Pointy-top in presentation, Sim orientation-agnostic | `judgment:review-engine-boundary` |
| 8. Domain language and Command/GameState model | `judgment:review-engine-boundary` |
| Vocabulary: Spec / Features / Plan, sizes small and planned | `scripts/check-stale-refs.sh` + `judgment:review-process-drift` |
| Spec id format, uniqueness, Spec↔Features pairing | `scripts/check-spec-ids.sh` (via `scripts/lib/spec-id.sh`) |
| Spec + Features approved before code (committed before the first `src/` commit); re-read on "approved" | `judgment:review-engine-boundary` |
| Code-first small batches; refactor evidence per batch; tests frozen in refactor | `judgment:review-engine-boundary` (and every `review-*`) |
| Size honest (small has at most six scenarios) | `judgment:spec-consistency` |
| Budget per branch | `scripts/check-budget.sh` |
| Reviewers may not raise the bar above the Spec | `judgment:review-process-drift` |
| Never rewrite history | `judgment:review-process-drift` (no hook blocks it; a candidate check) |
| Stage named paths only | `.claude/hooks/block-blanket-git-add.sh` PreToolUse hook (tested by `scripts/test-blanket-git-hook.sh`) |
| Deferred work becomes a GitHub issue | `judgment:review-process-drift` |
| Handoff file kept current, deleted on merge | `judgment:review-process-drift` |
| Retiring anything adds the term to `scripts/retired-terms.txt` | `scripts/check-stale-refs.sh` + `judgment:review-process-drift` |
| Red `main`: only fixes | `judgment:review-process-drift` |
| Never promote (no tags or publishing by agents) | `judgment:review-process-drift` |
| Anything that went wrong uses `root-cause-fix` | `judgment:review-process-drift` (fix/bug/incident PR body needs Cause / Cause fix / Check) |
| Every rule has a check or a `judgment:` tag | `judgment:review-process-drift` |
| Tests: one per scenario, `S<NN>_` naming, seeded state, no sleeps; property tests for invariants; golden replays | `judgment:review-determinism` (+ `judgment:review-save-and-replay-compat` for replays) |
| Tests: no coverage targets | `judgment:review-process-drift` |
| `scripts/verify.sh` before every PR | CI runs `scripts/verify.sh` (`.github/workflows/ci.yml`) |
| Process-only PRs include `review-process-drift` | pre-PR gate hook + `judgment:review-process-drift` |
| C# conventions (file-scoped namespaces, sealed, records) | `dotnet format` in `scripts/verify.sh` |
| Numbers in Spec with tolerance, then `content/` | `judgment:spec-consistency` |
| Assets need a manifest entry | `scripts/check-asset-manifest.sh` |
| `/dev-team:specs` not used; `/dev-team:plan --output plans/NNNN-<name>.md` copies Features scenarios unchanged, `plan-file-only` | `scripts/check-stale-refs.sh` + `judgment:review-process-drift` |
| Size the task: small and planned flows (reviewers, order of steps) | `judgment:review-process-drift` |
| One coding agent; no separate tester agent | `judgment:review-process-drift` |
| Code review once all scenarios are green, before cleanup; review fixes in their own commit | `judgment:review-process-drift` |
| `Status: implemented` set in Spec and Features in the PR's final commit | `judgment:review-process-drift` |
| Repowise block: unstaged during work, committed alone as `chore(repowise)` | `scripts/check-budget.sh` (does not count it) + `judgment:review-process-drift` |
| Budget exceeded: stop, write Deferred, open issues, escalate | `scripts/check-budget.sh` + `judgment:review-process-drift` |
| One standing "needs a person" issue collects playtests and visual checks | `judgment:review-process-drift` |
| Small commits on a spec branch (`NNNN-<name>`); trunk always green | CI runs `scripts/verify.sh` + `judgment:review-process-drift` |
| Mutation testing is a weekly health metric only, not a gate | `judgment:review-process-drift` |
| Gate bypass (`PR_GATE_BYPASS_REASON`) only for docs-only reviews, reason says so | pre-PR gate hook + `judgment:review-process-drift` |
| Namespaces mirror folders; public Sim API small and intention-revealing | `dotnet format` in `scripts/verify.sh` (namespaces) + `judgment:review-engine-boundary` (API) |
| Knowledge lives once in `.claude/skills/`; agent files hold judgment and output format only | `judgment:review-process-drift` |
| Retro issue from `.github/ISSUE_TEMPLATE/retro.md` after each merge; defects found → Defect template | `judgment:review-process-drift` |
| PR body has the "Done-when criteria from the brief/Spec" checklist; `/pr` refuses unchecked items unless title starts `[incomplete]` | `judgment:review-process-drift` (process PRs carry the section) |
