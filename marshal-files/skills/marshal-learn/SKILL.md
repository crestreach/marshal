---
name: marshal-learn
description: MARSHAL stage 7 (optional) - Learn/improve. Merges per-phase learning files into learning-rollup.md, then promotes durable items into AGENTS.md, rules, skills, prompts, checklists, and the knowledge layer (via marshal-knowledge-maintain from-learning). Human-approved per bucket. May also generate new skills, subagents, or rules under .marshal/.
---

# marshal-learn

MARSHAL stage 7 — see [marshal.md §7](../../../marshal.md). Optional;
skip when no phase produced a learning file worth promoting.

## Prerequisites

- Stage 6 complete (if rollout was in scope), or the change is
  otherwise final.
- `learning/phase-*.learning.md` files exist for the change.

## Inputs (read at start)

- All `learning/phase-*.learning.md` files for the change
  (subset of: `phase-1`, `phase-2`, `phase-3`, `phase-architecture`,
  `phase-4`, `phase-N` for each L1 implementation phase, `phase-release`).
- Targets that may be updated:
  [`AGENTS.md`](../../../AGENTS.md),
  [`README.md`](../../../README.md),
  [`.marshal/rules/`](../../rules/), custom skill files under
  [`.marshal/skills/`](../../skills/), subagent files under
  [`.marshal/agents/`](../../agents/), and `.marshal/knowledge/`.

## Workflow

1. Merge and deduplicate learnings; filter for high-value, generalizable
   items.
2. Group into buckets:
   - AGENTS updates (snippet to merge into the host repo's `AGENTS.md`).
   - README updates.
   - rules updates — add or revise files under
     [`.marshal/rules/`](../../rules/) (frontmatter: `description`,
     `applies-to`, `always-apply`).
   - skill updates — add or revise folders under
     [`.marshal/skills/`](../../skills/).
   - subagent updates — add or revise files under
     [`.marshal/agents/`](../../agents/).
   - **knowledge updates** (durable repo facts).
   - reusable prompts / checklists / test templates / architecture
     guidance.
3. For each non-knowledge bucket, propose a diff against the target
   file or area; get human approval per bucket before applying. New
   skills / subagents / rules are written to the corresponding
   `.marshal/` subfolder in the format used by
   [ai-dev-agent-config-sync](https://github.com/crestreach/ai-dev-agent-config-sync)
   so they can be fanned out to tool-native layouts.
3. For each non-knowledge bucket, propose a diff against the target
   file or area; get human approval per bucket before applying.
4. For the **knowledge** bucket, drop approved items into
   [`.marshal/knowledge/learn/inbox/`](../../knowledge/learn/inbox/) as
   structured fragments (one file per item or a single batch file with
   sections), then hand off to
   [`marshal-knowledge-maintain`](../marshal-knowledge-maintain/SKILL.md)
   mode `from-learning` for promotion into canonical knowledge files.

## Outputs

- `learning-rollup.md` (merged, deduplicated, filtered).
- Approved diffs applied to AGENTS / README / rules / skills.
- New / updated files under `.marshal/knowledge/learn/inbox/` for
  knowledge promotion.

## Exit criteria

- `learning-rollup.md` written.
- Each bucket has either an applied update or an explicit "skipped".
- Knowledge inbox handed off (if non-empty).

## Handoff

- **For knowledge promotion:**
  [`marshal-knowledge-maintain`](../marshal-knowledge-maintain/SKILL.md)
  mode `from-learning`. Pass: paths to the inbox files just added.

## Subagent

For batch promotions, the v2 subagent
[`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md)
wraps the `from-learning` run in fresh context and returns a single
diff for approval.
