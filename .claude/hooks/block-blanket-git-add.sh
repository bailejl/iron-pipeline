#!/bin/sh
# PreToolUse(Bash) hook: deny blanket staging. Stage named paths only (issue #18).
# Denies: git add -A | --all | . ; git commit -a | -am | --all
set -eu
command -v jq >/dev/null 2>&1 || { echo "block-blanket-git-add: jq required" >&2; exit 2; }
payload="$(cat)"
cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')"
[ -n "$cmd" ] || exit 0
# Flatten newlines and drop quoted strings so commit messages cannot trip the match.
flat="$(printf '%s' "$cmd" | tr '\n' ' ' | sed -E "s/\"[^\"]*\"//g; s/'[^']*'//g")"
sep='([[:space:]]|$|[;&|])'
add="git[[:space:]]+([^;&|]*[[:space:]])?add[[:space:]]+([^;&|]*[[:space:]])?(-[a-zA-Z]*A[a-zA-Z]*|--all|\\.)$sep"
com="git[[:space:]]+([^;&|]*[[:space:]])?commit[[:space:]]+([^;&|]*[[:space:]])?(-[a-zA-Z]*a[a-zA-Z]*|--all)$sep"
if printf '%s' "$flat" | grep -Eq "$add|$com"; then
  reason="Blanket staging is denied (git add -A / --all / . and git commit -a). Stage named paths only: git add <path> [<path>...]. Background tools (repowise) modify tracked files; blanket staging sweeps them into commits."
  jq -n --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
fi
exit 0
