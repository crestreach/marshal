---
name: marshail-delegate-to-rollout
description: MARSHAIL Release / rollout stage. Delegate when the user asks to "draft the rollout note", "produce rollout-note.md", "list the toggles / properties / log changes / migrations / rollback path", "write the porting instructions", "list user-visible docs changes", "write a manual test scenario list for release", "what's the deploy plan?", "how do we roll this back?". Also delegate after merge (PR stage) or after the Verify stage if PR was skipped, for any change with operational impact. The subagent walks the change for operational shape and emits rollout-note.md.
---

# marshail-delegate-to-rollout

Delegate this to the [`marshail-releaser`](../../agents/marshail-releaser.md) subagent.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshail-releaser`
- **Pass:** `change-brief.md`; `delivery-plan.md` (rollout boundary on phases); `verification-report.md`; migration / config / feature-flag files touched; operational-conventions knowledge files (logging / toggles / deploy) if any.
- **Expect back:** `rollout-note.md` (toggles, properties, log changes, migrations, rollback path, porting instructions, user-visible docs); `logs/stage-7-rollout.changelog.md`; `learning/stage-7-rollout.learning.md`.
- **On result:** hand off to [`marshail-delegate-to-learn`](../marshail-delegate-to-learn/SKILL.md) (Learn stage) with the rollout note plus pointers to all phase learning files.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshail-rollout`](../../skills-fallback/marshail-rollout/SKILL.md).
Source of truth: [`marshail-releaser.md`](../../agents/marshail-releaser.md).
