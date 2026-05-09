---
id: domains/snippets/logic
kind: reference
summary: Business rules and invariants for snippets.
repo_paths:
  - "src/services/snippets.ts"
parent: domains/snippets/INDEX
children: []
links: [domains/snippets/contracts, decisions/adr-0001-postgres-jsonb]
importance: high
confidence: high
updated: 2026-04-26
verified_against_commit: 0a3f75e
---

# Logic

## Creation

- `code` is required, non-empty, ≤ 64 KiB after trim.
- `language` is required, must match `^[a-z][a-z0-9+-]{0,31}$`.
- `tags` optional; each tag normalized to lower-case, trimmed, deduped;
  empty tags rejected.
- `metadata` optional; arbitrary JSON ≤ 4 KiB serialized; stored as
  `jsonb` (see [ADR-0001](../../decisions/adr-0001-postgres-jsonb.md)).
- `id` is a UUID v4 generated server-side.

## Retrieval

- `getSnippet(id)` returns `NotFound` if no row.

## Listing by tag

- `listSnippetsByTag(tag, cursor?, limit=20)`.
- Cursor is the opaque base64 of `(created_at, id)` of the last seen row.
- `limit` clamped to `[1, 100]`.

## Invariants

- A snippet row is immutable once created (no `PATCH /snippets/:id`).
- `tags` are stored as a Postgres `text[]` and indexed with GIN.
- `created_at` is server-set, never client-set.
