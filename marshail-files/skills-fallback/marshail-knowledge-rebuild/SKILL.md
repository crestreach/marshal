---
name: marshail-knowledge-rebuild
description: Post-feature rebuild of the MARSHAIL knowledge layer. Fallback skill for environments without subagent support. Triggers on "rebuild the knowledge tree", "restructure domains/ after this feature", "re-derive subsystems / domains", "quarterly knowledge rebuild". Runs mode `rebuild` inline in the current session.
---

# marshail-knowledge-rebuild (fallback — no-subagent environments)

This skill performs the work that the [`marshail-knowledge-curator`](../../agents/marshail-knowledge-curator.md) subagent does in mode `rebuild`, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshail-knowledge-curator.md`](../../agents/marshail-knowledge-curator.md) — section for mode `rebuild`.
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshail-delegate-to-knowledge-rebuild`](../../skills/marshail-delegate-to-knowledge-rebuild/SKILL.md) so the work runs in fresh context.
