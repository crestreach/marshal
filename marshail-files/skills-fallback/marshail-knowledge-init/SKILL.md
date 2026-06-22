---
name: marshail-knowledge-init
description: First-time bootstrap of the MARSHAIL knowledge layer. Fallback skill for environments without subagent support. Triggers on "bootstrap the knowledge layer", "initialize .marshail/knowledge/", "scan the repo and draft repo/ + domains/ files", "build initial INDEX.md files". Runs init mode inline in the current session.
---

# marshail-knowledge-init (fallback — no-subagent environments)

This skill performs the work that the [`marshail-knowledge-curator`](../../agents/marshail-knowledge-curator.md) subagent does in mode `init`, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshail-knowledge-curator.md`](../../agents/marshail-knowledge-curator.md) — section for mode `init`.
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshail-delegate-to-knowledge-init`](../../skills/marshail-delegate-to-knowledge-init/SKILL.md) so the work runs in fresh context.
