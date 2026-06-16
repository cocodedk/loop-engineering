# Orchestration and Tooling

This document covers the concrete mechanics Boris Cherny uses to run many Claude Code sessions at once: the agent view dashboard versus numbered terminal tabs, git worktrees for isolation, his rough session counts, the commands that move work between machine and cloud, phone-based control, and the routines that watch for work. For each item, the text notes whether it is a documented Claude Code feature or a behavior Cherny describes.

## Session counts: ~5 local plus 5-10 web

Cherny's own Jan 2026 X/Threads thread states the numbers verbatim: "I run 5 Claudes in parallel in my terminal. I number my tabs 1-5, and use system notifications to know when a Claude needs input," and "I also run 5-10 Claudes on claude.ai/code, in parallel with my local Claudes." This is a **described behavior** sourced directly from him (verdict: confirmed-primary), giving him roughly 10-15 concurrent sessions. The 5-10 parallel-session stage is what he later framed as the middle stage before he moved to loops ([Threads](https://www.threads.com/@boris_cherny/post/DTBVmoKkkpR), [X thread](https://x.com/bcherny/status/2007179836704600237)).

## Numbered terminal tabs and system notifications

To make the local fleet tractable, Cherny gives each terminal tab a number (1 through 5) for quick reference and configures OS-level notifications (for example iTerm2) so the system tells him which Claude is waiting on input instead of him polling each tab. This is a **described behavior / personal convention**, not a product feature, taken from his own thread ([howborisusesclaudecode.com](https://howborisusesclaudecode.com/), [OfficeChai](https://officechai.com/ai/claude-code-creator-boris-cherny-claude-code-tips/)).

## Agent view dashboard versus terminal tabs

Cherny describes moving off the numbered-tabs approach toward a single dashboard. He calls the desktop Agent View "the best way to level up from 1 agent => many agents. No more cycling between terminal tabs" ([howborisusesclaudecode.com](https://howborisusesclaudecode.com/)). The Neuron paraphrases the same shift from "six terminal tabs and six checkouts of the same repo" to one surface showing what is running, what needs input, what is ready for review, and what finished ([The Neuron](https://www.theneuron.ai/explainer-articles/claude-code-creators-boris-cherny-and-cat-wu-explain-how-to-use-agent-loops/)).

Agent view is a **documented feature**. The docs describe `claude agents` / agent view as "one screen for all your background sessions," grouping them under "Needs input," "Working," and "Completed," where each background session is a full Claude Code conversation that keeps running without a terminal attached. The docs also state agent view "automatically moves each dispatched session into its own worktree" ([agent-view docs](https://code.claude.com/docs/en/agent-view)).

## Git worktrees for isolation

Cherny's team uses git worktrees rather than separate full checkouts so each parallel agent gets an isolated working directory on its own branch and agents can edit the same repo without colliding. Per the compiled tips, the team "prefers worktrees for isolation" and Cherny "runs 3-5 worktrees simultaneously, each in its own Claude session" ([howborisusesclaudecode.com](https://howborisusesclaudecode.com/)). This usage is a **described behavior**.

Worktree support itself is a **documented feature**. The docs describe `claude --worktree <name>` (or `-w`), which creates an isolated checkout under `.claude/worktrees/<value>/` on branch `worktree-<value>`. In-session, Claude uses the `EnterWorktree` tool; subagents can be pinned to a worktree with `isolation: worktree` frontmatter; and `WorktreeCreate` / `WorktreeRemove` are documented hook events. The desktop app / agent view auto-creates a worktree per background session ([worktrees docs](https://code.claude.com/docs/en/worktrees)).

## Moving context with --teleport

To pull a cloud/web session down to local, Cherny uses `claude --teleport` or the in-session `/teleport` command. His own Threads post states it: "Run `claude --teleport` or `/teleport` to continue a cloud session on your machine," and he says he teleports "back and forth" between local and web ([Threads post](https://www.threads.com/@boris_cherny/post/DWfjo22FKJ4/)). This is a **documented command**, used as a **described behavior** in his workflow.

## The & operator: handing local sessions to the web

While working in the terminal, Cherny hands a local session off to the web using the `&` operator. His Jan 2026 thread states it verbatim: "As I code in my terminal, I will often hand off local sessions to web (using &), or manually kick off sessions in Chrome, and sometimes I will --teleport back and forth" (verdict: confirmed-primary, [X thread](https://x.com/bcherny/status/2007179836704600237)). This is a **described behavior** backing onto a CLI mechanism; the exact `&` syntax is reported in his own thread, though some secondary write-ups repeat it secondhand.

## Remote control and the phone workflow

Cherny controls locally-running sessions from his phone or the web with `/remote-control`, and keeps "Enable Remote Control for all sessions" turned on in his `/config`. His Threads post: "run `/remote-control` to control a locally running session from your phone/web. Personally, I have 'Enable Remote Control for all sessions' set in my /config," linking the remote-control docs ([Threads post](https://www.threads.com/@boris_cherny/post/DWfjo22FKJ4/)). The Neuron reports he says about half his engineering now happens on his phone through Remote Control. Remote control is a **documented feature**; the "half my engineering on my phone" figure is a **described behavior** reported secondarily.

He also kicks off sessions from his phone (Claude iOS app) in the morning and picks them up on his computer later: "Every morning I wake up and start a few agents to begin my code for the day... When I get to a computer, I'll check in on the status. Sometimes I'll merge it if the code looks good" ([developing.dev](https://www.developing.dev/p/boris-cherny-creator-of-claude-code)). This is a **described behavior** (confirmed-primary via the developing.dev interview).

## Voice / dictation mode

Cherny recommends voice dictation as a tip: "You speak 3x faster than you type, and your prompts get way more detailed as a result" ([whyaiman](https://whyaiman.substack.com/p/tips-for-working-with-claude-code)). This pairs with the phone/remote workflow (dictating prompts on the go). It is a **described behavior / recommendation**; note that his short Threads post on session mobility does not itself mention voice, so the voice tip comes from the broader tips collection (secondary).

## Routines that watch for work

The endpoint of Cherny's orchestration is routines that monitor channels and decide what to build, rather than him assigning each task. Secondary coverage of his Acquired Unplugged talk (June 2, 2026) and the WorkOS recap describe "hundreds of Claude instances monitoring Twitter feedback, GitHub issues, and Slack to generate product ideas," with "a couple hundred agents that read his GitHub, Slack, and Twitter and decide what to build next" ([WorkOS](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways), [Medium](https://medium.com/mountain-movers/what-a-loop-actually-is-boris-chernys-three-stage-definition-33dd2bfe01b3)). The three-stage progression behind this is confirmed-primary (Cherny's own on-stage account), though the exact "hundreds of agents" framing comes through secondary recaps.

Cat Wu gives two concrete watch-for-work routines: one that listens for every ticket, GitHub issue, and voice-mode bug report and proactively puts up fixes; and a second that finds bug reports left unanswered for about five hours and puts up fixes that are easy to verify and merge. She presents these as an early, obvious use of the Agent SDK ([The Neuron](https://www.theneuron.ai/explainer-articles/claude-code-creators-boris-cherny-and-cat-wu-explain-how-to-use-agent-loops/)). These are **described behaviors**.

## The primitives behind the routines (documented features)

The recurring work is wired up with documented commands, not a feature literally named "loop engineering" (that term is third-party framing).

- `/loop` is a **documented bundled skill**: it re-runs a prompt or slash command on a recurring interval, and when the interval is omitted Claude self-paces the cadence (1 min to 1 hr). Loops are session-scoped and expire after 7 days. Cherny's own running loops include `/loop 5m /babysit`, `/loop 30m /slack-feedback`, `/loop /post-merge-sweeper`, and `/loop 1h /pr-pruner` ([scheduled-tasks docs](https://code.claude.com/docs/en/scheduled-tasks), [howborisusesclaudecode.com](https://howborisusesclaudecode.com/)).
- `/schedule` and Cloud Routines are **documented features** for unattended work that runs even when the laptop is closed (Anthropic-managed, cron-backed, min interval 1 hour) ([scheduled-tasks docs](https://code.claude.com/docs/en/scheduled-tasks)).
- `/goal` is the **documented** condition-driven loop: it "sets a completion condition and Claude keeps working toward it without you prompting each step," with a small fast model checking the condition after each turn ([goal docs](https://code.claude.com/docs/en/goal)).
- Channels are a **documented** (research-preview) push-based alternative to interval polling: "A channel is an MCP server that pushes events into your running Claude Code session," matching Cat Wu's listen-for-events routines ([channels docs](https://code.claude.com/docs/en/channels)).

For long-running loops, Cherny says he adds explicit verification so the agent does not declare victory early: "For very long-running tasks, I will either (a) prompt Claude to verify its work with a background agent when it's done, (b) use an agent Stop hook to do that more deterministically, or (c) use the ralph-wiggum plugin" ([X thread tweet 12/](https://x.com/bcherny/status/2007179858435281082)). Stop hooks are a **documented feature**; this verification practice is his **described behavior**.

## Note on the "loop engineering" term

"Loop engineering" is not an Anthropic product feature. The implementable primitives are `/loop`, `/goal`, the Agent SDK, and Stop hooks. The named pattern was popularized by third parties (Peter Steinberger, Addy Osmani), while Cherny's own canonical statement is "my job is to write loops" (confirmed-primary, from his Sequoia AI Ascent 2026 and Acquired Unplugged appearances) ([The New Stack](https://thenewstack.io/loop-engineering/), [Addy Osmani](https://addyosmani.com/blog/loop-engineering/)).
