---
name: marshal-verify
description: MARSHAL stage 5b - Verify. Runs an explicit verification gate covering requirements validation, code testing guidance, and Dev-QA. Produces verification-report.md (or, for trivial changes, a verification paragraph in the phase changelog). Failed verification pushes back to marshal-implement with plan updates. Required before any PR.
---

# marshal-verify

MARSHAL stage 5b — see [marshal.md §5b](../../../marshal.md). Required
before any PR. For trivial changes, the report may collapse into a
short paragraph in the affected phase changelog — the rule still
holds: nothing merges without an explicit verification step recorded
somewhere.

## Prerequisites

- Stage 5a delivered work that fills a coherent PR boundary.
- `delivery-plan.md` reflects the actual current state.

## Inputs (read at start)

- `change-brief.md` if it exists — every requirement is walked. If
  there is no brief, walk the acceptance criteria directly from
  `delivery-plan.md`.
- `delivery-plan.md` — packets in scope of this verification.
- The diff / changed files for the PR boundary.
- Existing `verification-report.md` if a prior round was run.

## Workflow

1. **Requirements validation.** Walk every requirement in
   `change-brief.md` (or the plan's acceptance criteria); check
   implementation, corner cases, error cases.
2. **Code testing review.** Apply marshal.md §5a strategy: regression
   tests for bugfixes; unit as primary; integration for general /
   cross-component cases; E2E only for critical journeys.
3. **Dev-QA.** AI runs the code / app where possible. Human handles UX
   and unreachable environments. Capture results.
4. **Static / lint / typecheck / migration / observability / security**
   checks, where applicable.
5. Record results in `verification-report.md` (or, for trivial
   changes, a verification paragraph in the affected phase changelog).

## Outputs

- `verification-report.md` per the stage 5b template (acceptance
  criteria check, static analysis, unit tests, integration tests,
  migration checks, observability/logging checks, security/privacy
  checks if relevant, open issues / residual risks). For trivial
  changes, replace this with a verification paragraph in the affected
  `logs/phase-N.changelog.md`.
- Append results to the affected `logs/phase-N.changelog.md`
  (verification result, defects found, rework triggered, final status).
- Append reusable lessons to `learning/phase-N.learning.md`.

## Exit criteria

- Verification passed for the PR boundary, **or**
- Defects fed back into the plan and stage 5a is re-run.

## Handoff

- **Pass on success:** [`marshal-pr`](../marshal-pr/SKILL.md) (or
  directly to [`marshal-rollout`](../marshal-rollout/SKILL.md) if PR
  is skipped). Pass: `verification-report.md`, `delivery-plan.md`,
  list of packets in scope.
- **Pass on failure:** [`marshal-implement`](../marshal-implement/SKILL.md).
  Pass: failing items as plan updates ([FIXUP] / [CHANGED] / [ADDED]).

## Subagent

No dedicated v2 subagent. The
[`marshal-reviewer`](../../agents/marshal-reviewer.md) subagent
cross-checks at stage 5c using outputs from this skill.
