# Produce one item

Objective: {{OBJECTIVE}}
This loop handles exactly one item: **{{ITEM}}**

Produce the deliverable for this item only, and write it to:

    state/{{STAGE}}/{{SLUG}}.md

Keep it self-contained and complete for this one item. Do not touch other items'
files. If you need shared context, read other files under `state/` read-only.

If producing this item forces a choice the objective doesn't specify, append what
you chose and why to `state/{{STAGE}}/{{SLUG}}.decisions.md` (never a shared file —
other items' workers run in parallel).
