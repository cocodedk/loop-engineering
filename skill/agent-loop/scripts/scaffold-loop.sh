#!/usr/bin/env bash
# scaffold-loop.sh --template <name> --dest <dir> [--set KEY=VAL ...] [--templates-dir <dir>]
#
# Instantiate a reusable loop template into a run workspace, substituting {{KEY}}
# placeholders (e.g. {{OBJECTIVE}}, {{ITEM}}, {{SLUG}}, {{OUTPUT}}, {{NEXT}}) and
# writing a self-chaining run.sh entrypoint. Used by the planner and by run-chain
# (for fan-out children). Keeps loops self-contained and reusable.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TPL_DIR="$HERE/../templates"
TEMPLATE="" DEST=""; SETS=()
while [ $# -gt 0 ]; do case "$1" in
  --template) TEMPLATE="$2"; shift 2 ;;
  --dest) DEST="$2"; shift 2 ;;
  --templates-dir) TPL_DIR="$2"; shift 2 ;;
  --set) SETS+=("$2"); shift 2 ;;
  *) echo "unknown arg: $1" >&2; exit 2 ;;
esac; done
src="$TPL_DIR/$TEMPLATE"
[ -d "$src" ] || { echo "no such template: $src" >&2; exit 2; }
[ -n "$DEST" ] || { echo "--dest is required" >&2; exit 2; }

mkdir -p "$DEST"
cp -R "$src"/. "$DEST"/

esc(){ printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'; }
for kv in ${SETS[@]+"${SETS[@]}"}; do
  k="${kv%%=*}"; v="${kv#*=}"; ev="$(esc "$v")"
  find "$DEST" -type f \( -name '*.json' -o -name '*.md' -o -name '*.sh' \) -print0 \
    | xargs -0 -r sed -i "s|{{$k}}|$ev|g"
done

# Always expose the skill's scripts dir so a stage's verify.sh can call shared gates
# (e.g. judge-check.sh for a compound script+judge gate) by absolute path.
find "$DEST" -type f \( -name '*.json' -o -name '*.md' -o -name '*.sh' \) -print0 \
  | xargs -0 -r sed -i "s|{{SCRIPTS}}|$(esc "$HERE")|g"

# self-chaining entrypoint: run this loop, then (on success) the next one
printf '#!/usr/bin/env bash\nexec %q "$(cd "$(dirname "$0")" && pwd)" "$@"\n' "$HERE/loop-engine.sh" > "$DEST/run.sh"
chmod +x "$DEST/run.sh"
[ -f "$DEST/verify.sh" ] && chmod +x "$DEST/verify.sh"
echo "scaffolded $TEMPLATE -> $DEST"
