---
name: marshal-plan
description: MARSHAL Plan stage — MANDATORY. Fallback skill for environments without subagent support. Triggers on "produce delivery-plan.md", "plan this change", "break it into phases", "agree scope and depth (L1/L2/L3/L4)", "set timing mode (full/staged/mixed)", "do the planning stage". Runs planning inline in the current session.
---

# marshal-plan (fallback — no-subagent environments)

This skill performs the work that the [`marshal-planner`](../../agents/marshal-planner.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshal-planner.md`](../../agents/marshal-planner.md). Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly. Do not duplicate that content here.

> If subagents *are* available, prefer [`marshal-delegate-to-plan`](../../skills/marshal-delegate-to-plan/SKILL.md) so the work runs in fresh context.
