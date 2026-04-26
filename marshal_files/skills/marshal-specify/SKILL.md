---
name: marshal-specify
description: MARSHAL stage 1 (optional) - Specification / clarify. Works with the user on their raw prompt to produce specification.md - the agreed restatement of intent plus open questions, agent concerns, and an optional acceptance checklist. Never assumes; clarifies first.
---

# marshal-specify

MARSHAL stage 1 — see [marshal.md §1](../../../marshal.md). Optional;
may be skipped for trivial changes or when the prompt is already
unambiguous.

## Goal

Take the user's raw prompt and produce an agreed `specification.md` that
the rest of the MARSHAL pipeline can rely on. Drive a clarification
dialog rather than guessing.

## Prerequisites

- A user prompt describing the desired change (feature / bugfix /
  refactor / tech-debt). Nothing else is required.
- Repo with `.marshal/` initialized (so changelog/learning files have a
  home).

## Inputs (read at start)

- The user's prompt (in the conversation).
- Optional: pointers the user provides to existing context (issues,
  prior briefs, screenshots).
- Optional: `.marshal/knowledge/INDEX.md` only if the prompt references
  parts of the repo whose meaning the agent does not already know — keep
  the read minimal at this stage; deep recon belongs to stage 3.

## Behavior rules

- **Do not assume.** When a request is ambiguous, incomplete, or
  contradictory, list the open points and ask targeted questions.
- **Disagree explicitly.** If the prompt has a problem (unclear scope,
  hidden cost, conflict with stated constraints, infeasible request),
  state it plainly and discuss with the user.
- **Seek approval.** Do not move to stage 2 until the user approves the
  specification.
- **Don't do recon.** Do not search the codebase here beyond what the
  user explicitly asks; recon is stage 3.
- **Don't framework.** Avoid imposing the change-brief structure here —
  the user-facing artifact is a clarification, not a technical brief.

## Workflow

1. Read the user's prompt verbatim.
2. Restate the intent in your own words and present it back.
3. Surface every ambiguity / missing piece as a numbered list of
   targeted questions. Group by category (scope, behavior, constraints,
   rollout, success criteria).
4. Surface concerns / disagreements / risks as their own list, with a
   short explanation each, and ask for the user's decision.
5. Iterate with the user until ambiguities are resolved or explicitly
   accepted as open.
6. Optionally draft an **acceptance checklist** — a list of conditions
   the user expects to see satisfied. Skip it when the change is too
   small to benefit (mark "n/a" in `specification.md`).
7. Write `specification.md` once approved.
8. Append entries to `logs/phase-1.changelog.md` and reusable lessons to
   `learning/phase-1.learning.md`.

## Outputs (artifacts written)

- `specification.md` — required. Recommended sections:
  - **Original prompt** (verbatim).
  - **Clarified intent** (the agreed restatement).
  - **Assumptions** (explicitly marked).
  - **Open questions** (still unresolved, if any).
  - **Concerns raised** (agent objections + how each was resolved).
  - **Acceptance checklist** (optional).
- `logs/phase-1.changelog.md` — questions asked and answers received,
  clarifications added, agent concerns raised and outcomes.
- `learning/phase-1.learning.md` — only reusable learnings.

## Exit criteria

- `specification.md` is written and approved by the user.
- All ambiguities are either resolved or explicitly listed as open.
- All agent concerns / disagreements are recorded with the user's
  decision.

## Handoff

- **Next skill:** [`marshal-intake`](../marshal-intake/SKILL.md).
- **Pass:** `specification.md` (the only required input for stage 2).
- **Do not pass:** transient dialog notes; only the final agreed
  specification crosses the boundary.

## When invoked by a subagent

The orchestrator agent ([`marshal-driver`](../../agents/marshal-driver.md))
delegates this skill at the very start of a change. The skill itself is
single-context — it talks with the user directly. There is no v2
fresh-context subagent for stage 1; the dialog must stay with the
human-facing context.
