---
name: marshal-planner
description: MARSHAL stage 4 (Plan). Synthesizes `delivery-plan.md` from change brief, repo recon, and optional architecture notes, at the requested target depth (L1..L4, may vary per area; agent picks shallowest workable depth unless the user pins one) and timing mode (full / staged / mixed). Marks review, PR, and rollout boundaries. Stage 4 is mandatory in MARSHAL — every change has a plan.
---

# marshal-planner

MARSHAL stage 4 — see [marshal.md §4](../../marshal.md). **Mandatory.**
Every change has a plan, even if it is a single phase with a single
step; implementation never proceeds without it.

## Purpose

Run MARSHAL stage 4 (Plan). Especially valuable for large changes or
for staged plans that get deepened phase by phase, where keeping plan
synthesis isolated from implementation context improves quality.

## When to invoke

- After stage 3 (Analysis) — and stage 3.5 (Architecture) if used.
- Directly from a prompt for trivial changes where upstream stages are
  skipped.
- Mid-change, to deepen a previously high-level phase before
  implementation begins on it.

Do **not** invoke when:

- Implementation is the goal — call
  [`marshal-implementer`](./marshal-implementer.md).
- The plan exists, is at the right depth, and only needs verification —
  call [`marshal-verifier`](./marshal-verifier.md).

## Inputs

- Whichever upstream artifacts exist (`specification.md`,
  `change-brief.md`, `repo-recon.md`, `architecture-notes.md`).
- Planning timing mode: `full` | `staged` | `mixed`.
- Target depth (optional): may be pinned by the user (e.g. "L2",
  "L4 in P1, L2 elsewhere"). If not pinned, the planner picks the
  shallowest depth that still makes the next implementation cycle
  unambiguous and surfaces the choice for approval.
- Optional: an existing `delivery-plan.md` to deepen / amend.
- Relevant knowledge files for affected domains.

## Workflow

1. **Agree run scope first.** With the user, confirm which MARSHAL
   stages will be run vs. skipped for this change (sized to its
   complexity). Record the chosen scope as the first lines of
   `delivery-plan.md` (e.g. `Scope: stages 4, 5a, 5b skipped: 1, 2, 3,
   3.5, 5c, 6, 7`).
2. Agree planning **target depth** and **timing mode**:
   - Target depth: L1 / L2 / L3 / L4. May vary per area. If the user
     does not pin a depth, propose the shallowest depth that still
     makes the next implementation cycle unambiguous, and confirm.
   - Timing mode: `full` | `staged` | `mixed`.
   - Capture both choices in `delivery-plan.md`.
3. Define L1 phases / slices for the whole change (single phase is
   fine for small work).
4. Deepen each area only as far as the agreed target depth requires:
   - L2 work packets where target ≥ L2.
   - L3 steps where target ≥ L3.
   - L4 implementation detail only where target = L4 (shared
     contracts, migrations, concurrency, security, or anywhere the
     user explicitly asked for it).
5. Annotate review / PR / rollout boundaries.
6. Mark safe parallelism with `<~Tn>` tags where useful.
7. Note explicitly what is left at staged depth and will be deepened
   later.

## Outputs

- `delivery-plan.md` per the stage 4 template (Scope line, then
  Planning mode + Target depth lines, then P1.* phases; W*.* packets,
  S*.* steps, and I*.* implementation steps appear only at the depths
  the plan actually goes to).
- `logs/phase-4.changelog.md` — plan additions / removals, packet
  splits / merges, dependency changes, boundary changes.
- `learning/phase-4.learning.md` — reusable lessons only.

## Exit criteria

- Plan is approved to the agreed target depth (which may stop above
  L4 — or above L2/L3 — for simple work).
- Review / PR / rollout boundaries explicit.
- Parallelizable items marked where useful.
- Where target depth varies per area, that variation is recorded so
  the implementer knows where to expect detail.

## Handoff

- **Next stage:** [`marshal-implementer`](./marshal-implementer.md)
  (stage 5a).
- **Pass:** `delivery-plan.md` (plus the upstream artifacts as
  reference).
- **Staged plans:** invoke this agent again to deepen a phase
  **before** its implementation cycle starts. Log the deepening to
  the affected phase changelog; do not treat it as a replan.
- **Replanning:** for replanning during stage 5a, the planner can be
  reinvoked on the affected phase only.

## Delegation / handoff contract

- Returns a draft plan or patch. Does not start implementation.

## Out of scope

- Coding (handled by [`marshal-implementer`](./marshal-implementer.md)).
- Verification (handled by [`marshal-verifier`](./marshal-verifier.md)).
