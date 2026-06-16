# The Three Stages of Evolution

Boris Cherny describes his coding practice as moving through three "waves of abstraction." He laid out this three-stage framing on stage at Acquired Unplugged, presented by WorkOS, on June 2, 2026. The progression is from writing code by hand, to manually prompting many parallel agents, to writing loops that prompt the agents for him. This three-stage account is confirmed from primary sources: the WorkOS-hosted talk ([video](https://www.youtube.com/watch?v=RkQQ7WEor7w), [WorkOS recap](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)), with each numeric detail independently corroborated by Cherny's own posts.

Note on sourcing: this three-stage framing does **not** come from his Lenny's Newsletter podcast interview (Feb 19, 2026). That interview documents his throughput and productivity numbers but contains no "loops" framing, no parallel-session counts, and no autonomous channel-monitoring agents ([WorkOS](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)). The loop material traces to his January 2026 X thread and the June 2, 2026 talk.

## Stage 1 — Manual, line-by-line autocomplete

A year before the talk (roughly 2025), Cherny coded the conventional way: writing code himself with IDE autocomplete assisting him line by line. In his words, "The way that I coded a year ago was I wrote code with some autocomplete in the IDE." ([OfficeChai](https://officechai.com/ai/i-now-just-write-loops-to-prompt-claude-code-claude-code-creator-boris-cherny/)) The model functioned as a directed autocomplete tool. The human wrote the code and made every decision.

This stage ended in late November 2025. Cherny uninstalled his IDE after Opus 4.5 shipped (Anthropic dates Opus 4.5 to November 24, 2025), once he realized he had been coding entirely in a terminal for several weeks. He stated this directly: "After 4.5 came out I uninstalled my IDE when I realized that I'd been doing 100% of my coding in a terminal for a few weeks." ([X, @bcherny](https://x.com/bcherny/status/2064431111154053187)) This is confirmed-primary. His exact verb is "uninstalled" rather than "deleted," and the month anchors to November 2025 through the Opus 4.5 release date.

## Stage 2 — Parallel manual prompting of 5-10 sessions

In the second stage the human still initiates every prompt, but runs many agents at once instead of one. Cherny: "At that point, I was running maybe five, ten Claudes in parallel, and my coding was prompting Claude to write code." ([OfficeChai](https://officechai.com/ai/i-now-just-write-loops-to-prompt-claude-code-claude-code-creator-boris-cherny/))

The session counts are confirmed-primary from his own January 2026 X/Threads thread. He runs roughly 5 Claude instances locally in his terminal, numbering the tabs 1-5 and using system notifications to know when one needs input, plus another 5-10 sessions on claude.ai/code in the browser ([X, @bcherny](https://x.com/bcherny/status/2007179836704600237); [Threads](https://www.threads.com/@boris_cherny/post/DTBVmoKkkpR)). He hands sessions off between local and web using the `&` operator and moves context across machines with the `--teleport` flag and the `/teleport` command ([Threads](https://www.threads.com/@boris_cherny/post/DWfjo22FKJ4/)). The net is roughly 10-15 concurrent sessions, with the human inside the loop prompting each one.

This stage produced concrete output. In the 30 days before his December 27, 2025 post, he landed 259 pull requests (497 commits, 40k lines added, 38k removed), every line written by Claude Code with Opus 4.5 ([Threads](https://www.threads.com/@boris_cherny/post/DSxC69PCCz_/fast-forward-to-today-in-the-last-thirty-days-i-landed-p-rs-commits-k-lines)). He separately reported shipping "10 to 20 to 30 Pull Requests every day." Both figures are confirmed-primary and self-reported.

## Stage 3 — Autonomous loops

In the third stage the human stops prompting Claude directly and instead writes loops that do the prompting. Cherny's canonical statement: "Now it's actually leveled up, I think, again, to the next wave of abstraction where I don't prompt Claude anymore. I have loops that are running. They're the ones that are prompting Claude and figuring out what to do. My job is to write loops." ([Medium](https://medium.com/mountain-movers/what-a-loop-actually-is-boris-chernys-three-stage-definition-33dd2bfe01b3)) That he no longer prompts directly, and that loops prompt Claude for him, is confirmed-primary ([video](https://www.youtube.com/watch?v=Hth_tLaC2j8)).

A loop is a small program that prompts the agent, reads what it produced, decides whether the task is complete, and re-prompts with updated context if not. The fuller "sense-decide-act-check" definition (a model observes state, decides an action, takes it, checks the result, and decides whether to continue or halt) is widely repeated but is confirmed-secondary: the concept is Cherny's, but that exact formulation traces to commentators rather than to him ([WorkOS talk](https://www.youtube.com/watch?v=RkQQ7WEor7w)).

In this stage a couple hundred agents read his GitHub, Slack, and Twitter and decide what to build next. WorkOS's official recap describes "hundreds of Claude instances monitoring Twitter feedback, GitHub issues, and Slack to generate product ideas," and notes "his job shifted from writing code to orchestrating agents" ([WorkOS](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)). At Fortune Brainstorm Tech he described managing "a few hundred AI agents" on a given morning, "some days... thousands or tens of thousands," and said "Many mornings I wake up, and Claude already has pull requests that it came up with, verified end to end, it has screenshots for me." ([Fortune](https://fortune.com/2026/06/11/anthropic-claude-boris-cherny-doesnt-write-code-by-hand-anymore/))

The human role does not disappear; it transforms. Cherny: "Someone has to prompt the Claudes, talk to customers, coordinate with other teams, decide what to build next." ([OfficeChai](https://officechai.com/ai/claude-code-is-now-100-written-by-claude-code-creator-boris-cherny/))

## The human's role at each stage

| Stage | Tooling | What the human does | The unit of work |
|-------|---------|---------------------|------------------|
| 1. Manual autocomplete (until Nov 2025) | IDE with autocomplete | Writes code line by line; makes every decision | Source code |
| 2. Parallel manual prompting | ~5 local terminal sessions + 5-10 web sessions | Prompts each agent, reviews and merges output, context-switches between sessions | The prompt / the agent |
| 3. Autonomous loops | `/loop`, routines, `--teleport`, agent view | Writes loops, sets goals and constraints, reviews surfaced work, decides what to build | The loop / routine |

The shift across stages is the human moving up a level of abstraction each time. Cherny frames it as: "The interface moved from source code, to agent, to loop or routine." ([The Neuron](https://www.theneuron.ai/explainer-articles/claude-code-creators-boris-cherny-and-cat-wu-explain-how-to-use-agent-loops/)) In stage 1 the human authors code; in stage 2 the human authors prompts; in stage 3 the human authors the loops that author the prompts.

## A naming note

"Loop engineering" as a named term was popularized by third parties, not coined by Cherny. He said "my job is to write loops"; commentators including Peter Steinberger and Addy Osmani applied the "-engineering" label, modeled on "prompt engineering" and "context engineering" ([The New Stack](https://thenewstack.io/loop-engineering/); [Addy Osmani](https://addyosmani.com/blog/loop-engineering/)). The three-stage progression and the underlying "I write loops" idea are Cherny's; the packaging into a named pattern is community framing.
