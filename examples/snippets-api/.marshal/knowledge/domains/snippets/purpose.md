---
id: domains/snippets/purpose
kind: explanation
summary: Why the snippets domain exists; what it owns.
repo_paths:
  - "src/services/snippets.ts"
  - "src/routes/snippets.ts"
parent: domains/snippets/INDEX
children: []
links: [domains/snippets/logic, domains/snippets/contracts]
importance: high
confidence: high
updated: 2026-04-26
verified_against_commit: 0a3f75e
---

# Purpose

The snippets domain stores small pieces of code with optional tags and
arbitrary metadata, and serves them back by id or tag.

## Owns

- The `snippets` table.
- All validation of snippet payloads.
- Tag normalization (lower-case, trim, dedupe).
- Cursor pagination over tag listings.

## Does not own

- Authentication (API key check is in route middleware, not here).
- Rate limiting (not implemented).
- Search beyond tag equality.
