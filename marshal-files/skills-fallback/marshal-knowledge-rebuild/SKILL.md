---
name: marshal-knowledge-rebuild
description: Post-feature rebuild of the MARSHAL knowledge layer. Fallback skill for environments without subagent support. Triggers on "rebuild the knowledge tree", "restructure domains/ after this feature", "re-derive bounded contexts", "quarterly knowledge rebuild". Runs mode `rebuild` inline in the current session.
---

# marshal-knowledge-rebuild (fallback — no-subagent environments)

This skill performs the work that the [`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md) subagent does in mode `rebuild`, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshal-knowledge-curator.md`](../../agents/marshal-knowledge-curator.md) — section for mode `rebuild`.
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshal-delegate-to-knowledge-rebuild`](../../skills/marshal-delegate-to-knowledge-rebuild/SKILL.md) so the work runs in fresh context.
