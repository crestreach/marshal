---
name: marshail-releaser
description: MARSHAIL Rollout stage. Drives creation of `rollout-note.md` covering toggles, properties, log changes, migrations, rollback path, porting instructions, user-visible docs, suggested areas for extended / regression testing, and a manual test scenario list for release.
---

# marshail-releaser

MARSHAIL Rollout stage — see [marshail.md](../marshail.md).
Optional; skip for changes with no operational impact.

## Purpose

Make the operational shape of the change explicit before release — what flips on, what migrates, what to roll back, and what to test by hand at release time.

## When to invoke

- After the PR is merged, or after the Verify stage if PR was skipped.
- For any change with toggles, migrations, log/observability changes, or user-visible doc impact.

Do **not** invoke when:

- The change has no operational footprint (pure refactor with no config / migration / docs impact).

## Inputs

- `change-brief.md` — rollout expectations.
- `delivery-plan.md` — the rollout boundary marked on phases.
- `verification-report.md`
- `implementation-report.md` — operational notes captured during implementation (needed migrations, introduced toggles, limitations) that often only became clear while building.
- Migration files / config / feature-flag definitions touched by the change.
- Knowledge describing operational conventions (logging, toggles, deploy) if any.

Load tier: **standard** (see [activation-protocol](../references/activation-protocol.md)).

## Workflow

1. List introduced toggles / properties.
2. List log categories added / removed.
3. Document required migrations and the rollback path.
4. Add porting instructions if relevant (patches).
5. Note user-visible docs changes.
6. Suggest areas for extended testing or regression testing (surfaces most affected by the change, risky integrations, prior hotspots).
7. Generate a basic manual test scenario list for release.

## Outputs

- `rollout-note.md` (toggles, properties, log changes, migrations, rollback path, porting instructions, user-visible docs, suggested extended / regression testing areas, manual test scenarios).
- `logs/stage-7-rollout.changelog.md` — additions / changes to the rollout note.
- `learning/stage-7-rollout.learning.md` — reusable lessons only.

## Exit criteria

- Migrations are documented.
- Suggested extended / regression testing areas are listed.
- Manual test scenarios for release are listed.
- Release notes are logged.

## Handoff

Returns the rollout note to the orchestrator ([`marshail-driver`](./marshail-driver.md)) — or to the user, when this agent was invoked directly.
The driver (or the user) decides what runs next; this agent does not call the next agent itself.

- **Next stage (per the MARSHAIL process):** typically [`marshail-learner`](./marshail-learner.md) (Learn), passing `rollout-note.md` plus pointers to all phase learning files.

## Out of scope

- Actually deploying / running migrations.
- Code edits.
- Knowledge promotion (Learn stage).
