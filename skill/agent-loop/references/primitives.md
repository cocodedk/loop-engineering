# Loop primitives — documented Claude Code features

The building blocks an agent loop is made of. Each maps to a real, documented
Claude Code capability. Flags and defaults change between versions — confirm
against the current docs (https://code.claude.com/docs) before you rely on one.

## The harness: `claude -p` (headless / print mode)

Run Claude non-interactively so a script (the loop) drives it instead of a human.

- `claude -p "<prompt>"` / `--print` — one non-interactive turn.
- `--output-format json` — machine-parseable result. The answer is in `.result`;
  you also get `.session_id` and `.total_cost_usd`. Use `stream-json` to stream events.
- `--resume <session_id>` / `--continue` — carry context across loop iterations so
  iteration 4 remembers what 1–3 tried. Capture `session_id` from the first JSON output.
- `--allowedTools "Read,Edit,Bash"` — restrict what the headless run may do. Scope it
  tightly for unattended loops.

This is the foundation of `scripts/verify-loop.sh`. Docs: `/docs/en/headless`.

## The built-in loop: `/goal`

The simplest way to "keep working until a condition holds." In-session (and headless):

```
/goal all tests in test/auth pass and the lint step is clean
```

Claude works turn after turn; after each turn a small fast model checks whether the
stated condition is met, and the loop continues until it is. Under the hood it is a
prompt-based Stop hook. Start here unless you need custom control flow. Docs: `/docs/en/goal`.

## Deterministic termination: Stop hooks

A Stop hook runs when Claude is about to end its turn. **Exit code 2 prevents
stopping and continues the conversation** — which is exactly a "don't stop until
green" loop. Wire a hook that runs your verify command and exits 2 while it fails,
0 when it passes. This is what `/goal` wraps; use it directly when you need custom
termination logic. Docs: `/docs/en/hooks`.

```sh
# Stop-hook sketch (configure in settings.json): block stop until tests pass.
if npm test >/tmp/verify.log 2>&1; then exit 0; else
  echo "Tests still red; keep fixing. See /tmp/verify.log" >&2; exit 2
fi
```

## Recurring / watch-for-work: `/loop` and routines

When the loop should run on a cadence or react to incoming work rather than run once:

- **`/loop`** — re-run a prompt on a recurring interval (or self-paced when the
  interval is omitted). Session-scoped. Good for "every 30m, draft fix PRs for new
  bug-labeled issues." Docs: `/docs/en/scheduled-tasks`.
- **Cloud routines / scheduled agents** — for truly unattended runs (machine off),
  schedule a routine instead of a session-scoped `/loop`.

These are the path from one self-verifying loop to "a couple hundred agents watching
GitHub/Slack/Twitter."

## Isolation: git worktrees

When loops run in parallel they must not edit the same files. Give each its own
worktree:

- `claude --worktree <name>` / `-w` — run the session in an isolated worktree.
- Subagents can declare `isolation: worktree` in frontmatter.
- The agent-view / fleet UI auto-moves each dispatched session into its own worktree.

Docs: `/docs/en/worktrees`.

## Supporting layers

- **Subagents** (`/docs/en/sub-agents`) — isolated context windows with their own
  tools and permissions. Use a subagent as the *verifier* so the checker isn't the
  same context that wrote the code.
- **Skills** (`/docs/en/skills`) and **CLAUDE.md memory** (`/docs/en/memory`) — where
  recurring corrections go so the loop compounds and runs longer unattended.
- **MCP** (`/docs/en/mcp`) and **channels** (`/docs/en/channels`) — the loop's
  external read/write layer (issue trackers, Slack) and the event-driven alternative
  to polling on a timer.

## Mapping the methodology to the primitive

| Methodology piece | Primitive |
|---|---|
| "Write the loop that prompts the agent" | `claude -p` while-loop / `verify-loop.sh` |
| "Iterate until a condition holds" | `/goal`, or a Stop hook |
| "Verification is the engine" | the verify command that gates the loop |
| "Run while you're away" | `/loop` / cloud routine |
| "Don't let parallel work collide" | git worktrees |
| "Make the loop smarter over time" | CLAUDE.md + skills |

The full reasoning lives in the knowledge base:
https://github.com/cocodedk/loop-engineering (see `docs/06-orchestration-and-tooling.md`
and `docs/09-example-loops.md`).
