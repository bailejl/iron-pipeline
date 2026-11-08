#!/bin/sh
# PreToolUse(Bash) hook: deny blanket staging. Stage named paths only (issue #18).
# Denies: git add -A | --all | . ; git commit -a | -am | --all
set -eu
command -v jq >/dev/null 2>&1 || { echo "block-blanket-git-add: jq required" >&2; exit 2; }
payload="$(cat)"
cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')"
[ -n "$cmd" ] || exit 0
# Normalize: drop heredoc bodies, join backslash-newline, strip quoted strings (so commit
# messages cannot trip the match), then make remaining newlines command separators.
flat="$(printf '%s\n' "$cmd" \
  | awk '
      skip { t=$0; gsub(/^[ \t]+|[ \t]+$/, "", t); if (t == tag) skip=0; next }
      { print }
      match($0, /<<-?[ \t]*["\x27]?[A-Za-z_][A-Za-z_0-9]*["\x27]?/) {
        tag=substr($0, RSTART, RLENGTH); gsub(/<<-?[ \t]*["\x27]?|["\x27]?$/, "", tag); skip=1
      }' \
  | sed -e ':a' -e '/\\$/{N;s/\\\n/ /;ba' -e '}' \
  | tr '\n' '\001' \
  | sed -E "s/\"[^\"]*\"//g; s/'[^']*'//g" \
  | tr '\001' ';')"
sep='([[:space:]]|$|[;&|)])'
add="git[[:space:]]+([^;&|]*[[:space:]])?add[[:space:]]+([^;&|]*[[:space:]])?(-[a-zA-Z]*A[a-zA-Z]*|--all|\\.)$sep"
com="git[[:space:]]+([^;&|]*[[:space:]])?commit[[:space:]]+([^;&|]*[[:space:]])?(-[a-zA-Z]*a[a-zA-Z]*|--all)$sep"
if printf '%s' "$flat" | grep -Eq "$add|$com"; then
  reason="Blanket staging is denied (git add -A / --all / . and git commit -a). Stage named paths only: git add <path> [<path>...]. Background tools (repowise) modify tracked files; blanket staging sweeps them into commits."
  jq -n --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
fi
exit 0
