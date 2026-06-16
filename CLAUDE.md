# loop-engineering

A documentation-only knowledge base on **Boris Cherny's "loop" methodology** for running
Claude Code (popularized by third parties as *"loop engineering"*). No source code — this
project is a curated, fact-checked research deliverable.

## Structure

- `README.md` — thesis, TL;DR, and index into `docs/`.
- `docs/01..11-*.md` — one focused topic per file (who, the loop, three stages, anatomy,
  verification/memory, orchestration/tooling, receipts/timeline, how-to-apply, example
  loops, sources, caveats).

## Conventions

- Every file stays under 200 lines (see `~/.claude-shared/CLAUDE.md`).
- Claims are tagged by verification verdict: **confirmed-primary** (Cherny / Cat Wu /
  Anthropic directly), **confirmed-secondary** (third-party coverage only),
  **disputed**, or **unverifiable**. Preserve these tags when editing.
- Example loops in `docs/09` must use **only documented Claude Code features** and stay
  labeled as illustrative. Do not invent CLI flags; confirm against current docs.
- Do not upgrade a secondary claim to primary without a primary source.

## Provenance

Compiled 2026-06-16 via a multi-agent research → adversarial-verify → synthesize workflow.
Primary inputs: Cherny's own X/Threads posts, his Sequoia AI Ascent / Acquired Unplugged /
Anthropic talks, The Pragmatic Engineer and developing.dev interviews, and Anthropic's
Claude Code docs. See `docs/10-sources.md` for the full annotated bibliography.
