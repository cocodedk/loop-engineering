# Caveats and Open Questions

This document separates what the research actually substantiates from what is aspirational, promotional, or resting on secondary reporting. Read it alongside the rest of the knowledge base as a corrective: the loop methodology is real and the headline quotes are genuine, but several widely repeated framings and numbers carry weaker evidence than their viral circulation suggests.

## What is solidly substantiated (confirmed-primary)

The following claims trace to Boris Cherny's own first-person statements (his X/Threads posts, on-camera interviews) and were rated confirmed-primary in verification:

- He no longer prompts Claude directly; he writes loops that prompt Claude. The verbatim line ("I don't prompt Claude anymore... My job is to write loops") is his own, said on the record at a Sequoia AI Ascent 2026 talk and the Acquired Unplugged / WorkOS event ([Sequoia video](https://www.youtube.com/watch?v=SlGRN8jh2RI), [WorkOS recap](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)).
- He uninstalled his IDE after Opus 4.5 shipped in late November 2025, by his own account ([@bcherny](https://x.com/bcherny/status/2064431111154053187)). Note the exact verb is "uninstalled," not "deleted," and he anchors timing to "after 4.5 came out," not to the word "November."
- In the 30 days before Dec 27, 2025 he landed 259 PRs (497 commits) with every line written by Claude Code on Opus 4.5 ([Threads](https://www.threads.com/@boris_cherny/post/DSxC69PCCz_/fast-forward-to-today-in-the-last-thirty-days-i-landed-p-rs-commits-k-lines)). This is scoped to his own contributions over a trailing 30-day window, not the whole codebase or a steady state.
- On March 7, 2026 he stated "Claude Code is 100% written by Claude Code" ([@bcherny](https://x.com/bcherny/status/2030109840555790357)).
- He runs roughly 5 local terminal sessions plus 5-10 web sessions, verbatim from his own Jan 2026 thread ([@bcherny](https://x.com/bcherny/status/2007179836704600237)).
- He briefly left Anthropic for Anysphere/Cursor and returned about two weeks later (with Cat Wu), confirmed in his own [Lenny's Podcast](https://www.lennysnewsletter.com/p/head-of-claude-code) account and The Information's reporting.

These are reliable as statements of what Cherny did and said. They remain self-reported and were not independently audited, which is inherent to the claims themselves.

## What rests only on secondary reporting (confirmed-secondary)

Several headline numbers and definitions are real and uncontested but do not originate from a primary Anthropic or Cherny measurement. Treat them as community or third-party synthesis:

- The "roughly 4% of all public GitHub commits" figure comes from the research firm SemiAnalysis, not Anthropic ([SemiAnalysis report](https://newsletter.semianalysis.com/p/claude-code-is-the-inflection-point)). Cherny repeated it on a podcast while citing that report, not presenting Anthropic's own data. SemiAnalysis published no rigorous methodology, the number is a point-in-time estimate from around early February 2026, it covers only public commits, and it excludes competing tools. It is not a stable statistic.
- "Loop engineering" as a named, four-part orchestration pattern (scheduled execution, isolated workspaces, verifier agents, persistent memory) is a third-party coinage. Cherny said "write loops"; the named term and its taxonomy come from Addy Osmani and Peter Steinberger ([Osmani](https://addyo.substack.com/p/loop-engineering)). The underlying primitives are documented Anthropic features, but the bundled named pattern exists only in commentary.
- The crisp "sense-decide-act-check, each decision the model's not a hardcoded branch" definition of a loop is also a commentator paraphrase (Medium, Cobus Greyling), not Cherny's wording ([Acquired video](https://www.youtube.com/watch?v=RkQQ7WEor7w)). It mirrors the generic OODA loop rather than a Cherny coinage.
- The claim that the Lenny's Podcast interview does not contain the loops framing, parallel-session counts, or autonomous monitoring agents is well-supported but rests on a third-party transcript, because the official Lenny's transcript is paywalled ([WorkOS](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)).

## The star-engineer-versus-typical-user gap

Cherny is a principal-level engineer who created Claude Code and works inside Anthropic with access to internal tooling, experimental features, and the latest models before public release. His workflow is not a baseline a typical user should expect to reproduce:

- His "200% per-engineer productivity" figure (from the Lenny interview) and the separate "~70% per engineer" figure (from the developing.dev interview) are both his own framing, both rated medium confidence in the corpus, and they do not agree with each other. They describe different venues and possibly different scopes. Anthropic's own blog reportedly cautioned that the lines-of-code productivity framing was "almost certainly an overstatement" ([Fortune](https://fortune.com/2026/06/11/anthropic-claude-boris-cherny-doesnt-write-code-by-hand-anymore/)).
- "100% written by Claude Code" is the code-authoring step only. Cherny himself caveats that humans still prompt the loops, talk to customers, coordinate teams, and decide what to build ([OfficeChai](https://officechai.com/ai/claude-code-is-now-100-written-by-claude-code-creator-boris-cherny/)). The percentage measures authorship, not autonomy.
- The "hundreds of agents reading GitHub, Slack, and Twitter to decide what to build" claim is rated medium confidence and describes Cherny's personal scaled-up setup, not a documented out-of-the-box capability ([WorkOS](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)).

## Numbers that drifted or conflict

- The "99% of permission prompts accepted" line used in interviews is a rhetorical round number. Anthropic's own engineering data gives the measured figure as 93%, not 99% ([Anthropic Engineering](https://anthropic.com/engineering/claude-code-auto-mode)). The sharper "if humans accept 99%..." phrasing is attributed to Cat Wu by The Neuron but is unconfirmed in any primary transcript.
- The "2-3x quality improvement" from verification feedback loops is Cherny's own estimate, repeated across sources, but it is an unquantified self-report, not a measured benchmark.
- Auto mode's own evals report a 0.4% false-positive and 17% false-negative rate, and Anthropic explicitly states it is "not a drop-in replacement for careful human review on high-stakes infrastructure" ([Anthropic Engineering](https://anthropic.com/engineering/claude-code-auto-mode)). The 17% false-negative rate is a real, documented limit on the "more safe than reading every prompt" argument.
- Daily PR counts are quoted as "10 to 20 to 30," "20-30," "30," and in one outlier "150." Only the "10 to 20 to 30" range traces to Cherny directly.

## The survivorship and promotional angle

Most of the corpus is promotional in posture. WorkOS hosted the Acquired event and wrote the recap; Sequoia published its own interview; secondary blogs (explainx, The Neuron, Medium, Substack newsletters) amplify the same viral clips and have an incentive to dramatize. The "I write loops" clip spread because it is striking, not because it was independently verified. There is no visible counter-evidence in the corpus showing where loops fail, what they cost in wasted compute, or how often the autonomous agents produce work that gets discarded. The picture is selected for the most impressive outcome from the person best positioned to achieve it.

The weakest-evidenced parts of the methodology are openly flagged in the corpus: typed I/O schemas are "not explicitly detailed, but implied through skills discipline" (confidence: low), and trace/replay is framed as durability rather than a real debugging tool (confidence: low). These pattern elements are aspirational scaffolding more than documented practice.

## Open questions a careful reader should keep

- Does the loop approach hold up outside a mature, heavily instrumented repo with strong test and verification harnesses, or is the verification loop (the thing Cherny calls most important) the actual precondition that most teams lack?
- What is the real cost? The corpus mentions budget caps (an example "~$1,500/person/month" at Uber) only in passing. Unattended overnight loops have an unstated compute bill.
- How much of the "100%" output is net-new value versus churn? The 259-PR window added 40k and removed 38k lines; high throughput is not the same as high net progress.
- The "loop engineering" label, the four-part pattern, and several crisp definitions are journalist constructs. When implementing, map to documented primitives (`/goal`, `/loop`, the Agent SDK, Stop hooks), not to a product feature called "loop engineering," which does not exist.
- Productivity multipliers (70% vs 200%) conflict and are self-reported; treat any single number as illustrative, not measured.
