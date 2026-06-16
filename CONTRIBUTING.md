# Contributing

Thanks for helping keep this knowledge base accurate. Please read this before opening a PR.

## 1. What this repo is

This is a **docs-only, fact-checked knowledge base** — no application code, no build, no
test suite. It documents Boris Cherny's "loop" methodology for running Claude Code.

Every claim carries a **verification verdict tag**:

- `confirmed-primary` — stated by Cherny / Cat Wu / Anthropic directly.
- `confirmed-secondary` — third-party coverage only.
- `disputed` — sources conflict.
- `unverifiable` — no source found either way.

These tags are load-bearing. **Preserve them when editing.** Never upgrade a tag to a
stronger verdict (e.g. secondary → primary) without adding a primary source.

## 2. Local setup

```sh
git clone git@github.com:cocodedk/loop-engineering.git
cd loop-engineering
./scripts/install-hooks.sh   # run once, after cloning
```

`install-hooks.sh` points Git at the tracked hooks in `.githooks/` (commit-msg enforces
Conventional Commits; pre-push protects `main` and the `cocodedk` remote).

## 3. Local Git setup

Run these once per clone so your local config matches the project's expectations:

```sh
git config pull.rebase true          # rebase instead of merge on pull
git config core.autocrlf input       # keep LF line endings (also enforced via .gitattributes)
git config push.autoSetupRemote true # auto-create the upstream branch on first push
```

## 4. How to propose changes

- **Never commit to `main`.** Branch first.
- Use **kebab-case** branch names with a prefix that matches the Conventional Commit
  type you'll use:
  - `docs/` — content additions or edits (most changes here).
  - `fix/` — correcting an inaccurate claim, broken link, or wrong tag.
  - `chore/` — tooling, config, housekeeping.
  - `refactor/` — restructuring files without changing the facts.
  - Examples: `docs/add-orchestration-notes`, `fix/correct-timeline-date`.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (enforced by the `commit-msg` hook).
- Push your branch and **open a pull request**. Do not push directly to `main`.

## 5. PR checklist

Before requesting review, confirm:

- [ ] Every **new claim cites a source** (link the primary source where one exists).
- [ ] The **verdict tag is correct** and was **not upgraded** without a primary source.
- [ ] Each touched file stays **under 200 lines**.
- [ ] All **markdown links resolve** (no dead internal or external links).
- [ ] Any **example loops use only documented Claude Code features** — no invented CLI
      flags — and stay labeled as illustrative.

The PR template repeats the core items; fill it in.

## 6. Hook caveats

- `core.hooksPath` is **per-clone** configuration — it is not committed and does not
  travel with the repo. **Every fresh clone must run `./scripts/install-hooks.sh`** or
  the hooks will not fire.
- `git push --no-verify` **bypasses the hooks entirely**. Don't use it to skip the
  Conventional Commit or protected-branch checks.
