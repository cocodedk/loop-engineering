# Changelog — agent-loop

All notable changes to the `agent-loop` skill are recorded here. Format follows
[Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/).

**Convention for every change:** bump `version:` in `SKILL.md`, add an entry under a
new version heading here, and tag the merge commit `agent-loop-v<x.y.z>`. SemVer for
a skill: MAJOR = a breaking change to how you invoke it or to the loop/chain file
formats; MINOR = a new capability (template, gate type, flag); PATCH = a fix or doc
tweak that changes nothing about the interface.

## [Unreleased]

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
