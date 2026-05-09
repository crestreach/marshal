---
name: marshal-releaser
description: MARSHAL stage 6 (Rollout). Drives creation of `rollout-note.md` covering toggles, properties, log changes, migrations, rollback path, porting instructions, user-visible docs, and a manual test scenario list for release.
---

# marshal-releaser

MARSHAL stage 6 — see [marshal.md §6](../../marshal.md). Optional;
skip for changes with no operational impact.

## Purpose

Make the operational shape of the change explicit before release —
what flips on, what migrates, what to roll back, and what to test by
hand at release time.

## When to invoke

- After stage 5c (PR merged), or after stage 5b if PR was skipped.
- For any change with toggles, migrations, log/observability changes,
  or user-visible doc impact.

Do **not** invoke when:

- The change has no operational footprint (pure refactor with no
  config / migration / docs impact).

## Inputs

- `change-brief.md` — rollout expectations.
- `delivery-plan.md` — the rollout boundary marked on phases.
- `verification-report.md`
- Migration files / config / feature-flag definitions touched by the
  change.
- Knowledge files describing operational conventions (logging,
  toggles, deploy) if any.

## Workflow

1. List introduced toggles / properties.
2. List log categories added / removed.
3. Document required migrations and the rollback path.
4. Add porting instructions if relevant (patches).
5. Note user-visible docs changes.
6. Generate a basic manual test scenario list for release.

## Outputs

- `rollout-note.md` (toggles, properties, log changes, migrations,
  rollback path, porting instructions, user-visible docs).
- `logs/phase-rollout.changelog.md` — additions / changes to the
  rollout note.
- `learning/phase-release.learning.md` — reusable lessons only.

## Exit criteria

- Migrations are documented.
- Manual test scenarios for release are listed.
- Release notes are logged.

## Handoff

- **Next stage:** [`marshal-learner`](./marshal-learner.md) (stage 7).
- **Pass:** `rollout-note.md` plus pointers to all phase learning
  files.

## Out of scope

- Actually deploying / running migrations.
- Code edits.
- Knowledge promotion (stage 7).
