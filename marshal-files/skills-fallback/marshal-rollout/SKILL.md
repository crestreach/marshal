---
name: marshal-rollout
description: MARSHAL Rollout / release stage. Fallback skill for environments without subagent support. Triggers on "draft the rollout note", "produce rollout-note.md", "list toggles / properties / log changes / migrations / rollback path / porting instructions / user-visible docs / manual test scenarios". Runs rollout note authoring inline in the current session.
---

# marshal-rollout (fallback — no-subagent environments)

This skill performs the work that the [`marshal-releaser`](../../agents/marshal-releaser.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshal-releaser.md`](../../agents/marshal-releaser.md). Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly. Do not duplicate that content here.

> If subagents *are* available, prefer [`marshal-delegate-to-rollout`](../../skills/marshal-delegate-to-rollout/SKILL.md) so the work runs in fresh context.
