#!/usr/bin/env bash
# Compound gate for one slice: repo invariants AND the slice's own assertion AND an
# independent xhigh reviewer. Frozen (chmod 444) and hash-checked — the loop must not
# be able to turn this green by weakening it.
set -euo pipefail
REPO="{{REPO}}"
SLICE="{{SLICE_ID}}"
TEST_TARGET="{{TEST_TARGET}}"

# 0. Gate integrity, before anything else.
if [ -f "$WORKSPACE/state/gate-hashes.txt" ]; then
  sha256sum -c --status "$WORKSPACE/state/gate-hashes.txt" \
    || { echo "GATE TAMPERED: a verify.sh or rubric.md no longer matches state/gate-hashes.txt" >&2; exit 1; }
fi

cd "$REPO"

# 1-3. The repo's own gate: invariants, full suite, and this slice's assertion. Kept in one
#      hash-frozen file per workspace so the same template serves a Python backend and a
#      Gradle app without forking it. Receives the slice's test target as $1. The slice
#      target is RED before the work exists — that is the red-first guard doing its job, and
#      it is why "the whole suite passes" is not sufficient here.
bash "$WORKSPACE/state/gate-cmds.sh" "$TEST_TARGET"

# 4. The declared output: a completion note.
[ -s "$WORKSPACE/state/slices/$SLICE.md" ] \
  || { echo "missing or empty completion note: state/slices/$SLICE.md" >&2; exit 1; }

# 5. Independent reviewer — a SEPARATE claude run at xhigh that never saw the builder's
#    reasoning. Runs only once the objective checks pass, so it costs ~one call per green
#    attempt. Its REJECT feedback re-reds the gate and reaches the next, higher-effort try.
bash "{{SCRIPTS}}/judge-check.sh" \
  --rubric "$LOOP_DIR/rubric.md" \
  --context "Slice {{SLICE_ID}}: {{TITLE}}. Brief: {{PLAN_FILE}} {{SECTION}} lines {{PLAN_LINES}}. Declared scope: {{SCOPE_FILES}}" \
  --effort xhigh --model opus --tools "Read,Bash"
