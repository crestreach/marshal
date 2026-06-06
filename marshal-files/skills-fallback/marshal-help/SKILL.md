---
name: marshal-help
description: MARSHAL on-demand help. Fallback skill for environments without subagent support. Triggers on "how does MARSHAL work?", "which skill / agent next?", "what stage am I in?", "explain the knowledge layer", "what does X stage do?", "MARSHAL?". Answers procedural / conceptual questions about MARSHAL inline in the current session — read-only.
---

# marshal-help (fallback — no-subagent environments)

This skill performs the work that the [`marshal-helper`](../../agents/marshal-helper.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshal-helper.md`](../../agents/marshal-helper.md).
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshal-delegate-to-help`](../../skills/marshal-delegate-to-help/SKILL.md) so the work runs in fresh context.
