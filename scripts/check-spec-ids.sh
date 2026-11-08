#!/usr/bin/env bash
# Spec id hygiene (spec-format skill): names, uniqueness, Spec<->Features pairing and cross-links, branch id.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/lib/spec-id.sh
status=0
fail() { echo "SPEC ID VIOLATION: $*" >&2; status=1; }

name_re="^${SPEC_ID_RE}-[a-z0-9-]+\.(md|feature)$"
specs=(); feats=()
for f in docs/specs/*.md; do
  b=$(basename "$f"); [ "$b" = TEMPLATE.md ] && continue
  [[ "$b" =~ $name_re ]] || { fail "$f must match NNNN-<name>.md (four digits, lowercase name)"; continue; }
  specs+=("$b")
done
for f in features/*.feature; do
  b=$(basename "$f"); [ "$b" = TEMPLATE.feature ] && continue
  [[ "$b" =~ $name_re ]] || { fail "$f must match NNNN-<name>.feature (four digits, lowercase name)"; continue; }
  feats+=("$b")
done

# Unique ids among Specs and among Features files.
dupes=$(printf '%s\n' "${specs[@]:-}" | grep -oE "^${SPEC_ID_RE}" | sort | uniq -d || true)
for d in $dupes; do fail "duplicate Spec id $d"; done
dupes=$(printf '%s\n' "${feats[@]:-}" | grep -oE "^${SPEC_ID_RE}" | sort | uniq -d || true)
for d in $dupes; do fail "duplicate Features id $d"; done

# Exactly one Features file per Spec and vice versa (same NNNN-name).
for s in "${specs[@]:-}"; do
  [ -z "$s" ] && continue
  [ -f "features/${s%.md}.feature" ] || fail "docs/specs/$s has no features/${s%.md}.feature"
done
for f in "${feats[@]:-}"; do
  [ -z "$f" ] && continue
  [ -f "docs/specs/${f%.feature}.md" ] || fail "features/$f has no docs/specs/${f%.feature}.md"
done

# Cross-links.
for s in "${specs[@]:-}"; do
  [ -z "$s" ] && continue
  spec="docs/specs/$s"
  feat=$(grep -E '^\**Features:\**' "$spec" | head -1 | grep -oE 'features/[^ `)*]+' | head -1 || true)
  if [ -z "$feat" ] || [ ! -f "$feat" ]; then fail "$spec: **Features:** must point at an existing file (got '${feat:-none}')"; fi
  while IFS= read -r fol; do
    [ -z "$fol" ] && continue
    fid=$(printf '%s\n' "$fol" | grep -oE "${SPEC_ID_RE}" | head -1 || true)
    if [ -z "$fid" ] || ! ls docs/specs/"$fid"-*.md >/dev/null 2>&1; then fail "$spec: **Follows:** '$fol' names no existing Spec"; fi
  done < <(grep -E '^\**Follows:\**' "$spec" | sed -E 's/^\**Follows:\**//' | grep -v '^[[:space:]]*—*[[:space:]]*$' || true)
done
for f in "${feats[@]:-}"; do
  [ -z "$f" ] && continue
  back=$(grep -E '^# Spec:' "features/$f" | head -1 | sed -E 's/^# Spec:[[:space:]]*//' || true)
  [ "$back" = "docs/specs/${f%.feature}.md" ] || fail "features/$f: '# Spec:' line must be docs/specs/${f%.feature}.md (got '${back:-none}')"
done

# Branch id: must be valid, and (except reserved 0000 = process-only) its Spec must exist.
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)
[ "$branch" = HEAD ] && branch="${GITHUB_HEAD_REF:-HEAD}"
if printf '%s\n' "$branch" | grep -qE "(^|/)${SPEC_ID_RE}[a-zA-Z]"; then
  fail "branch '$branch' has a suffixed spec id; ids are exactly four digits (follow-ups get the next number)"
else
  bid=$(spec_id_from_branch "$branch")
  if [ -n "$bid" ] && [ "$bid" != 0000 ] && ! ls docs/specs/"$bid"-*.md >/dev/null 2>&1; then
    fail "branch '$branch' carries id $bid but docs/specs/$bid-*.md does not exist"
  fi
fi

[ $status -eq 0 ] && echo "spec ids: OK"
exit $status
