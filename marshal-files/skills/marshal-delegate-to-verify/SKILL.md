---
name: marshal-delegate-to-verify
description: MARSHAL Verify stage — REQUIRED before any PR. Delegate when the user asks to "verify the change", "run the verification gate", "check requirements coverage", "audit the tests", "do Dev-QA", "produce verification-report.md", "is this ready for PR?", "check static / lint / typecheck / migrations / observability / security for this PR boundary". Also delegate automatically after each implementation cycle that fills a coherent PR boundary, and to re-verify after a fixup loop. The subagent walks every requirement, applies the Implement-stage testing strategy, runs Dev-QA where possible, and either passes (→ PR) or pushes back with plan updates (→ Implement).
---

# marshal-delegate-to-verify

Delegate this to the [`marshal-verifier`](../../agents/marshal-verifier.md) subagent.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-verifier`
- **Pass:** `change-brief.md` (if it exists); `delivery-plan.md` (packets in scope); the diff / changed files for the PR boundary; any prior `verification-report.md`.
- **Expect back:** `verification-report.md` (or, for trivial changes, a verification paragraph appended to the affected phase changelog); appended results to `logs/phase-<n>.changelog.md`; reusable lessons in `learning/phase-<n>.learning.md`.
- **On result (pass):** hand off to [`marshal-delegate-to-pr`](../marshal-delegate-to-pr/SKILL.md) (PR stage) or directly to [`marshal-delegate-to-rollout`](../marshal-delegate-to-rollout/SKILL.md) (Rollout stage) if PR is skipped.
- **On result (fail):** hand back to [`marshal-delegate-to-implement`](../marshal-delegate-to-implement/SKILL.md) with failing items as plan updates ([FIXUP] / [CHANGED] / [ADDED]).

Nothing merges without an explicit verification step recorded somewhere.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-verify`](../../skills-fallback/marshal-verify/SKILL.md).
Source of truth: [`marshal-verifier.md`](../../agents/marshal-verifier.md).
