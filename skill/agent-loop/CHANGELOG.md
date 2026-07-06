# Changelog — agent-loop

All notable changes to the `agent-loop` skill are recorded here. Format follows
[Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/).

**Convention for every change:** bump `version:` in `SKILL.md`, add an entry under a
new version heading here, and tag the merge commit `agent-loop-v<x.y.z>`. SemVer for
a skill: MAJOR = a breaking change to how you invoke it or to the loop/chain file
formats; MINOR = a new capability (template, gate type, flag); PATCH = a fix or doc
tweak that changes nothing about the interface.

## [Unreleased]

## [0.8.0] — 2026-07-07

Cost ceilings, permission scoping, and assert design. Honest-TDD note: five
additions were approved; two were dropped because their baseline scenarios
PASSED (writing-skills rule: no failing test, no guidance). A stall-triage
checklist and a "freeze deterministic steps into scripts" note proved
redundant — agents (even haiku) derived correct stall triage from the
anti-patterns list, and baked the recurring codemod+format step into the gate
script unprompted, reasoning "the verify command is the only mechanism
guaranteed to execute every iteration."

### Added
- **`verify-loop.sh --max-cost USD`** — a dollar ceiling alongside `--max`:
  sums each iteration's reported `total_cost_usd` (resumed calls now also run
  `--output-format json`) and bails exit 1 once the cap is crossed. Tested
  against a mocked `claude` binary: bails at cap, under-cap unaffected,
  no-flag behavior unchanged, red-first guard intact.
- **Permission scoping in the 60-second setup**: if supervision is background,
  also decide what the loop may do alone — scope `--allowedTools`/permissions
  to the minimum (an overnight loop rarely needs push, network, or rm).
  Baseline: an overnight-loop setup took the default toolset with zero
  deliberation; re-test reasons about the minimum explicitly.
- **gates.md "Designing the asserts"**: force outcomes not shape, assert the
  critical class separately (aggregate accuracy hides the class that matters),
  direction-of-change relations for fuzzy outputs, free-riding invariants.
  Baseline (haiku): a triage-pipeline gate asserted "retrieval returned ≥1
  doc" and only aggregate accuracy — the exact "completion and shape" trap
  from the v0.6.0 six-defect hunt. Frontier baselines passed this scenario;
  the note exists for the cheaper models loops route mechanical work to.

### Verified
- 5-rep scenario suite per decision (fable + haiku, every result read
  manually): stall-triage drop 5/5 (all reps validate gate + signal before
  escalating); codemod-in-gate drop 5/5 (all reps bake the recurring step into
  the verify command); assert-design note binding on haiku 5/5 (4 reps produce
  all four elements, all 5 pin the critical class + grounding invariant);
  permission scoping 5/5 behavioral, 4/5 with explicit deliberation. Bonus:
  4/5 overnight-loop reps adopted `--max-cost` unprompted.
- `--max-cost`: 4/4 mocked-`claude` tests; shellcheck: pre-existing info note
  only; `verify-loop.sh` at 171/200 lines.

## [0.7.0] — 2026-07-07

Loop-type selection, aligned with the Claude Code team's taxonomy (Anthropic's
"Getting started with loops"): turn-based / goal-based / time-based / proactive,
selected by **which piece of the work you hand off** — the check, the stop
condition, the trigger, or the prompt itself. Baseline-tested per the
writing-skills TDD process: 4 selection scenarios run against v0.6.0 first.

### Added
- `references/choosing.md` — the four loop types with trigger, stop criteria,
  primitive mapping, and a token lever per type; plus the escalation ladder
  ("start at the top row; move down only when the current row can't hold the job").
- **The don't-loop off-ramp** (SKILL.md): if the work doesn't recur and one
  attempt — gate run once at the end — would plausibly reach the goal, run a
  single verified turn instead of building loop machinery. Baseline failure: a
  "add a like button and make sure it works" request was routed into `/goal`.
- **Proactive composition** (SKILL.md table + choosing.md): a recurring stream of
  well-defined work = `/schedule` trigger + `/goal` per-run done + skills to
  verify + workflows for fan-out, output kept as reviewable candidates.
- Frontmatter trigger: "which loop type or primitive fits" questions
  ("/goal or /loop?", "do I even need a loop for this?").
- **Turn-based verification names the bundled `/verify` skill** (v2.1.145+,
  confirmed against the current skills doc) with `/run-skill-generator` for
  project-specific launches; a custom verification skill remains the path for
  checks that are yours alone. Baseline: agents hand-rolled verification plans
  and never reached for `/verify`.

### Changed
- **"Pick the primitive" → "Pick the loop type, then the primitive"**: the table
  is now keyed on what you hand off, and the `/goal` row documents the explicit
  turn cap (`, stop after N tries`). Baseline failure: an agent picked
  `verify-loop.sh` for "give up after 5 attempts" *because* the skill nowhere
  said `/goal` takes a cap — primitives.md now states "you don't need
  `verify-loop.sh` just to get a ceiling" and that bare `/goal` reports
  turns + token usage.
- primitives.md: `/loop` marked session-scoped ("machine off, loop off");
  cloud routines named as `/schedule`; mapping table gains the
  "not every task is a loop" row.

### Verified
- All 4 selection scenarios re-run against v0.7.0: single-turn task → no loop;
  laptop-off schedule → `/schedule` routine; capped score goal → `/goal … stop
  after 5 tries`; around-the-clock feedback stream → proactive composition.
  Plus a variant one-shot task not named in the docs, to rule out
  example-matching.

## [0.6.0] — 2026-07-06

Two anti-patterns from a real six-defect hunt (each bug peeled at ~35 min/iteration):
**an expensive gate as the only instrument** — split cheap probes ("is the system
right?") from the expensive gate ("is the deliverable right?", once, at the end);
and **misreading a correct gate** — when a confident fix "didn't work", re-derive
the failing signal's semantics at its source before iterating (a filtered count or
lagging aggregate falsifies every fix the same way).

## [0.5.0] — 2026-07-05

An unknowns-surfacing pass (via the surfacing-unknowns skill): an unattended loop
is maximally exposed to the map-vs-territory gap — it resolves every ambiguity
alone, one iteration at a time — so the goal's forks and the loop's judgment
calls must be explicit and reviewable.

### Added
- **Goal forks** (60-second setup): before looping, name the 1–2 readings of the
  goal you'd otherwise resolve silently ("fix the failing tests": fix the code,
  or fix wrong tests?), pick a default, and bake it into the goal prompt.
- **Decisions log** (judgment seat + worker templates): the loop appends every
  goal-unspecified judgment call to `decisions.md` (`per-item` writes
  `{{SLUG}}.decisions.md` — parallel fan-out workers must not share one file);
  review decisions before diffs. The v0.4.0 judge-script edit was caught only by
  diff archaeology; a decisions log surfaces such calls directly.
- `references/gates.md` — gate hygiene: the full visual-judge recipe and the
  flaky-gate diagnosis playbook, moved out of the core (which sat at 197/200
  lines) behind summaries + pointers.

### Changed
- **Frontmatter description no longer summarizes the workflow** (it described
  picking primitives, ceilings, worktrees, decomposition): superpowers' skill
  testing shows agents follow a workflow-summarizing description INSTEAD of
  reading the body. All trigger phrases kept; triggers-only now.
- **Stop-hook wording corrected** (SKILL.md table + primitives.md): per current
  docs, a command Stop hook blocks with exit 2 (stderr fed back), while
  prompt/agent Stop hooks return `{"ok": false, "reason": …}` — the documented
  "don't stop until green" pattern that `/goal` wraps.

### Verified
- All primitives re-checked against current Claude Code docs (2026-07-04):
  `/goal` (requires v2.1.139+), `/loop`, `--worktree`/`-w`, headless `-p` +
  `--resume` + `--output-format json`, `--allowedTools`, cloud routines
  (research preview) — all current; only the Stop-hook nuance needed fixing.

## [0.4.0] — 2026-06-18

Lessons banked from running a real 4-stage loop chain (rebuilding a product's user
manual). The chain over-delivered on teaching us where the skill was thin.

### Added
- **Per-stage effort/model.** `verify-loop.sh` + `judge-check.sh` take `--effort`
  (`low`…`max`); `loop-engine.sh` threads `engine.effort` / `engine.model` from
  `loop.json` to the script-gate runner. A chain ran every stage at the default
  effort — mechanical and judgment stages alike — with no knob to change it.
- **Visual-judge recipe** (SKILL.md): for a *visual* deliverable, render the result
  to a PNG in `verify.sh`, then point the rubric at the image — `judge-check.sh`'s
  reviewer uses Read, which VIEWS images, so it rules on look-and-feel. Proven: a
  design loop's judge viewed the rendered pages and bounced its first redesign.

### Changed
- `judge-check.sh` now **robustly recovers the verdict object** from a judge that
  narrates or fences its JSON (was a bare `jq` parse → false-negative gate failures
  when the judge added prose). Reads the REAL verdict; a `pass:false` still fails.

### Documented (anti-patterns / gotchas)
- **A gate the loop can edit** is the sharpest new anti-pattern — a design loop, hitting
  the false-negative above, edited the judge script *itself*. That time a legit fix, but
  the capability is the risk; keep gate + skill scripts out of the loop's writable scope
  and diff them after a run.
- **Bake project conventions (file-size cap, ruff, type-check) into stage gates** — a
  stage with no lint gate shipped a 1121-line file.
- **Declare a real artifact as a stage output**, not the engine's `state/.done/<id>`
  marker (spurious "output missing" warnings otherwise).
- **The terminal stage must be `human`** (or `--allow-green-start`) — a redundant final
  script gate is green-before-change and trips the red-first guard (exit 3).

## [0.3.1] — 2026-06-18

### Fixed

- `judge-check.sh` now robustly recovers the verdict object from the judge's
  `.result`. The judge is a separate Claude run that routinely narrates and/or
  wraps its JSON in a ```` ```json ```` fence, so `.result` was prose + JSON, not a
  bare object — `jq -r '.result' | jq '.pass'` failed to parse and every green
  attempt reported "judge returned no parseable verdict" regardless of the real
  verdict. A small `python3` extractor scans for fenced/balanced/greedy JSON
  candidates and picks the last that validates as an object with a `pass` key.
  The gate is unchanged: a `pass:false` verdict still FAILS, and truly empty
  output still reports "no parseable verdict". Adds a `python3` dependency.

## [0.3.0] — 2026-06-18

Compound gates — a script gate alone can't catch what tests don't assert. Learned
from a loop whose tests passed but billed the wrong API key on an un-tested path; an
independent review caught it after the loop, not during.

### Added
- `scripts/judge-check.sh`: a ONE-SHOT independent-judge GATE (vs `judge-loop.sh`'s
  loop). A separate Claude adversarially reviews the working tree + `git diff` against
  a rubric → exit 0 PASS / 1 FAIL with feedback. Designed to chain in a stage's
  `verify.sh` after the objective tests: `run-tests && judge-check.sh --rubric rubric.md`.
- Compound script+judge gating in the `transform` + `per-item` templates: `verify.sh`
  now runs `judge-check.sh` automatically iff the stage carries a `rubric.md`, so a
  non-trivial / correctness-critical stage becomes script AND judge just by adding a
  rubric. `scaffold-loop.sh` substitutes `{{SCRIPTS}}` (the skill scripts dir) so the
  scaffolded gate can call the shared judge by path.
- SKILL.md gate-validity: "when tests can't see the bug, put a judge in the gate" —
  the judge catches missed call-sites, scope/permission leaks, and self-weakened tests
  that a script gate structurally cannot; it must be a separate run from the author.

## [0.2.0] — 2026-06-17

Hardening of the single-loop gate, learned from running a real flaky-suite loop.

### Added
- `verify-loop.sh` **red-first guard**: runs the gate before any change and refuses to
  start if it is already green — a gate that passes for the wrong reason (typo'd path,
  doesn't exercise the bug) otherwise "succeeds" having done nothing. `--allow-green-start`
  opts out (exit code 3 = green-before-change).
- `verify-loop.sh` flags: `--reset-every N` (drop the session for fresh eyes when an
  approach entrenches), `--escalate-model M` (last-ditch stronger model on the round
  before a stall bail), `--worktree PATH` (run the whole loop on a throwaway branch),
  `--log DIR` (write each iteration's verify output + git diff for an audit trail).
- SKILL.md: gate-*validity* guidance (prove red-first; use behavioral/live-data gates
  for correctness/security goals, not coverage); a flaky-gate diagnosis playbook
  (measure the rate, separate infra-flake from real bug, state-guard/bisect); and the
  `judge-loop.sh` LLM-judge gate + `loop-engine.sh` chain runner are now surfaced in the
  primitive table / chain steps.

### Changed
- `verify-loop.sh` stall detection compares a **normalized failure signature** (failure
  lines with paths/clock-times/durations/line-numbers/hex stripped, deduped) instead of
  an exact-output hash — so it catches "no progress" even when the failure looks
  cosmetically different each round (the case that previously burned the whole budget).

## [0.1.0] — 2026-06-16

Initial release. The runnable companion to the loop-engineering knowledge base.

### Single loop
- `scripts/verify-loop.sh` — a verification-gated `act → verify → re-prompt` loop
  over `claude -p`, with a budget ceiling (`--max`) and stall detection (bails after
  N identical failures).
- `references/primitives.md` — maps the methodology to documented Claude Code
  primitives (`claude -p`, `--output-format json`, `--resume`, `/goal`, `/loop`,
  Stop hooks, worktrees) with a decision table for picking one.
- `SKILL.md` — the runbook: verification-first rule, the 60-second setup
  (goal / verify command / budget / isolation / supervision), and anti-patterns.

### Loop chains (decomposition)
- `scripts/run-chain.sh` — drives a `chain.json` backbone: linear stages, parallel
  fan-out with a join, resume (skips done stages), and `--from` entry-from-anywhere.
- `scripts/loop-engine.sh` — runs one loop (input check → gate → mark done →
  self-chain to `next`).
- `scripts/scaffold-loop.sh` — instantiate a template into a loop folder.
- `scripts/judge-loop.sh` — experimental LLM-judge gate against a rubric.
- `templates/` — `discover-items`, `per-item`, `transform`, `assemble`,
  `final-review`.
- Hybrid gates: objective `script` → LLM `judge` → `human` sign-off at the terminal
  stage.
- `references/chains.md`, `references/loop-chains-design.md` — schemas, runtime,
  planner procedure, worked user-manual example, and the approved design spec.

### Verified
- Claude-free integration test (13/13): linear ordering, fan-out + bounded-parallel
  + join, human-gate pause → approve, `--from`, resume-skips-done, missing-input
  guard. All scripts shellcheck-clean; every file under 200 lines.

[Unreleased]: https://github.com/cocodedk/loop-engineering/compare/agent-loop-v0.1.0...HEAD
[0.1.0]: https://github.com/cocodedk/loop-engineering/releases/tag/agent-loop-v0.1.0
