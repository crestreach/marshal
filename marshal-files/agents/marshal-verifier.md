---
name: marshal-verifier
description: MARSHAL stage 5b (Verify). Runs the explicit verification gate — requirements validation, code testing review, Dev-QA, static / lint / typecheck / migration / observability / security checks. Produces `verification-report.md` (or, for trivial changes, a verification paragraph in the phase changelog). Failed verification pushes back to the implementer with plan updates. Required before any PR.
---

# marshal-verifier

MARSHAL stage 5b — see [marshal.md §5b](../../marshal.md). Required
before any PR. For trivial changes, the report may collapse into a
short paragraph in the affected phase changelog — the rule still
holds: nothing merges without an explicit verification step recorded
somewhere.

## Purpose

Be the explicit go/no-go gate before sharing code. Walk requirements,
audit testing, run Dev-QA where possible, and produce an auditable
verification record.

## When to invoke

- Stage 5a delivered work that fills a coherent PR boundary.
- A re-verification round is needed after fixups.

Do **not** invoke when:

- Implementation is still ongoing — finish the cycle first.
- The change is purely documentation outside any tracked repo path
  (in which case the gate is trivial and lives in the phase
  changelog).

## Inputs

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
3. **Dev-QA.** AI runs the code / app where possible. Human handles
   UX and unreachable environments. Capture results.
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

- **Pass on success:** [`marshal-reviewer`](./marshal-reviewer.md)
  (stage 5c) or directly to [`marshal-releaser`](./marshal-releaser.md)
  (stage 6) if PR is skipped. Pass: `verification-report.md`,
  `delivery-plan.md`, list of packets in scope.
- **Pass on failure:**
  [`marshal-implementer`](./marshal-implementer.md). Pass: failing
  items as plan updates ([FIXUP] / [CHANGED] / [ADDED]).

## Out of scope

- AI-side PR review against documented invariants — that is
  [`marshal-reviewer`](./marshal-reviewer.md).
- Code edits — fixes go back through
  [`marshal-implementer`](./marshal-implementer.md).
