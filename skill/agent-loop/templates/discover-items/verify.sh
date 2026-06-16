#!/usr/bin/env bash
# Objective gate: the declared output exists and holds a non-empty items array.
set -eu
out="$(jq -r '.outputs[0] // empty' "$LOOP_DIR/loop.json")"
key="$(jq -r '.check.items_key // "items"' "$LOOP_DIR/loop.json")"
[ -n "$out" ] || { echo "no output declared in loop.json"; exit 1; }
f="$WORKSPACE/$out"
[ -s "$f" ] || { echo "missing or empty: $f"; exit 1; }
n="$(jq -r --arg k "$key" '(.[$k] // []) | length' "$f" 2>/dev/null || echo 0)"
[ "$n" -gt 0 ] 2>/dev/null || { echo "no items under .$key in $f"; exit 1; }
echo "ok: $n items in $out"
