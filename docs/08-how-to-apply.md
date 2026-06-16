# How to Apply This Yourself

A practical playbook for adopting Boris Cherny's loop methodology. The steps below move from a single supervised agent toward the autonomous setup Cherny describes: "I don't prompt Claude anymore. I have loops that are running. They're the ones that are prompting Claude and figuring out what to do. My job is to write loops." ([confirmed-primary; Sequoia AI Ascent 2026](https://www.youtube.com/watch?v=SlGRN8jh2RI)). Each step maps to a documented Claude Code primitive, not to a product feature literally named "loop engineering" — that term is a third-party label coined by commentators like Addy Osmani and Peter Steinberger, not by Cherny ([confirmed-secondary](https://addyo.substack.com/p/loop-engineering)).

Start small. Do not attempt the full autonomous fleet on day one. Get each layer working before adding the next.

## 1. Build routines that watch for work

Stop assigning every task by hand. Set up loops that discover work and surface it for review.

- Use `/loop` to re-run a prompt or slash command on a recurring interval while a session stays open. Give an interval (`/loop 5m /babysit`) or omit it to let the model self-pace (1 minute to 1 hour per iteration). Loops are session-scoped, expire after 7 days, and stop with Esc ([Claude Code docs](https://code.claude.com/docs/en/scheduled-tasks)).
- Use `/schedule` to create cloud routines that run on a cron schedule even when your laptop is closed ([docs](https://code.claude.com/docs/en/scheduled-tasks)).
- For event-driven work instead of polling, connect Channels, an MCP server that pushes events (CI results, chat messages, webhooks) into a running session ([docs](https://code.claude.com/docs/en/channels)).

Cherny's own running loops, in his words: `/loop 5m /babysit, /loop 30m /slack-feedback, /loop /post-merge-sweeper, /loop 1h /pr-pruner` ([primary, @bcherny X thread](https://howborisusesclaudecode.com/)). His canonical babysit loop in longhand: "babysit all my PRs. Auto-fix build issues, and when comments come in, use a worktree agent to fix them" ([source](https://explainx.ai/blog/loop-engineering-coding-agents-claude-code-guide-2026)). Cat Wu describes a concrete watch-for-work routine an engineer built: one that listens for every ticket, GitHub issue, and bug report and proactively puts up a fix ([primary, via The Neuron](https://www.theneuron.ai/explainer-articles/claude-code-creators-boris-cherny-and-cat-wu-explain-how-to-use-agent-loops/)).

## 2. Build verification into every loop

Verification is the single highest-leverage thing you can add. Cherny: "give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result" ([primary](https://howborisusesclaudecode.com/)).

- Real verification means the agent can actually run and exercise what it changed, not just lint, type-check, or unit tests. Give it Bash, a simulator, a desktop app, or computer use. For browser UI work, the Claude Chrome extension opens a browser, tests changes, and iterates until they work ([primary](https://howborisusesclaudecode.com/)).
- For long-running loops, add an explicit verification gate so the agent does not declare victory early. Cherny's options: prompt Claude to verify with a background agent when done, use an agent Stop hook to do it deterministically, or use the ralph-wiggum plugin ([primary, @bcherny tweet 12/](https://x.com/bcherny/status/2007179858435281082)).
- Use `/goal` to keep working until a condition is actually true: "all tests in test/auth pass and the lint step is clean." After each turn a small fast model checks whether the condition holds before returning control ([docs](https://code.claude.com/docs/en/goal)).

The structure to aim for is a generator (the agent doing the work) plus a separate evaluator (a program or second agent grading output against checkable criteria), because the agent that wrote the code is a poor judge of its own work ([secondary](https://www.mindstudio.ai/blog/what-is-loop-engineering-ai-coding-agents)).

## 3. Practice context minimalism

Give goals and constraints, not step-by-step instructions. Cat Wu: treat Claude "like an engineer you're delegating to, not a pair programmer you're guiding line by line," and "tell the model only what it needs to know and let it figure it out. When you give the model too much context, it's like you're micromanaging it" ([primary](https://howborisusesclaudecode.com/)).

- Provide a goal, the constraints, acceptance criteria, and a retrieval path. Then let the model pull the rest of the context itself.
- Cherny historically started ~80% of tasks in plan mode, iterated the plan, then switched to auto-accept ([confirmed-primary; Lenny's Podcast](https://note.com/ai_eng_tech/n/nf940a6dc47e6?hl=en)). He now leans on auto mode because newer models need less explicit planning: "The newer models don't actually need a planning step" ([primary](https://howborisusesclaudecode.com/)). If your model still benefits from planning, keep using plan mode; the shift is capability-driven, not a rejection of planning.
- Prefer the highest-performing model with thinking on. Cherny uses Opus with thinking for everything because "you have to steer it less and it's better at tool use, so it's almost always faster in the end" ([primary](https://getpushtoprod.substack.com/p/how-the-creator-of-claude-code-actually)).

## 4. Isolate parallel work in worktrees

Run each agent in its own git worktree so parallel agents do not collide or create merge conflicts.

- Use `claude --worktree <name>` (or `-w`) to create an isolated checkout on its own branch under `.claude/worktrees/<value>/` ([docs](https://code.claude.com/docs/en/worktrees)).
- Cherny ran ~5 worktrees simultaneously, each in its own Claude session, plus 5-10 sessions on claude.ai/code, handing off with `&` and `--teleport` ([confirmed-primary; @bcherny thread](https://x.com/bcherny/status/2007179836704600237)). Worktree isolation is what makes parallel agents on one repo safe.
- A background worktree agent fixing review comments in isolation before pushing is exactly the mechanism behind the babysit loop in step 1.

## 5. Supervise via a dashboard, not individual tabs

As soon as you run more than one agent, stop cycling between terminal tabs.

- Use the agent view (`claude agents`), which groups every background session under "Needs input," "Working," and "Completed" on one screen and moves each dispatched session into its own worktree ([docs](https://code.claude.com/docs/en/agent-view)).
- Cherny calls this "the best way to level up from 1 agent => many agents. No more cycling between terminal tabs" ([primary](https://howborisusesclaudecode.com/)). His earlier manual approach (numbered tabs 1-5 plus OS notifications) works for a handful of local sessions but does not scale.
- Cherny controls sessions from his phone via `/remote-control` and starts agents each morning before reaching a computer: "Every morning I wake up and start a few agents to begin my code for the day" ([primary, developing.dev](https://www.developing.dev/p/boris-cherny-creator-of-claude-code)).

## 6. Keep the human in the judgment seat

Autonomy does not remove oversight; it relocates it. Cherny: "Someone has to prompt the Claudes, talk to customers, coordinate with other teams, decide what to build next" ([secondary](https://officechai.com/ai/claude-code-is-now-100-written-by-claude-code-creator-boris-cherny/)).

- Review the output, not every step. The Claude Code team holds the same quality bar regardless of author: "We have the same exact bar regardless of whether the code was written by the model or by a human. If the code sucks, we're not gonna merge it" ([primary](https://www.developing.dev/p/boris-cherny-creator-of-claude-code)). Have Claude review PRs as a first pass, then make the merge call yourself.
- Set budget and stop ceilings so a loop cannot run away: a maximum iteration count, a token or dollar cap, and a condition-based halt (for example, stop on two consecutive identical failures) ([secondary](https://explainx.ai/blog/loop-engineering-coding-agents-claude-code-guide-2026)).
- Be deliberate about auto mode. It routes actions through a safety classifier instead of prompting on every tool call. The argument for it is that manual approval degrades when you rubber-stamp nearly every prompt: Anthropic's measured figure is that users approve 93% of permission prompts ([primary; the "99%" figure in interviews is a rhetorical round number](https://anthropic.com/engineering/claude-code-auto-mode)). Anthropic explicitly cautions it is "not a drop-in replacement for careful human review on high-stakes infrastructure" ([primary](https://anthropic.com/engineering/claude-code-auto-mode)). Keep manual review for risky operations.

## 7. Convert every recurring mistake into a durable correction

This is the step Cherny calls the single most important idea for long-running work: "Every single time Claude makes a mistake, I don't tell it to do it differently. I tell it to write it to the CLAUDE.md, or make a skill, or something. If you can do this, then Claude can just run forever" ([primary](https://howborisusesclaudecode.com/)).

- Write the fix into CLAUDE.md, loaded at the start of every session. CLAUDE.md is context, not enforcement; to hard-block an action use a PreToolUse hook instead ([docs](https://code.claude.com/docs/en/memory)). On the Claude Code team a single repo CLAUDE.md is shared and updated multiple times a week; Cherny tags @claude on PRs to update it during review ([secondary](https://getpushtoprod.substack.com/p/how-the-creator-of-claude-code-actually)).
- Turn frequent multi-step procedures into skills (`.claude/skills/<name>/SKILL.md`), which load only when used so they cost almost nothing in context until needed ([docs](https://code.claude.com/docs/en/skills)). Cherny checks slash commands into `.claude/commands/` for "every 'inner loop' workflow that I end up doing many times a day" so the whole team and Claude can reuse them ([primary, @bcherny tweet 7/](https://x.com/bcherny/status/2007179847949500714)).
- When failures look environmental, point the loop at Slack via MCP to self-diagnose (is staging down, did a teammate already hit this) before debugging further, then update the relevant skill with what it learned ([secondary](https://www.theneuron.ai/explainer-articles/claude-code-creators-boris-cherny-and-cat-wu-explain-how-to-use-agent-loops/)).

## Where this leads

Run these seven steps together and you arrive at the workflow Cherny reports: by his own December 2025 post he landed 259 PRs in 30 days with every line written by Claude Code, after uninstalling his IDE in late November 2025 ([confirmed-primary](https://www.threads.com/@boris_cherny/post/DSxC69PCCz_/fast-forward-to-today-in-the-last-thirty-days-i-landed-p-rs-commits-k-lines)). Treat his more dramatic scale claims (hundreds or thousands of agents, ~4% of public GitHub commits) as directional. The 4% figure is a third-party SemiAnalysis estimate with no published methodology, scoped to public commits at one point in time ([confirmed-secondary](https://newsletter.semianalysis.com/p/claude-code-is-the-inflection-point)). The implementable core, available to you today, is `/goal`, `/loop`, `/schedule`, worktrees, agent view, hooks, skills, and CLAUDE.md, wrapped in loops you write and verify.
