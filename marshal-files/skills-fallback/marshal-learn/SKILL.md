---
name: marshal-learn
description: MARSHAL stage 7 (Learn). Fallback skill for environments without subagent support. Triggers on "merge the phase learnings", "produce learning-rollup.md", "promote learnings into AGENTS.md / rules / skills / agents / knowledge inbox", "draft a new rule / skill / subagent from learnings", "close the loop on this change". Runs learning rollup inline in the current session.
---

# marshal-learn (fallback — no-subagent environments)

This skill performs the work that the [`marshal-learner`](../../agents/marshal-learner.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshal-learner.md`](../../agents/marshal-learner.md). Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly. Do not duplicate that content here.

> If subagents *are* available, prefer [`marshal-delegate-to-learn`](../../skills/marshal-delegate-to-learn/SKILL.md) so the work runs in fresh context.
