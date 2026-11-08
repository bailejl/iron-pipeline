#!/usr/bin/env bash
# Cases for .claude/hooks/block-blanket-git-add.sh. Exit 1 on any mismatch.
set -u
cd "$(dirname "$0")/.."
fail=0
t() { # expect(deny|ok) command
  out=$(printf '{"tool_input":{"command":%s}}' "$(jq -Rn --arg c "$2" '$c')" | .claude/hooks/block-blanket-git-add.sh)
  got=ok; case "$out" in *deny*) got=deny ;; esac
  [ "$got" = "$1" ] || { echo "FAIL expected $1 got $got: $2"; fail=1; }
}
t deny 'git add -A'; t deny 'git add .'; t deny 'git add --all'
t deny 'git commit -am "x"'; t deny 'git commit -a -m x'
t deny 'git -C /x add -A'; t deny 'git -c k=v add .'
t deny '(git add -A)'; t deny '(cd x && git add .)'; t deny 'echo $(git commit -a -m x)'
t deny $'git add \\\n -A'; t deny $'git add -A\ngit status'
t deny 'git add -u'; t deny 'git add --update'; t deny 'git add ./'; t deny 'git add :/'
t deny 'git add "-A"'; t deny "git add '.'"; t deny 'git add -Av'
t ok 'git commit -uall -m x'; t ok 'git add -p src/a.cs'
t ok 'git add src/a.cs docs/x.md'; t ok 'git add ./a.cs'; t ok 'git add .gitignore'
t ok 'git commit --amend -m x'; t ok 'git commit -m "fix -a flag"'
t ok $'git add src/a.cs\nls -lA'; t ok $'git commit -m "x"\nls -la'
t ok $'git commit -m "$(cat <<\'EOF\'\nBlock "git add -A" in hook\nEOF\n)"'
[ $fail -eq 0 ] && echo "hook cases: OK"
exit $fail
