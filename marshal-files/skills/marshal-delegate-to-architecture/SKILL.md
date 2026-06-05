---
name: marshal-delegate-to-architecture
description: MARSHAL Architecture / design stage. Delegate when the user asks to "design the solution", "agree the implementation concept", "discuss the architecture", "propose components / modules / APIs / schemas", "produce architecture-notes.md", "draft an ADR for this", "what's the right shape for this?", "compare design tradeoffs", "high-level layout for this change". Also delegate when change-brief.md and repo-recon.md exist and the change is large enough that the solution shape isn't obvious yet. The subagent drives the design conversation, captures rationale, and (when significant) promotes durable decisions to ADRs.
---

# marshal-delegate-to-architecture

Delegate this to the [`marshal-architect`](../../agents/marshal-architect.md) subagent. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-architect`
- **Pass:** `change-brief.md`, `repo-recon.md`, relevant knowledge files (especially `repo/architecture.md`, affected `domains/<x>/`), existing ADRs under `.marshal/knowledge/decisions/`.
- **Expect back:** approved `architecture-notes.md`, optional ADR file(s), plus `logs/phase-architecture.changelog.md` and `learning/phase-architecture.learning.md`.
- **On result:** hand off to [`marshal-delegate-to-plan`](../marshal-delegate-to-plan/SKILL.md) (Plan stage). If new ADRs were drafted, route them through [`marshal-delegate-to-knowledge-maintain`](../marshal-delegate-to-knowledge-maintain/SKILL.md) for promotion into the canonical knowledge tree.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-architecture`](../../skills-fallback/marshal-architecture/SKILL.md). Source of truth: [`marshal-architect.md`](../../agents/marshal-architect.md).
