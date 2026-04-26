---
name: marshal-pr
description: MARSHAL stage 5c (optional) - PR/integration/merge. Composes the PR description from delivery-plan.md and verification-report.md, and handles review-driven fixups by updating the plan before any silent edits.
---

# marshal-pr

MARSHAL stage 5c — see [marshal.md §5c](../../../marshal.md). Optional;
skip for non-shared work or trunk-direct workflows. The Verify rule
still applies before any code is shared.

## Prerequisites

- Stage 5b complete: `verification-report.md` (or its in-changelog
  equivalent) records a pass for the PR boundary in scope.

## Inputs (read at start)

- `delivery-plan.md` — packets in scope of this PR.
- `verification-report.md`
- `change-brief.md` — for the change summary.
- Repo conventions in
  [`.marshal/knowledge/repo/conventions.md`](../../knowledge/repo/conventions.md)
  if present.

## Workflow

1. Confirm the PR boundary matches the plan (whole change / phase /
   slice / multi-phase / occasional packet group).
2. Compose PR description: linked phase(s) / packet(s), change summary,
   test summary, rollout note pointer, known limitations, follow-up
   packets.
3. On review feedback:
   - Small correction inside same packet → add a `[FIXUP yyyy-mm-dd]`
     substep under the current work packet.
   - Scope/approach change → mark packet `[CHANGED yyyy-mm-dd]` and
     update remaining steps and dependencies.
   - Isolatable correction → create a new sibling packet
     `Wxa. Review fixups [ADDED yyyy-mm-dd]`.
4. Append rationale to the affected `logs/phase-N.changelog.md`.
5. Loop back through stage 5a and stage 5b for any updated packets
   before re-requesting review.

## Outputs

- A PR description (in the host's PR system).
- Plan updates with `[FIXUP]` / `[CHANGED]` / `[ADDED]` markers.
- Updated phase changelog.

## Exit criteria

- PR opened (or updated) at a meaningful integration boundary.
- Any review feedback reflected in the plan, not in silent edits.
- Verification re-run for any code changed during the fixup loop.

## Handoff

- **Next stage on merge:** [`marshal-rollout`](../marshal-rollout/SKILL.md)
  if rollout is in scope; otherwise
  [`marshal-learn`](../marshal-learn/SKILL.md) (or end-of-change).
  Pass: merged commit / tag, summary of what was integrated, any
  rollout-relevant notes from the PR.
- **Knowledge upkeep:** if not already done in stage 5a, dispatch
  [`marshal-knowledge-maintain`](../marshal-knowledge-maintain/SKILL.md)
  mode `from-changes` for the merged diff.

## Subagent

V2 candidate: [`marshal-reviewer`](../../agents/marshal-reviewer.md)
runs the AI-side review of the PR in fresh context, grounded in
`delivery-plan.md`, `verification-report.md`, and the knowledge layer.
