---
id: repo/build-test-run
kind: guide
summary: Local dev, tests, migrations.
repo_paths:
  - "package.json"
  - "src/db/migrations/**"
  - "test/**"
parent: repo/INDEX
children: []
links: []
importance: medium
confidence: high
updated: 2026-04-26
verified_against_commit: 0a3f75e
---

# Build, test, run

## Prereqs

- Node 20+, pnpm 9+, Postgres 15 reachable at `$DATABASE_URL`.

## Run

```sh
pnpm install
pnpm db:migrate
pnpm dev          # starts on :3000
```

## Test

```sh
pnpm test         # jest, all suites
pnpm test:unit    # services only, no DB
pnpm test:int     # routes + db, requires Postgres
```

Service unit tests pass an in-memory fake `db` object that satisfies `{ query(sql, params): Promise<{ rows: T[] }> }`.
Route tests use `supertest` and a stubbed service.

## Migrations

- Plain SQL files under `src/db/migrations/NNN-<name>.sql`.
- Applied by `pnpm db:migrate` (uses `node-pg-migrate`).
- Down migrations are not maintained — forward-only.
