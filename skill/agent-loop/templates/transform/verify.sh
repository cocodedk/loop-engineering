#!/usr/bin/env bash
# Objective gate: every declared output exists and is non-empty.
set -eu
mapfile -t outs < <(jq -r '.outputs[]? // empty' "$LOOP_DIR/loop.json")
[ "${#outs[@]}" -gt 0 ] || { echo "no outputs declared"; exit 1; }
for o in "${outs[@]}"; do [ -s "$WORKSPACE/$o" ] || { echo "missing/empty output: $o"; exit 1; }; done
echo "ok: ${#outs[@]} output(s) present"
# Compound gate: if this stage carries a rubric.md, an INDEPENDENT judge must ALSO
# pass (script AND judge). Add a rubric.md to non-trivial / correctness-critical
# stages — tests assert only what they assert; the judge catches missed call-sites,
# scope leaks, and self-weakened tests.
if [ -f "$LOOP_DIR/rubric.md" ]; then
  bash "{{SCRIPTS}}/judge-check.sh" --rubric "$LOOP_DIR/rubric.md"
fi
