# Loop chains — design spec

Status: approved 2026-06-16. Extends the `agent-loop` skill so a high-level
objective is decomposed into a chain of smaller, self-contained, reusable loops.

## Problem

The base skill runs one verification-gated loop. Real objectives ("create user
manuals", "migrate this API") need several steps, some of which fan out over many
items. We want: decompose the objective into ordered loops, run them with
verification at every step, fan out where there are N items, keep loops as reusable
artifacts in their own folders, and let any loop hand off to the next.

## Decisions (locked)

1. **Shape: pipeline + fan-out.** A linear backbone of stages; any stage may fan
   out into N parallel sub-loops that must all pass before the chain continues.
2. **Gates: hybrid.** Per loop, prefer an objective `script` gate; fall back to an
   LLM `judge` against a rubric; the terminal loop always requires `human` sign-off.
3. **Planning: fixed skeleton, runtime fan-out.** The planner fixes which stages
   exist up front (via an ultracode/Workflow pass). Only fan-out counts (how many
   items) are discovered at runtime.
4. **Reuse: templates + instances.** A library of parameterized loop templates;
   each run instantiates them into a per-run workspace kept as a re-runnable record.

## Architecture

- **Template library** (`templates/`): `discover-items`, `per-item`, `transform`,
  `assemble`, `final-review`. Each = `loop.json` + `prompt.md` (+ `verify.sh` /
  `rubric.md`).
- **Run workspace** (`.agent-loops/<slug>/`): `chain.json` (backbone + fan-out
  config), one folder per stage, shared `state/` (the data contract), `state/.done/`
  markers for resume.
- **Engine** (`scripts/`): `verify-loop.sh` (unchanged single-loop engine) ·
  `loop-engine.sh` (one loop: input-check → gate → mark done → self-chain) ·
  `run-chain.sh` (driver: walk backbone, fan-out scaffold+parallel+join, resume,
  `--from`) · `scaffold-loop.sh` (instantiate a template) · `judge-loop.sh`
  (LLM-judge gate, experimental).

## Data flow

Each loop declares `inputs`/`outputs` (paths under the workspace). The engine
refuses to start a loop with missing inputs and warns on missing outputs. Stages
communicate only through `state/`, which keeps loops decoupled, independently
runnable, and resumable. A loop is "done" when its gate passes; a `state/.done/`
marker records it so re-runs skip it.

## Chaining semantics

`loop-engine.sh` self-chains: on success it `exec`s the next loop's `run.sh`. So
running `02-order/run.sh` directly walks forward to the terminal loop ("start
loop-b → ends at loop-z"). `run-chain.sh` is the driver used for whole-chain runs
and for fan-out (a single sub-loop can't orchestrate its own join). Both share the
same `state/.done/` markers, so they interoperate and resume.

## Verification

Verified with a claude-free integration test (`/tmp/le-chain-test.sh` pattern):
linear ordering, fan-out + bounded-parallel + join, human-gate pause → approve,
`--from` entry-from-anywhere, resume-skips-done, and the missing-input guard —
13/13 assertions pass. The test pre-seeds gate outputs so only the orchestration
(not `claude`) is exercised.

## Limitations / future

- Fan-out requires `run-chain.sh`; only linear loops self-chain standalone.
- The planner is a skill-driven procedure (Claude + optional Workflow), not a
  standalone binary. A `plan-chain` helper that emits `chain.json` could come later.
- JSON (jq) over YAML to avoid a `yq` dependency.
- Possible later work: per-stage cost ceilings, a `judge` rubric library, a
  `chain-status` summary command, and richer fan-out keys (objects, not just strings).
