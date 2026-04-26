---
name: marshal-analysis
description: MARSHAL stage 3 (optional) - Research/analysis. Narrows the repo search surface, identifies likely files/services/contracts, captures invariants, locates test seams, and explicitly excludes irrelevant areas. Produces repo-recon.md.
---

# marshal-analysis

MARSHAL stage 3 — see [marshal.md §3](../../../marshal.md). Optional;
may be skipped when the surface is already known or covered by the
knowledge layer.

## Prerequisites

- `change-brief.md` if stage 2 was run; otherwise the user prompt and
  whatever framing exists.

## Inputs (read at start)

- `change-brief.md`
- [`.marshal/knowledge/INDEX.md`](../../knowledge/INDEX.md), then
  selectively descend into topic indexes whose `repo_paths` plausibly
  intersect the brief (`repo/`, `domains/<x>/`, `decisions/`).
- Read-only access to the repo for targeted code reads.

## Workflow

1. Read the change brief. Extract concrete touch points (entities,
   APIs, behaviors named in scope and acceptance criteria).
2. Pull relevant knowledge files first; let them narrow the search
   surface.
3. If a needed topic is missing or stale, invoke
   [`marshal-knowledge-research`](../marshal-knowledge-research/SKILL.md)
   for that topic (consume the returned delta inline; do **not** write
   to the knowledge tree from here).
4. Walk likely code paths: entry points → services → data → tests.
   Use semantic-aware tools; avoid loading unrelated areas.
5. Identify invariants, contracts, test seams, unknowns / risks.
6. **Explicitly exclude** irrelevant areas to avoid context pollution
   in stage 4.

## Outputs

- `repo-recon.md` per the stage 3 template (likely bounded context;
  files / classes / services / tables / APIs; invariants and
  contracts; existing tests and test seams; unknowns / risks; excluded
  areas).
- `logs/phase-3.changelog.md` — files inspected, assumptions confirmed
  / rejected, narrowed search surface.
- `learning/phase-3.learning.md` — reusable lessons only.

## Exit criteria

- Likely change surface identified.
- Key invariants/contracts captured.
- Unknowns explicit.
- Planning can proceed without broad repo search.

## Handoff

- **Next skill:** [`marshal-architecture`](../marshal-architecture/SKILL.md)
  (optional) or [`marshal-plan`](../marshal-plan/SKILL.md).
- **Pass:** `repo-recon.md` plus `change-brief.md`.
- **Side effects to surface:** any knowledge files flagged stale during
  reading; pass the list to the caller for later
  `marshal-knowledge-maintain` invocation.

## Subagent

Strong v2 candidate:
[`marshal-code-archaeologist`](../../agents/marshal-code-archaeologist.md)
runs this skill in fresh context and returns just the draft
`repo-recon.md` plus the stale-knowledge list, keeping intermediate
exploration out of the parent context.
