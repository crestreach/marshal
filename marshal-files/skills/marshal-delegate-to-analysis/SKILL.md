---
name: marshal-delegate-to-analysis
description: MARSHAL stage 3 (Repo recon / analysis). Delegate when the user asks to "analyze the repo for this change", "do recon", "narrow the search surface", "find the likely files / services / contracts", "identify invariants and test seams", "produce repo-recon.md", "what touches X in this codebase?", "where does Y live?", "scope the code areas before planning". Also delegate when change-brief.md exists and stage 3 is in scope, or when a planner / implementer flags they don't know enough about an area. The subagent reads the brief and existing knowledge, walks likely paths, and returns a tight repo-recon.md plus a stale-knowledge list — keeping intermediate exploration out of the parent context.
---

# marshal-delegate-to-analysis

Delegate this to the [`marshal-code-archaeologist`](../../agents/marshal-code-archaeologist.md) subagent. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-code-archaeologist`
- **Pass:** `change-brief.md`; pointers to `.marshal/knowledge/INDEX.md` and any topic indexes. Read-only repo access.
- **Expect back:** draft `repo-recon.md`, a list of stale/missing knowledge files, plus `logs/phase-3.changelog.md` and `learning/phase-3.learning.md`.
- **On result:** review and save the recon under the change folder; surface the stale-knowledge list (consider [`marshal-delegate-to-knowledge-research`](../marshal-delegate-to-knowledge-research/SKILL.md) or [`marshal-delegate-to-knowledge-maintain`](../marshal-delegate-to-knowledge-maintain/SKILL.md)). Hand off to [`marshal-delegate-to-architecture`](../marshal-delegate-to-architecture/SKILL.md) (stage 3.5) or [`marshal-delegate-to-plan`](../marshal-delegate-to-plan/SKILL.md) (stage 4).

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-analysis`](../../skills-fallback/marshal-analysis/SKILL.md). Source of truth: [`marshal-code-archaeologist.md`](../../agents/marshal-code-archaeologist.md).
