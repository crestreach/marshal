---
name: mx-add-snippet-endpoint
description: Repo-specific playbook for adding a new HTTP endpoint to snippets-api. Delegate when the user asks to "add an endpoint", "expose a new route", "add POST/GET /snippets/...", or similar. Encodes this repo's route → service → db layering, error shape, and test expectations so a new endpoint is consistent with the existing ones.
---

# mx-add-snippet-endpoint

Repo extension skill drafted by `marshal-learner` from recurring learnings
about how endpoints are added in this codebase. `mx-`-prefixed because it is
a repo-specific extension, not a built-in MARSHAL skill.

## When to apply

The user wants to add or change an HTTP endpoint in snippets-api.

## Workflow

1. Add the route in `src/routes/snippets.ts`; keep handlers thin — parse and
   delegate to a service function.
2. Implement the logic in `src/services/snippets.ts` as a verb-named function
   returning a `Result<T, SnippetError>` (see the `mx-snippets-error-shape`
   rule).
3. Touch the database only through `src/db/client.ts`; add a migration under
   `src/db/migrations/` if the schema changes.
4. Add a test in `test/snippets.test.ts` covering the happy path and each
   expected error `code`.
5. Update the relevant knowledge under `.marshal/knowledge/domains/snippets/`
   if a contract or invariant changed.

## Output

A new endpoint wired route → service → db, with tests and refreshed
knowledge, consistent with the existing snippets-api conventions.
