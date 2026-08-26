# Implement one slice: {{SLICE_ID}}

**{{TITLE}}**

## Read your brief from the plan — do not work from this summary alone

Your authoritative brief is **{{PLAN_FILE}}, section {{SECTION}} (lines {{PLAN_LINES}})**.
Read those lines first. This file only tells you which section is yours and how you will be
judged.

**Where this slice came from:** {{BRIEF}}
(If the section above reads "(not from the plan)", there is nothing to go read — this slice
was raised outside the plan document, and the notes below plus the acceptance criterion are
the whole brief.)

**Also read, before you start:** {{ALSO_READ}}

Other cross-cutting specs exist (§11 protocol v3, §12 ceremony, §13 MCP ACL matrix, §14
migration order, Appendix A finding→phase matrix, Appendix B per-phase acceptance) — read any
your own section references.

**Section numbers are not phase numbers.** This slice is Phase {{PHASE}}, section {{SECTION}}.
§5=Phase 1, §6=Phase 2, §7=Phase 3, §8=Phase 4, §9=Phase 5, §10=Phase 6.

## Acceptance criterion (this is what the gate asserts)

{{ACCEPTANCE}}

## Declared scope — stay inside it

    {{SCOPE_FILES}}

A diff outside these paths is rejected. No drive-by refactors, no "while I was in here".
If the work genuinely requires a file outside this list, write that in your completion note
and explain why; do not silently widen.

## Slice-specific notes

{{NOTES}}

## How to work

1. **Write the failing test first.** Your test target is `{{TEST_TARGET}}` and it does not
   exist yet — that is deliberate: the gate is red at start, which is what proves the gate
   tests your goal rather than something already true.
2. Make it pass by fixing the root cause. **Never** weaken, skip, delete or `xfail` a test,
   and never edit the gate (`verify.sh`, `rubric.md`, anything under `.agent-loops/`). Both
   are automatic rejections and the gate hashes are checked.
3. Repo invariants, all enforced: **200 lines max** for anything under `src/`, `chat/`, plus
   `main.py` and `chat_server.py` (`tests/` and `scripts/` are exempt). If your target file is
   at the cap, extract first — that is normal and expected here.
4. If you change behaviour, configuration, or a contract: update `README.md`,
   `website/index.html` and `website/fa/index.html` in the same commit (repo invariant, and
   the fa copy uses Persian numerals). If you change the test count, update it everywhere it
   appears.
5. Follow the repo conventions: tests are `test_<module>_<aspect>.py`, shared fixtures live in
   underscore-prefixed helper modules (there is no root `conftest.py`), subprocess is patched
   at the consuming module (`mocker.patch("src.spawner.subprocess.Popen")`), and
   `pytest-mock`'s `mocker` is used rather than patch decorators.
6. Commit on the current branch with a conventional-commit message
   (`^(feat|fix|chore|docs|style|refactor|test|ci|build|perf|revert)(\(.+\))?: .+` — the
   commit-msg hook rejects anything else). Never `--no-verify`. Never commit to master.
7. **Write your completion note to `state/slices/{{SLICE_ID}}.md`** (relative to the loop
   workspace). It is a declared output and the gate checks it exists. Include: what you
   changed and why, anything the plan got wrong, anything you resolved that the brief did not
   specify, and anything an operator must do by hand (secret rotation, a restart, a decision).

## Anything you cannot do in code

Some briefs contain operator actions — rotating a secret, restarting a service, a physical
device step. Do **not** fake them and do not claim them done. Implement the code half, and
record the operator half in your completion note as an explicit hand-off.
