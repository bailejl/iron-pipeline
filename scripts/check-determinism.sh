#!/usr/bin/env bash
# Greppable determinism hazards in Sim rule code. Exit 1 on any hit.
# Allow an explicit, reviewed exception with a trailing comment: // determinism: ok <reason>
set -euo pipefail
cd "$(dirname "$0")/.."
pattern='new\s+Random\s*\(\s*\)|Random\.Shared|DateTime\.(Now|UtcNow|Today)|Stopwatch|Environment\.TickCount|Parallel\.|Task\.Run|\b(float|double|decimal)\b|Guid\.NewGuid'
hits=$(grep -rnE "$pattern" src/IronPipeline.Sim --include='*.cs' --exclude-dir=obj --exclude-dir=bin | grep -v 'determinism: ok' || true)
if [ -n "$hits" ]; then
  echo "$hits"
  echo "DETERMINISM HAZARD(S) found in IronPipeline.Sim (see above). Use the injected IRandom, integer math, and deterministic ordering." >&2
  exit 1
fi
echo "determinism: OK"
