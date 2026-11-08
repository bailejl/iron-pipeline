#!/usr/bin/env bash
# The one command. Same thing CI runs. Headless: does not need Godot.
set -euo pipefail
cd "$(dirname "$0")/.."
# Cheap, deterministic checks first; build and tests after.
echo "== engine boundary"; scripts/check-engine-boundary.sh
echo "== dependencies";    scripts/check-dependencies.sh
echo "== spec ids";        scripts/check-spec-ids.sh
echo "== determinism";     scripts/check-determinism.sh
echo "== asset manifest";  scripts/check-asset-manifest.sh
echo "== stale refs";      scripts/check-stale-refs.sh
echo "== budget";          scripts/check-budget.sh
echo "== format";        dotnet format IronPipeline.sln --verify-no-changes
echo "== build";         dotnet build IronPipeline.sln -c Release --nologo
echo "== test";          dotnet test  IronPipeline.sln -c Release --no-build --nologo
if [ -d tests/replays ]; then
  echo "== golden replays"; dotnet run --project src/IronPipeline.Tools -c Release --no-build -- replay tests/replays
fi
echo "verify: ALL GREEN"
