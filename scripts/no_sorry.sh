#!/usr/bin/env bash
# Sorry-gate: fail if any `sorry` / `admit` / `native_decide` / `axiom`
# declaration appears in the committed Lean sources. Run locally and in CI.
# Rename LIB to match your library directory.
set -euo pipefail
cd "$(dirname "$0")/.."

LIB="Project"
status=0

if grep -RnE '(^|[^[:alnum:]_])(sorry|admit|native_decide)([^[:alnum:]_]|$)' \
    "$LIB" --include='*.lean'; then
  echo "ERROR: forbidden token (sorry/admit/native_decide) in $LIB/." >&2
  status=1
fi

if grep -RnE '^[[:space:]]*axiom[[:space:]]' "$LIB" --include='*.lean'; then
  echo "ERROR: 'axiom' declaration in $LIB/." >&2
  status=1
fi

if [ "$status" -eq 0 ]; then
  echo "sorry-gate: OK (no sorry/admit/native_decide/axiom in $LIB/)."
fi
exit "$status"
