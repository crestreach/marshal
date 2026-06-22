# snippets-api (example project)

Hypothetical project used to illustrate a MARSHAIL knowledge tree.

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

To show what `.marshail/knowledge/` looks like once the `marshail-knowledge-curator` subagent has run in `init` mode (via `marshail-delegate-to-knowledge-init` or its fallback `marshail-knowledge-init`) on a real-but-small repo.
Browse the tree below.

It also shows the **repo-specific extensions** and **override** a repo accumulates over time:

- [.marshail/extensions/rules/mx-snippets-error-shape.md](.marshail/extensions/rules/mx-snippets-error-shape.md) — a rule promoted by `marshail-learner` during the Learn stage.
- [.marshail/extensions/skills/mx-add-snippet-endpoint/SKILL.md](.marshail/extensions/skills/mx-add-snippet-endpoint/SKILL.md) — a repo-specific playbook skill drafted from recurring learnings.
- [.marshail/marshail-override.md](.marshail/marshail-override.md) — an example filled-in override (this file is empty in a fresh install).

Extensions are always `mx-`-prefixed at creation and live outside the built-in `marshail-*` assets, so they survive MARSHAIL upgrades.

## Knowledge tree

See [.marshail/knowledge/INDEX.md](.marshail/knowledge/INDEX.md).
