#!/usr/bin/env bash
# judge-check.sh --rubric <file> [--context "<text>"] [--tools LIST]
#
# A ONE-SHOT independent-judge GATE (not a loop). A SEPARATE Claude — not the one
# that wrote the code — adversarially reviews the current working tree + `git diff`
# against the rubric and exits 0 = PASS, 1 = FAIL (printing what must change).
#
# Chain it in a stage's verify.sh AFTER the objective tests so the gate is
# script AND judge:
#     run-tests && judge-check.sh --rubric "$LOOP_DIR/rubric.md"
#
# Why: tests assert only what they assert. The judge catches what they
# structurally can't — a missed call-site, a scope/permission leak, a loop that
# weakened its own tests to pass. The author is a poor judge of its own work, so
# this MUST be a separate run from the one that produced the change.
#
# On FAIL the feedback is printed (captured by the loop) so the next iteration can
# act on it. The judge only runs once the tests pass (the `&&`), so it costs ~one
# model call per green attempt, not one per loop iteration.
#
# Experimental: needs claude + jq. Prefer adding it to correctness-/security-
# critical stages; a trivial mechanical stage may not need a judge.
set -euo pipefail

RUBRIC="" CONTEXT="" TOOLS="Read,Bash" EFFORT="" MODEL=""
while [ $# -gt 0 ]; do case "$1" in
  --rubric) RUBRIC="$2"; shift 2 ;;
  --context) CONTEXT="$2"; shift 2 ;;
  --tools) TOOLS="$2"; shift 2 ;;
  --effort) EFFORT="$2"; shift 2 ;;
  --model) MODEL="$2"; shift 2 ;;
  -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
  *) echo "unknown arg: $1" >&2; exit 2 ;;
esac; done
[ -f "$RUBRIC" ] || { echo "judge-check: need an existing --rubric file" >&2; exit 2; }
command -v claude >/dev/null && command -v jq >/dev/null && command -v python3 >/dev/null \
  || { echo "judge-check: need claude + jq + python3" >&2; exit 2; }

prompt="You are a strict, INDEPENDENT reviewer — you did NOT write this code. Adversarially
inspect the CURRENT working tree: read the changed files and run \`git diff\` (and
\`git diff --staged\`). Decide whether the change satisfies EVERY item in the rubric.
Be skeptical and look specifically for: a requirement wired in one place but MISSED at
another call-site; scope/permission/tenant leaks; and tests that were deleted, weakened,
or that don't exercise the real path (e.g. mocking the very thing under test). When in
doubt, FAIL. Respond with ONLY JSON: {\"pass\":true|false,\"feedback\":\"specific, with file:line, what must change\"}.
${CONTEXT:+
CONTEXT: $CONTEXT}

RUBRIC:
$(cat "$RUBRIC")"

eflag=(); [ -n "$EFFORT" ] && eflag=(--effort "$EFFORT")
mflag=(); [ -n "$MODEL" ] && mflag=(--model "$MODEL")
raw="$(claude -p "$prompt" "${eflag[@]}" "${mflag[@]}" --allowedTools "$TOOLS" --output-format json | jq -r '.result')"

# The judge is a separate Claude run; it routinely narrates and/or wraps its
# verdict in a ```json fence, so .result is prose + JSON, not a bare object.
# Recover the verdict object (validating each candidate with json.loads) before
# reading it. This reads the judge's REAL decision — a pass:false verdict still
# FAILS the gate — it does not weaken the check.
verdict="$(printf '%s' "$raw" | python3 -c '
import json, re, sys
text = sys.stdin.read()
cands = []
for m in re.finditer(r"```(?:json)?\s*(\{.*?\})\s*```", text, re.S):
    cands.append(m.group(1))
depth = 0; start = None
for i, ch in enumerate(text):
    if ch == "{":
        if depth == 0: start = i
        depth += 1
    elif ch == "}" and depth > 0:
        depth -= 1
        if depth == 0 and start is not None:
            cands.append(text[start:i + 1]); start = None
a = text.find("{"); b = text.rfind("}")
if a != -1 and b > a: cands.append(text[a:b + 1])
best = None
for c in cands:
    try:
        obj = json.loads(c)
    except Exception:
        continue
    if isinstance(obj, dict) and "pass" in obj:
        best = obj
sys.stdout.write(json.dumps(best) if best is not None else "")
')"
pass="$(printf '%s' "$verdict" | jq -r '.pass' 2>/dev/null || echo false)"
feedback="$(printf '%s' "$verdict" | jq -r '.feedback' 2>/dev/null || echo 'judge returned no parseable verdict')"

if [ "$pass" = "true" ]; then
  echo "✓ judge: PASS"
  exit 0
fi
echo "✗ judge: FAIL — $feedback" >&2
exit 1
