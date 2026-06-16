#!/usr/bin/env bash
# verify-loop.sh — a verification-gated agent loop over `claude -p`.
#
# Runs the VERIFY command; if it passes, exits. Otherwise feeds the failure back
# into a resumed Claude session and tries again, until the gate passes, a budget
# ceiling is hit, or the loop stalls (N identical failures in a row).
#
# The verify command's EXIT CODE is the gate: 0 = done. That brake is the whole
# point — it lets reality, not the model's self-assessment, decide when to stop.
#
# Usage:
#   verify-loop.sh --goal "<prompt>" --verify "<shell cmd>" [options]
#
# Options:
#   --goal     PROMPT   What to fix/achieve (required).
#   --verify   CMD      Shell command whose exit 0 means success (required).
#   --max      N        Max iterations (default 10). The unattended-safety ceiling.
#   --tools    LIST     --allowedTools for claude (default "Read,Edit,Bash").
#   --stall    N        Bail after N identical verify outputs in a row (default 3).
#   --dry-run           Print what would run without calling claude.
#
# Requires: claude, jq.
set -euo pipefail

GOAL="" VERIFY="" MAX=10 TOOLS="Read,Edit,Bash" STALL=3 DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --goal)   GOAL="$2"; shift 2 ;;
    --verify) VERIFY="$2"; shift 2 ;;
    --max)    MAX="$2"; shift 2 ;;
    --tools)  TOOLS="$2"; shift 2 ;;
    --stall)  STALL="$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

[ -n "$GOAL" ]   || { echo "error: --goal is required"   >&2; exit 2; }
[ -n "$VERIFY" ] || { echo "error: --verify is required" >&2; exit 2; }
command -v claude >/dev/null || { echo "error: claude CLI not found" >&2; exit 2; }
command -v jq     >/dev/null || { echo "error: jq not found"         >&2; exit 2; }

session=""
iter=0
last_hash=""
stall_count=0

while [ "$iter" -lt "$MAX" ]; do
  iter=$((iter + 1))
  echo "── iteration $iter/$MAX ── verifying: $VERIFY"

  # The gate. Capture output and exit code without tripping `set -e`.
  set +e
  out="$(eval "$VERIFY" 2>&1)"
  rc=$?
  set -e

  if [ "$rc" -eq 0 ]; then
    echo "✓ verify passed on iteration $iter. Done."
    exit 0
  fi

  # Stall detection: identical failure output N times in a row means the loop is
  # stuck and will only burn budget. Bail so a human can look.
  this_hash="$(printf '%s' "$out" | cksum | awk '{print $1}')"
  if [ "$this_hash" = "$last_hash" ]; then
    stall_count=$((stall_count + 1))
  else
    stall_count=0
  fi
  last_hash="$this_hash"
  if [ "$stall_count" -ge "$STALL" ]; then
    echo "✗ stalled: $STALL identical failures in a row. Stopping for human review." >&2
    exit 1
  fi

  if [ "$DRY" -eq 1 ]; then
    echo "[dry-run] would prompt claude with the goal + this failure output."
    continue
  fi

  prompt="Goal: $GOAL

The verification command \`$VERIFY\` is still failing. Fix the ROOT CAUSE — do not
weaken, skip, or delete the check to make it pass. Failure output:
$out"

  if [ -z "$session" ]; then
    session="$(claude -p "$prompt" \
      --allowedTools "$TOOLS" \
      --output-format json | jq -r '.session_id')"
    [ -n "$session" ] && [ "$session" != "null" ] || { echo "error: no session_id from claude" >&2; exit 1; }
  else
    # --resume keeps the agent's prior reasoning across iterations.
    claude -p "$prompt" --allowedTools "$TOOLS" --resume "$session" >/dev/null
  fi
done

echo "✗ hit iteration ceiling ($MAX) without passing verification." >&2
exit 1
