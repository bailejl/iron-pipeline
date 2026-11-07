#!/usr/bin/env bash
# Sim must never reference Godot. Exit 1 on any violation.
set -euo pipefail
cd "$(dirname "$0")/.."
status=0
if grep -rnE '^\s*using\s+Godot|\bGodot\.[A-Z]|\[GlobalClass\]|\bpartial class .*: *(Node|Resource|RefCounted)\b' \
     src/IronPipeline.Sim --include='*.cs' --exclude-dir=obj --exclude-dir=bin ; then
  echo "ENGINE BOUNDARY VIOLATION: Godot referenced from IronPipeline.Sim" >&2; status=1
fi
if grep -nE 'Sdk="Godot|Include="Godot' src/IronPipeline.Sim/IronPipeline.Sim.csproj ; then
  echo "ENGINE BOUNDARY VIOLATION: Godot package/SDK in Sim csproj" >&2; status=1
fi
[ $status -eq 0 ] && echo "engine boundary: OK"
exit $status
