#!/usr/bin/env bash
# loop-engine.sh <loop-dir> [--driven] [--approve]
#
# Runs ONE loop in a chain: read loop.json, check inputs exist, run the gated
# act->verify loop, mark done, and (unless --driven) self-chain to `next`.
# Gate types: script (objective, preferred) | judge (LLM rubric) | human (sign-off).
#
# The loop's working directory is the WORKSPACE root (the dir holding chain.json),
# so prompts/verify commands see the project and the shared state/ dir. The loop
# dir and workspace are exported as LOOP_DIR and WORKSPACE for verify scripts.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

LOOP_DIR="" DRIVEN=0 APPROVE=0
while [ $# -gt 0 ]; do case "$1" in
  --driven)  DRIVEN=1; shift ;;
  --approve) APPROVE=1; shift ;;
  -*) echo "unknown arg: $1" >&2; exit 2 ;;
  *)  LOOP_DIR="$(cd "$1" && pwd)"; shift ;;
esac; done
[ -n "$LOOP_DIR" ] && [ -f "$LOOP_DIR/loop.json" ] || { echo "need a loop dir containing loop.json" >&2; exit 2; }

# WORKSPACE = nearest ancestor holding chain.json
WORKSPACE="$LOOP_DIR"
while [ "$WORKSPACE" != "/" ] && [ ! -f "$WORKSPACE/chain.json" ]; do WORKSPACE="$(dirname "$WORKSPACE")"; done
[ -f "$WORKSPACE/chain.json" ] || { echo "no chain.json above $LOOP_DIR" >&2; exit 2; }
export WORKSPACE LOOP_DIR

j(){ jq -r "$1" "$LOOP_DIR/loop.json"; }
relid="${LOOP_DIR#"$WORKSPACE"/}"
marker="$WORKSPACE/state/.done/$(printf '%s' "$relid" | tr '/' '_')"
mkdir -p "$WORKSPACE/state/.done"
gate="$(j '.gate.type')"
next="$(j '.next // empty')"

if [ -f "$marker" ]; then
  echo "✓ $relid already done (skip)"
else
  # input contract: every declared input must exist before this loop runs
  while IFS= read -r inp; do [ -z "$inp" ] && continue
    [ -e "$WORKSPACE/$inp" ] || { echo "✗ $relid missing input: $inp — run the upstream loop first" >&2; exit 3; }
  done < <(j '.inputs[]? // empty')

  goal="$(cat "$LOOP_DIR/$(j '.goal_file // "prompt.md"')" 2>/dev/null || j '.goal // ""')"
  max="$(j '.engine.max // 8')"; tools="$(j '.engine.tools // "Read,Edit,Bash"')"
  # Per-stage reasoning effort / model (default = claude's session default): set
  # engine.effort high on the hard judgment stages, low on mechanical ones.
  effort="$(j '.engine.effort // ""')"; model="$(j '.engine.model // ""')"
  eopt=(); [ -n "$effort" ] && eopt=(--effort "$effort")
  mopt=(); [ -n "$model" ] && mopt=(--model "$model")
  cd "$WORKSPACE"
  case "$gate" in
    script)
      "$HERE/verify-loop.sh" --goal "$goal" --verify "$(j '.gate.verify')" --max "$max" --tools "$tools" "${eopt[@]}" "${mopt[@]}"
      ;;
    judge)
      "$HERE/judge-loop.sh" --goal "$goal" --rubric "$LOOP_DIR/$(j '.gate.rubric // "rubric.md"')" --max "$max" --tools "$tools"
      ;;
    human)
      if [ "$APPROVE" -eq 0 ]; then
        echo "⏸ $relid is a HUMAN gate. Review its inputs, then re-run with --approve." >&2
        exit 10
      fi
      ;;
    *) echo "unknown gate type: $gate" >&2; exit 2 ;;
  esac

  # warn (don't fail) if declared outputs are missing
  while IFS= read -r out; do [ -z "$out" ] && continue
    [ -e "$WORKSPACE/$out" ] || echo "⚠ $relid passed its gate but declared output is missing: $out" >&2
  done < <(j '.outputs[]? // empty')
  touch "$marker"; echo "✓ $relid passed"
fi

# self-chain (standalone mode only; the chain runner advances itself)
if [ "$DRIVEN" -eq 0 ] && [ -n "$next" ] && [ "$next" != "null" ]; then
  [ -x "$WORKSPACE/$next/run.sh" ] || { echo "✗ next loop has no runnable run.sh: $next" >&2; exit 2; }
  exec "$WORKSPACE/$next/run.sh"
fi
