---
name: marshal-rollout
description: MARSHAL stage 6 (optional) - Release/rollout. Drives creation of rollout-note.md covering toggles, properties, log changes, migrations, rollback path, porting instructions, user-visible docs, and a manual test scenario list for release.
---

# marshal-rollout

MARSHAL stage 6 — see [marshal.md §6](../../../marshal.md). Optional;
skip for changes with no operational impact.

## Prerequisites

- Stage 5c complete (if PR was in scope): relevant PR(s) merged. If PR
  was skipped, the implemented change is otherwise integrated.

## Inputs (read at start)

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

- **Next skill:** [`marshal-learn`](../marshal-learn/SKILL.md).
- **Pass:** `rollout-note.md` plus pointers to all phase learning files.

## Subagent

No dedicated v2 subagent.
