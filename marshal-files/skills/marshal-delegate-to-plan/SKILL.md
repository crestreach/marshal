---
name: marshal-delegate-to-plan
description: MARSHAL Plan / shape stage — MANDATORY for every MARSHAL change. Delegate whenever the user asks to "plan this change", "make a delivery plan", "produce delivery-plan.md", "shape the work", "break this into phases / packets / steps", "decide L1 / L2 / L3 / L4 depth", "decide PR boundaries", "decide rollout boundaries", "mark parallelizable work", "deepen the plan for phase X", "replan phase Y", or simply "let's plan". Also delegate at the start of any MARSHAL change once the earlier stages (Specification through Architecture) are agreed (or skipped), and mid-change to deepen a previously high-level phase before its implementation cycle. The subagent picks the shallowest workable depth unless the user pins a target depth, and chooses a timing mode (full / staged / mixed).
---

# marshal-delegate-to-plan

Delegate this to the [`marshal-planner`](../../agents/marshal-planner.md) subagent. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-planner`
- **Pass:** whichever upstream artifacts exist (`specification.md`, `change-brief.md`, `repo-recon.md`, `architecture-notes.md`); planning timing mode (`full` | `staged` | `mixed`) if the user has a preference; target depth if pinned (e.g. "L2", "L4 in P1, L2 elsewhere"); existing `delivery-plan.md` if deepening / amending.
- **Expect back:** approved `delivery-plan.md` (Scope line + Planning mode + Target depth, then phases / packets / steps to the agreed depth), plus `logs/phase-4.changelog.md` and `learning/phase-4.learning.md`.
- **On result:** confirm approval and hand off to [`marshal-delegate-to-implement`](../marshal-delegate-to-implement/SKILL.md) (Implement stage). For staged deepening, re-invoke this delegate before each implementation cycle of a still-shallow phase.

The Plan stage is **mandatory** in MARSHAL — every change has a plan, even a single phase with one step.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-plan`](../../skills-fallback/marshal-plan/SKILL.md). Source of truth: [`marshal-planner.md`](../../agents/marshal-planner.md).
