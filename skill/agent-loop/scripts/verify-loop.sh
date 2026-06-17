#!/usr/bin/env bash
# verify-loop.sh — a verification-gated agent loop over `claude -p`.
#
# Runs the VERIFY command; if it passes, exits. Otherwise feeds the failure back
# into a resumed Claude session and tries again, until the gate passes, a budget
# ceiling is hit, or the loop stalls (no progress — same failure SIGNATURE in a row).
#
# The verify command's EXIT CODE is the gate: 0 = done. That brake is the whole
# point — it lets reality, not the model's self-assessment, decide when to stop.
#
# RED-FIRST: a gate proves only what it ASSERTS, so by default the loop runs the
# gate once before touching anything and refuses to start if it is already green
# (a green-before-any-change gate usually is not testing the goal — the "100%-green
# but wrong" trap). Pass --allow-green-start to skip that guard.
#
# Usage:
#   verify-loop.sh --goal "<prompt>" --verify "<shell cmd>" [options]
#
# Options:
#   --goal     PROMPT   What to fix/achieve (required).
#   --verify   CMD      Shell command whose exit 0 means success (required).
#   --max      N        Max iterations (default 10). The unattended-safety ceiling.
#   --tools    LIST     --allowedTools for claude (default "Read,Edit,Bash").
#   --stall    N        Bail after N no-progress rounds (same failure signature) (default 3).
#   --reset-every N     Drop the session every N iterations for fresh eyes (default 0 = never).
#   --model    NAME     --model for claude (default: claude's default).
#   --escalate-model M  Switch to model M for the last try before a stall bail.
#   --worktree PATH     Create + run inside a git worktree at PATH (isolation).
#   --log      DIR      Write each iteration's verify output + git diff to DIR.
#   --allow-green-start Skip the red-first guard (loop even if the gate starts green).
#   --dry-run           Print what would run without calling claude.
#
# Exit: 0 done · 1 ceiling/stall · 2 bad args · 3 gate green before any change.
# Requires: claude, jq (git too if --worktree/--log diff).
set -euo pipefail

GOAL="" VERIFY="" MAX=10 TOOLS="Read,Edit,Bash" STALL=3 DRY=0
RESET_EVERY=0 MODEL="" ESCALATE_MODEL="" WORKTREE="" LOGDIR="" ALLOW_GREEN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --goal) GOAL="$2"; shift 2 ;;
    --verify) VERIFY="$2"; shift 2 ;;
    --max) MAX="$2"; shift 2 ;;
    --tools) TOOLS="$2"; shift 2 ;;
    --stall) STALL="$2"; shift 2 ;;
    --reset-every) RESET_EVERY="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --escalate-model) ESCALATE_MODEL="$2"; shift 2 ;;
    --worktree) WORKTREE="$2"; shift 2 ;;
    --log) LOGDIR="$2"; shift 2 ;;
    --allow-green-start) ALLOW_GREEN=1; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,33p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

[ -n "$GOAL" ]   || { echo "error: --goal is required"   >&2; exit 2; }
[ -n "$VERIFY" ] || { echo "error: --verify is required" >&2; exit 2; }
command -v claude >/dev/null || { echo "error: claude CLI not found" >&2; exit 2; }
command -v jq     >/dev/null || { echo "error: jq not found"         >&2; exit 2; }

# Optional git-worktree isolation: run the whole loop on a throwaway branch so the
# agent's edits never touch the main checkout. The worktree is left in place for
# inspection — remove it with `git worktree remove` when done.
if [ -n "$WORKTREE" ]; then
  command -v git >/dev/null || { echo "error: git needed for --worktree" >&2; exit 2; }
  branch="agent-loop-$(basename "$WORKTREE")"
  git worktree add -q -B "$branch" "$WORKTREE" 2>/dev/null || git worktree add -q "$WORKTREE"
  cd "$WORKTREE"; echo "↳ worktree: $WORKTREE (branch $branch)"
fi
[ -n "$LOGDIR" ] && mkdir -p "$LOGDIR"

GATE_OUT=""
run_gate() {  # sets GATE_OUT; returns the gate's exit code
  set +e; GATE_OUT="$(eval "$VERIFY" 2>&1)"; local rc=$?; set -e; return $rc
}

# A failure SIGNATURE = the set of failure-ish lines with volatile noise removed
# (paths, clock times, durations, line numbers, hex). This is what makes stall
# detection robust: a loop that fails on a DIFFERENT line/test/timestamp each
# round but makes no real progress still produces a STABLE signature, so we catch
# it instead of burning the whole budget on exact-output comparison.
signature() {
  local norm sig
  norm="$(printf '%s' "$1" | sed -E \
    -e 's#/[A-Za-z0-9._/-]+#/PATH#g' -e 's/[0-9]{2}:[0-9]{2}:[0-9]{2}//g' \
    -e 's/[0-9]+\.[0-9]+s?//g' -e 's/:[0-9]+:/:N:/g' -e 's/0x[0-9a-fA-F]+/0xADDR/g')"
  sig="$(printf '%s\n' "$norm" | grep -iE 'fail|error|assert|traceback|exception|✗' | sort -u)"
  [ -n "$sig" ] && printf '%s' "$sig" || printf '%s' "$norm"
}

log_iter() {  # $1 = iteration number
  [ -n "$LOGDIR" ] || return 0
  printf '%s\n' "$GATE_OUT" > "$LOGDIR/iter-$1.verify"
  git diff > "$LOGDIR/iter-$1.diff" 2>/dev/null || true
}

# Red-first guard: prove the gate is actually red before looping on it.
if run_gate; then
  [ "$ALLOW_GREEN" -eq 1 ] && { echo "✓ verify already green (--allow-green-start). Nothing to do."; exit 0; }
  {
    echo "⚠ verify passed BEFORE any change — the gate may not test the goal"
    echo "  (the '100%-green-but-wrong' trap). Make it fail on the bug first, or"
    echo "  pass --allow-green-start if a green start is genuinely expected."
  } >&2
  exit 3
fi

session="" iter=0 last_sig="__init__" stall_count=0
while [ "$iter" -lt "$MAX" ]; do
  iter=$((iter + 1))

  # Stall = no progress: same failure signature as the previous round.
  this_sig="$(signature "$GATE_OUT")"
  if [ "$this_sig" = "$last_sig" ]; then stall_count=$((stall_count + 1)); else stall_count=0; fi
  last_sig="$this_sig"
  if [ "$stall_count" -ge "$STALL" ]; then
    echo "✗ stalled: $STALL no-progress rounds (same failure signature). Stopping for human review." >&2
    exit 1
  fi

  echo "── iteration $iter/$MAX ── fixing (stall $stall_count/$STALL)"
  [ "$DRY" -eq 1 ] && { echo "[dry-run] would prompt claude with the goal + the failure."; exit 0; }

  # Fresh eyes: drop the session every N iterations so the agent can abandon an
  # entrenched failing approach instead of iterating variations of it.
  [ "$RESET_EVERY" -gt 0 ] && [ $((iter % RESET_EVERY)) -eq 0 ] && session=""
  # Last-ditch: escalate to a stronger model on the round before a stall bail.
  use_model="$MODEL"
  [ -n "$ESCALATE_MODEL" ] && [ "$stall_count" -ge $((STALL - 1)) ] && use_model="$ESCALATE_MODEL"
  mflag=(); [ -n "$use_model" ] && mflag=(--model "$use_model")

  prompt="Goal: $GOAL

The verification command \`$VERIFY\` is failing. Fix the ROOT CAUSE — do not
weaken, skip, or delete the check to make it pass. Failure output:
$GATE_OUT"

  if [ -z "$session" ]; then
    session="$(claude -p "$prompt" "${mflag[@]}" --allowedTools "$TOOLS" --output-format json | jq -r '.session_id')"
    [ -n "$session" ] && [ "$session" != "null" ] || { echo "error: no session_id from claude" >&2; exit 1; }
  else
    claude -p "$prompt" "${mflag[@]}" --allowedTools "$TOOLS" --resume "$session" >/dev/null
  fi

  # Re-run the gate to test this iteration's fix.
  if run_gate; then log_iter "$iter"; echo "✓ verify passed on iteration $iter. Done."; exit 0; fi
  log_iter "$iter"
done

echo "✗ hit iteration ceiling ($MAX) without passing verification." >&2
exit 1
