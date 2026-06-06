---
name: marshal-analysis
description: MARSHAL Analysis stage. Fallback skill for environments without subagent support. Triggers on "analyze the repo", "do code archaeology", "produce repo-recon.md", "find call-sites and integration points", "build a code map for this change", "what code is affected by this change?". Runs analysis inline in the current session.
---

# marshal-analysis (fallback — no-subagent environments)

This skill performs the work that the [`marshal-code-archaeologist`](../../agents/marshal-code-archaeologist.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshal-code-archaeologist.md`](../../agents/marshal-code-archaeologist.md).
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshal-delegate-to-analysis`](../../skills/marshal-delegate-to-analysis/SKILL.md) so the work runs in fresh context.
