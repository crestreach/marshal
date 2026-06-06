---
id: repo/conventions
kind: reference
summary: Naming, error shape, logging.
repo_paths:
  - "src/**"
parent: repo/INDEX
children: []
links: [repo/architecture]
importance: medium
confidence: high
updated: 2026-04-26
verified_against_commit: 0a3f75e
---

# Conventions

## Naming

- Files: `kebab-case.ts`.
  Symbols: `camelCase`.
  Types: `PascalCase`.
- Service functions are verbs: `createSnippet`, `getSnippet`, `listSnippetsByTag`.

## Error shape

- Service layer returns `Result<T, SnippetError>`-style discriminated unions.
  No throwing for expected errors.
- Unexpected errors throw and are caught by the top-level Express error handler; mapped to `500` with a generic body.
- HTTP error body: `{ error: { code: string, message: string } }`.

## Logging

- `pino` JSON logger.
  One log line per request at info level.
- Never log request bodies (may contain secrets in `code`).
- Always include `requestId` (generated in `src/server.ts` middleware).

## API keys

- Static map in env: `API_KEYS=key1,key2`.
  Validated in middleware.
- Treated as opaque tokens; no per-key authorization scopes (yet).
