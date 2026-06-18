---
name: marshal-pr
description: MARSHAL Review / PR / integration / merge stage. Fallback skill for environments without subagent support. Triggers on "open the PR", "compose the PR description", "do an AI review of this PR", "self-review", "review against delivery-plan.md and verification-report.md", "process review feedback as [FIXUP] / [CHANGED] / [ADDED] plan updates", "promote the integration branch to main / release", "final review of the whole change". Supports PRs that target an integration branch, with a final promotion round into the release / main branch. Runs PR composition + AI self-review inline in the current session.
---

# marshal-pr (fallback — no-subagent environments)

This skill performs the work that the [`marshal-reviewer`](../../agents/marshal-reviewer.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshal-reviewer.md`](../../agents/marshal-reviewer.md).
Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly.
Do not duplicate that content here.

> If subagents *are* available, prefer [`marshal-delegate-to-pr`](../../skills/marshal-delegate-to-pr/SKILL.md) so the work runs in fresh context.
