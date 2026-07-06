# Gate hygiene — assertions, visual judges, flaky gates

Moved from the core `SKILL.md` (which stays under the 200-line cap); the pointers
there lead here. All sections are banked lessons from real loop runs.

## Designing the asserts: force outcomes, don't check shape

The six-defect hunt behind the v0.6.0 anti-patterns survived 100% coverage
because every assert checked *completion and shape* ("ran, parsed, non-empty"),
never truth. When writing the gate's assertions:

1. **Assert outcomes the domain forces, not presence.** "Retrieval returned ≥1
   doc" is a shape check; "the labeled gold doc for THIS input appears in the
   top-k" is an assertion. Build fixtures where the right answer is forced by
   construction — a corpus deliberately missing one document, whose requirement
   therefore MUST come back unmet — and assert that consequence.
2. **Assert the critical class separately.** One aggregate threshold ("accuracy
   ≥95%") lets the class that actually matters hide in the average. Pull it out
   and pin it: abuse recall ≥98%, zero abuse tickets auto-replied.
3. **Fuzzy output with no single correct answer? Assert the direction of
   change**: add the decisive evidence ⇒ the verdict must not get worse; remove
   it ⇒ it must not stay "met"; reorder or reformat the input ⇒ the output must
   not change. Direction-relations tolerate nondeterminism; exact values don't.
4. **Invariants ride along free in every other test**: idempotence, no data
   loss, output ⊆ input, every URL in a reply exists in the retrieved docs.

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
