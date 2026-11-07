# Iron Pipeline — agent operating manual

Turn-based hex wargame (modern-era combined arms, logistics-centric). Godot 4.7 .NET + C#.
Full plan: project doc "Tech Stack and SDLC Plan". Design: `docs/gdd.md`. Decisions: `docs/adr/`.

> If the `dev-team` plugin's `/setup` has appended its own section below, both apply; where they conflict, this section wins.

## Architecture rules (non-negotiable)
1. **`src/IronPipeline.Sim` never references Godot.** No `using Godot`, no Godot types, no Godot NuGet. All game rules live here. `scripts/check-engine-boundary.sh` enforces it.
2. **The Godot project (`src/IronPipeline.Game`) contains no rules.** It renders Sim state and submits `Command`s.
3. **Determinism in Sim.** Full rules in the `determinism-rules` skill — load it before writing Sim code. `scripts/check-determinism.sh` enforces the greppable parts.
4. **Every state change is a serializable `Command`.** `Apply(state, command)` is the only mutation path. Replays must reproduce the same state hash.
5. **Content is data.** Units, terrain, factions, scenarios live in `content/**/*.yaml` with a schema in `content/schemas/`. Balance numbers never hard-coded in C#.
6. **Hexes are pointy-top in presentation; Sim is orientation-agnostic** (axial/cube coordinates, `HexCoord`). Layout math and Game-layer conventions: `godot-presentation` skill.
7. **Domain language** (hex, unit, stack, ZOC, supply line, depot, truck, MP, fuel, ammo) and the Command/GameState model: `wargame-domain` skill. Spec layout and scenario→test mapping: `spec-format` skill.

## How to work (ADR 0003)
- **Spec first, then code-first.** A feature has an approved `docs/specs/NNNN-*.feature` before any code. Then implement **code-first in small batches**: one behavior → its test → green → **refactor** → commit. Repeat.
- **Refactor every batch.** Run the structure/complexity lens on what you just wrote. **Tests are frozen during refactor**: if a refactor needs a test change, stop, revert the refactor, and treat it as a behavior change in the next batch.
- **One coding agent.** Do not spawn a separate tester agent.
- **Size the task:**
  - *Small* (bug fix, one-file change, content/balance tweak): implement directly; run `scripts/verify.sh`; open PR. No spec reviewers, no review fan-out.
  - *Feature* (multi-file, new rule or UI): full pipeline — spec → spec reviewers (`.claude/agents/spec-*`) → human approval → implement → `scripts/verify.sh` → code reviewers (`.claude/agents/review-*`) → `/playtest-checklist NNNN` → PR.
- **Small commits** on a feature branch/worktree; trunk (`main`) is always green and shippable.
- **Red pipeline = only fixes.** If `main` is red, no new features until it's green (Agentic CD constraint 8).
- **Never promote.** Agents never tag releases or publish builds; they open PRs (Agentic CD constraint 7).

## Tests
- One xUnit test per Gherkin scenario, named `S<NN>_<Scenario>` in `IronPipeline.Sim.Tests`, mirroring the spec's scenario IDs.
- Property tests (FsCheck) for invariants. Golden replays under `tests/replays/` once spec 0008 lands.
- No coverage targets. Do not add tests to raise coverage. Mutation testing runs weekly as a health metric only.

## One command
`scripts/verify.sh` — format check, build (warnings as errors), tests, engine-boundary and determinism checks. CI runs the same script. Run it before every PR.

## Conventions
- C#: file-scoped namespaces, `readonly record struct` for value types, `sealed` by default, no `var` for built-in types. `dotnet format` is the arbiter.
- Namespaces mirror folders: `IronPipeline.Sim.Hex`, `IronPipeline.Sim.Supply`, …
- Public Sim API is small and intention-revealing: `GameState`, `Command`s, `Rules.Apply`, queries. Domain language: hex, unit, stack, ZOC, supply line, depot, truck, MP (movement points), fuel, ammo.
- Specs: numbers in the spec's Numbers table, then in `content/`, never inline in code.
- Assets: any binary in `assets/` must have an entry in `assets-src/manifest.yaml` (tool, model, prompt, seed, license). No entry → CI fails.

## Repo map
```
src/IronPipeline.Sim        rules (no Godot)        src/IronPipeline.Sim.Tests  xUnit + FsCheck
src/IronPipeline.Tools      replay/validate/selfplay CLI
src/IronPipeline.Game       Godot 4.7 project (opens with Godot .NET; Godot generates its own .sln here)
docs/gdd.md  docs/adr/  docs/specs/  docs/playtest/
content/  assets/  assets-src/  scripts/  .github/workflows/
.claude/skills/   shared knowledge: determinism-rules, wargame-domain, spec-format, godot-presentation, asset-pipeline, playtest-checklist
.claude/agents/   isolated read-only reviewers that preload those skills
```

## Skills vs agents
Knowledge lives once, in `.claude/skills/`, and is preloaded by the coding session and by the reviewer agents, so coder and reviewer are held to the same text. Reviewers stay separate agents for isolation (a cold read of the diff), parallel fan-out, and enforced read-only tools. Keep agent files to judgment and output format; put facts in skills.
The root `IronPipeline.sln` is the headless solution (Sim, Tests, Tools) — build and test it without Godot.
