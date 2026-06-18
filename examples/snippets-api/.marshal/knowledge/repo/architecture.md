---
id: repo/architecture
kind: architecture
summary: Request flow - route -> service -> db. Boundaries and invariants.
repo_paths:
  - "src/routes/**"
  - "src/services/**"
  - "src/db/**"
parent: repo/INDEX
children: []
links: [repo/overview, domains/snippets/contracts]
importance: high
confidence: high
updated: 2026-04-26
verified_against_commit: 0a3f75e
---

# Architecture

## Layers

1. **Route layer** (`src/routes/`) — Express handlers.
   Responsibilities: parse + validate input, translate service results to HTTP, map known errors to status codes.
   **No domain logic.**
2. **Service layer** (`src/services/`) — domain logic.
   Pure with respect to HTTP. Talks to the DB through `src/db/client.ts`.
3. **DB layer** (`src/db/`) — `pg` client, parameterized queries, migrations.

## Invariants

- Routes never `import` from `src/db/` directly.
- Services never `import` from `express` types.
- All DB queries use parameterized statements; no string interpolation.
- Errors returned by services are typed (`SnippetError` union).

## Test seams

- Service unit tests use a fake `db.query` (see [build-test-run](build-test-run.md)).
- Route tests use `supertest` against the Express app with a stubbed service.
