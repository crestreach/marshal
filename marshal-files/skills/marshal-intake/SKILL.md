---
name: marshal-intake
description: MARSHAL stage 2 (optional) - Intake/framing. Turns the approved specification.md (or the raw prompt, if specification was skipped) into change-brief.md, the structured engineering framing (problem, scope, non-goals, acceptance criteria, constraints, rollout expectations).
---

# marshal-intake

MARSHAL stage 2 — see [marshal.md §2](../../../marshal.md). Optional;
may be skipped for trivial changes or folded into the plan's framing
section.

## Prerequisites

- Either `specification.md` (from stage 1) **or** a clear user prompt
  if stage 1 was skipped.

## Inputs (read at start)

- `specification.md` if present; otherwise the user prompt.
- Top-level [`AGENTS.md`](../../../AGENTS.md) (project conventions, if
  any).
- [`.marshal/knowledge/INDEX.md`](../../knowledge/INDEX.md) — only the
  index, to know what is available; do not pull domain files yet (that
  is stage 3).

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

- `change-brief.md` per the stage 2 template.
- `logs/phase-2.changelog.md` — clarifications added, scope changes,
  acceptance criteria changes.
- `learning/phase-2.learning.md` — reusable lessons only.

## Exit criteria

- Goal, scope/non-goals, acceptance criteria, constraints, rollout
  expectations are explicit.
- The change brief is approved by the user.

## Handoff

- **Next skill:** [`marshal-analysis`](../marshal-analysis/SKILL.md).
- **Pass:** `change-brief.md`. (Spec stays available but is no longer
  required reading downstream.)

## Subagent

Stage 2 is dialog-shaped and stays in the main context (no v2 subagent
candidate). Orchestrated by
[`marshal-driver`](../../agents/marshal-driver.md).
