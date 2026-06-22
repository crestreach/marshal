---
id: domains/snippets/contracts
kind: contract
summary: HTTP and DB schemas for snippets.
repo_paths:
  - "src/routes/snippets.ts"
  - "src/db/migrations/001-snippets.sql"
parent: domains/snippets/INDEX
children: []
links: [domains/snippets/logic]
importance: high
confidence: high
updated: 2026-04-26
verified_against_commit: 0a3f75e
---

# Contracts

## HTTP

### `POST /snippets`

Request:

```json
{
  "language": "typescript",
  "code": "export const x = 1;",
  "tags": ["example", "ts"],
  "metadata": { "source": "docs" }
}
```

Response `201`:

```json
{ "id": "8c1b...", "createdAt": "2026-04-26T10:00:00Z" }
```

Errors: `400 invalid_payload`, `401 unauthorized`, `413 payload_too_large`.

### `GET /snippets/:id`

Response `200`:

```json
{ "id": "...", "language": "...", "code": "...", "tags": [...], "metadata": {...}, "createdAt": "..." }
```

Errors: `404 not_found`, `401 unauthorized`.

### `GET /snippets?tag=:tag&cursor=:cursor&limit=:n`

Response `200`:

```json
{ "items": [ /* snippet */ ], "nextCursor": "..." | null }
```

## DB

```sql
CREATE TABLE snippets (
  id          uuid PRIMARY KEY,
  language    text NOT NULL,
  code        text NOT NULL,
  tags        text[] NOT NULL DEFAULT '{}',
  metadata    jsonb  NOT NULL DEFAULT '{}'::jsonb,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX snippets_tags_gin    ON snippets USING gin (tags);
CREATE INDEX snippets_created_idx ON snippets (created_at DESC, id DESC);
```
