#!/bin/sh
# dev-team PostToolUse hook: run dotnet format on an edited .cs file in an IronPipeline.sln project
# (Sim, Sim.Tests, Tools). Game is not in the headless solution, so its files are skipped.
set -eu
payload="$(cat)"
file="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.path // empty')"
case "$file" in *.cs) ;; *) exit 0 ;; esac
root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
case "$file" in "$root"/src/IronPipeline.Game/*) exit 0 ;; "$root"/src/*) ;; *) exit 0 ;; esac
command -v dotnet >/dev/null 2>&1 || exit 0
cd "$root"
rel="${file#"$root"/}"
dotnet format IronPipeline.sln --no-restore --include "$rel" >/dev/null 2>&1 || true
exit 0
