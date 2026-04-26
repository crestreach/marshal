---
name: marshal-implement
description: MARSHAL stage 5a - Implement. Drives implementation cycles inside the implementation round. Picks a target (phase / packet / step), confirms or deepens the plan, executes (code + tests + Dev-QA where possible), and closes the cycle by updating statuses, tests, and changelogs.
---

# marshal-implement

MARSHAL stage 5a — see [marshal.md §5a](../../../marshal.md).

## Prerequisites

- Stage 4 complete: `delivery-plan.md` exists and is approved to at
  least the depth needed for the next target.
- Whichever upstream artifacts the plan references exist (typically
  `change-brief.md` and `repo-recon.md`, but they are optional).

- `delivery-plan.md` — the source of truth for the work.
- `change-brief.md` — for acceptance criteria reference, if it exists.
- Relevant knowledge files for the affected `repo_paths` (pulled
  selectively; do not preload).
- The target item the user / driver picked (phase / packet / step).

## Workflow (per cycle)

1. Pick the cycle target.
2. Confirm the plan is accurate **and detailed enough**. If staged
   planning left this item shallow, hand back to
   [`marshal-plan`](../marshal-plan/SKILL.md) to deepen before
   continuing.
3. Execute: write code, write or update tests, run Dev-QA where
   possible (per marshal.md §5a Testing strategy).
4. Apply review feedback if a conversational review happens during the
   cycle.
5. Close the cycle:
   - Update plan status markers (`[IN PROGRESS]` / `[DONE]` etc.).
   - Append entries to `logs/phase-N.changelog.md` (where N is the L1
     phase number from the delivery plan, **not** the stage number).
   - Add reusable lessons to `learning/phase-N.learning.md`.
6. After the cycle, if code under tracked `repo_paths` changed, hand
   off to
   [`marshal-knowledge-maintain`](../marshal-knowledge-maintain/SKILL.md)
   mode `from-changes`.

## Outputs

- Code + tests committed against the plan.
- Updated `delivery-plan.md` (status markers, [FIXUP] / [ADDED] /
  [CHANGED] / [REVERT] / [DROPPED] entries with dates).
- `logs/phase-N.changelog.md` (per L1 phase).
- `learning/phase-N.learning.md` (per L1 phase).

## Exit criteria (per work packet)

- Acceptance criteria met.
- Plan status updated.
- Tests added / updated.
- Changelog entry written.

## Handoff

- **Within the round:** when all packets in the current PR boundary are
  done → [`marshal-verify`](../marshal-verify/SKILL.md). Pass:
  `delivery-plan.md`, `change-brief.md`, list of changed files / tests.
- **Knowledge upkeep after cycle:**
  [`marshal-knowledge-maintain`](../marshal-knowledge-maintain/SKILL.md)
  mode `from-changes`. Pass: list of changed paths or a git diff range.
- **Replanning:** if assumptions break, hand back to
  [`marshal-plan`](../marshal-plan/SKILL.md) for the affected phase
  before continuing.

## Subagent

No v2 subagent — implementation should stay in the main context where
the human is engaged.
