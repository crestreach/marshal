---
name: marshail-intake
description: MARSHAIL Intake stage. Fallback skill for environments without subagent support. Triggers on "do intake", "produce change-brief.md", "frame this prompt as a change", "turn this idea / specification into a change brief", "what's the scope and risk?". Runs intake inline in the current session.
---

# marshail-intake (fallback — no-subagent environments)

This skill performs the work that the [`marshail-framer`](../../agents/marshail-framer.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshail-framer.md`](../../agents/marshail-framer.md).
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshail-delegate-to-intake`](../../skills/marshail-delegate-to-intake/SKILL.md) so the work runs in fresh context.
