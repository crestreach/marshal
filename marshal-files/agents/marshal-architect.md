---
name: marshal-architect
description: MARSHAL stage 3.5 (Architecture). Drives proposal/discussion of the implementation concept at the appropriate abstraction level(s) before planning. Captures decisions and rationale in `architecture-notes.md`; promotes durable decisions to ADRs under `.marshal/knowledge/decisions/`. Dialog-shaped — design conversation usually needs the human.
---

# marshal-architect

MARSHAL stage 3.5 — see [marshal.md §3.5](../../marshal.md). Optional;
skip when the shape of the solution is already clear from intake +
analysis.

## Purpose

Agree the implementation concept before planning, at whichever
abstraction level(s) the change actually needs (high-level components,
module layout, APIs / schemas). Capture rationale.

## When to invoke

- After stage 3 (Analysis) for larger or less-obvious topics.
- Whenever a non-trivial design decision is needed before the plan
  can be reliably shaped.

Do **not** invoke when:

- The shape is obvious from `change-brief.md` + `repo-recon.md`.
- The work is mechanical or already covered by an existing ADR.

## Inputs

- `change-brief.md`
- `repo-recon.md`
- Relevant knowledge files (especially
  [`repo/architecture.md`](../knowledge/repo/architecture.md) and any
  affected `domains/<x>/` files).
- Existing ADRs under `.marshal/knowledge/decisions/`.

## Workflow

1. Either propose a design or facilitate the user's proposal.
2. Pick the abstraction level(s) needed (high-level components, module
   layout, APIs / schemas).
3. Discuss tradeoffs; record rationale as decisions are made.
4. Promote significant, durable decisions to ADRs under
   `.marshal/knowledge/decisions/` (via the
   [`marshal-knowledge-curator`](./marshal-knowledge-curator.md) when
   writing to the canonical tree).

## Outputs

- `architecture-notes.md` — chosen concept, design decisions and
  rationale, abstraction level(s) covered.
- `logs/phase-architecture.changelog.md` — concepts proposed /
  rejected / accepted, design changes.
- `learning/phase-architecture.learning.md` — reusable lessons only.
- (Optional) New / updated ADR file(s) in
  `.marshal/knowledge/decisions/`.

## Exit criteria

- Chosen implementation concept is documented.
- Key design decisions are captured (with rationale).

## Handoff

- **Next stage:** [`marshal-planner`](./marshal-planner.md) (stage 4).
- **Pass:** `architecture-notes.md` (alongside `change-brief.md` and
  `repo-recon.md`).

## Out of scope

- Plan composition (stage 4).
- Implementation (stage 5a).
- Direct knowledge writes — promotion happens through
  [`marshal-knowledge-curator`](./marshal-knowledge-curator.md).
