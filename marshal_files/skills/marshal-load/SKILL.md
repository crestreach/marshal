---
name: marshal-load
description: Session bootstrap for MARSHAL. Reads .marshal/ENTRYPOINT.md, .marshal/knowledge/INDEX.md, and .marshal/config.yml, then reports a one-paragraph orientation so the agent can pick the right next skill with minimal extra context.
---

# marshal-load

Setup skill — runs once per fresh session.

## Prerequisites

- Repo with `.marshal/` initialized (run `marshal-init` first if not).

## Inputs (read at start)

- [`.marshal/ENTRYPOINT.md`](../../ENTRYPOINT.md)
- [`.marshal/knowledge/INDEX.md`](../../knowledge/INDEX.md)
- [`.marshal/config.yml`](../../config.yml) — note `knowledge.autonomy`.
- Working folder for the current change, if any (look for the artifact
  chain: `specification.md`, `change-brief.md`, …).

## Workflow

1. Read entry point + root knowledge index + config.
2. Detect current MARSHAL stage from the artifact chain present in the
   working folder, treating every stage as optional except stage 4 Plan
   (none → not started; `specification.md` only → stage 1 done; `…` up
   to `learning-rollup.md` → stage 7 done). If `delivery-plan.md` is
   present, read its `Scope:` line to learn which stages were chosen
   for this change.
3. Emit a short orientation block (≤ ~20 lines):
   - process: which stage is current, which artifact is next, which
     stages were skipped per the plan's Scope.
   - knowledge: autonomy mode, root index summary line count.
   - skills available: next stage skill + relevant knowledge skills.

## Outputs

- A single orientation block returned to the calling context. No files
  written.

## Exit criteria

- The agent (or human) knows the current stage, the next skill to
  invoke, and the autonomy mode.

## Handoff

- **Next skill:** the stage skill matching the detected stage. Most
  commonly [`marshal-specify`](../marshal-specify/SKILL.md) at stage 1
  or [`marshal-intake`](../marshal-intake/SKILL.md) at stage 2; or
  jump straight to [`marshal-plan`](../marshal-plan/SKILL.md) (stage 4)
  if upstream stages are out of scope.
- **Pass:** the orientation block. The next skill re-reads its own
  inputs from disk.

## Subagent

Used by [`marshal-driver`](../../agents/marshal-driver.md) as its first
action.
