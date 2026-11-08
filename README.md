# Iron Pipeline

A turn-based hex wargame about modern-era combined arms where logistics is the game.
Godot 4.7 (.NET) + C#. Windows and Linux. Built with an AI-agent-driven process.

- Design: [`docs/gdd.md`](docs/gdd.md) · Decisions: [`docs/adr/`](docs/adr/) · Specs: [`docs/specs/`](docs/specs/) · Features (Gherkin): [`features/`](features/) · Plans: [`plans/`](plans/)
- Agent manual: [`CLAUDE.md`](CLAUDE.md) · Agents: [`.claude/agents/`](.claude/agents/)
- Full plan: project doc *Iron Pipeline — Tech Stack & SDLC Plan*

## Layout
```
src/IronPipeline.Sim         game rules — plain .NET library, never references Godot
src/IronPipeline.Sim.Tests   xUnit acceptance tests (one per spec scenario) + FsCheck properties
src/IronPipeline.Tools       CLI: replay runner, content validator, self-play (stubs for now)
src/IronPipeline.Game        Godot 4.7 project — presentation only
docs/                        gdd, adr, specs (.md), playtest, handoff
features/                    Gherkin, one file per spec
plans/                       /dev-team:plan output for planned-size work
content/                     units/terrain/factions/scenarios as YAML + schemas   (all rights reserved)
assets/                      final PNG/OGG via Git LFS                            (all rights reserved)
assets-src/                  prompts + provenance manifest (Steam AI disclosure record)
scripts/verify.sh            the one command: boundary, dependencies, spec-ids, determinism, manifest, stale-refs, budget, then format, build, test
```
`IronPipeline.sln` at the root is the **headless** solution (Sim, Tests, Tools). It builds and tests
without Godot. The Game project is opened with the Godot .NET editor, which generates its own solution.

## Setup (Mac, primary)
```bash
brew install --cask dotnet-sdk          # .NET 10 LTS
brew install git-lfs && git lfs install
# Godot 4.7 .NET build: https://godotengine.org/download/macos/  (the ".NET" variant)
git clone <this repo> && cd iron-pipeline
scripts/verify.sh                       # should end with "verify: ALL GREEN"
```
Then open `src/IronPipeline.Game` in Godot (.NET). First open: Project → Tools → C# → Create C# solution if
Godot asks, then Build. Run the main scene: you should see a ring of hexes rendered from `IronPipeline.Sim`.

Claude Code: `claude plugin marketplace add bdfinst/agentic-dev-team && claude plugin install dev-team@bfinster`,
then `/setup` in the repo. It appends to `CLAUDE.md`; the existing section stays authoritative.

## Setup (Bazzite PC — Linux/Proton testing)
```bash
distrobox create -n dev --image fedora:latest && distrobox enter dev
sudo dnf install -y dotnet-sdk-10.0 git git-lfs libwayland-egl libwayland-cursor libdecor dbus-libs fontconfig
# download the Godot 4.7 .NET Linux binary, unzip, then: distrobox-export --bin ./Godot_v4.7-stable_mono_linux.x86_64
```
Windows testing without Windows: add the exported `.exe` from the `build` workflow as a non-Steam game and
force Proton.

## Workflow (short version — see CLAUDE.md)
1. Change → Spec `docs/specs/NNNN-*.md` + Features `features/NNNN-*.feature` → (planned: spec reviewers) → **you approve**.
2. Coding agent: code-first small batches, refactor every batch, tests frozen during refactor.
3. `scripts/verify.sh` → code reviewers → playtest checklist → PR → **you playtest the exported build** → merge.
Small tasks skip the reviewers and the plan and go straight to `verify.sh`. Budgets are enforced; past budget = stop, defer to issues, escalate.

## CI
| Workflow | When | What |
|---|---|---|
| `ci` | every push/PR | `scripts/verify.sh` (full history checkout for the budget check); Godot import + build |
| `build` | `main`, nightly | Linux + Windows exports; Windows launch smoke test |
| `nightly` | nightly | self-play balance report (stub) |
| `weekly` | Mondays | Stryker.NET mutation report (health metric) |
| `release` | `v*` tags (human only) | publish placeholder |

Export presets (`export_presets.cfg`) are created in the Godot editor on first export; name them
`Linux` and `Windows` to match `build.yml`.

## License
Code: MIT ([`LICENSE`](LICENSE)). Content and assets: all rights reserved (`content/LICENSE`, `assets/LICENSE`).
