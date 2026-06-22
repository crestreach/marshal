---
name: marshail-load
description: Session bootstrap for MARSHAIL. Reads .marshail/ENTRYPOINT.md, .marshail/config.yml, the knowledge contract, the active knowledge implementation, and the root knowledge index, then reports a one-paragraph orientation so the agent can pick the right next skill with minimal extra context.
---

# marshail-load

Setup skill — runs once per fresh session.

## Prerequisites

- Repo with `.marshail/` initialized (run `marshail-init` first if not).

## Inputs (read at start)

- [`.marshail/ENTRYPOINT.md`](../../ENTRYPOINT.md)
- [`.marshail/marshail-override.md`](../../marshail-override.md) when present and non-empty — optional repo-specific overrides on top of `marshail.md`.
  Read it after the entry point; entries here take precedence over the canonical spec on the points they address.
- [`.marshail/knowledge/INDEX.md`](../../knowledge/INDEX.md)
- [`.marshail/config.yml`](../../config.yml) — note `knowledge.autonomy`, `knowledge.contract_ref`, and `knowledge.representation_ref`.
- General knowledge contract named by `knowledge.contract_ref` (default [`../../references/knowledge-contract.md`](../../references/knowledge-contract.md)).
- Active knowledge implementation named by `knowledge.representation_ref` (default [`../../references/knowledge-markdown-spine.md`](../../references/knowledge-markdown-spine.md)).
- Working folder for the current change, if any (look for the artifact chain: `specification.md`, `change-brief.md`, …).

## Workflow

1. Read entry point, `marshail-override.md` (if present and non-empty), config, knowledge contract, active implementation, and root knowledge index.
2. Detect current MARSHAIL stage from the artifact chain present in the working folder, treating every stage as optional except the Plan stage (none → not started; `specification.md` only → the Specification stage done; `…` up to `learning-rollup.md` → the Learn stage done).
   If `delivery-plan.md` is present, read its `Scope:` line to learn which stages were chosen for this change.
3. Emit a short orientation block (≤ ~20 lines):
   - process: which stage is current, which artifact is next, which stages were skipped per the plan's Scope.
   - **overrides**: one-line note if `marshail-override.md` is present and non-empty ("override active: <one-line gist>"); omit when absent or empty.
   - knowledge: contract reference, implementation reference, autonomy mode, root index summary line count.
   - skills available: next stage skill + relevant knowledge skills.

## Outputs

- A single orientation block returned to the calling context.
  No files written.

## Exit criteria

- The agent (or human) knows the current stage, the next skill to invoke, and the autonomy mode.

## Suggested next step

This skill only orients; it does **not** invoke anything itself.
It reports which step would come next so the user (or the driver) can decide.

- **Likely next:** the stage matching the detected position — typically the Specification stage ([`marshail-delegate-to-specify`](../marshail-delegate-to-specify/SKILL.md) or the [`marshail-specifier`](../../agents/marshail-specifier.md) agent), the Intake stage ([`marshail-delegate-to-intake`](../marshail-delegate-to-intake/SKILL.md)), or, when upstream stages are out of scope, the Plan stage ([`marshail-delegate-to-plan`](../marshail-delegate-to-plan/SKILL.md)).
- Whatever runs next re-reads its own inputs from disk; this skill passes only the orientation block.

## Subagent

Used by [`marshail-driver`](../../agents/marshail-driver.md) as its first action.
