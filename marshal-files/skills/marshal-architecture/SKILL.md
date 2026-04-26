---
name: marshal-architecture
description: MARSHAL stage 3.5 (optional) - Architecture/design. Drives discussion or proposal of the implementation concept at the appropriate abstraction level(s) before planning. Captures decisions and rationale.
---

# marshal-architecture

MARSHAL stage 3.5 — see [marshal.md §3.5](../../../marshal.md). Optional.

## When to use

For larger or less-obvious topics. Skip when the shape of the solution
is already clear from intake + analysis.

## Prerequisites

- `change-brief.md` (if stage 2 was run) and `repo-recon.md` (if stage
  3 was run). At least one of these or an equivalent prompt-level
  framing is needed to ground the design discussion.

## Inputs (read at start)

- `change-brief.md`
- `repo-recon.md`
- Relevant knowledge files (especially
  [`repo/architecture.md`](../../knowledge/repo/architecture.md) and any
  affected `domains/<x>/` files).
- Existing ADRs under `.marshal/knowledge/decisions/`.

## Workflow

1. Either propose a design or facilitate the user's proposal.
2. Pick the abstraction level(s) needed (high-level components, module
   layout, APIs / schemas).
3. Discuss tradeoffs; record rationale as decisions are made.
4. Promote significant, durable decisions to ADRs under
   `.marshal/knowledge/decisions/` (via
   [`marshal-knowledge-maintain`](../marshal-knowledge-maintain/SKILL.md)
   if writing to the canonical tree).

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

- **Next skill:** [`marshal-plan`](../marshal-plan/SKILL.md).
- **Pass:** `architecture-notes.md` (alongside `change-brief.md` and
  `repo-recon.md`).

## Subagent

No dedicated v2 subagent — design dialog usually needs the human.
Orchestrated by [`marshal-driver`](../../agents/marshal-driver.md).
