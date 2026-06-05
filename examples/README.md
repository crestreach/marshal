# MARSHAL examples

Worked examples of MARSHAL on small, hypothetical projects.

These are not runnable apps. They fill in the durable `.marshal/` assets — the
agent-managed `.marshal/knowledge/` tree, plus repo-specific
`.marshal/extensions/` and a sample `.marshal/marshal-override.md` — to show
the file formats, frontmatter, indexes, and how the pieces hang together. Use
them as templates when running the `marshal-knowledge-curator` subagent in
`init` mode (or its `marshal-delegate-to-knowledge-init` /
`marshal-knowledge-init` skill wrappers) on a real repo, and as a reference
for what a repo accumulates as MARSHAL learns.

## Available examples

- [snippets-api/](snippets-api/) — a small Express + Postgres HTTP API
  for storing and retrieving code snippets. Single knowledge domain, one ADR,
  one learned extension rule, one extension skill, and a filled-in override.
