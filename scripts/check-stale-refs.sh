#!/usr/bin/env bash
# Drift check: retired terms must not appear in process docs. Add a term the same PR you retire it.
set -euo pipefail
cd "$(dirname "$0")/.."
targets=(CLAUDE.md README.md .claude .github docs features plans)
status=0
while IFS= read -r line || [ -n "$line" ]; do
  [ -z "$line" ] && continue; [[ "$line" == \#* ]] && continue
  if [[ "$line" == re:* ]]; then
    flags=(-rniE); term="${line#re:}"
  else
    flags=(-rniwF); term="$line"
  fi
  set +e
  raw=$(grep "${flags[@]}" --include='*.md' --include='*.feature' --include='*.txt' --include='*.yml' \
          --exclude-dir=adr --exclude-dir=research --exclude-dir=worktrees --exclude-dir=memory \
          -- "$term" "${targets[@]}" 2>&1); rc=$?
  set -e
  if [ $rc -ge 2 ]; then echo "check-stale-refs: grep failed for '$line': $raw" >&2; exit 2; fi
  hits=$(printf '%s\n' "$raw" | grep -v 'retired: ok' | grep -v '^scripts/retired-terms.txt' | grep -v '^$' || true)
  if [ -n "$hits" ]; then echo "STALE REFERENCE to retired '$line':"; echo "$hits"; status=1; fi
done < scripts/retired-terms.txt
[ $status -eq 0 ] && echo "stale refs: OK"
exit $status
