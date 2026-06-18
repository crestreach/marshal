---
id: repo/overview
kind: overview
summary: What the service does and its top-level shape.
repo_paths:
  - "src/**"
  - "package.json"
  - "README.md"
parent: repo/INDEX
children: []
links: [repo/architecture]
importance: high
confidence: high
updated: 2026-04-26
verified_against_commit: 0a3f75e
---

# Overview

`snippets-api` is a small HTTP service for creating and retrieving code snippets keyed by id and tag.

## Surface

- `POST /snippets` — create a snippet.
  Body: `{ language, code, tags?, metadata? }`.
- `GET  /snippets/:id` — fetch one.
- `GET  /snippets?tag=:tag` — list by tag (paginated, `cursor` query param).

All requests require `Authorization: Bearer <api-key>`.

## Top-level shape

- `src/server.ts` boots Express and wires routes.
- `src/routes/` — thin HTTP adapters; validate input, call services.
- `src/services/` — domain logic.
- `src/db/` — pg client + migrations.

There is exactly one domain: **snippets**.
There is no user / org modeling; api keys are static (see [conventions](conventions.md)).
