# Reviewer rubric — slice {{SLICE_ID}}

You are reviewing **{{TITLE}}**.

The authoritative brief is `{{PLAN_FILE}}` section **{{SECTION}}**, lines **{{PLAN_LINES}}**, in
`{{REPO}}`. Read those lines before judging. You are judging the diff against that brief, not
against a summary of it.

## Automatic FAIL — check these first, no judgement required

1. **The gate was touched.** Any change to a `verify.sh`, a `rubric.md`, `state/gate-hashes.txt`,
   or anything else under `.agent-loops/` other than `state/slices/{{SLICE_ID}}.md`.
2. **A test was weakened.** Any test deleted, renamed-away, skipped, `xfail`ed, an assertion
   removed, a tightened assertion loosened, or a real code path replaced with a mock of the
   very thing under test. Read `git diff` on `tests/` line by line.
3. **The 200-line cap is breached.** Any file under `src/` or `chat/`, or `main.py` /
   `chat_server.py`, now over 200 lines. Verify by counting, not by trusting
   `check-line-limit.sh` — confirm the script's scan actually covers the changed files.
4. **The diff strays outside the declared scope:** `{{SCOPE_FILES}}`. A file outside that list
   is a FAIL unless the completion note names it and gives a reason that holds up.
5. **The commit message** does not match
   `^(feat|fix|chore|docs|style|refactor|test|ci|build|perf|revert)(\(.+\))?: .+`.
6. **Master was committed to**, or a hook was bypassed with `--no-verify`.

## Extra auto-FAIL rules for this campaign

{{RUBRIC_ADDITIONS}}

## The substantive question

7. **Does the change actually satisfy the acceptance criterion?** Quoted from the plan:

   > {{ACCEPTANCE}}

   Not "is there code that looks related" — does it *meet* this? If the criterion names an
   absence (a credential absent from a child environment, a tool absent from a schema), verify
   the absence directly rather than trusting a test's name.

8. **Is the requirement wired at EVERY call-site, not just one?** This is the failure mode
   tests structurally cannot catch and the single most valuable thing you do here. Grep for
   every sibling call-site of whatever was changed and confirm each one is covered. A security
   requirement honoured in three of four spawn sites is a FAIL, not a partial pass.

9. **Scope, permission, and tenant leaks.** Can the new code path be reached by a caller that
   should not reach it? Does it widen what an existing caller can do? For anything touching
   the chat bus or email ingress, assume a hostile local process and a compromised mailbox.

10. **Does the test exercise the real path?** A test that mocks the function under test, or
    asserts on a string it also constructed, proves nothing. The test must fail if the
    implementation is reverted — reason about whether it would.

11. **Docs invariant.** If behaviour, configuration, or a contract changed, then `README.md`,
    `website/index.html` and `website/fa/index.html` must be updated in the same commit (the
    Persian copy uses Persian numerals). If the test count changed, it must be updated
    everywhere it appears.

12. **Honesty of the completion note.** `state/slices/{{SLICE_ID}}.md` must not claim anything
    the diff does not show. Operator-only steps (rotating a secret, restarting a service, a
    physical device action) must be recorded as hand-offs, not reported as done. A note that
    overclaims is a FAIL even if the code is fine — it corrupts every downstream decision.

## Slice-specific notes the builder was given

{{NOTES}}

## Verdict

When in doubt, FAIL — a false pass here lands broken security work on a branch that a human
will trust. Be specific: cite `file:line` and say exactly what must change. Your feedback is
fed verbatim into the next attempt, which runs at a higher reasoning effort, so a precise
rejection is worth far more than a vague one.
