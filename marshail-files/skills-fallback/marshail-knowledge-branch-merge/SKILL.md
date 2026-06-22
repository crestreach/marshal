---
name: marshail-knowledge-branch-merge
description: Reconcile MARSHAIL knowledge files diverged on two branches. Fallback skill for environments without subagent support. Triggers on "merge knowledge files from two branches", "resolve a knowledge conflict", "3-way merge knowledge frontmatter and bodies", "reconcile feature branch knowledge with trunk". Runs mode `branch-merge` inline in the current session.
---

# marshail-knowledge-branch-merge (fallback — no-subagent environments)

This skill performs the work that the [`marshail-knowledge-curator`](../../agents/marshail-knowledge-curator.md) subagent does in mode `branch-merge`, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshail-knowledge-curator.md`](../../agents/marshail-knowledge-curator.md) — section for mode `branch-merge`.
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshail-delegate-to-knowledge-branch-merge`](../../skills/marshail-delegate-to-knowledge-branch-merge/SKILL.md) so the work runs in fresh context.
