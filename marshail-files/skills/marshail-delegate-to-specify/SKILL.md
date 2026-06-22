---
name: marshail-delegate-to-specify
description: MARSHAIL Specification / clarify stage. Delegate when the user asks to "spec out", "clarify", "frame", or "agree the intent of" a feature / bugfix / refactor / tech-debt prompt before any coding — or says things like "what exactly do you want me to build?", "let's pin down the requirements", "produce a specification.md", "ask me clarifying questions", "I have a vague idea, help me sharpen it", "list the open questions", "draft acceptance criteria". Also delegate when starting a new MARSHAIL change with an ambiguous prompt and the Specification stage is in scope. The subagent drives the clarification dialog (no assumptions, explicit disagreement, optional acceptance checklist) and writes specification.md.
---

# marshail-delegate-to-specify

Delegate this to the [`marshail-specifier`](../../agents/marshail-specifier.md) subagent.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshail-specifier`
- **Pass:** the user's raw prompt; pointers to any prior context the user named (issues, prior briefs, screenshots).
- **Expect back:** an approved `specification.md` plus `logs/stage-1-specification.changelog.md` and `learning/stage-1-specification.learning.md`.
- **On result:** confirm the spec is approved and hand off to [`marshail-delegate-to-intake`](../marshail-delegate-to-intake/SKILL.md) (Intake stage) or [`marshail-delegate-to-plan`](../marshail-delegate-to-plan/SKILL.md) (Plan stage) per the agreed scope.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshail-specify`](../../skills-fallback/marshail-specify/SKILL.md) — same workflow, runs inline.
Both share [`marshail-specifier.md`](../../agents/marshail-specifier.md) as source of truth.
