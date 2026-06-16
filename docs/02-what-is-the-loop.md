# What "The Loop" Is

The loop is the central idea behind Boris Cherny's current way of working with Claude Code: instead of typing a prompt, reading the reply, and typing the next prompt, you write a small program that does the prompting for you. Cherny is the creator and Head of Claude Code at Anthropic, and he frames this as a change in what an engineer's actual job is.

## The core statement

The canonical line is Cherny's own:

> "Now it's actually leveled up, I think, again, to the next wave of abstraction where I don't prompt Claude anymore. I have loops that are running. They're the ones that are prompting Claude and figuring out what to do. My job is to write loops."

This statement is **confirmed against primary sources**. It comes from Cherny speaking on the record (reported from his June 2026 talks and an Anthropic conversation with Cat Wu), and the wording is reproduced consistently across many independent outlets with no source disputing it ([Medium / Mountain Movers](https://medium.com/mountain-movers/what-a-loop-actually-is-boris-chernys-three-stage-definition-33dd2bfe01b3), [WorkOS](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)). A note on provenance: the specific venue varies between secondary write-ups (a WorkOS-hosted Acquired Unplugged talk on June 2, 2026; a Sequoia AI Ascent appearance; an Anthropic one-year retrospective video). The substance is firmly primary; the exact venue attribution is where sources differ.

Importantly, the loop framing does **not** come from Cherny's Lenny's Podcast interview (Feb 19, 2026). That interview is the source for his throughput and productivity numbers, not the loop methodology. A near-verbatim transcript of the Lenny episode contains no mention of "loops," no parallel-session counts, and no autonomous monitoring agents ([note.com transcript](https://note.com/ai_eng_tech/n/nf940a6dc47e6?hl=en)). This separation is itself **confirmed**, though the proof of absence rests on a third-party transcript because the official one is paywalled ([WorkOS](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)).

## The basic cycle: prompt, read, check, re-prompt

A loop is a small program you write that prompts the coding agent on your behalf, reads what the agent produced, decides whether the task is complete, and if not, prompts the agent again with updated context. Stated more generally, a loop runs a model that looks at the current state, decides what action to take, takes the action, checks whether the action worked, and decides whether to continue or halt. Each decision in that cycle is made by the model, not by a hardcoded branch.

This sense-decide-act-check description is **confirmed only at the secondary level**. The underlying idea is genuinely Cherny's, but this specific formulation (and the "not a hardcoded branch" phrasing) is a third-party synthesis from commentators, not Cherny's own wording ([explainx.ai](https://explainx.ai/blog/loop-engineering-coding-agents-claude-code-guide-2026), [Cobus Greyling](https://cobusgreyling.substack.com/p/loop-engineering)). The phrasing also echoes the generic OODA loop rather than a coined term.

The cycle only works if the agent can actually check its own output. Cherny calls verification "probably the most important thing to get great results out of Claude Code" and says a verification feedback loop will "2-3x the quality of the final result." Real verification means the agent can run the thing it changed (a bash command, a test suite, a browser, a simulator), not just lint or type-check it ([howborisusesclaudecode.com](https://howborisusesclaudecode.com/)). For long-running loops, he adds explicit verification so the agent does not declare victory prematurely, for example a background agent that checks the work or an agent Stop hook that does the same more deterministically ([@bcherny, X thread, tweet 12](https://x.com/bcherny/status/2007179858435281082)).

## The three waves of abstraction

Cherny describes his own evolution as three stages, and the loop is stage three. This three-stage progression is **confirmed against primary sources** (his own talk plus his own X thread for the session counts) ([WorkOS recap of the June 2, 2026 talk](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)).

1. **Autocomplete.** "The way that I coded a year ago was I wrote code with some autocomplete in the IDE." The model is a directed autocomplete tool and the human writes the code ([officechai](https://officechai.com/ai/i-now-just-write-loops-to-prompt-claude-code-claude-code-creator-boris-cherny/)).
2. **Parallel manual prompting.** "At that point, I was running maybe five, ten Claudes in parallel, and my coding was prompting Claude to write code." The human is still inside the loop, initiating each prompt. The specific counts match his own thread: roughly 5 local terminal instances plus 5-10 web sessions on claude.ai/code ([@bcherny](https://x.com/bcherny/status/2007179836704600237)).
3. **Loops.** "Now it's actually leveled up... I don't prompt Claude anymore... My job is to write loops." Loops prompt Claude, and a couple hundred agents read his GitHub, Slack, and Twitter to decide what to build next ([Medium](https://medium.com/mountain-movers/what-a-loop-actually-is-boris-chernys-three-stage-definition-33dd2bfe01b3)).

## The prompt is the smallest unit of work

The shift across these stages changes what the basic unit of work is. The interface "moved from source code, to agent, to loop or routine" ([The Neuron](https://www.theneuron.ai/explainer-articles/claude-code-creators-boris-cherny-and-cat-wu-explain-how-to-use-agent-loops/)). In stage one the unit was a line of code; in stage two it was a prompt the human typed; in stage three the prompt becomes the smallest unit the human still touches directly, and even that is increasingly written by the loop rather than the person.

The summary phrase "the prompt is becoming the smallest unit of work" is a journalistic gloss from The Neuron, not a verbatim Cherny quote. The underlying idea that the prompt is superseded by loops and routines as the unit of work is **confirmed primary** through Cherny's own video statements; the exact "smallest unit of work" label is the **secondary** packaging of that idea ([The Neuron](https://www.theneuron.ai/explainer-articles/claude-code-creators-boris-cherny-and-cat-wu-explain-how-to-use-agent-loops/)).

## The formal "loop engineering" definition

The named pattern "loop engineering" bundles the loop idea with a set of supporting mechanics:

- **Scheduled execution.** The loop runs on a cadence or until a goal condition is true, rather than as a one-off session.
- **Isolated workspaces.** Each agent or iteration runs in its own git worktree so parallel agents do not collide.
- **Verifier agents.** A separate agent or program grades the generator's output, because the agent that wrote the code is a poor judge of its own work.
- **Persistent memory.** Intent and progress live on disk (markdown anchor files plus git), so work survives across runs.

This four-part definition is **confirmed only at the secondary level**. The component primitives trace to primary Anthropic and Cherny material (the `/loop` and `/goal` commands, git worktrees, "give Claude a way to verify its work," and CLAUDE.md memory), but the specific named pattern with this four-part anatomy exists only in third-party synthesis ([Addy Osmani](https://addyo.substack.com/p/loop-engineering), [The New Stack](https://thenewstack.io/loop-engineering/)).

The term itself is **not Cherny's coinage**. Cherny used the verb "write loops"; the noun phrase "loop engineering" was applied by commentators modeling it on "prompt engineering" and "context engineering." Peter Steinberger supplied the imperative form ("You shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents."), and Google engineer Addy Osmani gave the pattern its name and taxonomy ([Cobus Greyling](https://cobusgreyling.substack.com/p/loop-engineering), [Addy Osmani](https://addyosmani.com/blog/loop-engineering/)).

## Why it works, in practice

The loop is not a demo. In the 30 days before December 27, 2025, Cherny landed 259 PRs (497 commits, 40k lines added, 38k removed), every line written by Claude Code on Opus 4.5, after uninstalling his IDE in late November 2025. Both the PR figures and the IDE removal are **confirmed against his own posts** ([Threads](https://www.threads.com/@boris_cherny/post/DSxC69PCCz_/fast-forward-to-today-in-the-last-thirty-days-i-landed-p-rs-commits-k-lines), [X](https://x.com/bcherny/status/2064431111154053187)). He also says he ships 10 to 30 PRs every day ([note.com](https://note.com/ai_eng_tech/n/nf940a6dc47e6?hl=en)).

The human role does not disappear; it changes shape. As Cherny puts it: "Someone has to prompt the Claudes, talk to customers, coordinate with other teams, decide what to build next" ([officechai](https://officechai.com/ai/claude-code-is-now-100-written-by-claude-code-creator-boris-cherny/)). The engineer designs the loop, sets its stopping conditions, and reviews what it surfaces. Writing loops is the work.
