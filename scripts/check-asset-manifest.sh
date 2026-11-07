#!/usr/bin/env bash
# Every binary under assets/ must have a manifest entry (id == path relative to assets/).
set -euo pipefail
cd "$(dirname "$0")/.."
status=0
while IFS= read -r -d '' f; do
  rel="${f#assets/}"
  if ! grep -qF -- "path: $rel" assets-src/manifest.yaml; then
    echo "ASSET WITHOUT MANIFEST ENTRY: $rel" >&2; status=1
  fi
done < <(find assets -type f ! -name '.gitkeep' ! -name 'LICENSE' -print0)
[ $status -eq 0 ] && echo "asset manifest: OK"
exit $status
