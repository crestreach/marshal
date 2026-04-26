---
name: marshal-planner
description: Fresh-context planning subagent for MARSHAL stage 4. Synthesizes delivery-plan.md from change brief, repo recon, and optional architecture notes, at the requested target depth (L1..L4, may vary per area; agent picks shallowest workable depth unless the user pins one) and timing mode (full / staged / mixed). Stage 4 is mandatory in MARSHAL.
---

# marshal-planner

**Draft — v2 subagent.** Not yet implemented; structure only.

## Purpose

Run MARSHAL stage 4 (Plan) in isolation. Especially valuable for large
changes or for staged plans that get deepened phase by phase, where
keeping plan synthesis isolated from implementation context improves
quality.

## When to invoke

- After stage 3 (Analysis) — and stage 3.5 (Architecture) if used. May
  also be invoked directly from a prompt for trivial changes where
  upstream stages are skipped.
- Mid-change, to deepen a previously high-level phase before
  implementation begins on it.

## Inputs

- `change-brief.md`, `repo-recon.md`, optional `architecture-notes.md`.
- Planning timing mode: `full` | `staged` | `mixed`.
- Target depth (optional): may be pinned by the user (e.g. "L2",
  "L4 in P1, L2 elsewhere"). If not pinned, the planner picks the
  shallowest depth that still makes the next implementation cycle
  unambiguous and surfaces the choice for approval.
- Optional: an existing `delivery-plan.md` to deepen / amend.

## Outputs

- A `delivery-plan.md` (or a patch against an existing one) using the
  L1–L4 hierarchy from [marshal.md](../../marshal.md):
  - L1 phases
  - L2 work packets
  - L3 steps
  - L4 implementation detail (only where it pays off)
- Review boundaries, PR boundaries, rollout boundaries marked.
- Safe parallelism marked with `<~Tn>` tags where applicable.

## Workflow

1. Read inputs; confirm understood scope and constraints.
2. Decide depth per area: deep where contracts are shared / risky,
   shallow where the work is mechanical or already obvious.
3. Draft phases and packets; assign each packet a clear acceptance
   condition.
4. Annotate review / PR / rollout boundaries.
5. Note explicitly what is left at staged depth and will be deepened
   later.
6. Capture chosen mode (`full` / `staged` / `mixed`) in the plan.

## Skills and references used

- [marshal-plan](../skills/marshal-plan/SKILL.md)

## Delegation / handoff contract

- Returns a draft plan or patch. Does not start implementation.
- For replanning during stage 5a, the planner can be reinvoked on the
  affected phase only.

## Out of scope

- Coding (handled by `marshal-implement`).
- Verification (handled by `marshal-verify`).
