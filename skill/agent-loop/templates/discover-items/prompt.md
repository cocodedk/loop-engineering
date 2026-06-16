# Discover items

Objective: {{OBJECTIVE}}

Enumerate the discrete items this objective must cover, then write them to
`{{OUTPUT}}` as JSON of the form:

    { "{{ITEMS_KEY}}": ["item one", "item two", ...] }

Be exhaustive but deduplicated. Each item should be the unit of work for one
downstream loop (one manual page, one screen, one endpoint, etc.). Do not start
the downstream work — only produce the list. Write the file at the workspace root.
