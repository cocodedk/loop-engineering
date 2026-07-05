# Gate hygiene — visual judges and flaky gates

Moved from the core `SKILL.md` (which stays under the 200-line cap); the pointers
there lead here. Both sections are banked lessons from real loop runs.

## Visual / subjective deliverables: render, then let the judge SEE it

A judge reading HTML/CSS can't tell whether a page *looks* good. But
`judge-check.sh`'s reviewer uses Read, which VIEWS images — so for a visual goal:

1. Make the stage's `verify.sh` render the deliverable to PNG (headless browser,
   a `--screenshot` flag, or the project's own render path), e.g. `build/page-*.png`.
2. Point the rubric at the files: "view `build/page-*.png`; FAIL if it looks
   auto-generated / violates the style guide."
3. The judge then rules on look-and-feel, not markup plausibility.

Proven in a real run: a manual-design loop's judge viewed the rendered pages and
bounced its first redesign.

Two companions that belong in the same gate:

- **Fold the project's OWN conventions into the gate** — file-size cap,
  `ruff`/lint, type-check. A stage with no lint gate happily shipped a 1121-line
  file (seen for real).
- **Spend effort where judgment lives** — give the judge stage a higher `effort`
  (per-stage `engine.effort` / `--effort`); mechanical stages can stay low.

## Flaky gates: stabilize before you loop

A nondeterministic check makes the loop thrash — and worse, tempts it to "fix"
the *symptom* of a flake instead of a bug. Stabilize the gate *first*:

1. **Measure the flake rate** — run the gate N times on untouched code; count
   divergent outcomes.
2. **Classify** — an **infra flake** (parallel test-DB races, port collisions,
   shared state, test-order dependence) is not a **real bug**; they need
   different fixes, and only one of them belongs in your loop's goal.
3. **Pin the cause** — add a state-guard (snapshot global state before/after each
   test to catch the mutator) or bisect the suite. A flake that fails on a
   *different* test each run is usually ONE shared-state root cause, not many.
4. Only then loop — with the stabilized gate as the brake.
