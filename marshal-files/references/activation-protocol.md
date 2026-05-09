# Activation Protocol — reference

Shared by all `marshal-knowledge-*` skills.

## Read order (every fresh session)

1. Tool instruction file (synced from `.marshal/AGENTS.md`) → "read
   `.marshal/ENTRYPOINT.md`".
2. `.marshal/ENTRYPOINT.md` → "read `.marshal/knowledge/INDEX.md`".
3. `.marshal/knowledge/INDEX.md` → pick a topic index.
4. Topic `INDEX.md` → pick specific topic file(s).
5. Only if knowledge is missing or stale, invoke
   `marshal-knowledge-research` to gather a delta.

## Approval

`.marshal/config.yml` → `knowledge.autonomy`:

- `review` (default): every write produces a unified diff. Wait for the
  human's approval before applying. Group related edits into one diff.
- `auto`: write without per-change approval. Still log each write to
  `learn/inbox/` so it can be audited.

## Write discipline

- Never silently rewrite knowledge mid-task. Either:
  - propose a diff and wait, or
  - drop a delta into `learn/inbox/` for later promotion.
- Never write into `generated/` from a knowledge skill. That folder is
  produced only by mechanical generators (v1.5+).
- Always update `updated` and `verified_against_commit` when modifying a
  file's body.
- Always regenerate the affected `INDEX.md` after writes.
