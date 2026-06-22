# MARSHAIL override (snippets-api example)

Example of a filled-in `.marshail/marshail-override.md` in a consumer repo.
In a real repo this file starts empty (an empty file means "no overrides"); here it is populated to show the shape of repo-specific adjustments on top of [`marshail.md`](marshail.md).

## Stage policy

- The **Plan** stage is mandatory (as always).
  The **Specification** stage is also mandatory in this repo — every change starts from an agreed `specification.md`, because endpoints are externally visible.
- The **Rollout** stage is always run for schema-affecting changes; its `rollout-note.md` must include the rollback data-handling plan.

## Artifact policy

- `repo-recon.md` must include a "Database migrations" section whenever `src/db/migrations/` is touched.
- `delivery-plan.md` must list every touched HTTP route explicitly.

## Knowledge policy

- `knowledge.autonomy` stays `auto`; the knowledge layer is agent-managed.
  Switch to `review` only for a structural rebuild.
