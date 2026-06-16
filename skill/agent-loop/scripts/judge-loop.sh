#!/usr/bin/env bash
# judge-loop.sh --goal <prompt> --rubric <file> [--max N] [--tools LIST]
#
# An LLM-judge gated loop, for steps with no objective check. Each pass: Claude
# acts, then a SEPARATE Claude reviews the result against the rubric and returns
# {"pass":bool,"feedback":...}. Loops until PASS or the ceiling. The judge being a
# separate run is the point — the author is a poor judge of its own work.
# Experimental: needs claude + jq. Prefer an objective `script` gate where possible.
set -euo pipefail
GOAL="" RUBRIC="" MAX=6 TOOLS="Read,Edit,Bash"
while [ $# -gt 0 ]; do case "$1" in
  --goal) GOAL="$2"; shift 2 ;;
  --rubric) RUBRIC="$2"; shift 2 ;;
  --max) MAX="$2"; shift 2 ;;
  --tools) TOOLS="$2"; shift 2 ;;
  *) echo "unknown arg: $1" >&2; exit 2 ;;
esac; done
[ -n "$GOAL" ] && [ -f "$RUBRIC" ] || { echo "need --goal and an existing --rubric file" >&2; exit 2; }
command -v claude >/dev/null && command -v jq >/dev/null || { echo "need claude + jq" >&2; exit 2; }

session=""; feedback=""; i=0
while [ "$i" -lt "$MAX" ]; do
  i=$((i+1)); echo "── judge-loop $i/$MAX ──"
  if [ -z "$session" ]; then
    session="$(claude -p "$GOAL" --allowedTools "$TOOLS" --output-format json | jq -r '.session_id')"
  else
    claude -p "$GOAL

A reviewer rejected the previous attempt. Address this feedback precisely:
$feedback" --allowedTools "$TOOLS" --resume "$session" >/dev/null
  fi
  verdict="$(claude -p "You are a strict, independent reviewer. Inspect the current work and decide whether it satisfies the rubric below. Respond with ONLY JSON: {\"pass\":true|false,\"feedback\":\"what must change\"}.

RUBRIC:
$(cat "$RUBRIC")" --allowedTools "Read,Bash" --output-format json | jq -r '.result')"
  pass="$(printf '%s' "$verdict" | jq -r '.pass' 2>/dev/null || echo false)"
  feedback="$(printf '%s' "$verdict" | jq -r '.feedback' 2>/dev/null || echo '')"
  if [ "$pass" = "true" ]; then echo "✓ judge: PASS"; exit 0; fi
  echo "… judge: revise — $feedback"
done
echo "✗ judge-loop hit the ceiling without a PASS" >&2; exit 1
