---
name: marshail-delegate-to-intake
description: MARSHAIL Intake / framing stage. Delegate when the user asks to "frame the change", "write the change brief", "produce change-brief.md", "structure the engineering framing for this change", "list the non-goals and acceptance criteria", "convert the spec into a brief". Also delegate when the Specification stage is finished (specification.md exists) and the Intake stage is in scope, or when the user has a clear prompt but wants a structured brief before analysis/planning. The subagent turns the spec or prompt into change-brief.md (problem, scope, non-goals, acceptance criteria, constraints, rollout expectations).
---

# marshail-delegate-to-intake

Delegate this to the [`marshail-framer`](../../agents/marshail-framer.md) subagent.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshail-framer`
- **Pass:** `specification.md` if it exists; otherwise the user prompt.
  Plus the top-level `AGENTS.md` and `.marshail/knowledge/INDEX.md` paths for context.
- **Expect back:** approved `change-brief.md` plus `logs/stage-2-intake.changelog.md` and `learning/stage-2-intake.learning.md`.
- **On result:** hand off to [`marshail-delegate-to-analysis`](../marshail-delegate-to-analysis/SKILL.md) (Analysis stage) or directly to [`marshail-delegate-to-plan`](../marshail-delegate-to-plan/SKILL.md) (Plan stage) per the agreed scope.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshail-intake`](../../skills-fallback/marshail-intake/SKILL.md).
Source of truth: [`marshail-framer.md`](../../agents/marshail-framer.md).
