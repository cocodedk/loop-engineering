# Loop Engineering — Boris Cherny's Claude Code Methodology

"The loop" is Boris Cherny's name for how he runs Claude Code today: instead of prompting the model turn by turn, he writes small programs (loops) that prompt Claude on his behalf, read what it produced, decide whether the task is done, and re-prompt with updated context if not. The loop runs the model in a sense-decide-act-check cycle where each decision is the model's, not a hardcoded branch, on a schedule or until a goal condition is met. Cherny stated the core idea verbatim: "I don't prompt Claude anymore. I have loops that are running. They're the ones that are prompting Claude and figuring out what to do. My job is to write loops" ([source](https://www.youtube.com/watch?v=SlGRN8jh2RI)).

## Website

[Read online](https://cocodedk.github.io/loop-engineering/) — the GitHub Pages rendering of this knowledge base.

## TL;DR

- Cherny's evolution runs in three stages: hand-writing code with autocomplete, then running 5-10 Claude sessions in parallel that he prompts manually, then writing loops that prompt Claude autonomously ([source](https://www.youtube.com/watch?v=RkQQ7WEor7w)).
- A loop discovers work, hands tasks to agents and sub-agents, verifies results, persists state, and decides the next action ([source](https://cobusgreyling.substack.com/p/loop-engineering)).
- The single most important factor for quality is giving the agent a way to verify its own work; Cherny says a verification feedback loop "2-3x" the result ([source](https://howborisusesclaudecode.com/)).
- Every caught mistake becomes a durable correction in `CLAUDE.md` or a skill, so the fix persists across future runs ([source](https://howborisusesclaudecode.com/)).
- The methodology maps onto documented Claude Code primitives: `/loop`, `/goal`, the Agent SDK, sub-agents, skills, memory, hooks, worktrees, MCP, and channels ([source](https://code.claude.com/docs/en/goal)).
- "Loop engineering" as a named term was popularized by third parties (Peter Steinberger, Addy Osmani), not coined by Cherny himself ([source](https://addyo.substack.com/p/loop-engineering)).
- Most receipts (parallel-session counts, PR figures, IDE deletion) trace to Cherny's own posts and talks; a few productivity numbers are confirmed only in secondary coverage. See [docs/11-caveats.md](docs/11-caveats.md).

## What's in here

- [docs/01-who-is-boris-cherny.md](docs/01-who-is-boris-cherny.md) — Who Cherny is: Head of Claude Code at Anthropic, author of *Programming TypeScript*, his Meta/Instagram career, and the brief Cursor detour.
- [docs/02-what-is-the-loop.md](docs/02-what-is-the-loop.md) — The definition of "the loop" and how "loop engineering" became a named pattern; who coined what.
- [docs/03-three-stages.md](docs/03-three-stages.md) — The three waves of abstraction from autocomplete to parallel sessions to autonomous loops.
- [docs/04-loop-anatomy.md](docs/04-loop-anatomy.md) — The anatomy of a loop: trigger, scope, action, budget, stop, report, plus generator and evaluator roles.
- [docs/05-verification-and-memory.md](docs/05-verification-and-memory.md) — Verification as "can the agent run the thing" and turning mistakes into durable `CLAUDE.md`/skill corrections.
- [docs/06-orchestration-and-tooling.md](docs/06-orchestration-and-tooling.md) — Orchestration and the documented Claude Code primitives that implement the methodology.
- [docs/07-receipts-and-timeline.md](docs/07-receipts-and-timeline.md) — The receipts and timeline: dates, PR counts, and exact numbers, each tagged by verification verdict.
- [docs/08-how-to-apply.md](docs/08-how-to-apply.md) — How to apply the methodology yourself with real, documented Claude Code features.
- [docs/09-example-loops.md](docs/09-example-loops.md) — Example loops Cherny and team run: PR babysitting, Slack feedback, post-merge sweeps, PR pruning.
- [docs/10-sources.md](docs/10-sources.md) — Full source list: primary posts, talks, and secondary coverage.
- [docs/11-caveats.md](docs/11-caveats.md) — Caveats: what is confirmed-primary, what is only confirmed-secondary, and what is unverifiable.

## Run it — the `agent-loop` skill

Reading the method is one thing; running it is another. **`agent-loop`** is a
companion Claude Code skill that turns this knowledge base into something you can
run. It triggers on phrasings like *"loop until the tests pass"* or *"keep going
until the build is green"* — even when you never say the word "loop."

**One loop.** Give it a goal and a verification gate — a test, a build, a runnable
check. It runs an `act → verify → re-prompt` cycle until the gate passes or a
budget ceiling stops it. Verification is the engine: the loop only advances when
reality says it did.

```bash
verify-loop.sh --goal "fix the failing auth tests, root cause only" \
               --verify "pytest tests/auth -q" --max 10
```

**A chain of loops.** For a larger objective ("create user manuals"), it
decomposes the work into a chain — a linear backbone of stages where any stage can
fan out into one parallel sub-loop per item (per page, screen, or endpoint) and
join before continuing. Each loop is a self-contained, reusable folder that
verifies its own step and hands off to the next, so starting any loop runs forward
to the end; a human signs off at the terminal stage.

Gates are hybrid: an objective check where one exists, an LLM-judge against a
rubric where it doesn't, and a human at the end. The runnable patterns it automates
are in [docs/09-example-loops.md](docs/09-example-loops.md).

## Author

**Babak Bandpey** — [cocode.dk](https://cocode.dk) | [LinkedIn](https://linkedin.com/in/babakbandpey) | [GitHub](https://github.com/cocodedk)

---

Compiled from public talks and articles, mostly secondary coverage of Boris Cherny's podcast and conference appearances (Sequoia AI Ascent, Acquired Unplugged presented by WorkOS, Lenny's Podcast, The Pragmatic Engineer, and developing.dev), together with his own posts on X and Threads and Anthropic's Claude Code documentation. Where a claim is dramatic or numeric, the relevant document notes whether it is confirmed against a primary source, only against secondary coverage, or left unverifiable.

## License

Apache-2.0 | © 2026 [Cocode](https://cocode.dk) | Created by [Babak Bandpey](https://linkedin.com/in/babakbandpey)
