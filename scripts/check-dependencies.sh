#!/usr/bin/env bash
# Every PackageReference/ProjectReference in src/**/*.csproj must be listed under that project in
# dependencies.allowed; Sim has none; Sim does no I/O and no text-format parsing (that is IronPipeline.Content).
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

# Sim does no I/O and no text-format parsing (that is IronPipeline.Content). Content check, not a filename heuristic.
# Exception: '// dependency: ok <reason>' on the offending line, reviewed by review-engine-boundary.
io_re='(^|[^A-Za-z0-9_.])(File|Directory|Path)\.|System\.IO([^A-Za-z0-9_]|$)|StreamReader|TextReader|YamlDotNet|System\.Text\.Json|Regex'
while IFS= read -r f; do
  while IFS= read -r hit; do
    line=${hit#*:}
    case "$line" in *[![:space:]]*) ;; *) continue ;; esac
    trimmed=${line#"${line%%[![:space:]]*}"}
    case "$trimmed" in //*) continue ;; esac
    if printf '%s' "$line" | grep -qE '//[[:space:]]*dependency: ok .+'; then continue; fi
    fail "$f:${hit%%:*}: I/O or text-format handling in Sim ('${trimmed}'); move it to IronPipeline.Content or mark the line '// dependency: ok <reason>'"
  done < <(grep -nE "$io_re" "$f" || true)
done < <(find src/IronPipeline.Sim -type f -name '*.cs' -not -path '*/obj/*' -not -path '*/bin/*' | sort)

[ $status -eq 0 ] && echo "dependencies: OK"
exit $status
