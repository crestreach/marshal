---
name: marshail-delegate-to-analysis
description: MARSHAIL Repo recon / analysis stage. Delegate when the user asks to "analyze the repo for this change", "do recon", "narrow the search surface", "find the likely files / services / contracts", "identify invariants and test seams", "produce repo-recon.md", "what touches X in this codebase?", "where does Y live?", "scope the code areas before planning". Also delegate when change-brief.md exists and the Analysis stage is in scope, or when a planner / implementer flags they don't know enough about an area. The subagent reads the brief and existing knowledge, walks likely paths, and returns a tight repo-recon.md plus a stale-knowledge list — keeping intermediate exploration out of the parent context.
---

# marshail-delegate-to-analysis

Delegate this to the [`marshail-code-archaeologist`](../../agents/marshail-code-archaeologist.md) subagent.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshail-code-archaeologist`
- **Pass:** `change-brief.md`; pointers to `.marshail/knowledge/INDEX.md` and any topic indexes.
  Read-only repo access.
- **Expect back:** draft `repo-recon.md`, a list of stale/missing knowledge files, plus `logs/stage-3-analysis.changelog.md` and `learning/stage-3-analysis.learning.md`.
- **On result:** review and save the recon under the change folder; surface the stale-knowledge list (consider [`marshail-delegate-to-knowledge-research`](../marshail-delegate-to-knowledge-research/SKILL.md) or [`marshail-delegate-to-knowledge-maintain`](../marshail-delegate-to-knowledge-maintain/SKILL.md)).
  Hand off to [`marshail-delegate-to-architecture`](../marshail-delegate-to-architecture/SKILL.md) (Architecture stage) or [`marshail-delegate-to-plan`](../marshail-delegate-to-plan/SKILL.md) (Plan stage).

## Fallback (no-subagent environments)

If subagents are not available, use [`marshail-analysis`](../../skills-fallback/marshail-analysis/SKILL.md).
Source of truth: [`marshail-code-archaeologist.md`](../../agents/marshail-code-archaeologist.md).
