---
name: marshal-delegate-to-specify
description: MARSHAL Specification / clarify stage. Delegate when the user asks to "spec out", "clarify", "frame", or "agree the intent of" a feature / bugfix / refactor / tech-debt prompt before any coding — or says things like "what exactly do you want me to build?", "let's pin down the requirements", "produce a specification.md", "ask me clarifying questions", "I have a vague idea, help me sharpen it", "list the open questions", "draft acceptance criteria". Also delegate when starting a new MARSHAL change with an ambiguous prompt and the Specification stage is in scope. The subagent drives the clarification dialog (no assumptions, explicit disagreement, optional acceptance checklist) and writes specification.md.
---

# marshal-delegate-to-specify

Delegate this to the [`marshal-specifier`](../../agents/marshal-specifier.md) subagent. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-specifier`
- **Pass:** the user's raw prompt; pointers to any prior context the user named (issues, prior briefs, screenshots).
- **Expect back:** an approved `specification.md` plus `logs/phase-1.changelog.md` and `learning/phase-1.learning.md`.
- **On result:** confirm the spec is approved and hand off to [`marshal-delegate-to-intake`](../marshal-delegate-to-intake/SKILL.md) (Intake stage) or [`marshal-delegate-to-plan`](../marshal-delegate-to-plan/SKILL.md) (Plan stage) per the agreed scope.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-specify`](../../skills-fallback/marshal-specify/SKILL.md) — same workflow, runs inline. Both share [`marshal-specifier.md`](../../agents/marshal-specifier.md) as source of truth.
