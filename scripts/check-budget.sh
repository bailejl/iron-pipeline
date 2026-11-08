#!/usr/bin/env bash
# Commit budget per spec.
#   Branch name carries the spec number: 0007-supply-v0 or feat/0007-supply-v0.
#   Spec header carries:  **Budget:** N commits, M review round(s)   (markdown bold optional)
# Fails when commits since the base branch exceed N. Review rounds are reviewer-enforced, not counted here.
# No-op on main, on a branch with no spec number, or when the spec has no Budget line.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/lib/spec-id.sh

# Branch: local HEAD, or the PR head ref when CI checks out a detached HEAD.
in_ci_pr=0
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)
if [ "$branch" = "HEAD" ] && [ -n "${GITHUB_HEAD_REF:-}" ]; then branch="$GITHUB_HEAD_REF"; in_ci_pr=1; fi
if [ "$branch" = "HEAD" ]; then echo "budget: n/a (detached HEAD, no GITHUB_HEAD_REF)"; exit 0; fi
if [ "$branch" = "main" ]; then echo "budget: n/a (main)"; exit 0; fi

num=$(spec_id_from_branch "$branch")
if [ -z "$num" ]; then echo "budget: n/a (no spec number in branch '$branch')"; exit 0; fi

spec=$(ls docs/specs/"$num"-*.md 2>/dev/null | head -1 || true)
if [ -z "$spec" ]; then echo "budget: no spec docs/specs/$num-*.md; skipping"; exit 0; fi

# First Budget line only; tolerate "**Budget:** 6 commits" and "Budget: 6 commits".
limit=$(grep -iE '^\**Budget:\**' "$spec" | head -1 | grep -oE '[0-9]+' | head -1 || true)
if [ -z "$limit" ]; then echo "budget: no Budget line in $spec; skipping"; exit 0; fi
if [ "$(grep -ciE '^\**Budget:\**' "$spec")" -gt 1 ]; then
  echo "BUDGET: $spec has more than one Budget line; keep exactly one." >&2; exit 1
fi

# Base: origin/main when present (local main may be stale), else main. Fail loudly if neither exists.
base_ref=""
for r in origin/main main; do
  if git rev-parse --verify -q "$r" >/dev/null; then base_ref="$r"; break; fi
done
if [ -z "$base_ref" ]; then echo "BUDGET: neither 'main' nor 'origin/main' exists; cannot compute base." >&2; exit 1; fi
# In a CI pull_request run, HEAD is a synthetic merge commit (HEAD^1 = base, HEAD^2 = PR head):
# count the PR side against the base side. Locally, HEAD may be a merge too (git merge main), so
# the CI path is taken only when GITHUB_HEAD_REF is set.
head=HEAD
if [ "$in_ci_pr" = 1 ] && git rev-parse --verify -q HEAD^2 >/dev/null; then
  head=HEAD^2; base=$(git merge-base HEAD^1 HEAD^2)
else
  base=$(git merge-base HEAD "$base_ref")
fi
# chore(repowise) commits (index refresh, see CLAUDE.md) are not counted.
count=$(git log --no-merges --format=%s "$base".."$head" | { grep -vc '^chore(repowise)' || true; })

if [ "$count" -gt "$limit" ]; then
  echo "BUDGET EXCEEDED: $count commits on '$branch', budget $limit ($spec)." >&2
  echo "Stop. Write remaining work into the PR's 'Deferred' section, open issues, escalate to the human." >&2
  exit 1
fi
echo "budget: $count/$limit commits ($spec, base $base_ref, head $head)"
