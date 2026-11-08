#!/usr/bin/env bash
# Single definition of the spec id (spec-format skill): exactly four digits, allocated as max existing + 1,
# never reused, no suffixes. Source this file; do not copy the regex. 0000 is reserved for process-only branches.
SPEC_ID_RE='[0-9]{4}'

# spec_id_from_branch <branch> -> prints the four-digit id, or nothing. "0007-x" and "feat/0007-x" carry 0007;
# "0002b-x" carries none (a suffixed id is invalid; check-spec-ids.sh fails it).
spec_id_from_branch() {
  printf '%s\n' "$1" | grep -oE "(^|/)${SPEC_ID_RE}(-|\$)" | head -1 | grep -oE "${SPEC_ID_RE}" || true
}

# next_spec_id -> max id in docs/specs/ + 1, zero-padded (0001 when none).
next_spec_id() {
  local root max=0 f n
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  for f in "$root"/docs/specs/*.md; do
    n=$(basename "$f" | grep -oE "^${SPEC_ID_RE}" || true)
    [ -n "$n" ] && [ $((10#$n)) -gt "$max" ] && max=$((10#$n))
  done
  printf '%04d\n' $((max + 1))
}
