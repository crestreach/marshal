# MARSHAIL examples

Worked examples of MARSHAIL on small, hypothetical projects.

These are not runnable apps.
They fill in the durable `.marshail/` assets — the agent-managed `.marshail/knowledge/` tree, plus repo-specific `.marshail/extensions/` and a sample `.marshail/marshail-override.md` — to show the file formats, frontmatter, indexes, and how the pieces hang together.
Use them as templates when running the `marshail-knowledge-curator` subagent in `init` mode (or its `marshail-delegate-to-knowledge-init` / `marshail-knowledge-init` skill wrappers) on a real repo, and as a reference for what a repo accumulates as MARSHAIL learns.

## Available examples

- [snippets-api/](snippets-api/) — a small Express + Postgres HTTP API for storing and retrieving code snippets.
  Single knowledge domain, one ADR, one learned extension rule, one extension skill, and a filled-in override.
