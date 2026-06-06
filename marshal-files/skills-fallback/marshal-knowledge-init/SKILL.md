---
name: marshal-knowledge-init
description: First-time bootstrap of the MARSHAL knowledge layer. Fallback skill for environments without subagent support. Triggers on "bootstrap the knowledge layer", "initialize .marshal/knowledge/", "scan the repo and draft repo/ + domains/ files", "build initial INDEX.md files". Runs init mode inline in the current session.
---

# marshal-knowledge-init (fallback — no-subagent environments)

This skill performs the work that the [`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md) subagent does in mode `init`, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshal-knowledge-curator.md`](../../agents/marshal-knowledge-curator.md) — section for mode `init`.
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshal-delegate-to-knowledge-init`](../../skills/marshal-delegate-to-knowledge-init/SKILL.md) so the work runs in fresh context.
