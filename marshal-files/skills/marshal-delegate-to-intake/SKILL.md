---
name: marshal-delegate-to-intake
description: MARSHAL Intake / framing stage. Delegate when the user asks to "frame the change", "write the change brief", "produce change-brief.md", "structure the engineering framing for this change", "list the non-goals and acceptance criteria", "convert the spec into a brief". Also delegate when the Specification stage is finished (specification.md exists) and the Intake stage is in scope, or when the user has a clear prompt but wants a structured brief before analysis/planning. The subagent turns the spec or prompt into change-brief.md (problem, scope, non-goals, acceptance criteria, constraints, rollout expectations).
---

# marshal-delegate-to-intake

Delegate this to the [`marshal-framer`](../../agents/marshal-framer.md) subagent.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-framer`
- **Pass:** `specification.md` if it exists; otherwise the user prompt.
  Plus the top-level `AGENTS.md` and `.marshal/knowledge/INDEX.md` paths for context.
- **Expect back:** approved `change-brief.md` plus `logs/phase-2.changelog.md` and `learning/phase-2.learning.md`.
- **On result:** hand off to [`marshal-delegate-to-analysis`](../marshal-delegate-to-analysis/SKILL.md) (Analysis stage) or directly to [`marshal-delegate-to-plan`](../marshal-delegate-to-plan/SKILL.md) (Plan stage) per the agreed scope.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-intake`](../../skills-fallback/marshal-intake/SKILL.md).
Source of truth: [`marshal-framer.md`](../../agents/marshal-framer.md).
