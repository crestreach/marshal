---
name: marshal-delegate-to-pr
description: MARSHAL stage 5c (PR / integration / merge). Delegate when the user asks to "open the PR", "compose the PR description", "do an AI review of this PR", "self-review before requesting human review", "review against delivery-plan.md and verification-report.md", "check the diff for plan alignment / test coverage / knowledge conflicts / risks", "handle review feedback", "convert review comments into plan FIXUP / CHANGED / ADDED entries". Also delegate any time a coherent integration boundary is ready and stage 5b passed. The subagent composes the PR, runs structured AI review against the plan + knowledge layer, and converts feedback into plan updates rather than silent edits.
---

# marshal-delegate-to-pr

Delegate this to the [`marshal-reviewer`](../../agents/marshal-reviewer.md) subagent. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-reviewer`
- **Pass:** PR diff (or branch + base commit range); `delivery-plan.md` (packets in scope); `verification-report.md`; `change-brief.md`; relevant `.marshal/knowledge/` files (invariants, contracts, conventions); `.marshal/config.yml`.
- **Expect back:** PR description; structured review document with sections (Plan alignment, Test coverage, Knowledge conflicts, Risks, Recommendation: `approve` | `request-changes` | `comment`); inline comments; plan updates with `[FIXUP]` / `[CHANGED]` / `[ADDED]` markers; updated phase changelog.
- **On result (approve):** hand off to [`marshal-delegate-to-rollout`](../marshal-delegate-to-rollout/SKILL.md) (stage 6) or [`marshal-delegate-to-learn`](../marshal-delegate-to-learn/SKILL.md) (stage 7). If knowledge upkeep wasn't done in 5a, run [`marshal-delegate-to-knowledge-maintain`](../marshal-delegate-to-knowledge-maintain/SKILL.md) (`from-changes`).
- **On result (request-changes):** hand back to [`marshal-delegate-to-implement`](../marshal-delegate-to-implement/SKILL.md), then re-verify and re-review.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-pr`](../../skills-fallback/marshal-pr/SKILL.md). Source of truth: [`marshal-reviewer.md`](../../agents/marshal-reviewer.md).
