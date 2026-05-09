---
id: decisions/adr-0001-postgres-jsonb
kind: decision
summary: Use Postgres jsonb for snippet metadata instead of a sidecar table.
repo_paths:
  - "src/db/migrations/001-snippets.sql"
  - "src/services/snippets.ts"
parent: null
children: []
links: [domains/snippets/logic, domains/snippets/contracts]
importance: medium
confidence: high
updated: 2026-04-26
verified_against_commit: 0a3f75e
---

# ADR-0001 — Use Postgres `jsonb` for snippet metadata

## Status

Accepted.

## Context

Snippet metadata is open-ended (source tool, author, project, etc.) and
neither queried nor enforced beyond size limits. A sidecar
`snippet_metadata(snippet_id, key, value)` table would add joins for no
read benefit.

## Decision

Store `metadata` as a single `jsonb` column on `snippets`. Cap serialized
size at 4 KiB (enforced in service layer). No GIN index on `metadata`
yet — add only when a real query pattern emerges.

## Consequences

- Reads return metadata in one row; no join.
- Schema migrations for new metadata fields are unnecessary.
- Querying *into* metadata will require either an index later or
  application-side filtering. Acceptable for the current scope.
