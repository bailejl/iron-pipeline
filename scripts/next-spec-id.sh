#!/usr/bin/env bash
# Prints the next free spec id. Run it when naming work, before the issue or branch exists.
set -euo pipefail
source "$(dirname "$0")/lib/spec-id.sh"
next_spec_id
