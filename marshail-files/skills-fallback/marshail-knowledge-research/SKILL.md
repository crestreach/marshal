---
name: marshail-knowledge-research
description: Focused research on a topic, codebase area, or library, returning a condensed source-linked markdown delta. Fallback skill for environments without subagent support. Triggers on "research X", "study how Y is wired up", "deep-dive on this module", "answer this narrow question without polluting context", "give me a delta I can promote to the knowledge tree later". Runs research inline in the current session — read-only.
---

# marshail-knowledge-research (fallback — no-subagent environments)

This skill performs the work that the [`marshail-researcher`](../../agents/marshail-researcher.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshail-researcher.md`](../../agents/marshail-researcher.md).
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshail-delegate-to-knowledge-research`](../../skills/marshail-delegate-to-knowledge-research/SKILL.md) so the work runs in fresh context.
