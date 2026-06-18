---
name: agent-loop
version: 0.3.0
description: Run a disciplined, verification-gated autonomous loop on the current project — Boris Cherny's "I write loops" methodology made runnable. Use whenever the user wants Claude to keep working on its own until a goal holds: "run a loop", "loop until the tests pass", "keep going until the build is green", "fix all of these until the suite is clean", "babysit this until it's done", "run this autonomously", "set up a self-verifying loop", "iterate until X", or references agent loops / loop engineering / Cherny's methodology. Trigger even when the user never says the word "loop" — any "keep doing X until condition Y holds, then stop" request is a loop. This skill picks the right primitive (/goal, a `claude -p` while-loop, a Stop hook, or a scheduled /loop), sets a budget ceiling, isolates parallel work in git worktrees, and keeps the human in the judgment seat. It also DECOMPOSES a large objective into a chain of smaller loops when one loop isn't enough — fires on "create user manuals", "break this objective into steps", "turn this into a pipeline of loops", or any multi-stage deliverable whose stages fan out over many items (one loop per page, screen, or endpoint).
argument-hint: [goal, e.g. "all tests in api/ pass and lint is clean"]
---

# Agent Loop

Turn a goal into a loop that runs itself. Instead of prompting turn by turn, you
define a goal with a real verification gate and let Claude run **act → verify →
re-prompt** until the gate passes or a budget ceiling stops it. This is the
practical companion to the loop-engineering knowledge base (see end of file).

## The one rule: verification is the engine

A loop without a real verification gate is just repeated guessing. The model will
happily declare victory while the build is red. What makes a loop trustworthy is a
gate that lets *reality* — a test suite, a build, the app actually running — decide
whether a pass made progress. Cherny's line: a verification feedback loop "2-3x"
the quality of the result. So the first question is never "what should the agent
do" — it's **"how will the loop know it's done?"**

If the project has no way to verify the goal (no tests, no build, no runnable
check), stop and say so. Propose adding a check first. Looping without one is the
single most common way these go wrong.

**A gate proves only what it asserts — so validate the gate, don't just run it.**
Two traps hide here: a gate green *for the wrong reason* (a typo'd test path, a check
that never exercises the bug — 100% coverage with mocks has shipped real auth bugs
past review), and a gate too shallow to catch a behavioral break. Two habits close
both: **prove it red-first** — run the gate on the *unfixed* code and confirm it fails
*for the right reason* before looping (`verify-loop.sh` does this by default and
refuses a green start unless `--allow-green-start`); and for correctness- or
security-critical goals make the gate **behavioral / live-data** (drive the real
endpoint, assert the real contract), not coverage.

**When tests can't see the bug, put a judge in the gate.** Even a behavioral,
red-first test only checks what it asserts — it can't catch a requirement wired in one
place but missed at another call-site, a scope/permission leak, or a loop that quietly
weakened its own tests. For non-trivial or correctness-/security-critical stages, make
the gate **script AND judge**: the objective tests PLUS an independent reviewer
(`scripts/judge-check.sh`) that adversarially reads the diff against a rubric and fails
with feedback the loop then acts on. Drop a `rubric.md` into the stage folder and the
scaffolded `verify.sh` runs it automatically (`run-tests && judge-check.sh --rubric
rubric.md`); the judge only fires once the tests pass, so it costs ~one model call per
green attempt. It MUST be a separate run from the one that wrote the code — the author
judges its own work poorly. (Real case: a loop's tests passed but it billed the wrong
API key on one un-tested code path; only an independent review caught it.)

## Before you loop — the 60-second setup

Walk these five with the user (or infer and state your assumptions). Don't start
the loop until the gate and ceiling exist.

1. **Goal** — a *checkable* condition, not a vibe. "All tests in `api/` pass and
   `ruff` is clean," not "make the API better."
2. **Verify command** — the shell command whose exit code is the gate. Discover it:
   inspect `package.json` scripts, `Makefile`, `pyproject.toml`/`pytest`, `gradlew`,
   `go test`, `cargo test`, or the CI workflow. Prefer "can the agent actually run
   the thing" (tests, a smoke run, a headless browser) over lint-only — lint passing
   says nothing about whether the code works.
3. **Budget ceiling** — a max iteration count (and/or token budget). This is what
   makes a loop safe to leave unattended. No ceiling, no unattended loop.
4. **Isolation** — if the loop runs alongside other work, give it its own git
   worktree so parallel changes don't collide (`claude --worktree <name>`).
5. **Supervision** — attended (watch it) or background (notify on done/stuck).
   Decide up front; it changes which primitive you pick.

## Pick the primitive

| Situation | Use | Why |
|---|---|---|
| Simplest, in-session, one goal | **`/goal <condition>`** | Claude loops turn after turn until a small fast model confirms the condition. Works headless too. Start here. |
| Scriptable / headless / CI / a budget you control | **`scripts/verify-loop.sh`** (a `claude -p` while-loop with a verify gate) | You own the control flow, the ceiling, and the failure handling. |
| Deterministic "don't stop until green" | **Stop hook** (exit code 2 keeps the session going) | The same mechanism `/goal` wraps; use it when you need custom termination logic. |
| Recurring / watch-for-work / runs while you're away | **`/loop`** (interval) or a cloud routine | "Every 30m, draft fix PRs for new bug issues." Polls or schedules instead of running once. |
| A step with NO objective check (prose, design, "is this good enough?") | **`scripts/judge-loop.sh`** (LLM-judge gate) | A *separate* Claude scores the result against a rubric and returns pass/fail — independent verification when no shell command can decide. |

Read `references/primitives.md` for the exact flags, caveats, and doc links for each
of these. Confirm flags against current Claude Code docs — they change between
versions.

## Run the loop

**In-session (default):** state the goal as a condition and hand it to `/goal`:

```
/goal all tests in test/auth pass and the lint step is clean
```

**Headless / scriptable:** use the bundled script. It runs the verify command,
breaks the moment it exits zero, and otherwise feeds the failure back into a
resumed `claude -p` session until the ceiling:

```bash
scripts/verify-loop.sh \
  --goal "Fix the failing auth tests. Find and fix the root cause, don't skip tests." \
  --verify "npm test -- test/auth" \
  --max 10 \
  --tools "Read,Edit,Bash"
```

The cycle each iteration: **act** (Claude edits) → **verify** (run the gate) →
feed the result back → **check budget** → stop or continue. The verify command is
the brake and the steering wheel.

Safety flags worth knowing (`--help` lists all): `--stall N` bails after N no-progress
rounds (compared by *normalized signature*, not exact output, so it still catches a
loop that fails differently each round); `--reset-every N` drops the session for fresh
eyes when an approach entrenches; `--escalate-model M` makes a last-ditch stronger-model
attempt before a stall bail; `--worktree PATH` runs the loop on a throwaway branch;
`--log DIR` writes each iteration's verify output + diff as an audit trail;
`--allow-green-start` skips the red-first guard.

## Stay in the judgment seat

The loop produces *candidates*, not merged truth. Your job doesn't disappear, it
moves up a level: review the diff or the PRs, kill runaway loops, and never let a
loop auto-merge work you haven't looked at. Cherny: "if the code sucks, we're not
gonna merge it." Set the gate, set the ceiling, then judge the output.

## Compound — make the loop smarter over time

The highest-leverage habit: every time the loop makes the *same* mistake twice,
don't just fix it in-session — write the lesson into `CLAUDE.md` or turn it into a
skill. Each durable correction means the next loop starts smarter and can run
longer unattended. This is what lets a loop "just run forever" instead of needing a
babysitter. Treat recurring corrections as a signal to update memory, not to re-explain.

## Anti-patterns (how loops go wrong)

- **No verify gate** — looping on the model's self-assessment. It will lie to itself.
- **Lint-only verification** — green lint, broken code. Run the actual thing.
- **No budget ceiling** — an unattended loop with no max burns the whole budget on a
  stuck problem. Always cap iterations; consider bailing after N identical failures.
- **A flaky gate** — a nondeterministic check makes the loop thrash, and worse, tempts
  it to "fix" the *symptom* of a flake instead of a bug. Stabilize it *first*: measure
  the flake rate (run the gate N times), then separate an **infra flake** (parallel
  test-DB races, ports, shared state, test ordering) from a **real bug**. To pin the
  cause, add a state-guard — snapshot the global before/after each test to catch the
  mutator — or bisect; a flake that fails on a *different* test each run is usually one
  shared-state root cause, not many.
- **Verifying with the context that wrote the code** — a fresh check (a separate run,
  a Stop hook, a real command) catches what the author missed.

## Decompose a big objective into a loop chain

One loop fixes one thing. A big objective ("create user manuals", "migrate every
endpoint") needs several loops, some fanning out over many items. When that's the
case, build a **loop chain** instead of a single loop:

1. **Plan it** — restate the objective, then run an ultracode/Workflow pass to
   decide the ordered stages, each with a goal, a verification gate, declared
   inputs/outputs, and a `next`. Mark stages that fan out (one sub-loop per page /
   screen / endpoint), and mark non-trivial / correctness-critical stages to get a
   `rubric.md` (a compound script+judge gate — see "put a judge in the gate" above).
   The planner fixes the stage skeleton; fan-out counts are discovered at runtime.
2. **Show the plan and get approval** before building anything.
3. **Build it** — write `chain.json` and instantiate the backbone from the
   template library with `scripts/scaffold-loop.sh`.
4. **Run it** — `scripts/run-chain.sh <workspace>` drives the chain (one loop at a
   time via `scripts/loop-engine.sh`, whose gate can be **script** | **judge** |
   **human**): linear stages self-verify, fan-out stages run their sub-loops in
   parallel and join, and the terminal stage pauses for your sign-off. Resumable;
   start mid-chain with `--from <stage>`.

Each loop lives in its own folder with its own files and is reusable; loops share
data only through `state/`. **Read `references/chains.md` for the schemas, runtime,
planner procedure, and a worked user-manual example before building a chain.**

## Reference

- `references/chains.md` — loop-chain schemas, runtime, planner procedure, example.
- `references/loop-chains-design.md` — the approved design spec for loop chains.
- `references/primitives.md` — the documented Claude Code primitives, with flags and caveats.
- Knowledge base (the "why" behind all of this): `/home/cocodedk/0-projects/loop-engineering`
  · online at https://cocodedk.github.io/loop-engineering/ · repo
  https://github.com/cocodedk/loop-engineering. Start with `docs/04-loop-anatomy.md`,
  `docs/05-verification-and-memory.md`, and `docs/09-example-loops.md`.
