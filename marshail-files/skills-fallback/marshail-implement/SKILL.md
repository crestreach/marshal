---
name: marshail-implement
description: MARSHAIL Implement stage. Fallback skill for environments without subagent support. Triggers on "implement the next phase", "do the next packet", "code this packet", "apply the plan", "drive the implement-verify-pr cycle", "write the code for delivery-plan.md phase N". Runs implementation cycles inline in the current session.
---

# marshail-implement (fallback — no-subagent environments)

This skill performs the work that the [`marshail-implementer`](../../agents/marshail-implementer.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshail-implementer.md`](../../agents/marshail-implementer.md).
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshail-delegate-to-implement`](../../skills/marshail-delegate-to-implement/SKILL.md) so the work runs in fresh context.
