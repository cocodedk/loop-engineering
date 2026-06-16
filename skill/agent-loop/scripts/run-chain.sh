#!/usr/bin/env bash
# run-chain.sh <workspace> [--from <stage-id>] [--approve] [--force]
#
# Drives a planned chain (chain.json) from a start stage to the end. Linear stages
# run via loop-engine; a fan-out stage instantiates one sub-loop per discovered
# item, runs them in bounded parallel, and JOINS (all must pass) before advancing.
# Resumable: stages already marked done are skipped. Start anywhere with --from;
# the run proceeds through the chain's `next` pointers to the terminal stage.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ENGINE="$HERE/loop-engine.sh"; SCAFFOLD="$HERE/scaffold-loop.sh"

WS="" FROM="" APPROVE="" FORCE=0
while [ $# -gt 0 ]; do case "$1" in
  --from) FROM="$2"; shift 2 ;;
  --approve) APPROVE="--approve"; shift ;;
  --force) FORCE=1; shift ;;
  -*) echo "unknown arg: $1" >&2; exit 2 ;;
  *) WS="$(cd "$1" && pwd)"; shift ;;
esac; done
[ -n "$WS" ] && [ -f "$WS/chain.json" ] || { echo "need a workspace dir containing chain.json" >&2; exit 2; }

sf(){ jq -r --arg id "$1" '.stages[] | select(.id==$id) | '"$2" "$WS/chain.json"; }
slugify(){ printf '%s' "$1" | tr -c 'A-Za-z0-9._-' '-' | sed 's/--*/-/g; s/^-//; s/-$//'; }
done_marker(){ printf '%s/state/.done/%s' "$WS" "$(printf '%s' "$1" | tr '/' '_')"; }

[ "$FORCE" -eq 1 ] && rm -rf "$WS/state/.done"
cur="${FROM:-$(jq -r '.stages[0].id' "$WS/chain.json")}"

while [ -n "$cur" ] && [ "$cur" != "null" ]; do
  if [ -f "$(done_marker "$cur")" ] && [ "$FORCE" -ne 1 ]; then
    echo "✓ $cur done (skip)"; cur="$(sf "$cur" '.next // "null"')"; continue
  fi
  echo "══ stage: $cur ══"
  fanout="$(sf "$cur" '.fanout // "null"')"

  if [ "$fanout" = "null" ]; then
    [ -f "$WS/$cur/loop.json" ] || { echo "✗ stage $cur has no loop.json" >&2; exit 2; }
    "$ENGINE" "$WS/$cur" --driven $APPROVE
  else
    items_from="$(sf "$cur" '.fanout.items_from')"
    items_key="$(sf "$cur" '.fanout.items_key // "items"')"
    template="$(sf "$cur" '.fanout.template')"
    maxp="$(sf "$cur" '.fanout.max_parallel // 4')"
    [ -s "$WS/$items_from" ] || { echo "✗ fan-out source missing: $items_from (run the discovery stage first)" >&2; exit 3; }
    mapfile -t items < <(jq -r --arg k "$items_key" '.[$k][]' "$WS/$items_from")
    echo "  fan-out: ${#items[@]} items into '$template' (max_parallel=$maxp)"
    running=0
    for it in "${items[@]}"; do
      slug="$(slugify "$it")"; child="$WS/$cur/$slug"
      if [ ! -f "$child/loop.json" ]; then
        "$SCAFFOLD" --template "$template" --dest "$child" \
          --set ITEM="$it" --set SLUG="$slug" --set STAGE="$cur" \
          --set OBJECTIVE="$(jq -r '.objective // ""' "$WS/chain.json")"
      fi
      ( "$ENGINE" "$child" --driven ) &
      running=$((running+1))
      if [ "$running" -ge "$maxp" ]; then wait -n 2>/dev/null || wait; running=$((running-1)); fi
    done
    wait
    # join: every child must be marked done
    fail=0
    for it in "${items[@]}"; do
      slug="$(slugify "$it")"
      [ -f "$(done_marker "$cur/$slug")" ] || { echo "✗ fan-out item failed: $cur/$slug" >&2; fail=1; }
    done
    [ "$fail" -eq 0 ] || { echo "✗ fan-out join failed at $cur — fix the failing items and re-run" >&2; exit 1; }
    touch "$(done_marker "$cur")"; echo "✓ $cur fan-out joined (${#items[@]} items)"
  fi
  cur="$(sf "$cur" '.next // "null"')"
done
echo "✅ chain complete"
