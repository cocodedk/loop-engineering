# Anatomy of a Loop

This document breaks down what technically makes a loop in Boris Cherny's methodology: the control program, the state it feeds in, the model reasoning and tool calls, the action execution, the self-verification step, and the re-prompt with updated context. It also explains why self-verification is mandatory and contrasts a one-shot script with a true closed loop.

## The core statement

Cherny describes his current workflow as no longer prompting Claude turn-by-turn. Instead he writes loops that prompt Claude. His verbatim words: "Now it's actually leveled up... to the next wave of abstraction where I don't prompt Claude anymore. I have loops that are running. They're the ones that are prompting Claude and figuring out what to do. My job is to write loops." This statement is **confirmed-primary** (Cherny on the record; reported across multiple outlets, with the primary venue traced to recorded interviews including Sequoia AI Ascent 2026 and the Acquired Unplugged event presented by WorkOS, June 2, 2026) ([Medium write-up](https://medium.com/mountain-movers/what-a-loop-actually-is-boris-chernys-three-stage-definition-33dd2bfe01b3), [WorkOS takeaways](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)).

One framing worth keeping in mind: the noun phrase "loop engineering" is a third-party label (popularized by Peter Steinberger and Addy Osmani), not Cherny's own coinage. Cherny said "write loops"; commentators named the pattern ([The New Stack](https://thenewstack.io/loop-engineering/)).

## What a loop is, technically

A loop is a small control program you write that runs a model in a cycle and decides, at each step, what happens next. The decision at each step is the model's, not a hardcoded branch. The plain-language definition: "A loop is a small program you write that prompts the coding agent on your behalf, reads what the agent produced, decides whether the task is complete, and if not, prompts the agent again with updated context" ([explainx.ai](https://explainx.ai/blog/loop-engineering-coding-agents-claude-code-guide-2026)).

The sense-decide-act-check description (a model looks at current state, decides an action, takes it, checks whether it worked, then decides to continue or halt) captures the idea, but note this exact formulation is **confirmed-secondary**: it is commentator synthesis (it mirrors the generic OODA loop), not a verbatim Cherny definition ([WorkOS](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)).

## The six parts of one loop iteration

A single turn of the loop has a consistent structure:

1. **Control program.** The outer harness you author. It owns the goal, the budget, the stop condition, and the re-prompt logic. This is "the loop" Cherny says is now his job to write. Concretely it can be a script around repeated `claude -p` (headless) invocations, the Agent SDK, or the built-in `/goal` and `/loop` drivers ([headless docs](https://code.claude.com/docs/en/headless), [goal docs](https://code.claude.com/docs/en/goal)).

2. **State, history, and goals fed in.** The control program assembles context: the goal or completion condition, prior progress, and durable state. State is kept on disk and in git rather than in a growing conversation, so work survives across runs and crashes. Anchor files cited in practice include VISION.md, CLAUDE.md / AGENTS.md, a PROMPT.md or loop.md, and SKILL.md ([explainx.ai](https://explainx.ai/blog/loop-engineering-coding-agents-claude-code-guide-2026)).

3. **The model reasons, plans, and calls tools.** Given the assembled context, the model decides what to do and invokes tools (read, edit, bash, search, MCP). Cherny favors context minimalism here: "Minimal system prompt, minimal tools, and a way for Claude to pull context" ([The Neuron](https://www.theneuron.ai/explainer-articles/claude-code-creators-boris-cherny-and-cat-wu-explain-how-to-use-agent-loops/)).

4. **The action executes.** The chosen action runs against the real workspace. To keep parallel iterations from colliding, each agent or iteration runs in an isolated git worktree, its own working directory on its own branch ([worktrees docs](https://code.claude.com/docs/en/worktrees), [Addy Osmani](https://addyosmani.com/blog/loop-engineering/)).

5. **The loop self-verifies.** A separate check grades the result against checkable criteria: run the build, run the tests, run the app. This is the inner feedback step (detailed below).

6. **Re-prompt with updated context.** If the check fails or the goal is not yet met, the control program feeds the verifier's report back in and prompts the model again. If the stop condition holds, or a budget or iteration ceiling is hit, the loop halts and reports.

## Why self-verification is mandatory

Without a verification step a loop has no reliable signal for whether it is done, so it either stops on the agent's own unchecked say-so or runs forever producing garbage. The agent that wrote the code is a poor judge of its own work, so a separate evaluator is needed ([Cobus Greyling](https://cobusgreyling.substack.com/p/loop-engineering)).

The common three-part structure is a generator (the agent doing the work), an evaluator (a separate agent or program that grades output against a rubric), and the loop itself, which feeds the evaluator's report back to the generator until the rubric passes or a budget runs out ([MindStudio](https://www.mindstudio.ai/blog/what-is-loop-engineering-ai-coding-agents)).

Cherny ranks verification as the single most important factor for quality, and is specific about what counts. Real verification means the agent can actually run and exercise what it changed, not just lint or type-check or unit-test it: "give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result" ([howborisusesclaudecode.com](https://howborisusesclaudecode.com/)). The 2-3x figure is Cherny's own claim, reported via this compilation. For UI work, his team has Claude open a browser through the Chrome extension and iterate until it works; for desktop apps, computer-use clicks through the interface ([Pragmatic Engineer](https://newsletter.pragmaticengineer.com/p/building-claude-code-with-boris-cherny)).

For very long-running tasks Cherny adds explicit verification mechanisms so the agent does not declare victory prematurely. His own options: prompt Claude to verify with a background agent when done, use an agent Stop hook to do that more deterministically, or use the ralph-wiggum plugin (originally by Geoffrey Huntley) ([@bcherny tweet 12/](https://x.com/bcherny/status/2007179858435281082)).

The same discipline extends to memory. Every repeated mistake is written into CLAUDE.md or turned into a skill so the fix persists: "Every single time Claude makes a mistake, I don't tell it to do it differently. I tell it to write it to the CLAUDE.md, or make a skill, or something. If you can do this, then Claude can just run forever" ([howborisusesclaudecode.com](https://howborisusesclaudecode.com/)).

## Budget and stop gates

Self-verification answers "did it work." Gates answer "when do we give up." A safe unattended loop needs hard ceilings alongside verification: a maximum iteration count, a token or dollar budget ceiling, and a condition-based halt (all tests passing, or N consecutive identical failures). No-progress detection halts the loop when the same error repeats N times in a row ([explainx.ai](https://explainx.ai/blog/loop-engineering-coding-agents-claude-code-guide-2026)). These gates are **confirmed-secondary**: they appear in commentator synthesis describing the pattern, not in a verbatim Cherny spec.

A useful template for the loop contract: TRIGGER (every 15m, on PR comment, on CI failure) to SCOPE (open PRs I authored, repo X) to ACTION (run tests, fix lint, respond to review) to BUDGET (max N sub-agents per tick, token cap) to STOP (all PRs green, or 10 iterations, or $5 spent) to REPORT (post summary to Slack) ([explainx.ai](https://explainx.ai/blog/loop-engineering-coding-agents-claude-code-guide-2026)).

## One-shot script vs. true closed loop

A one-shot script runs the agent once and trusts the result. The agent declares "done" and control returns to the human regardless of whether the work is actually correct. In the verification framing this is the "open loop": the agent's self-report is taken at face value, which is fine for a demo but not for unattended production work ([MindStudio](https://www.mindstudio.ai/blog/what-is-loop-engineering-ai-coding-agents)).

A true closed loop replaces "agent says done" with "checker confirms done." The cycle is write, run tests, read results, correct, repeat, until an external check passes or a budget is exhausted. The difference is the feedback edge: the verifier's output is wired back into the next prompt. That single edge is what lets the loop self-correct instead of either stopping early on a false claim or running forever producing garbage.

In Cherny's tooling, the closed-loop primitive is `/goal`, which "sets a completion condition and Claude keeps working toward it without you prompting each step. After each turn, a small fast model checks whether the condition holds. If not, Claude starts another turn instead of returning control to you" ([goal docs](https://code.claude.com/docs/en/goal)). The recurring driver is `/loop`, which re-runs a prompt on an interval (or self-paces when the interval is omitted) ([scheduled-tasks docs](https://code.claude.com/docs/en/scheduled-tasks)). A bare `claude -p "..."` with no surrounding harness is the one-shot case; wrapping it in `/goal`, a Stop hook, or an Agent SDK loop turns it into a closed loop.

## Why the loop is the unit of work

In this model the human writes the loop, not the prompt. The interface, in Cherny's framing, "moved from source code, to agent, to loop or routine" ([The Neuron](https://www.theneuron.ai/explainer-articles/claude-code-creators-boris-cherny-and-cat-wu-explain-how-to-use-agent-loops/)). The receipts for this being a real production workflow rather than a demo are **confirmed-primary** from Cherny's own posts: in the 30 days before December 27, 2025 he landed 259 PRs (497 commits, 40k lines added, 38k removed), "Every single line was written by Claude Code + Opus 4.5," after uninstalling his IDE in late November 2025 ([Threads post](https://www.threads.com/@boris_cherny/post/DSxC69PCCz_/fast-forward-to-today-in-the-last-thirty-days-i-landed-p-rs-commits-k-lines), [X post](https://x.com/bcherny/status/2064431111154053187)). The closed loop, with self-verification at its center, is what makes that volume run unattended.
