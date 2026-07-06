# Choosing the loop type

Four loop types, per the Claude Code team's taxonomy (Anthropic's "Getting
started with loops" guide). The selector is **which piece of the work you hand
off** — everything else (trigger, stop criteria, primitive) follows from that.

| You hand off | Loop type | Triggered by | Stops when |
|---|---|---|---|
| the check | Turn-based | your prompt, every turn | Claude judges it done; you verify and re-prompt |
| the stop condition | Goal-based | one prompt | the condition holds OR a turn cap is hit |
| the trigger | Time-based | an interval or schedule | you cancel it, or the watched work completes |
| the prompt itself | Proactive | event/schedule, no human in real time | each item exits when its goal holds; the routine runs until turned off |

Start at the top row; move down only when the current row can't hold the job.
Not all tasks need loop machinery — the simplest thing that reaches the goal wins.

## Turn-based — you hand off the check

Not a loop primitive at all: one agentic turn (gather context → act → verify →
respond), with you judging the result and writing the next prompt. **If the work
doesn't recur and one attempt — with the gate run once at the end — would
plausibly reach the goal, stay here.** "Add a like button and make sure it
works" is this: edit, run the test, screenshot, done. Building `/goal` or a
script loop around it buys nothing but tokens and review overhead.

What to invest in instead of machinery: verification. Claude Code bundles
`/verify` (v2.1.145+) — build and run the app to confirm the change does what it
should, not tests-only — and `/run-skill-generator` to teach it project-specific
launches. Where the check is yours alone (visual conventions, domain rules),
encode it as a project verification skill (start the dev server, click the
control, zero console errors, screenshot before/after) so the single turn
self-verifies end-to-end. Token lever: more specific prompts + better
self-verification = fewer turns.

## Goal-based — you hand off the stop condition

You know what done looks like; you don't want to re-prompt until it holds.

- **`/goal <condition>`** — and it takes an explicit turn cap in the condition:
  `/goal get the homepage Lighthouse score to 90 or above, stop after 5 tries.`
  Deterministic criteria (tests passed, a score threshold) beat "good enough" —
  they stop the evaluator ending the loop early or late.
- **`scripts/verify-loop.sh`** when you need to own the control flow: headless /
  CI, stall detection, session resets, model escalation, audit logs.
- **A raw Stop hook** when you need custom termination logic.

Token lever: tight completion criteria + explicit caps ("stop after 5 tries");
`/goal` with no arguments reports turns and token usage so far.

## Time-based — you hand off the trigger

The work recurs, or lives in an external system you can only observe by checking
("check my PR, address review comments, fix failing CI").

- **`/loop 5m <prompt>`** re-runs a prompt on an interval — but it is
  session-scoped: machine off, loop off.
- **`/schedule`** creates a cloud routine when the trigger must survive your
  laptop ("every morning at 7:00, summarize overnight #support messages").

Token lever: match the interval to how often the watched thing actually changes;
prefer reacting to events (channels, webhooks) over tight polling.

## Proactive — you hand off the prompt itself

A recurring stream of well-defined work — bug reports, issue triage, migrations,
dependency upgrades — handled end-to-end with no human in real time. This is a
composition, not one primitive:

- **`/schedule`** (or an event) is the trigger;
- **`/goal`** defines done for each run — "don't stop until every report found
  this run is triaged, actioned, and responded to";
- **skills** encode how to verify each item;
- **workflows / subagents** fan out per item (worktree isolation if they edit
  files in parallel);
- **auto mode / scoped permissions** let it run without pausing for approval.

The output is still candidates — PRs and replies you review, never auto-merges.
Token lever: route mechanical stages to smaller, faster models and keep the
capable model for judgment calls; pilot on a small slice before a large run;
inspect spend with `/usage` and `/workflows`.

## Cross-cutting

- A step with NO objective check (prose, design, "is this good?") needs a judge
  gate (`judge-loop.sh` / a rubric) — that's a gate choice, orthogonal to loop type.
- Every row below turn-based still needs SKILL.md's 60-second setup: a real gate,
  a budget ceiling, isolation, and a supervision decision.
