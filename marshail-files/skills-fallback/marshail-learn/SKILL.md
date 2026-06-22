---
name: marshail-learn
description: MARSHAIL Learn stage. Fallback skill for environments without subagent support. Triggers on "merge the phase learnings", "produce learning-rollup.md", "promote learnings into AGENTS.md / rules / skills / agents / knowledge inbox", "draft a new rule / skill / subagent from learnings", "close the loop on this change". Runs learning rollup inline in the current session.
---

# marshail-learn (fallback — no-subagent environments)

This skill performs the work that the [`marshail-learner`](../../agents/marshail-learner.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshail-learner.md`](../../agents/marshail-learner.md).
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshail-delegate-to-learn`](../../skills/marshail-delegate-to-learn/SKILL.md) so the work runs in fresh context.
