#!/usr/bin/env bash
# Commit budget per spec.
#   Branch name carries the spec number: 0007-supply-v0 or feat/0007-supply-v0.
#   Spec header carries:  **Budget:** N commits, M review round(s)   (markdown bold optional)
# Fails when commits since the base branch exceed N. Review rounds are reviewer-enforced, not counted here.
# No-op on main, on a branch with no spec number, or when the spec has no Budget line.
set -euo pipefail
cd "$(dirname "$0")/.."

# Branch: local HEAD, or the PR head ref when CI checks out a detached HEAD.
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)
if [ "$branch" = "HEAD" ]; then branch="${GITHUB_HEAD_REF:-${CI_BRANCH:-HEAD}}"; fi
if [ "$branch" = "HEAD" ]; then echo "budget: n/a (detached HEAD, no GITHUB_HEAD_REF)"; exit 0; fi
if [ "$branch" = "main" ]; then echo "budget: n/a (main)"; exit 0; fi

num=$(printf '%s\n' "$branch" | grep -oE '(^|/)[0-9]{4}' | tr -d '/' | head -1 || true)
if [ -z "$num" ]; then echo "budget: n/a (no spec number in branch '$branch')"; exit 0; fi

spec=$(ls docs/specs/"$num"-*.md 2>/dev/null | head -1 || true)
if [ -z "$spec" ]; then echo "budget: no spec docs/specs/$num-*.md; skipping"; exit 0; fi

# First Budget line only; tolerate "**Budget:** 6 commits" and "Budget: 6 commits".
limit=$(grep -iE '^\**Budget:\**' "$spec" | head -1 | grep -oE '[0-9]+' | head -1 || true)
if [ -z "$limit" ]; then echo "budget: no Budget line in $spec; skipping"; exit 0; fi
if [ "$(grep -ciE '^\**Budget:\**' "$spec")" -gt 1 ]; then
  echo "BUDGET: $spec has more than one Budget line; keep exactly one." >&2; exit 1
fi

# Base: local main, else origin/main. Fail loudly if neither exists.
base_ref=""
for r in main origin/main; do
  if git rev-parse --verify -q "$r" >/dev/null; then base_ref="$r"; break; fi
done
if [ -z "$base_ref" ]; then echo "BUDGET: neither 'main' nor 'origin/main' exists; cannot compute base." >&2; exit 1; fi
# On a PR, CI checks out a synthetic merge commit (HEAD^1 = base branch, HEAD^2 = PR head).
# Count the PR side against the base side; otherwise count HEAD against main.
head=HEAD
if git rev-parse --verify -q HEAD^2 >/dev/null; then
  head=HEAD^2; base=$(git merge-base HEAD^1 HEAD^2)
else
  base=$(git merge-base HEAD "$base_ref")
fi
count=$(git rev-list --count --no-merges "$base".."$head")

if [ "$count" -gt "$limit" ]; then
  echo "BUDGET EXCEEDED: $count commits on '$branch', budget $limit ($spec)." >&2
  echo "Stop. Write remaining work into the PR's 'Deferred' section, open issues, escalate to the human." >&2
  exit 1
fi
echo "budget: $count/$limit commits ($spec, base $base_ref, head $head)"
