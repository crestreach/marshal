# snippets-api (example project)

Hypothetical project used to illustrate a MARSHAL knowledge tree.

## What the project is (imaginary)

A small HTTP API for storing and retrieving code snippets.

- **Stack:** Node.js 20, Express 4, PostgreSQL 15 (via `pg`), Jest.
- **Surface:** `POST /snippets`, `GET /snippets/:id`, `GET /snippets?tag=…`.
- **Auth:** API key in `Authorization: Bearer <key>` header.
- **Deployment:** Single container; one DB.

Source layout (also imaginary):

```text
src/
  server.ts
  routes/
    snippets.ts
  services/
    snippets.ts
  db/
    client.ts
    migrations/
test/
  snippets.test.ts
```

## Why this example exists

To show what `.marshal/knowledge/` looks like once the `marshal-knowledge-curator` subagent has run in `init` mode (via `marshal-delegate-to-knowledge-init` or its fallback `marshal-knowledge-init`) on a real-but-small repo.
Browse the tree below.

It also shows the **repo-specific extensions** and **override** a repo accumulates over time:

- [.marshal/extensions/rules/mx-snippets-error-shape.md](.marshal/extensions/rules/mx-snippets-error-shape.md) — a rule promoted by `marshal-learner` during the Learn stage.
- [.marshal/extensions/skills/mx-add-snippet-endpoint/SKILL.md](.marshal/extensions/skills/mx-add-snippet-endpoint/SKILL.md) — a repo-specific playbook skill drafted from recurring learnings.
- [.marshal/marshal-override.md](.marshal/marshal-override.md) — an example filled-in override (this file is empty in a fresh install).

Extensions are always `mx-`-prefixed at creation and live outside the built-in `marshal-*` assets, so they survive MARSHAL upgrades.

## Knowledge tree

See [.marshal/knowledge/INDEX.md](.marshal/knowledge/INDEX.md).
