# Changelog — agent-loop

All notable changes to the `agent-loop` skill are recorded here. Format follows
[Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/).

**Convention for every change:** bump `version:` in `SKILL.md`, add an entry under a
new version heading here, and tag the merge commit `agent-loop-v<x.y.z>`. SemVer for
a skill: MAJOR = a breaking change to how you invoke it or to the loop/chain file
formats; MINOR = a new capability (template, gate type, flag); PATCH = a fix or doc
tweak that changes nothing about the interface.

## [Unreleased]

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
