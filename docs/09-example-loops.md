# Example Loop Patterns

This document shows three concrete loop patterns that map only to documented Claude Code features. Treat the code blocks as illustrative sketches, not copy-paste production scripts. Every CLI flag used below is drawn from the research corpus; confirm each one against the current Claude Code docs before relying on it, because flags and defaults change between versions.

## What "writing a loop" means here

Boris Cherny's framing is that he no longer prompts Claude turn by turn. His words: "I don't prompt Claude anymore. I have loops that are running. They're the ones that are prompting Claude and figuring out what to do. My job is to write loops." This is [confirmed against primary sources](https://www.youtube.com/watch?v=SlGRN8jh2RI). A loop is a small program that prompts the agent, reads what it produced, decides whether the task is done, and re-prompts with updated context if not.

The verification gate is the load-bearing part. Cherny calls giving Claude a way to verify its own work "probably the most important thing to get great results," and says a real feedback loop will "2-3x the quality of the final result" ([source](https://howborisusesclaudecode.com/)). Real verification means the agent can actually run the thing (a bash command, a test suite, the app itself), not just lint and type checks ([source](https://www.infoq.com/news/2026/01/claude-code-creator-workflow/)).

### Documented building blocks used below

- `claude -p` / `--print`: headless, non-interactive mode ([docs](https://code.claude.com/docs/en/headless)).
- `--output-format json` / `stream-json`: machine-parseable output, with the answer in a `.result` field plus `session_id` and `total_cost_usd` ([docs](https://code.claude.com/docs/en/headless)).
- `--resume` / `--continue`: capture `session_id` from JSON output, then continue across iterations ([docs](https://code.claude.com/docs/en/headless)).
- `--allowedTools`: restrict which tools the headless run may use ([docs](https://code.claude.com/docs/en/headless)).
- `/goal`: a built-in in-session loop that keeps working until a stated condition holds, checked by a small fast model after each turn ([docs](https://code.claude.com/docs/en/goal)).
- `/loop`: a bundled skill that re-runs a prompt on a recurring interval, or self-paces when the interval is omitted ([docs](https://code.claude.com/docs/en/scheduled-tasks)).
- Stop hooks: exit code 2 prevents stopping and continues the conversation, which is the basis of a custom termination loop ([docs](https://code.claude.com/docs/en/hooks)).
- Git worktrees, subagents, skills, CLAUDE.md memory, and MCP are the supporting layers ([worktrees](https://code.claude.com/docs/en/worktrees), [subagents](https://code.claude.com/docs/en/sub-agents), [skills](https://code.claude.com/docs/en/skills), [memory](https://code.claude.com/docs/en/memory), [mcp](https://code.claude.com/docs/en/mcp)).

Note: there is no Claude Code feature literally named "loop engineering." That term is a third-party label popularized by commentators, not an Anthropic product feature ([confirmed-secondary](https://addyo.substack.com/p/loop-engineering)). The implementable primitives are `/goal`, `/loop`, and the [Claude Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview).

## Pattern A: bash while-loop with a test-passing gate

A hand-written outer loop that calls `claude -p`, runs the test suite as the verification gate, and breaks when tests pass. This is illustrative pseudocode. The interesting flags are real, but the control flow is yours to own.

```bash
#!/usr/bin/env bash
# ILLUSTRATIVE — verify all flags against current Claude Code docs first.
set -euo pipefail

MAX_ITERS=10          # budget ceiling: hard stop to prevent runaway loops
iter=0
session=""

while [ "$iter" -lt "$MAX_ITERS" ]; do
  iter=$((iter + 1))

  # Verification gate: run the real test suite. Break when it passes.
  if npm test; then
    echo "Tests pass on iteration $iter. Done."
    break
  fi

  # Capture failing output and feed it back into context.
  test_output="$(npm test 2>&1 || true)"

  if [ -z "$session" ]; then
    # First turn: start a session, capture its id from JSON output.
    session="$(claude -p "Tests are failing. Fix the cause. Output:
$test_output" \
      --allowedTools "Read,Edit,Bash" \
      --output-format json | jq -r '.session_id')"
  else
    # Subsequent turns: resume so prior analysis carries over.
    claude -p "Tests still failing. Fix the cause. Output:
$test_output" \
      --allowedTools "Read,Edit,Bash" \
      --resume "$session" >/dev/null
  fi
done

[ "$iter" -ge "$MAX_ITERS" ] && echo "Hit iteration ceiling without green tests."
```

Key points: `npm test` is the verification gate, the loop breaks the moment it exits zero, `--output-format json` plus `jq` reads the `session_id`, and `--resume` preserves context across iterations ([headless docs](https://code.claude.com/docs/en/headless)). The `MAX_ITERS` ceiling is what makes the loop safe to leave unattended. Consider also stopping on N consecutive identical failures, since a stuck loop will otherwise burn the whole budget.

A nearly equivalent result is available as a single built-in call, where Claude runs the loop itself until the condition holds:

```bash
# /goal runs the loop in-session, even in headless mode.
claude -p "/goal all tests in test/auth pass and the lint step is clean"
```

`/goal` checks the completion condition with a small fast model after each turn and keeps going until it is met ([docs](https://code.claude.com/docs/en/goal)).

## Pattern B: watch GitHub issues, draft a fix PR

A routine sketch for the watch-for-work pattern Cat Wu described: a routine that listens for tickets, GitHub issues, and bug reports, then proactively puts up a fix and pings the PR ([source](https://www.theneuron.ai/explainer-articles/claude-code-creators-boris-cherny-and-cat-wu-explain-how-to-use-agent-loops/)). Cherny runs comparable recurring `/loop` commands such as a PR babysitter ([source](https://howborisusesclaudecode.com/)).

This is a sketch, not a runnable script. The polling cadence and GitHub access are real concepts, but wire them to your own auth and repo.

```bash
# ILLUSTRATIVE sketch — recurring "draft a fix PR" routine.
# In-session, the bundled /loop skill re-runs a prompt on an interval:
#   /loop 30m draft fix PRs for new GitHub issues labeled "bug"

# Headless equivalent of one tick (run this on your own scheduler, e.g. cron):
claude -p "/goal every open issue labeled 'bug' with no linked PR has a draft \
fix PR opened against a new branch, with the issue number referenced" \
  --allowedTools "Read,Edit,Bash"
```

Supporting layers for this pattern:

- Each fix should run in an isolated git worktree so parallel drafts do not collide (`claude --worktree <name>`, [docs](https://code.claude.com/docs/en/worktrees)).
- Use MCP or `gh` for reading issues and opening PRs; MCP lets the loop act on the issue tracker directly rather than on pasted text ([docs](https://code.claude.com/docs/en/mcp)).
- For truly unattended runs (machine off), use a cloud routine via `/schedule` rather than a session-scoped `/loop` ([docs](https://code.claude.com/docs/en/scheduled-tasks)).
- To react to issue events as they happen instead of polling on a timer, the docs point to Channels, an MCP server that pushes events into a running session ([docs](https://code.claude.com/docs/en/channels)).

Caution: opening PRs automatically writes to your repo. Keep a budget ceiling, scope the routine narrowly (one repo, one label), and gate merges on human review. Cherny himself notes "if the code sucks, we're not gonna merge it" ([source](https://www.developing.dev/p/boris-cherny-creator-of-claude-code)).

## Pattern C: self-verifying test-fix loop via a Stop hook

The most deterministic way to keep a session running until verification passes is a Stop hook. Per the docs, a Stop hook that exits 2 "prevents stopping, continues conversation" ([docs](https://code.claude.com/docs/en/hooks)). This is what `/goal` wraps under the hood ([source](https://code.claude.com/docs/en/goal)). Cherny lists exactly this: for long-running tasks, use an agent Stop hook to verify work more deterministically before exit ([source](https://x.com/bcherny/status/2007179858435281082)).

Sketch of a Stop-hook verifier (configured in `settings.json`, illustrative):

```bash
#!/usr/bin/env bash
# ILLUSTRATIVE Stop-hook script: block stop until tests pass.
# Wire this as a Stop hook in settings.json; confirm hook config in current docs.
if npm test >/tmp/verify.log 2>&1; then
  exit 0          # tests pass -> allow the session to stop
else
  echo "Tests still failing; keep fixing. See /tmp/verify.log" >&2
  exit 2          # exit 2 prevents stopping; Claude continues the loop
fi
```

This makes the agent self-verifying: it cannot declare victory while the test command is red. The same logic expressed as the built-in command is `/goal all tests pass`, which is the recommended path unless you need custom termination behavior.

To make corrections persist across runs rather than dying with the session, write each repeated mistake into CLAUDE.md or a skill. Cherny calls this "the single most important idea for long-running work": "Every single time Claude makes a mistake, I don't tell it to do it differently. I tell it to write it to the CLAUDE.md, or make a skill... then Claude can just run forever." ([source](https://howborisusesclaudecode.com/), [memory docs](https://code.claude.com/docs/en/memory)).

## A note on the dramatic numbers

The productivity figures behind this methodology vary in how well they verify. Cherny's self-reported output (259 PRs in the 30 days before Dec 27, 2025, every line written by Claude Code) is [confirmed-primary from his own posts](https://www.threads.com/@boris_cherny/post/DSxC69PCCz_/fast-forward-to-today-in-the-last-thirty-days-i-landed-p-rs-commits-k-lines). The "roughly 4% of all public GitHub commits" figure is [confirmed-secondary](https://newsletter.semianalysis.com/p/claude-code-is-the-inflection-point): it originates from SemiAnalysis with no published methodology and is a point-in-time estimate, not an audited Anthropic statistic. Treat the loop patterns above as the durable, implementable part; treat the headline percentages as context, weighted by their verification verdict.
