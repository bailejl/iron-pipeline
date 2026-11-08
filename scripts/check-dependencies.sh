#!/usr/bin/env bash
# Every PackageReference/ProjectReference in src/**/*.csproj must be listed under that project in
# dependencies.allowed; Sim has none; Sim has no standard-format handling code (that is IronPipeline.Content).
set -euo pipefail
cd "$(dirname "$0")/.."
status=0
fail() { echo "DEPENDENCY VIOLATION: $*" >&2; status=1; }

allowed_for() { # <project> -> "package X" / "project Y" lines
  awk -v p="[$1]" '/^\[/ {on = ($0 == p); next} on && /^(package|project) / {print}' dependencies.allowed
}
has_block() { grep -qxF "[$1]" dependencies.allowed; }

while IFS= read -r csproj; do
  proj=$(basename "$csproj" .csproj)
  if ! has_block "$proj"; then fail "$proj has no block in dependencies.allowed; add it via a human Spec decision"; continue; fi
  allowed=$(allowed_for "$proj")
  refs=$( { grep -oE '<PackageReference[^>]*Include="[^"]+"' "$csproj" | sed -E 's/.*Include="([^"]+)"/package \1/' || true
            grep -oE '<ProjectReference[^>]*Include="[^"]+"' "$csproj" | sed -E 's/.*Include="([^"]+)"/\1/' \
              | while read -r p; do p=${p//\\//}; echo "project $(basename "$p" .csproj)"; done || true; } )
  while IFS= read -r ref; do
    [ -z "$ref" ] && continue
    if [ "$proj" = "IronPipeline.Sim" ]; then
      fail "IronPipeline.Sim must have zero references; found '$ref' in $csproj. Add it to dependencies.allowed via a human Spec decision."
    elif ! printf '%s\n' "$allowed" | grep -qxF "$ref"; then
      fail "$proj references '$ref' ($csproj), not in dependencies.allowed. Add it to dependencies.allowed via a human Spec decision."
    fi
  done <<< "$refs"
done < <(find src -name '*.csproj' -not -path '*/obj/*' -not -path '*/bin/*' | sort)

# Heuristic for hand-rolled standard-format handling inside Sim.
while IFS= read -r f; do
  if ! head -n1 "$f" | grep -qE '^// dependency: ok .+'; then
    fail "$f: standard-format handling belongs in IronPipeline.Content (or mark line 1 '// dependency: ok <reason>')"
  fi
done < <(find src/IronPipeline.Sim -type f \( -name '*Parser*' -o -name '*Yaml*' -o -name '*Json*' -o -name '*Csv*' -o -name '*Toml*' -o -name '*Serializer*' \) -not -path '*/obj/*' -not -path '*/bin/*')

[ $status -eq 0 ] && echo "dependencies: OK"
exit $status
