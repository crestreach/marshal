---
name: marshail-delegate-to-pr
description: MARSHAIL Review / PR / integration / merge stage. Delegate when the user asks to "open the PR", "compose the PR description", "do an AI review of this PR", "self-review before requesting human review", "review against delivery-plan.md and verification-report.md", "check the diff for plan alignment / test coverage / knowledge conflicts / risks", "handle review feedback", "convert review comments into plan FIXUP / CHANGED / ADDED entries", "promote the integration branch to main / release", "do the final review of the whole change". Also delegate any time a coherent integration boundary is ready and the Verify stage passed. The subagent composes the PR, runs structured AI review against the plan + knowledge layer, and converts feedback into plan updates rather than silent edits. Supports PRs that target an integration branch, with a final promotion round (Implement -> Verify -> Review / PR) into the release / main branch.
---

# marshail-delegate-to-pr

Delegate this to the [`marshail-reviewer`](../../agents/marshail-reviewer.md) subagent.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshail-reviewer`
- **Pass:** PR diff (or branch + base commit range); the **target branch** (final `main` / release, or an integration branch); `delivery-plan.md` (packets in scope); `verification-report.md`; `change-brief.md`; relevant `.marshail/knowledge/` files (invariants, contracts, conventions); `.marshail/config.yml`.
- **Expect back:** PR description; structured review document with sections (Plan alignment, Test coverage, Knowledge conflicts, Risks, Recommendation: `approve` | `request-changes` | `comment`); inline comments; plan updates with `[FIXUP]` / `[CHANGED]` / `[ADDED]` markers; updated phase changelog.
- **On result (approve):** hand off to [`marshail-delegate-to-rollout`](../marshail-delegate-to-rollout/SKILL.md) (Rollout stage) or [`marshail-delegate-to-learn`](../marshail-delegate-to-learn/SKILL.md) (Learn stage).
  If knowledge upkeep wasn't done in the Implement stage, run [`marshail-delegate-to-knowledge-maintain`](../marshail-delegate-to-knowledge-maintain/SKILL.md) (`from-changes`).
- **On result (request-changes):** hand back to [`marshail-delegate-to-implement`](../marshail-delegate-to-implement/SKILL.md), then re-verify and re-review.
- **Integration branch:** when the PR targets an integration branch, finish with one more round to promote it to the final branch — Implement (merge / rebase onto the target, resolve conflicts, final improvements) → Verify (whole integrated scope) → Review / PR (final review of the change as a whole).

## Fallback (no-subagent environments)

If subagents are not available, use [`marshail-pr`](../../skills-fallback/marshail-pr/SKILL.md).
Source of truth: [`marshail-reviewer.md`](../../agents/marshail-reviewer.md).
