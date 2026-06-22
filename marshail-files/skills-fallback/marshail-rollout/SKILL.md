---
name: marshail-rollout
description: MARSHAIL Rollout / release stage. Fallback skill for environments without subagent support. Triggers on "draft the rollout note", "produce rollout-note.md", "list toggles / properties / log changes / migrations / rollback path / porting instructions / user-visible docs / manual test scenarios". Runs rollout note authoring inline in the current session.
---

# marshail-rollout (fallback — no-subagent environments)

This skill performs the work that the [`marshail-releaser`](../../agents/marshail-releaser.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshail-releaser.md`](../../agents/marshail-releaser.md).
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshail-delegate-to-rollout`](../../skills/marshail-delegate-to-rollout/SKILL.md) so the work runs in fresh context.
