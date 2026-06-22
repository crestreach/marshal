---
name: marshail-specify
description: MARSHAIL Specification stage. Fallback skill for environments without subagent support. Triggers on "specify the change", "write a specification", "clarify requirements before building", "produce specification.md", "do the requirements clarification dialog", "I have a vague idea — help me sharpen it before planning". Runs the full specification dialog inline in the current session.
---

# marshail-specify (fallback — no-subagent environments)

This skill performs the work that the [`marshail-specifier`](../../agents/marshail-specifier.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshail-specifier.md`](../../agents/marshail-specifier.md).
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshail-delegate-to-specify`](../../skills/marshail-delegate-to-specify/SKILL.md) so the work runs in fresh context.
