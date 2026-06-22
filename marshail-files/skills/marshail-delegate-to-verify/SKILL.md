---
name: marshail-delegate-to-verify
description: MARSHAIL Verify stage — REQUIRED before any PR. Delegate when the user asks to "verify the change", "run the verification gate", "check requirements coverage", "audit the tests", "do Dev-QA", "produce verification-report.md", "is this ready for PR?", "check static / lint / typecheck / migrations / observability / security for this PR boundary". Also delegate automatically after each implementation cycle that fills a coherent PR boundary, and to re-verify after a fixup loop. The subagent walks every requirement, applies the Implement-stage testing strategy, runs Dev-QA where possible, and either passes (→ PR) or pushes back with plan updates (→ Implement).
---

# marshail-delegate-to-verify

Delegate this to the [`marshail-verifier`](../../agents/marshail-verifier.md) subagent.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshail-verifier`
- **Pass:** `change-brief.md` (if it exists); `delivery-plan.md` (packets in scope); the diff / changed files for the PR boundary; any prior `verification-report.md`.
- **Expect back:** `verification-report.md` (or, for trivial changes, a verification paragraph appended to the affected phase changelog); appended results to `logs/phase-<n>.changelog.md`; reusable lessons in `learning/phase-<n>.learning.md`.
- **On result (pass):** hand off to [`marshail-delegate-to-pr`](../marshail-delegate-to-pr/SKILL.md) (PR stage) or directly to [`marshail-delegate-to-rollout`](../marshail-delegate-to-rollout/SKILL.md) (Rollout stage) if PR is skipped.
- **On result (fail):** hand back to [`marshail-delegate-to-implement`](../marshail-delegate-to-implement/SKILL.md) with failing items as plan updates ([FIXUP] / [CHANGED] / [ADDED]).

Nothing merges without an explicit verification step recorded somewhere.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshail-verify`](../../skills-fallback/marshail-verify/SKILL.md).
Source of truth: [`marshail-verifier.md`](../../agents/marshail-verifier.md).
