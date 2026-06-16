#!/usr/bin/env bash
# Objective gate: every declared output exists and is non-empty.
set -eu
mapfile -t outs < <(jq -r '.outputs[]? // empty' "$LOOP_DIR/loop.json")
[ "${#outs[@]}" -gt 0 ] || { echo "no outputs declared"; exit 1; }
for o in "${outs[@]}"; do [ -s "$WORKSPACE/$o" ] || { echo "missing/empty output: $o"; exit 1; }; done
echo "ok: ${#outs[@]} output(s) present"
