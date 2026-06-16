# Who Is Boris Cherny

Boris Cherny is the creator and Head of Claude Code at Anthropic. He is the central figure in the "loop engineering" topic because the methodology traces back to his own statements and his public, documented workflow: he says he no longer prompts Claude directly but instead writes loops that prompt Claude for him. Everything below is sourced from the research corpus, with verification status flagged where it matters.

## Role at Anthropic

Cherny holds the title Head of Claude Code at Anthropic. Note that at Anthropic everyone carries the same nominal title, "Member of Technical Staff," so "Head of Claude Code" describes his function rather than a formal HR title ([The Neuron](https://www.theneuron.ai/explainer-articles/claude-code-creators-boris-cherny-and-cat-wu-explain-how-to-use-agent-loops/)).

He is the person most associated with Claude Code being built largely by Claude Code. By his own first-party account, in the 30 days before December 27, 2025, he landed 259 pull requests (497 commits, 40k lines added, 38k removed), every line written by Claude Code on Opus 4.5 ([Threads](https://www.threads.com/@boris_cherny/post/DSxC69PCCz_/fast-forward-to-today-in-the-last-thirty-days-i-landed-p-rs-commits-k-lines)). This is **confirmed-primary**. He later posted "Can confirm Claude Code is 100% written by Claude Code" on March 7, 2026 ([@bcherny](https://x.com/bcherny/status/2030109840555790357)), also **confirmed-primary**.

## Career before Anthropic

Cherny spent about five years at Meta as a principal engineer before joining Anthropic. The "Programming TypeScript" authorship is **confirmed-primary** (O'Reilly is the publisher and Cherny lists it himself); the five-years-as-principal-engineer detail is corroborated across two interview-based outlets that draw directly from him, so it is treated as confirmed via primary interview sourcing rather than a verbatim self-quote ([Pragmatic Engineer](https://newsletter.pragmaticengineer.com/p/building-claude-code-with-boris-cherny)).

His own account of the Meta years: he joined under-leveled at IC4, which "gave me the space to explore and just build cool stuff for the sake of building cool stuff." His breakout project was "Chats in Groups," and he progressed to Principal (IC8), later leading large migrations (including a Python-to-Hack migration scoped for hundreds of engineers) and pivoting into Dev Infra at Instagram on the principle that "you can't build great products on a terrible foundation" ([developing.dev](https://www.developing.dev/p/boris-cherny-creator-of-claude-code)).

A career habit there prefigures loop engineering: he logged recurring code-review comments in a spreadsheet, and once a pattern recurred three or four times he wrote a lint rule to automate it away ([developing.dev](https://www.developing.dev/p/boris-cherny-creator-of-claude-code)). The instinct to turn repeated manual work into a durable, automated rule is the same instinct behind his "write it to CLAUDE.md or make a skill" practice today.

He is the author of O'Reilly's "Programming TypeScript: Making Your JavaScript Applications Scale" (2019), described on his own profile as "O'Reilly's first ever book on TypeScript" ([O'Reilly](https://www.oreilly.com/library/view/programming-typescript/9781492037644/colophon01.html)).

## The Cursor departure and return

In mid-2025 Cherny briefly left Anthropic to join Anysphere, the maker of Cursor, then returned about two weeks later. This is **confirmed-primary**.

His own framing: he left because he "was a huge fan of the product," then came back after two weeks because "what I really missed at Anthropic was the mission... It was about safety." The story is documented as a dedicated chapter ("Why Boris briefly left Anthropic for Cursor (and what brought him back)") in his Lenny's Podcast appearance, aired February 19, 2026 ([Lenny's Newsletter](https://www.lennysnewsletter.com/p/head-of-claude-code-what-happens)).

Independent corroboration came from the original reporting: The Information (July 16, 2025) reported that two leaders of Anthropic's coding product who had joined Cursor "two weeks ago have returned to Anthropic." Two clarifying notes on the simplified one-liner: the move was to Anysphere (Cursor's maker), and it was a joint departure-and-return with Cat Wu, not Cherny alone.

## Why he is the central figure

Cherny is central because he is both the originator of the underlying idea and the most-quoted practitioner of it. The canonical statement is his: "I don't prompt Claude anymore. I have loops that are running. They're the ones that are prompting Claude and figuring out what to do. My job is to write loops." That he made this statement on the record is **confirmed-primary**, attributed to his own appearances (the Acquired Unplugged talk presented by WorkOS on June 2, 2026, and a Sequoia AI Ascent 2026 interview), though the exact second-by-second transcript line was confirmed through uniform secondary transcription because the original video captions could not be read in-tool ([WorkOS](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways), [officechai](https://officechai.com/ai/i-now-just-write-loops-to-prompt-claude-code-claude-code-creator-boris-cherny/)).

Two sourcing corrections matter for anyone tracing the topic to its roots:

- The term "loop engineering" is a third-party label, not Cherny's coinage. He used the verb form ("my job is to write loops"); the "-engineering" framing was applied by commentators such as Peter Steinberger and Addy Osmani, modeled on "prompt engineering" and "context engineering" ([The New Stack](https://thenewstack.io/loop-engineering/), [Addy Osmani](https://addyosmani.com/blog/loop-engineering/)).
- The loop methodology does **not** come from the Lenny's Podcast interview. That interview is the source for his throughput and productivity numbers; the loops material comes from his January 2026 X thread and his June 2026 Acquired Unplugged / Sequoia talks. The Lenny episode contains no "loops" framing, no parallel-session counts, and no autonomous channel-monitoring agents (**confirmed-secondary**, since Lenny's transcript is paywalled and the absence-proof rests on a high-fidelity third-party transcript) ([WorkOS](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)).

## The evolution he describes

Cherny frames his own progression in three stages (**confirmed-primary**, from the Acquired Unplugged talk): (1) hand-writing code with IDE autocomplete; (2) running roughly 5 to 10 Claude sessions in parallel that he prompted manually; (3) writing loops that prompt Claude autonomously, with a couple hundred agents reading his GitHub, Slack, and Twitter to decide what to build next ([WorkOS recap, via YouTube event](https://www.youtube.com/watch?v=RkQQ7WEor7w), [Medium](https://medium.com/mountain-movers/what-a-loop-actually-is-boris-chernys-three-stage-definition-33dd2bfe01b3)).

Supporting receipts, all his own first-person statements:

- He stopped editing code by hand and uninstalled his IDE after Opus 4.5 shipped in late November 2025 (**confirmed-primary**). His exact verb is "uninstalled," not "deleted," and he anchors the timing to "after 4.5 came out... back in November" rather than naming the month directly; Opus 4.5 released November 24, 2025 ([@bcherny](https://x.com/bcherny/status/2064431111154053187)).
- He ships 10 to 30 PRs every day (**confirmed-primary**, self-reported on the podcast) ([Threads](https://www.threads.com/@boris_cherny/post/DSxC69PCCz_/fast-forward-to-today-in-the-last-thirty-days-i-landed-p-rs-commits-k-lines)).
- By June 2026 he said he hadn't written a line of code by hand in about eight months and described managing a few hundred (sometimes thousands of) agents ([Fortune](https://fortune.com/2026/06/11/anthropic-claude-boris-cherny-doesnt-write-code-by-hand-anymore/)).

## Numbers to treat with care

Some widely-cited figures are weaker than the personal-workflow claims. The statistic that Claude Code accounts for roughly 4% of all public GitHub commits is **confirmed-secondary**: it originates from the research firm SemiAnalysis (no published methodology, a point-in-time estimate around early February 2026, public commits only), and Cherny repeated it on the podcast while explicitly citing that report rather than Anthropic's own data ([SemiAnalysis](https://newsletter.semianalysis.com/p/claude-code-is-the-inflection-point)). Fortune also noted Anthropic's own blog cautioned that the lines-of-code productivity framing was "almost certainly an overstatement" ([Fortune](https://fortune.com/2026/06/11/anthropic-claude-boris-cherny-doesnt-write-code-by-hand-anymore/)). His own caveat keeps humans in the picture: "Someone has to prompt the Claudes, talk to customers, coordinate with other teams, decide what to build next" ([officechai](https://officechai.com/ai/claude-code-is-now-100-written-by-claude-code-creator-boris-cherny/)).
