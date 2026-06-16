# Receipts and Timeline

This document lays out the concrete, dated claims behind Boris Cherny's "loop"
methodology in chronological order. Each entry carries a verification verdict
taken from the project's verdicts data:

- **confirmed-primary** — traces to Cherny's own first-person statement or to an
  official/publisher artifact.
- **confirmed-secondary** — the substance is real and uncontested, but the
  best available evidence is third-party reporting or synthesis, not a primary
  source.
- **disputed** — credible sources disagree.
- **unverifiable** — no usable evidence either way.

No claim in the timeline below landed as *disputed* or *unverifiable*. Several
landed as *confirmed-secondary*, and those are flagged explicitly. Self-reported
figures (PR counts, percentages) are exactly that: self-reported and not
independently audited, which is inherent to the claims.

## November 2025 — Cherny uninstalls his IDE

**Verdict: confirmed-primary.**

After Claude Opus 4.5 shipped, Cherny stopped using a code editor entirely. In
his own X post he wrote: "After 4.5 came out I uninstalled my IDE when I
realized that I'd been doing 100% of my coding in a terminal for a few weeks"
([@bcherny, June 9, 2026](https://x.com/bcherny/status/2064431111154053187)).
Opus 4.5 was released November 24, 2025, so "after 4.5 came out / back in
November" anchors the action to late November 2025.

Two wording nuances worth keeping straight: his exact verb is "uninstalled,"
not "deleted" (functionally equivalent), and he does not literally name November
as the uninstall month — he anchors it to the 4.5 release, which was November.
On Lenny's Podcast he separately stated: "I haven't edited a single line by hand
since November"
([@lennysan summary](https://x.com/lennysan/status/2024896611818897438)). The
substance is his own first-person account, corroborated across his late-December
2025 posts and the June 2026 Acquired Unplugged interview.

## December 27, 2025 — 259 PRs, 100% Claude-written (trailing 30 days)

**Verdict: confirmed-primary.**

On both his X and Threads accounts on December 27, 2025, Cherny posted verbatim:
"In the last thirty days, I landed 259 PRs -- 497 commits, 40k lines added, 38k
lines removed. Every single line was written by Claude Code + Opus 4.5"
([@boris_cherny, Threads](https://www.threads.com/@boris_cherny/post/DSxC69PCCz_/fast-forward-to-today-in-the-last-thirty-days-i-landed-p-rs-commits-k-lines)).
A companion line states "100% of my contributions to Claude Code were written by
Claude Code." Simon Willison and a Hacker News thread
([item 46407967](https://news.ycombinator.com/item?id=46407967)) reproduce the
same text linking the original post.

Scope matters here. The "259 PRs / 100%" figure covers the trailing 30 days as
of December 27, 2025 (roughly late November to late December), and it is scoped
to *his own* contributions, not the entire Claude Code codebase. "Every single
line was written by Claude Code" describes authorship via the tool while he
prompted and looped, not hand-typing in an IDE — consistent with the same month
in which he did not open an editor.

## December 2025 — "didn't open an IDE at all"

**Verdict: confirmed-primary.**

In the same period, Cherny posted: "The last month was my first month as an
engineer that I didn't open an IDE at all"
([officechai recap](https://officechai.com/ai/claude-code-creator-says-he-didnt-open-an-ide-all-of-last-month-used-claude-code-for-all-his-coding/)).
This is the receipt directly supporting the November IDE-uninstall claim above.

## February 19, 2026 — Lenny's Podcast: throughput numbers, not the loop framing

**Verdict (productivity numbers): confirmed-primary. Verdict (4% commits stat):
confirmed-secondary.**

Lenny's Podcast ("Head of Claude Code: What happens after coding is solved,"
published Feb 19, 2026) is the source for Cherny's throughput and productivity
figures, *not* for the loop methodology. In it he says "I ship 10 to 20 to 30
Pull Requests every day," "I start about 80% of my tasks in plan mode," and
"Claude reviews 100% of the PRs"
([note.com transcript](https://note.com/ai_eng_tech/n/nf940a6dc47e6?hl=en)).
The "10 to 30 PRs/day" range is a first-party Cherny statement (confirmed-primary).

The widely repeated "4% of all GitHub commits are made by Claude Code" line is
**confirmed-secondary**: the figure originates with the third-party research firm
SemiAnalysis ("Claude Code is the Inflection Point") as a point-in-time estimate
(~early Feb 2026) of *public* commits with no published methodology
([SemiAnalysis](https://newsletter.semianalysis.com/p/claude-code-is-the-inflection-point)).
Cherny repeats it on the podcast, but he is citing SemiAnalysis, not presenting
Anthropic's own measurement.

This episode notably does **not** contain the "loop engineering" framing,
parallel-session counts, or autonomous channel-monitoring agents
([WorkOS recap](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)).
That separation is itself a **confirmed-secondary** finding: the proof that
Lenny's lacks those elements rests on a high-fidelity third-party transcript
because the official transcript is paywalled.

## March 7, 2026 — "Claude Code is 100% written by Claude Code"

**Verdict: confirmed-primary.**

On his verified X account, Cherny posted: "Can confirm Claude Code is 100%
written by Claude Code"
([officechai](https://officechai.com/ai/claude-code-is-now-100-written-by-claude-code-creator-boris-cherny/)).
This is a product-level statement (the codebase), distinct from his personal
claim about not hand-writing code. The exact text, date, and ~133K view count
are reproduced consistently across officechai, Fortune, and developing.dev. The
tweet itself returns HTTP 402 to automated fetches, so the wording is confirmed
through multiple independent verbatim quotations rather than a direct read.

The trajectory is internally consistent with his earlier primary statement that
"most of Claude Code is written using Claude Code... like 80 or 90%"
([developing.dev](https://www.developing.dev/p/boris-cherny-creator-of-claude-code)).
Cherny caveats that "100%" does not remove humans: "Someone has to prompt the
Claudes, talk to customers, coordinate with other teams, decide what to build
next."

## June 2026 — The "loops" framing goes public

**Verdict (the "I write loops" statement): confirmed-primary. Verdict (the named
"loop engineering" pattern): confirmed-secondary.**

The canonical loop statement comes from Cherny's June 2026 appearances, not from
the Lenny interview. At Acquired Unplugged, presented by WorkOS (June 2, 2026),
he said: "I don't prompt Claude anymore. I have loops that are running. They're
the ones that are prompting Claude and figuring out what to do. My job is to
write loops"
([medium write-up](https://medium.com/mountain-movers/what-a-loop-actually-is-boris-chernys-three-stage-definition-33dd2bfe01b3)).
The statement is **confirmed-primary** — it is his own on-record wording, also
captured in the Anthropic one-year video and his Sequoia AI Ascent appearance.

The **term** "loop engineering," and its four-part anatomy (scheduled execution,
isolated workspaces, verifier agents, persistent memory), is **confirmed-secondary**.
It was coined and systematized by third parties — Peter Steinberger and Google
engineer Addy Osmani — not by Cherny or Anthropic
([Addy Osmani](https://addyo.substack.com/p/loop-engineering),
[The New Stack](https://thenewstack.io/loop-engineering/)). The underlying
primitives (`/loop`, `/goal`, worktrees, CLAUDE.md, verification) trace to
primary Anthropic material; the named bundle is journalistic synthesis.

## June 11, 2026 — Fortune Brainstorm Tech: "eight months"

**Verdict: confirmed-primary.**

At Fortune Brainstorm Tech, Cherny said: "I haven't written a line of code by
hand in, I think, eight months now," and described managing "a few hundred AI
agents," occasionally "thousands or tens of thousands"
([Fortune](https://fortune.com/2026/06/11/anthropic-claude-boris-cherny-doesnt-write-code-by-hand-anymore/)).
The "eight months" back from June 2026 is consistent with the November 2025
start. Fortune also noted Anthropic's own blog cautioned the lines-of-code
productivity framing was "almost certainly an overstatement" — a useful hedge on
the headline numbers.

## Productivity figures: handle with care

Two different per-engineer productivity numbers appear in the corpus and they do
not match. Lenny's quotes "productivity per engineer has also increased by 200%"
(confirmed-primary as a quote)
([note.com](https://note.com/ai_eng_tech/n/nf940a6dc47e6?hl=en)), while
developing.dev quotes "almost 70% per engineer"
([developing.dev](https://www.developing.dev/p/boris-cherny-creator-of-claude-code)).
Both are Cherny's own statements from different venues; treat each as a
self-reported figure tied to its source rather than a single settled number.
