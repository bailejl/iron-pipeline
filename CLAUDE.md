# Iron Pipeline — agent operating manual

Turn-based hex wargame (modern-era combined arms, logistics-centric). Godot 4.7 .NET + C#.
Full plan: project doc "Tech Stack and SDLC Plan". Design: `docs/gdd.md`. Decisions: `docs/adr/`.

> If the `dev-team` plugin's `/setup` has appended its own section below, both apply; where they conflict, this section wins.

## Architecture rules (non-negotiable)
1. **`src/IronPipeline.Sim` never references Godot.** No `using Godot`, no Godot types, no Godot NuGet. All game rules live here. `scripts/check-engine-boundary.sh` enforces it.
2. **The Godot project (`src/IronPipeline.Game`) contains no rules.** It renders Sim state and submits `Command`s.
3. **Determinism in Sim.** Full rules in the `determinism-rules` skill — load it before writing Sim code. `scripts/check-determinism.sh` enforces the greppable parts.
4. **Every state change is a serializable `Command`.** `Apply(state, command)` is the only mutation path. Replays must reproduce the same state hash.
5. **Sim takes no third-party packages.** `IronPipeline.Sim` references nothing outside the BCL. Content parsing (YAML etc.) belongs in a separate `IronPipeline.Content` project where YamlDotNet is allowed; Sim receives parsed data. (Existing parser code moves in a follow-up spec, not before.)
6. **Content is data.** Units, terrain, factions, scenarios live in `content/**/*.yaml` with a schema in `content/schemas/`. Balance numbers never hard-coded in C#.
7. **Hexes are pointy-top in presentation; Sim is orientation-agnostic** (axial/cube coordinates, `HexCoord`). Layout math and Game-layer conventions: `godot-presentation` skill.
8. **Domain language** (hex, unit, stack, ZOC, supply line, depot, truck, MP, fuel, ammo) and the Command/GameState model: `wargame-domain` skill. Spec layout and scenario→test mapping: `spec-format` skill.

## Vocabulary (exact; see `spec-format` skill)
- **Spec** = `docs/specs/NNNN-<name>.md` — intent, Numbers (with tolerances), Decisions & Ambiguity Log, ACs, Size, Budget.
- **Features** = `features/NNNN-<name>.feature` — Gherkin only.
- **Plan** = `plans/NNNN-<name>.md` — from `/dev-team:plan`, **planned**-size work only.
- Sizes are **small** and **planned**. The word "feature" is never a size.
- We do **not** use `/dev-team:specs` (its output would collide with `docs/specs/`); write the Spec from `docs/specs/TEMPLATE.md`. `/dev-team:plan` always takes `--output plans/NNNN-<name>.md`, copies the approved Features scenarios (same S-IDs and steps, plus `# Still passes if:` comments; no new ones; Features wins on any difference), and the plan file is pre-seeded with `**Gherkin persistence**: plan-file-only`.

## How to work (ADR 0003, ADR 0005)
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
- **Repowise block.** Its block in `.claude/CLAUDE.md` stays in the repo and is kept current, like a lockfile: leave it unstaged during the work; `/pr` commits it alone as `chore(repowise): refresh index`, which `check-budget.sh` does not count, and `check-stale-refs.sh` / `review-process-drift` skip that file.
- **Budget.** The Spec header sets `Budget: N commits, M review rounds`. Default for small = number of scenarios + 3 commits, 1 review round (review fixes included); planned slice default stays 15/2. Budgets are **per branch**; planned work uses one branch and one PR per slice, so slice budget = branch budget. `scripts/check-budget.sh` fails `verify.sh` when exceeded. At that point the only allowed move is: stop, write remaining work into the PR's "Deferred" section, open issues, escalate to the human. Never keep polishing past budget.
- **Reviewers may not raise the bar above the Spec.** A stricter bar is a `spec-change` finding for the human, never a fix request. Numbers in the Spec carry tolerances for exactly this reason.
- **Deferred work becomes a GitHub issue** (`gh issue create`), never "later slice N" in prose. Agents may open issues. One standing issue, "needs a person", collects playtests and visual checks.
- **Handoff.** For any in-progress planned work, keep `docs/handoff/HANDOFF-NNNN-<name>.md` (template there) current: decisions in force, next steps. Delete it on merge.
- **Retiring anything** (a tool, a path, a convention, a name) is not done until the term is in `scripts/retired-terms.txt` and `scripts/check-stale-refs.sh` passes. The `review-process-drift` agent runs on any PR touching CLAUDE.md, ADRs, skills, agents or templates.
- **Small commits** on a spec branch (`NNNN-<name>`) or worktree; trunk (`main`) is always green and shippable.
- **Red pipeline = only fixes.** If `main` is red, no new features until it's green (Agentic CD constraint 8).
- **Never promote.** Agents never tag releases or publish builds; they open PRs (Agentic CD constraint 7).

## Tests (full rules: `test-conventions` skill — load it before writing tests)
- One xUnit test per scenario, named `S<NN>_<Scenario>` in `IronPipeline.Sim.Tests`, mirroring the Features file's IDs.
- Property tests (FsCheck) for invariants. Golden replays under `tests/replays/` once spec 0008 lands. Seed state with builders; never command through setup; no sleeps; never assert on engine internals.
- No coverage targets. Do not add tests to raise coverage. Mutation testing runs weekly as a health metric only.

## One command
`scripts/verify.sh` — format check, build (warnings as errors), tests, engine-boundary, determinism, asset-manifest, stale-reference and budget checks. CI runs the same script. Run it before every PR.

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
.claude/skills/   shared knowledge: determinism-rules, wargame-domain, spec-format, test-conventions, godot-presentation, asset-pipeline, playtest-checklist
.claude/agents/   isolated read-only reviewers that preload those skills
```

## Skills vs agents
Knowledge lives once, in `.claude/skills/`, and is preloaded by the coding session and by the reviewer agents, so coder and reviewer are held to the same text. Reviewers stay separate agents for isolation (a cold read of the diff), parallel fan-out, and enforced read-only tools. Keep agent files to judgment and output format; put facts in skills.
The root `IronPipeline.sln` is the headless solution (Sim, Tests, Tools) — build and test it without Godot.
