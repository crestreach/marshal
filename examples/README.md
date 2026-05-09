# MARSHAL examples

Worked examples of MARSHAL knowledge trees on small, hypothetical projects.

These are not runnable apps — only the `.marshal/knowledge/` content is
filled in, to show the file format, frontmatter, indexes, and how the
pieces hang together. Use them as templates when running the
`marshal-knowledge-curator` subagent in `init` mode (or its
`marshal-delegate-to-knowledge-init` / `marshal-knowledge-init` skill
wrappers) on a real repo.

## Available examples

- [snippets-api/](snippets-api/) — a small Express + Postgres HTTP API
  for storing and retrieving code snippets. Single domain, one ADR.
