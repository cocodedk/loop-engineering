# Loop chains — decomposing an objective into chained loops

When one loop can't reach the goal in a single act→verify cycle, decompose the
objective into a **chain**: a fixed backbone of stages (planned up front), where
any stage can **fan out** into N parallel sub-loops discovered at runtime. Each
loop is a self-contained, reusable folder that verifies its own objective and, on
success, hands off to the next — so starting any loop runs forward to the end.

## Two layers

1. **Template library** (`../templates/`) — reusable, project-agnostic loop
   templates: `discover-items`, `per-item`, `transform`, `assemble`,
   `final-review`. Each is a folder with `loop.json` + `prompt.md` (+ `verify.sh`
   or `rubric.md`). Add your own.
2. **Run instance** — a workspace in the target project, by default
   `.agent-loops/<objective-slug>/`, holding `chain.json`, one folder per
   backbone stage, a shared `state/` dir, and (after fan-out) per-item sub-loops.

## Workspace layout

```
.agent-loops/user-manuals/
├── chain.json                 # the backbone + fan-out config
├── 01-inventory/              # a loop: loop.json, prompt.md, verify.sh, run.sh
├── 02-order/
├── 03-pages/                  # fan-out stage → children created at runtime
│   ├── getting-started/       # one sub-loop per item
│   └── billing/
├── 04-assemble/
├── 05-review/
└── state/                     # shared artifacts (the data contract)
    ├── pages.json
    ├── 03-pages/<slug>.md
    ├── manual.md
    └── .done/<stage>          # completion markers (resume)
```

## chain.json

```json
{
  "objective": "Create user manuals for the app",
  "slug": "user-manuals",
  "stages": [
    {"id": "01-inventory", "next": "02-order", "fanout": null},
    {"id": "02-order",     "next": "03-pages", "fanout": null},
    {"id": "03-pages",     "next": "04-assemble",
      "fanout": {"items_from": "state/pages.json", "items_key": "pages",
                 "template": "per-item", "max_parallel": 4}},
    {"id": "04-assemble",  "next": "05-review", "fanout": null},
    {"id": "05-review",    "next": null,        "fanout": null}
  ]
}
```

A fan-out stage needs no `loop.json` of its own — the runner reads `items_from`,
instantiates one sub-loop per item from `template`, runs them in bounded parallel,
and only advances when **all** pass (the join).

## loop.json (one loop)

```json
{
  "goal_file": "prompt.md",
  "gate": {"type": "script", "verify": "bash \"$LOOP_DIR/verify.sh\""},
  "inputs":  ["state/pages.json"],
  "outputs": ["state/toc.json"],
  "engine":  {"max": 6, "tools": "Read,Write,Edit,Bash"},
  "next": "03-pages"
}
```

- **Gate types** (hybrid): `script` — objective check, preferred (a `verify.sh`
  whose exit 0 is the gate); `judge` — an LLM reviews the work against `rubric.md`
  (use only where no objective check exists); `human` — pauses for sign-off
  (always the terminal gate). The act→verify engine is `verify-loop.sh`, so every
  loop keeps its budget ceiling and stall detection.
- **inputs/outputs** are the data contract. The engine refuses to start a loop
  whose declared inputs are missing, and warns if a passed loop didn't produce its
  outputs. This is what makes loops independently runnable and resumable.

## Runtime

- `scripts/loop-engine.sh <loop-dir> [--driven] [--approve]` — run ONE loop:
  check inputs, run the gate, mark done, and (unless `--driven`) `exec` the next
  loop's `run.sh`. That self-chaining is your "start loop-b → ends at loop-z".
- `scripts/run-chain.sh <workspace> [--from <id>] [--approve] [--force]` — drive
  the whole backbone with fan-out orchestration, joins, and resume (done stages
  skipped). Fan-out stages must run through this driver. `--from` starts mid-chain.
- `scripts/scaffold-loop.sh` — instantiate a template into a loop folder.

## The planner (the ultracode part)

When the skill fires on a multi-stage objective, decompose before building:

1. Restate the objective and what "done well" means.
2. Run an **ultracode/Workflow planning pass** to produce the stage skeleton:
   ordered stages, each with a template, goal, gate type, inputs, outputs, `next`,
   and a `fanout` block where the stage is per-item. The Workflow analyzes how many
   stages are needed and which ones fan out — this is "use ultracode to figure out
   the steps."
3. Choose each gate: prefer an objective `verify.sh`; fall back to a `judge`
   rubric; make the terminal stage `human`.
4. Write `chain.json` and instantiate the backbone with `scaffold-loop.sh`
   (filling `OBJECTIVE`, `OUTPUT`, `INPUT`, `ITEMS_KEY`, `NEXT`).
5. **Show the plan to the human and get approval** before running.
6. Run with `run-chain.sh`; the human signs off at the terminal stage.

## Worked example — user manuals

`01-inventory` (discover-items) lists every page → `state/pages.json`.
`02-order` (transform) orders them → `state/toc.json`.
`03-pages` (fan-out, per-item) writes one section per page in parallel →
`state/03-pages/<slug>.md`. `04-assemble` stitches them into `state/manual.md`.
`05-review` (human) signs off. Start at `02-order` later and it still runs through
to `05-review`, reusing `state/pages.json`.

## Limitations (v1)

- Fan-out stages require `run-chain.sh` (a single sub-loop can't self-orchestrate
  the join); linear loops self-chain standalone.
- `chain.json`/`loop.json` use JSON (parsed with `jq`, zero extra deps), not YAML.
- The planner step is driven by the skill/Claude, not a standalone binary.
