---
name: marshail-knowledge-maintain
description: Maintain the MARSHAIL knowledge layer. Fallback skill for environments without subagent support. Triggers on "update the knowledge tree from this diff", "promote learnings from learn/inbox/", "rescan the knowledge tree", "refresh stale knowledge files", "split oversize topics", "update knowledge after this implementation cycle". Runs modes `from-changes` / `from-learning` / `rescan` inline in the current session.
---

# marshail-knowledge-maintain (fallback — no-subagent environments)

This skill performs the work that the [`marshail-knowledge-curator`](../../agents/marshail-knowledge-curator.md) subagent does in modes `from-changes` / `from-learning` / `rescan`, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshail-knowledge-curator.md`](../../agents/marshail-knowledge-curator.md) — sections for those modes.
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshail-delegate-to-knowledge-maintain`](../../skills/marshail-delegate-to-knowledge-maintain/SKILL.md) so the work runs in fresh context.
