---
name: marshal-plan
description: MARSHAL stage 4 (mandatory) - Plan/shape. Builds the executable delivery-plan.md to whatever depth (L1..L4) the change actually needs, defaulting to the shallowest depth that still makes the next implementation cycle unambiguous, unless the user pins a target depth. Picks a timing mode (full / staged / mixed). Marks review, PR, and rollout boundaries. The plan is the canonical source of truth for the change.
---

# marshal-plan

MARSHAL stage 4 — see [marshal.md §4](../../../marshal.md). **Mandatory.**
Every change has a plan, even if it is a single phase with a single
step; implementation never proceeds without it.

## Prerequisites

- At least one of: `specification.md`, `change-brief.md`, or a clear
  user prompt. Upstream stages are optional, so the plan may be built
  directly from the prompt for trivial changes.
- `repo-recon.md` if stage 3 was run.
- `architecture-notes.md` if stage 3.5 was run.

## Inputs (read at start)

- Whichever upstream artifacts exist (`specification.md`,
  `change-brief.md`, `repo-recon.md`, `architecture-notes.md`).
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

- **Next skill:** [`marshal-implement`](../marshal-implement/SKILL.md).
- **Pass:** `delivery-plan.md` (plus the upstream artifacts as
  reference).
- For staged plans: invoke this skill again to deepen a phase **before**
  its implementation cycle starts. Log the deepening to the affected
  phase changelog; do not treat it as a replan.

## Subagent

Strong v2 candidate: [`marshal-planner`](../../agents/marshal-planner.md)
runs this in fresh context, especially valuable for large changes or
phase-by-phase deepening of a staged plan.
