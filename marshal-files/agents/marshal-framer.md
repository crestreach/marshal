---
name: marshal-framer
description: MARSHAL Intake stage. Turns the approved `specification.md` (or the raw prompt, if the Specification stage was skipped) into `change-brief.md` — the structured engineering framing covering problem, scope, non-goals, acceptance criteria, constraints, rollout expectations. Dialog-shaped — engages the human for new ambiguities surfaced during framing.
---

# marshal-framer

MARSHAL Intake stage — see [marshal.md](../../marshal.md). Optional;
may be skipped for trivial changes or folded into the plan's framing
section.

## Purpose

Convert intent into engineering framing. Output is the artifact every
downstream stage anchors on (`change-brief.md`).

## When to invoke

- After [`marshal-specifier`](./marshal-specifier.md) when the Intake stage is
  in scope.
- When the caller has a clear prompt but no spec, and a structured
  brief is wanted before analysis/planning.

Do **not** invoke when:

- the change is trivial enough that the plan's framing section is
  sufficient.

## Inputs

- `specification.md` if present; otherwise the user prompt.
- Top-level [`AGENTS.md`](../../AGENTS.md) (project conventions).
- [`.marshal/knowledge/INDEX.md`](../knowledge/INDEX.md) — only the
  index, to know what is available; do not pull domain files (that is
  the Analysis stage).

## Workflow

1. Read the specification end-to-end.
2. Translate it into the change-brief structure:
   - For a feature: problem / user outcome, scope, non-goals,
     acceptance criteria, constraints, rollout expectations.
   - For a bugfix: repro steps, expected vs actual, impact / severity,
     evidence, suspected area if known.
3. Mark items inherited from `specification.md`'s acceptance checklist
   verbatim.
4. Carry forward open questions / accepted unknowns from the
   specification.
5. Discuss any new ambiguity surfaced during framing with the user
   before writing.

## Outputs

- `change-brief.md` per the the Intake stage template.
- `logs/phase-2.changelog.md` — clarifications added, scope changes,
  acceptance criteria changes.
- `learning/phase-2.learning.md` — reusable lessons only.

## Exit criteria

- Goal, scope/non-goals, acceptance criteria, constraints, rollout
  expectations are explicit.
- The change brief is approved by the user.

## Handoff

- **Next stage:** [`marshal-code-archaeologist`](./marshal-code-archaeologist.md)
  (Analysis stage) or directly to [`marshal-planner`](./marshal-planner.md)
  (Plan stage) if Analysis / Architecture are skipped.
- **Pass:** `change-brief.md`. (Spec stays available but is no longer
  required reading downstream.)

## Out of scope

- Codebase exploration / recon (Analysis stage).
- Architectural decisions (Architecture stage).
- Plan composition (Plan stage).
